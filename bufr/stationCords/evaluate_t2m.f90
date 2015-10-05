program evaluate_t2m
  use benchmarking
  use date_utils
  
  implicit none
  
  integer, parameter :: TMAX   = 17
  integer, parameter :: DAYS   = 10
  integer, parameter :: MODELS = 10
  
  character(len=2)   :: t_buffer
  character(len=12)  :: fct_date_string
  character(len=255) :: fct_file
  character(len=12)  :: obs_date_string
  character(len=255) :: obs_file
  
  integer            :: array_size
  integer            :: fct_unit
  integer            :: obs_unit
  integer            :: bias_unit
  integer            :: rmse_unit
  
  integer            :: day, t
  integer            :: l, m
  
  real               :: latitude
  real               :: longitude
  
  type(Date)          :: period
  type(Date)          :: date_obs
  type(GregorianDate) :: date_start
  type(GregorianDate) :: date_end
  type(GregorianDate) :: date_fct
  type(GregorianDate) :: date_now
  
  character(len=23), dimension(MODELS) :: model
  real, dimension(MODELS, DAYS) :: rmse_instant
  real, dimension(MODELS, DAYS) :: bias_instant
  
  real, dimension(MODELS, TMAX) :: rmse
  real, dimension(MODELS, TMAX) :: bias
  
  real, allocatable, dimension(:) :: forecast
  real, allocatable, dimension(:) :: observed
  
  ! Prefixes for each model output.
  model = (/ "ecmwf_smoke_direct_    ", &
             "ecmwf_smoke_noaerosols_", &
             "jma_smoke_direct_      ", &
             "jma_smoke_indirect_    ", &
             "jma_smoke_interactive_ ", &
             "jma_smoke_noaerosols_  ", &
             "nasa_smoke_interactive_", &
             "nasa_smoke_noaerosols_ ", &
             "ncep_smoke_interactive_", &
             "ncep_smoke_noaerosols_ "  /)
  
  ! Starting date for the experiment.
  date_start = GregorianDate(2012, 9,  5, 0, 0, 0)
  
  ! Loop through each model.
  do m=1, size(model)
		! Loop through each forecast time.
		do t=1, TMAX
			write(t_buffer,'(i0)') t
			call makeInterval(date_start, DAYS*24, period)
			
			! Reset the instantaneous bias and rmse arrays.
			bias_instant = 0.
			rmse_instant = 0.
		
			! Loop through each model output after 3*(t-1) hours have elapsed.
			do day=1, DAYS
				! Find the current date.
				date_now = getCurrentDate(period)
				! Find the forecast file's name.
				fct_date_string = gradsDate(date_now)
				fct_file = "temp2m/" // trim(model(m)) // fct_date_string // "_"   &
									 // trim(t_buffer) //".txt"
				! Find the observation file's name.
				call makeInterval(date_now, 3*(t-1), date_obs)
				call incrementBySeconds(3*(t-1)*3600, date_obs)
				obs_date_string = gradsDate(getCurrentDate(date_obs))
				obs_file = "is-filtered/is_" // obs_date_string // ".txt"

				! Get the number of lines in the file.
				array_size = getNumberOfLines(obs_file)
				
				! Open the files.
				fct_unit = getFreeUnit()
				open(fct_unit, file=trim(fct_file))
				obs_unit = getFreeUnit()
				open(obs_unit, file=trim(obs_file))
				
				! Clean up the memory from previous round and reallocate the arrays.
				if(allocated(forecast)) deallocate(forecast)
				allocate(forecast(array_size))
				forecast = 0.
				if(allocated(observed)) deallocate(observed)
				allocate(observed(array_size))
				observed = 0.
				
				do l=1, array_size
				  read(fct_unit,*) forecast(l)
				  read(obs_unit,*) latitude, longitude, observed(l)
				end do
				
				bias_instant(m,day) = calculateBias(forecast, observed)
				rmse_instant(m,day) = calculateRMSE(forecast, observed)
				
				close(fct_unit)
				close(obs_unit)
			
				call incrementBySeconds(24*3600, period)
				print *, "MODEL: ", model(m), "DATE: ", fct_date_string, " @ t=", t
			end do ! do day=1, DAYS
			
			bias(m,t) = sum(bias_instant(m,:)) / DAYS
		  rmse(m,t) = sum(rmse_instant(m,:)) / DAYS
		end do ! do t=1, TMAX
  end do ! do m=1, size(model)
  
  rmse_unit = getFreeUnit()
	open(rmse_unit, file="rmse_all_models.txt")
  do m=1, MODELS
    write(rmse_unit,'(A23,2X,17(F5.2,X))') model(m), rmse(m,:)
  end do

  bias_unit = getFreeUnit()
	open(bias_unit, file="bias_all_models.txt") 
  do m=1, MODELS
    write(bias_unit,'(A23,2X,17(F5.2,X))') model(m), bias(m,:)
  end do

contains
  function getNumberOfLines(filename) result(lines)
    character(len=255) :: filename
    integer            :: lines
    integer            :: fl_unit
    
    fl_unit = getFreeUnit()
    
    open(fl_unit, file=trim(filename))
    
    lines = 0
  	do
      read(fl_unit,*,end=440)
      lines = lines + 1
    end do
    440 close(fl_unit)
  end function getNumberOfLines
  
  function calculateRMSE(forecast, observed) result(rmse)
    real, dimension(:), intent(in) :: forecast
    real, dimension(:), intent(in) :: observed
    real                           :: rmse
        
    integer                        :: i
    real                           :: sum
    
    sum = 0.
    
    do i=1, size(forecast)
      sum = sum + (forecast(i) - observed(i))**2
    end do
    
    rmse = sqrt(sum / size(forecast))
  end function calculateRMSE
  
  function calculateBias(forecast, observed) result(bias)
    real, dimension(:), intent(in) :: forecast
    real, dimension(:), intent(in) :: observed
    real                           :: bias
        
    integer                        :: i
    real                           :: sum
    
    sum = 0.
    
    do i=1, size(forecast)
      sum = sum + forecast(i) - observed(i)
    end do
    
    bias = sum / size(forecast)
  end function calculateBias
end program evaluate_t2m