! Lê os arquivos .dat, gerados a partir dos arquivos do tipo BUFR, através do
! programa bufrscan (INPE) e gera arquivos de saída contendo os valores de n
! variáveis 
!
! Compilar: ./compile.sh
!
! Uso:
!     ./generateVars.x <pathEntrada> <pathSaida> <numVariaveis>
! Ex: ./generateVars.x "/home/usr/dirEntrada" "/home/usr/dirSaida" 49
!

program get_station_vars
  use benchmarking
  use date_utils

  implicit none
  
  character(len=255) :: argInPath, argOutPath, argNumVars
  
  character(:), allocatable :: inputFileName, inputFilePattern, outputFileName&
  ,outputFilePattern, inputPath, outputPath, dateString, outputMask, numVarsChar
  integer :: lines, l, variables, iErr, inputFile, outputFile, varIdx, numVars
  type(Date)          :: period
  type(GregorianDate) :: date_current, date_start, date_end

  character(len=30), allocatable, dimension(:) :: vars !all vars
  real(KIND=SELECTED_REAL_KIND(8,2)), allocatable, dimension(:) :: varsTypeReal !all vars Real
  character :: dummy

!************************ DEFINIR !!! **********************************
  character(len=*), parameter :: undef="-999999"
  
  call getarg(1,argInPath)
  call getarg(2,argOutPath)
  call getarg(3,argNumVars)

  inputPath=argInPath
  inputPath=trim(inputPath)
  outputPath=argOutPath
  outputPath=trim(outputPath)
  numVarsChar=argNumVars
  numVarsChar=trim(numVarsChar)
  read(numVarsChar,*) numVars
  outputMask='('//numVarsChar//'(F10.2,X))'

  inputFilePattern = 'bufr_09800001013001'
  outputFilePattern = 'station_vars_bufr_09800001013001'
  
  ! Define the period of interest.
  date_start = GregorianDate(2012, 4, 10, 0, 0, 0)
  date_end   = GregorianDate(2012, 5, 01, 23, 0, 0)
  call makeDate(date_start, date_end, period)
  
  ! Loop through the period with 1-hour increments.
  do while (.not. period%iterationOver)
    
    if(allocated(vars)) then
      deallocate(vars)
      deallocate(varsTypeReal)
    end if
    allocate(vars(numVars))
    allocate(varsTypeReal(numVars))

    dateString = formatDateYYYYMMDDHHMM(getCurrentDate(period))
    inputFileName = inputPath//'/'//inputFilePattern//dateString//'.dat'
    outputFileName = outputPath//'/'//outputFilePattern//dateString//'.dat'
    print*, "lendo arquivo ...", NEW_LINE("A"), inputFileName
    
		inputFile = getFreeUnit()
		open(inputFile, file=inputFileName)
		outputFile = getFreeUnit()
		open(outputFile, file=outputFileName, status='replace')
	
		! Skip the header.
		read(inputFile,*) dummy
    read(inputFile,*) dummy

		do l=1, 1000000000
      read(inputFile,*,ERR=99,END=100) vars
      do varIdx = 1, numVars
        if(trim(vars(varIdx))=='Null') then
          vars(varIdx)=undef
        end if
        read(vars(varIdx),*) varsTypeReal(varIdx)  
      end do
  		write(outputFile,outputMask) varsTypeReal
		end do
    99 print*, "ERRO na leitura !!!!!"
    100 print*, "... gerado arquivo de saída: ",NEW_LINE("A"),outputFileName
    print*, " linhas lidas: ",l,NEW_LINE("A")
	
		close(inputFile)
		close(outputFile)
  	call incrementBySeconds(3600, period)
	end do

end program get_station_vars
    

