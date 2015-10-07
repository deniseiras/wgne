program get_station_coords
  use benchmarking
  use date_utils
  use inmet_stations

  implicit none
  
  character(len=255) :: filename
  character(len=15)  :: date_string
  character(len=12)  :: grads_date
  integer            :: lines, l, variables
  integer            :: is_unit
  integer            :: gs_unit
  integer            :: op_unit
  character          :: dummy
  real, allocatable, dimension(:) :: latitude
  real, allocatable, dimension(:) :: longitude
  real, allocatable, dimension(:) :: temperature
  type(Date)          :: period
  type(GregorianDate) :: date_current, date_start, date_end
  
  
  ! Define the period of interest.
  date_start = GregorianDate(2012, 9,  5, 0, 0, 0)
  date_end   = GregorianDate(2012, 9, 17, 0, 0, 0)
  call makeDate(date_start, date_end, period)
  
  ! Loop through the period with 3-hour increments.
  do while (.not. period%iterationOver)
    ! Format the current date to strings matching IS and GrADS formats.
    date_string = formatDate(getCurrentDate(period))
    grads_date  = gradsDate (getCurrentDate(period))
    filename = 'surface-inmet/is' // date_string
  
    print *, grads_date
  
		! Obtain the number of stations in this file.
		lines = getNumberOfStations(filename)
	
		! Allocate arrays for the desired data.
		if (allocated(latitude))    deallocate(latitude)
		allocate(latitude(lines))
		if (allocated(longitude))   deallocate(longitude)
		allocate(longitude(lines))
		if (allocated(temperature)) deallocate(temperature)
		allocate(temperature(lines))
	
	  ! Open the files.
		is_unit = getFreeUnit()
		open(is_unit, file=trim(filename))
		gs_unit = getFreeUnit()
		open(gs_unit, file='scripts/coords_'//grads_date//'.gs', status='replace')
		op_unit = getFreeUnit()
		open(op_unit, file='is-filtered/is_'//grads_date//'.txt', status='replace')
	
		! Skip the header.
		read(is_unit,*)
		read(is_unit,*) variables
		do l=1, variables
			read(is_unit,*)
		end do
		read(is_unit,*)

                ! Add a header to the GrADS script.
                write(gs_unit,*) "function main(args)"
                write(gs_unit,*) "vardisplay=subwrd(args,1)"
                write(gs_unit,*) "outfile=subwrd(args,2)"
	
		! Loop through each station and read only latitude/longitude/temperature.
		do l=1, lines
			read(is_unit,*) dummy, dummy, dummy, dummy, dummy, latitude(l),          &
											longitude(l), dummy, dummy, dummy, dummy, dummy,         &
											temperature(l)
			
			! Check if the measurement is valid and if station is inside the
			! experiment domain.
			if(latitude(l)    .ge. -40. .and. latitude(l)  .le.  20. .and.          &
			   longitude(l)   .ge. -90. .and. longitude(l) .le. -30. .and.          &
			   temperature(l) .ne. -999.0) then

                                longitude(l) = 360. + longitude(l)
		
		    ! Append this station's coordinates to the GrADS script.
				write(gs_unit,100) latitude(l)
				write(gs_unit,101) longitude(l)
				write(gs_unit,102) 
				write(gs_unit,103) 
				write(gs_unit,104) 
				write(gs_unit,*)   ''
				
				! Write the station data to a filtered file.
				write(op_unit,'(3(F7.2, X))') latitude(l), longitude(l), temperature(l)
		  end if
		end do
	
		close(is_unit)
		close(gs_unit)
		close(op_unit)
		
		call incrementBySeconds(3*3600, period)
	end do
  
  100 format("'set lat ", F7.2, "'")
  101 format("'set lon ", F7.2, "'")
  102 format("'d ' vardisplay")
  103 format("output=sublin(result,2)")
  104 format("write(outfile,output,append)")

	if (allocated(latitude))    deallocate(latitude)
	if (allocated(longitude))   deallocate(longitude)
	if (allocated(temperature)) deallocate(temperature)

end program get_station_coords
