program get_station_coords
  use benchmarking
  use date_utils
  use inmet_stations

  implicit none
  
  character(:), allocatable :: inputFileName, inputFilePattern, outputFileName&
  ,outputFilePattern, basePath, inputPath, outputPath, dateString, dummy

  integer            :: lines, l, variables
  integer            :: inputFile, outputFile
  type(Date)          :: period
  type(GregorianDate) :: date_current, date_start, date_end

  real, allocatable, dimension(:) :: blockNumber !WMO BLOCK NUMBER (NUMERIC)
  real, allocatable, dimension(:) :: stationNumber !WMO STATION NUMBER (NUMERIC)
  real, allocatable, dimension(:) :: stationType !TYPE OF STATION (CODE TABLE 2001)
  real, allocatable, dimension(:) :: year !YEAR (YEAR)
  real, allocatable, dimension(:) :: month !MONTH (MONTH)
  real, allocatable, dimension(:) :: day !DAY (DAY)
  real, allocatable, dimension(:) :: hour !HOUR (HOUR)
  real, allocatable, dimension(:) :: minute !MINUTE (MINUTE)
  real, allocatable, dimension(:) :: latitude !LATITUDE (HIGH ACCURACY) (DEGREE)
  real, allocatable, dimension(:) :: longitude !LONGITUDE (HIGH ACCURACY) (DEGREE)
  real, allocatable, dimension(:) :: stationHeight !HEIGHT OF STATION (SEE NOTE 1) (M)
  real, allocatable, dimension(:) :: pressure !PRESSURE (PA)
  real, allocatable, dimension(:) :: pressureSeaLevel !PRESSURE REDUCED TO MEAN SEA LEVEL (PA)
  real, allocatable, dimension(:) :: pressure3hour !3-HOUR PRESSURE CHANGE (PA)
  real, allocatable, dimension(:) :: pressureTendency !CHARACTERISTIC OF PRESSURE TENDENCY (CODE TABLE 10063)
  real, allocatable, dimension(:) :: windDirection10m !WIND DIRECTION AT 10 M (DEGREE TRUE)
  real, allocatable, dimension(:) :: windSpeed10m !WIND SPEED AT 10 M (M/S)
  real, allocatable, dimension(:) :: tempDryBuld2m !DRY-BULB TEMPERATURE AT 2 M (K)
  real, allocatable, dimension(:) :: tempDewPoint2m !DEW-POINT TEMPERATURE AT 2 M (K)
  real, allocatable, dimension(:) :: relatHumidity !RELATIVE HUMIDITY (%)
  real, allocatable, dimension(:) :: horizontalVisibility !HORIZONTAL VISIBILITY (M)
  real, allocatable, dimension(:) :: weatherPresent !PRESENT WEATHER (SEE NOTE 1) (CODE TABLE 20003)
  real, allocatable, dimension(:) :: weatherPast1 !PAST WEATHER (1) (SEE NOTE 2) (CODE TABLE 20004)
  real, allocatable, dimension(:) :: weatherPast2 !PAST WEATHER (2) (SEE NOTE 2) (CODE TABLE 20005)
  real, allocatable, dimension(:) :: cloudCoverTotalPerc !CLOUD COVER (TOTAL) (%)
  real, allocatable, dimension(:) :: vertSignificance !VERTICAL SIGNIFICANCE (SURFACE OBSERVATIONS) (CODE TABLE 8002)
  real, allocatable, dimension(:) :: cloudAmount !CLOUD AMOUNT (CODE TABLE 20011)
  real, allocatable, dimension(:) :: cloudBaseHeight !HEIGHT OF BASE OF CLOUD (M)
  real, allocatable, dimension(:) :: cloudType1 !CLOUD TYPE (CODE TABLE 20012)
  real, allocatable, dimension(:) :: cloudType2 !CLOUD TYPE (CODE TABLE 20012)
  real, allocatable, dimension(:) :: cloudType3 !CLOUD TYPE (CODE TABLE 20012)
  real, allocatable, dimension(:) :: vertSignificanceN1 !VERTICAL SIGNIFICANCE (SURFACE OBSERVATIONS) (CODE TABLE 8002)
  real, allocatable, dimension(:) :: cloudAmountN1 !CLOUD AMOUNT (CODE TABLE 20011)
  real, allocatable, dimension(:) :: cloudTypeN1 !CLOUD TYPE (CODE TABLE 20012)
  real, allocatable, dimension(:) :: cloudBaseHeightN1 !HEIGHT OF BASE OF CLOUD (M)
  real, allocatable, dimension(:) :: vertSignificanceN2 !VERTICAL SIGNIFICANCE (SURFACE OBSERVATIONS) (CODE TABLE 8002)
  real, allocatable, dimension(:) :: cloudAmountN2 !CLOUD AMOUNT (CODE TABLE 20011)
  real, allocatable, dimension(:) :: cloudTypeN2 !CLOUD TYPE (CODE TABLE 20012)
  real, allocatable, dimension(:) :: cloudBaseHeightN2 !HEIGHT OF BASE OF CLOUD (M)
  real, allocatable, dimension(:) :: vertSignificanceN3 !VERTICAL SIGNIFICANCE (SURFACE OBSERVATIONS) (CODE TABLE 8002)
  real, allocatable, dimension(:) :: cloudAmountN3 !CLOUD AMOUNT (CODE TABLE 20011)
  real, allocatable, dimension(:) :: cloudTypeN3 !CLOUD TYPE (CODE TABLE 20012)
  real, allocatable, dimension(:) :: cloudBaseHeightN3 !HEIGHT OF BASE OF CLOUD (M)
  real, allocatable, dimension(:) :: vertSignificanceN4 !VERTICAL SIGNIFICANCE (SURFACE OBSERVATIONS) (CODE TABLE 8002)
  real, allocatable, dimension(:) :: cloudAmountN4 !CLOUD AMOUNT (CODE TABLE 20011)
  real, allocatable, dimension(:) :: cloudTypeN4 !CLOUD TYPE (CODE TABLE 20012)
  real, allocatable, dimension(:) :: cloudBaseHeightN4 !HEIGHT OF BASE OF CLOUD (M)
  real, allocatable, dimension(:) :: precipTotal6h !TOTAL PRECIPITATION PAST 6 HOURS (KG/M**2)
  real, allocatable, dimension(:) :: snowTotalDepth !TOTAL SNOW DEPTH (M)
  
  
  ! Define the period of interest.
  date_start = GregorianDate(2012, 4, 10, 0, 0, 0)
  date_end   = GregorianDate(2012, 4, 10, 0, 0, 0)