!   character(len=30), allocatable, dimension(:) :: blockNumber !WMO BLOCK NUMBER (NUMERIC)
!   character(len=30), allocatable, dimension(:) :: stationNumber !WMO STATION NUMBER (NUMERIC)
!   character(len=30), allocatable, dimension(:) :: stationType !TYPE OF STATION (CODE TABLE 2001)
!   character(len=30), allocatable, dimension(:) :: year !YEAR (YEAR)
!   character(len=30), allocatable, dimension(:) :: month !MONTH (MONTH)
!   character(len=30), allocatable, dimension(:) :: day !DAY (DAY)
!   character(len=30), allocatable, dimension(:) :: hour !HOUR (HOUR)
!   character(len=30), allocatable, dimension(:) :: minute !MINUTE (MINUTE)
!   character(len=30), allocatable, dimension(:) :: latitude !LATITUDE (HIGH ACCURACY) (DEGREE)
!   character(len=30), allocatable, dimension(:) :: longitude !LONGITUDE (HIGH ACCURACY) (DEGREE)
!   character(len=30), allocatable, dimension(:) :: stationHeight !HEIGHT OF STATION (SEE NOTE 1) (M)
!   character(len=30), allocatable, dimension(:) :: pressure !PRESSURE (PA)
!   character(len=30), allocatable, dimension(:) :: pressureSeaLevel !PRESSURE REDUCED TO MEAN SEA LEVEL (PA)
!   character(len=30), allocatable, dimension(:) :: pressure3hour !3-HOUR PRESSURE CHANGE (PA)
!   character(len=30), allocatable, dimension(:) :: pressureTendency !CHARACTERISTIC OF PRESSURE TENDENCY (CODE TABLE 10063)
!   character(len=30), allocatable, dimension(:) :: windDirection10m !WIND DIRECTION AT 10 M (DEGREE TRUE)
!   character(len=30), allocatable, dimension(:) :: windSpeed10m !WIND SPEED AT 10 M (M/S)
!   character(len=30), allocatable, dimension(:) :: tempDryBuld2m !DRY-BULB TEMPERATURE AT 2 M (K)
!   character(len=30), allocatable, dimension(:) :: tempDewPoint2m !DEW-POINT TEMPERATURE AT 2 M (K)
!   character(len=30), allocatable, dimension(:) :: relatHumidity !RELATIVE HUMIDITY (%)
!   character(len=30), allocatable, dimension(:) :: horizontalVisibility !HORIZONTAL VISIBILITY (M)
!   character(len=30), allocatable, dimension(:) :: weatherPresent !PRESENT WEATHER (SEE NOTE 1) (CODE TABLE 20003)
!   character(len=30), allocatable, dimension(:) :: weatherPast1 !PAST WEATHER (1) (SEE NOTE 2) (CODE TABLE 20004)
!   character(len=30), allocatable, dimension(:) :: weatherPast2 !PAST WEATHER (2) (SEE NOTE 2) (CODE TABLE 20005)
!   character(len=30), allocatable, dimension(:) :: cloudCoverTotalPerc !CLOUD COVER (TOTAL) (%)
!   character(len=30), allocatable, dimension(:) :: vertSignificance !VERTICAL SIGNIFICANCE (SURFACE OBSERVATIONS) (CODE TABLE 8002)
!   character(len=30), allocatable, dimension(:) :: cloudAmount !CLOUD AMOUNT (CODE TABLE 20011)
!   character(len=30), allocatable, dimension(:) :: cloudBaseHeight !HEIGHT OF BASE OF CLOUD (M)
!   character(len=30), allocatable, dimension(:) :: cloudType1 !CLOUD TYPE (CODE TABLE 20012)
!   character(len=30), allocatable, dimension(:) :: cloudType2 !CLOUD TYPE (CODE TABLE 20012)
!   character(len=30), allocatable, dimension(:) :: cloudType3 !CLOUD TYPE (CODE TABLE 20012)
!   character(len=30), allocatable, dimension(:) :: vertSignificanceN1 !VERTICAL SIGNIFICANCE (SURFACE OBSERVATIONS) (CODE TABLE 8002)
!   character(len=30), allocatable, dimension(:) :: cloudAmountN1 !CLOUD AMOUNT (CODE TABLE 20011)
!   character(len=30), allocatable, dimension(:) :: cloudTypeN1 !CLOUD TYPE (CODE TABLE 20012)
!   character(len=30), allocatable, dimension(:) :: cloudBaseHeightN1 !HEIGHT OF BASE OF CLOUD (M)
!   character(len=30), allocatable, dimension(:) :: vertSignificanceN2 !VERTICAL SIGNIFICANCE (SURFACE OBSERVATIONS) (CODE TABLE 8002)
!   character(len=30), allocatable, dimension(:) :: cloudAmountN2 !CLOUD AMOUNT (CODE TABLE 20011)
!   character(len=30), allocatable, dimension(:) :: cloudTypeN2 !CLOUD TYPE (CODE TABLE 20012)
!   character(len=30), allocatable, dimension(:) :: cloudBaseHeightN2 !HEIGHT OF BASE OF CLOUD (M)
!   character(len=30), allocatable, dimension(:) :: vertSignificanceN3 !VERTICAL SIGNIFICANCE (SURFACE OBSERVATIONS) (CODE TABLE 8002)
!   character(len=30), allocatable, dimension(:) :: cloudAmountN3 !CLOUD AMOUNT (CODE TABLE 20011)
!   character(len=30), allocatable, dimension(:) :: cloudTypeN3 !CLOUD TYPE (CODE TABLE 20012)
!   character(len=30), allocatable, dimension(:) :: cloudBaseHeightN3 !HEIGHT OF BASE OF CLOUD (M)
!   character(len=30), allocatable, dimension(:) :: vertSignificanceN4 !VERTICAL SIGNIFICANCE (SURFACE OBSERVATIONS) (CODE TABLE 8002)
!   character(len=30), allocatable, dimension(:) :: cloudAmountN4 !CLOUD AMOUNT (CODE TABLE 20011)
!   character(len=30), allocatable, dimension(:) :: cloudTypeN4 !CLOUD TYPE (CODE TABLE 20012)
!   character(len=30), allocatable, dimension(:) :: cloudBaseHeightN4 !HEIGHT OF BASE OF CLOUD (M)
!   character(len=30), allocatable, dimension(:) :: precipTotal6h !TOTAL PRECIPITATION PAST 6 HOURS (KG/M**2)
!   character(len=30), allocatable, dimension(:) :: snowTotalDepth !TOTAL SNOW DEPTH (M)