!  date_end   = GregorianDate(2012, 5, 01, 23, 0, 0)
  call makeDate(date_start, date_end, period)
  
  ! Loop through the period with 1-hour increments.
  do while (.not. period%iterationOver)
    
    dateString = formatDateYYYYMMDDHHMM(getCurrentDate(period))
    print*, dateString

    basePath='/home2/denis/magnitude/observation'
    inputPath='dat'
    outputPath='stationvars'
    inputFilePattern = 'bufr_09800001013001'
    inputFileName = basePath//"/"//inputPath//'/'//inputFilePattern//&
      dateString//'.dat'
    outputFilePattern = 'station_vars_bufr_09800001013001'
    outputFileName = basePath//'/'//outputPath//'/'//outputFilePattern//&
      dateString//'.dat'
    call msg("arquivo de entrada: "//inputFileName)
    call msg("arquivo de saída: "//outputFileName)

		lines = getNumberOfStations(inputFileName)
    print*, lines
	
		inputFile = getFreeUnit()
		open(inputFile, file=inputFileName)
		outputFile = getFreeUnit()
		open(outputFile, file=outputFileName, status='replace')
	
		! Skip the header.
		read(inputFile,*) dummy

    print*, dummy
    read(*,*) dummy
    print*, dummy
    read(*,*) dummy

		! Loop through each station and read only latitude/longitude/temperature.
		do l=1, lines
			read(inputFile,*)&
        blockNumber, stationNumber, stationType, year, month,&
        day, hour, minute, latitude, longitude, stationHeight, pressure, &
        pressureSeaLevel, pressure3hour, pressureTendency, windDirection10m,&
        windSpeed10m, tempDryBuld2m, tempDewPoint2m, relatHumidity,&
        horizontalVisibility, weatherPresent, weatherPast1, weatherPast2,&
        cloudCoverTotalPerc, vertSignificance, cloudAmount, cloudBaseHeight,&
        cloudType1, cloudType2, cloudType3, vertSignificanceN1, cloudAmountN1,&
        cloudTypeN1, cloudBaseHeightN1, vertSignificanceN2, cloudAmountN2,&
        cloudTypeN2, cloudBaseHeightN2, vertSignificanceN3, cloudAmountN3,&
        cloudTypeN3, cloudBaseHeightN3, vertSignificanceN4, cloudAmountN4,&
        cloudTypeN4, cloudBaseHeightN4, precipTotal6h, snowTotalDepth

        print*, blockNumber
		
				! Write the station data to a filtered file.
				write(outputFile,'(3(F7.2, X))')&
        blockNumber, stationNumber, stationType, year, month,&
        day, hour, minute, latitude, longitude, stationHeight, pressure, &
        pressureSeaLevel, pressure3hour, pressureTendency, windDirection10m,&
        windSpeed10m, tempDryBuld2m, tempDewPoint2m, relatHumidity,&
        horizontalVisibility, weatherPresent, weatherPast1, weatherPast2,&
        cloudCoverTotalPerc, vertSignificance, cloudAmount, cloudBaseHeight,&
        cloudType1, cloudType2, cloudType3, vertSignificanceN1, cloudAmountN1,&
        cloudTypeN1, cloudBaseHeightN1, vertSignificanceN2, cloudAmountN2,&
        cloudTypeN2, cloudBaseHeightN2, vertSignificanceN3, cloudAmountN3,&
        cloudTypeN3, cloudBaseHeightN3, vertSignificanceN4, cloudAmountN4,&
        cloudTypeN4, cloudBaseHeightN4, precipTotal6h, snowTotalDepth
		end do
	
		close(inputFile)
		close(outputFile)
  	call incrementBySeconds(3600, period)
	end do


end program get_station_coords

