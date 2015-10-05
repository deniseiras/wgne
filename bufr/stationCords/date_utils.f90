!> @brief Module that handles date and time.
!! @details Includes custom types and subroutines to create, increment and
!! control dates.
!! Some of the storage strategies and conversion routines are based on NOAA's
!! Time Manager module, available in its entirety at:<br>
!! <http://www.nco.ncep.noaa.gov/pmb/codes/nwprod/cfs.v2.1.0/sorc/cfs_cdas_godas_anl.fd/src/shared/time_manager/time_manager.f90>
!!
!! @author Antonio Mauricio Zarzur              <mauricio.zarzur@cptec.inpe.br>
!! @author Rafael Mello de Fonseca              <rafael.mello@cptec.inpe.br>
!! @author Rafael Stockler Santos Lima          <rafael.stockler@cptec.inpe.br>
!! @author Rodrigo de Oliveira Braz             <rodrigo.braz@cptec.inpe.br>
!! @author Valter José Ferreira de Oliveira     <valter.oliveira@cptec.inpe.br>
module date_utils
  use benchmarking

  implicit none

  include 'parameters.h'

  private

  ! ---- DEFINITION OF PUBLIC TYPES AND FUNCTIONS.
  ! Public types.
  public :: Time
  public :: Date
  public :: GregorianDate

  ! Public functions and subroutines.
  public :: formatGregorianDateToBRAMS
  public :: generateTime
  public :: getCurrentDate
  public :: getInterval
  public :: getStartDate
  public :: hasEnded
  public :: incrementBySeconds
  public :: makeDate
  public :: makeDateSequence
  public :: makeInterval
  public :: parseFileName
  public :: formatDate
  public :: formatDateYYYYMMDDHHMM
  public :: gradsDate

  ! ---- TYPE DECLARATIONS.
  !> Type used to store a given date. Uses two integer fields to allow for
  !! larger intervals - days and seconds.
  type Time
    integer :: days
    integer :: seconds
  end type Time

  !> Date type that can be used to represent a time interval and move through
  !! it. Stores the start and end date of the period, as well as the current
  !! date, in Time types.
  type Date
    type(Time) :: start
    type(Time) :: current
    type(Time) :: finish
    logical    :: iterationOver
  end type Date

  !> Gregorian Date type.
  !! Contains 6 integer fields to store year, month, day, hours, minutes and
  !! seconds. The module provides functions and subroutines to handle this date
  !! type and convert it to different formats.
  type GregorianDate
    integer :: year
    integer :: month
    integer :: day
    integer :: hour
    integer :: minute
    integer :: second
  end type GregorianDate

  ! ---- FUNCTIONS AND SUBROUTINES.
contains
  !> Converts a GregorianDate type to a formatted string as used in BRAMS
  !! filenames.
  !!
  !! @param gregDate A GregorianDate type to be formatted.
  !! @return dateString A 19 character string in the 'YYYY-MM-DD-hhmmss' format
  !! used by BRAMS.
  function formatGregorianDateToBRAMS(gregDate) result(dateString)
    ! Input.
    type(GregorianDate), intent(in) :: gregDate
    ! Output.
    character(len=17)               :: dateString
    character(len=26)               :: sformat

    sformat = '(i4.4,A,2(i2.2,A),3(i2.2))'

    write(dateString, sformat) gregDate%year, "-", gregDate%month, "-", &
      gregDate%day, "-", gregDate%hour, gregDate%minute, gregDate%second
  end function formatGregorianDateToBRAMS

  !> Given a gregorian date, generates a Time type that represents it.
  !!
  !! @param gregDate A GregorianDate type containing the input date.
  !! @return A Time type that represents the input gregorian date.
  function generateTime(gregDate) result(aTime)
    ! Input.
    type(GregorianDate), intent(in) :: gregDate
    ! Output.
    type(Time)          :: aTime
    ! Counters.
    integer             :: m
    ! Additional variables.
    integer             :: daysSinceEpoch, daysThisYear, leapYears, seconds
    integer             :: daysInMonth(12) = (/31,28,31,30,31,30,31,31,30,31,30,31/)
    logical             :: isLeapYear

    ! Before we start, check if the input is valid.
    if(gregDate%second .gt. 59 .or. gregDate%second .lt. 0 .or. &
      gregDate%minute  .gt. 59 .or. gregDate%minute .lt. 0 .or. &
      gregDate%hour    .gt. 23 .or. gregDate%hour   .lt. 0 .or. &
      gregDate%day     .gt. 31 .or. gregDate%day    .lt. 1 .or. &
      gregDate%month   .gt. 12 .or. gregDate%month  .lt. 1 .or. &
      gregDate%year    .lt. BASEYEAR) then
      call handleError('Invalid date input in generateTime().','DateUtils.f90')
    end if

    ! First we verify if the input year is a leap year; that is, any year that
    ! can be evenly divisible by 4, except century years unevenly divisible by
    ! 400 (i.e., 2000 is a leap year, but 1500 is not).
    isLeapYear = (modulo(gregDate%year,4) .eq. 0)
    if((modulo(gregDate%year,100) .eq. 0) .and. &
      (modulo(gregDate%year,400) .ne. 0))then
      isLeapYear = .false.
    endif

    ! Calculate the number of leap years since the base year.
    ! Subtract one because we already verified the current year.
    leapYears = ((gregDate%year - 1) - BASEYEAR) / 4   - &
      ((gregDate%year - 1) - BASEYEAR) / 100 + &
      ((gregDate%year - 1) - 1600)     / 400

    ! Compute the number of days in all the months before the current:
    daysThisYear = 0
    do m = 1, gregDate%month-1
      daysThisYear = daysThisYear + daysInMonth(m)
      if (m .eq. 2 .and. isLeapYear) daysThisYear = daysThisYear + 1
    end do

    ! Compute the total number of days since the base year.
    daysSinceEpoch = 365*(gregDate%year - BASEYEAR - leapYears) + 366*leapYears
    daysSinceEpoch = daysSinceEpoch + daysThisYear + gregDate%day - 1
    ! Compute the number of leftover seconds.
    seconds = gregDate%second + (60 * gregDate%minute) + (3600 * gregDate%hour)

    ! Set the results into a Time type.
    aTime          = Time(daysSinceEpoch, seconds)
  end function generateTime

  !> Retrieves the current date stored in a Date type.
  !! Code slightly adapted from NOAA's Time Manager module.
  !!
  !! @param aDate Date type that contains a time interval.
  !! @return The current date as a GregorianDate type.
  function getCurrentDate(aDate) result(currentDate)
    ! Input.
    type(Date), intent(in) :: aDate
    ! Output.
    type(GregorianDate)    :: currentDate
    ! Temporary output storage.
    integer                :: year, month, day, hour, minute, second
    ! Counters.
    integer                :: m
    ! Additional variables.
    integer                :: baseFH
    integer                :: daysInMonth(12)
    integer                :: leapYears
    integer                :: numberEX
    integer                :: numberFH
    integer                :: numberFY
    integer                :: numberHY
    integer                :: numberOfDays
    integer                :: numberOfSeconds
    logical                :: isLeapYear

    ! Set the base 400 year to 1601; this is chosen because 1600 is the highest
    ! century year below 1900 that is also evenly divisible by 400.
    baseFH = 1601

    ! Set numberOfDays initially to 109207 (the number of days from 1/1/1601
    ! to 1/1/1900, encompassing 227 years of 365 days and 72 leap years).
    numberOfDays=109207

    ! Days from base year (1900).
    numberOfDays = numberOfDays + aDate%current%days

    ! Find the number of four hundred year periods.
    numberFH = numberOfDays / 146097
    numberOfDays = modulo(numberOfDays, 146097)

    ! Find number of hundred year periods.
    numberHY = numberOfDays / 36524
    !if(numberHY .gt. 3) then     ! Check for rounding errors.
    !  numberHY=3
    !  numberOfDays=36524
    !else
    numberOfDays=modulo(numberOfDays, 36524)
    !endif

    ! Find number of four year periods.
    numberFY=numberOfDays / 1461
    numberOfDays = modulo(numberOfDays, 1461)

    ! Find the remaining number of years.
    numberEX = numberOfDays / 365
    !if(numberEX .gt. 3) then     ! Check for rounding errors.
    !  numberEX=3
    !  numberOfDays=365
    !else
    numberOfDays=modulo(numberOfDays,365)
    !endif

    ! Check if this is a leap year.
    isLeapYear = (numberEX .eq. 3) .and. &
      ((numberFY .ne. 24) .or. (numberHY .eq. 3))

    ! Find the current year.
    year = baseFH + (400 * numberFH) + (100 * numberHY) + (4 * numberFY) + &
      numberEX

    numberOfDays=numberOfDays+1

    ! Find the current month.
    month = 0
    daysInMonth = (/31,28,31,30,31,30,31,31,30,31,30,31/)
    if (isLeapYear) daysInMonth(2) = 29
    mloop: do m=1, 12
      ! If month has been found, we can store it and exit this 'do' statement.
      if (numberOfDays .le. daysInMonth(m)) then
        month = m
        exit mloop
      ! Otherwise, keep looking.
      else
        numberOfDays = numberOfDays - daysInMonth(m)
      end if
    end do mloop

    ! The current day is what's left after finding the year and month.
    day = numberOfDays

    ! Leftover seconds in the Time type (less than a full day).
    numberOfSeconds = aDate%current%seconds

    ! Find the current hour, minute and second.
    hour = numberOfSeconds / (3600)
    numberOfSeconds = numberOfSeconds - (hour * (3600))
    minute = numberOfSeconds / 60
    second = numberOfSeconds - (60 * minute)

    currentDate = GregorianDate(year, month, day, hour, minute, second)
  end function getCurrentDate

  !> Calculates the number of days between (and including) 2 gregorian dates.
  !! This assumes both dates are set at the same hour of the day.
  !!
  !! @param sDate Start gregorian date.
  !! @param eDate End gregorian date.
  !! @return The number of days in the interval, including the start and end
  !! dates.
  function getInterval(sDate, eDate) result (interval)
    ! Input.
    type(GregorianDate), intent(in) :: sDate, eDate
    ! Output.
    integer                         :: interval
    ! Additional variables.
    type(Time)                      :: eTime, sTime

    eTime = generateTime(eDate)
    sTime = generateTime(sDate)

    interval = eTime%days - sTime%days + 1
  end function getInterval

  !> Retrieves the start date stored in a Date type.
  !! Code slightly adapted from NOAA's Time Manager module.
  !!
  !! @param aDate Date type that contains a time interval.
  !! @return The start date as a GregorianDate type.
  function getStartDate(aDate) result(startDate)
    ! Input.
    type(Date), intent(in) :: aDate
    ! Output.
    type(GregorianDate)    :: startDate
    ! Temporary output storage.
    integer                :: year, month, day, hour, minute, second
    ! Counters.
    integer                :: m
    ! Additional variables.
    integer                :: baseFH
    integer                :: daysInMonth(12)
    integer                :: leapYears
    integer                :: numberEX
    integer                :: numberFH
    integer                :: numberFY
    integer                :: numberHY
    integer                :: numberOfDays
    integer                :: numberOfSeconds
    logical                :: isLeapYear

    ! Set the base 400 year to 1601; this is chosen because 1600 is the highest
    ! century year below 1900 that is also evenly divisible by 400.
    baseFH = 1601

    ! Set numberOfDays initially to 109207 (the number of days from 1/1/1601
    ! to 1/1/1900, encompassing 227 years of 365 days and 72 leap years).
    numberOfDays=109207

    ! Days from base year (1900).
    numberOfDays = numberOfDays + aDate%start%days

    ! Find the number of four hundred year periods.
    numberFH = numberOfDays / 146097
    numberOfDays = modulo(numberOfDays, 146097)

    ! Find number of hundred year periods.
    numberHY = numberOfDays / 36524
    !if(numberHY .gt. 3) then     ! Check for rounding errors.
    !  numberHY=3
    !  numberOfDays=36524
    !else
    numberOfDays=modulo(numberOfDays, 36524)
    !endif

    ! Find number of four year periods.
    numberFY=numberOfDays / 1461
    numberOfDays = modulo(numberOfDays, 1461)

    ! Find the remaining number of years.
    numberEX = numberOfDays / 365
    !if(numberEX .gt. 3) then     ! Check for rounding errors.
    !  numberEX=3
    !  numberOfDays=365
    !else
    numberOfDays=modulo(numberOfDays,365)
    !endif

    ! Check if this is a leap year.
    isLeapYear = (numberEX .eq. 3) .and. &
      ((numberFY .ne. 24) .or. (numberHY .eq. 3))

    ! Find the current year.
    year = baseFH + (400 * numberFH) + (100 * numberHY) + (4 * numberFY) + &
      numberEX

    numberOfDays=numberOfDays+1

    ! Find the current month.
    month = 0
    daysInMonth = (/31,28,31,30,31,30,31,31,30,31,30,31/)
    if (isLeapYear) daysInMonth(2) = 29
    mloop: do m=1, 12
      ! If month has been found, we can store it and exit this 'do' statement.
      if (numberOfDays .le. daysInMonth(m)) then
        month = m
        exit mloop
      ! Otherwise, keep looking.
      else
        numberOfDays = numberOfDays - daysInMonth(m)
      end if
    end do mloop

    ! The current day is what's left after finding the year and month.
    day = numberOfDays

    ! Leftover seconds in the Time type (less than a full day).
    numberOfSeconds = aDate%start%seconds

    ! Find the current hour, minute and second.
    hour = numberOfSeconds / (3600)
    numberOfSeconds = numberOfSeconds - (hour * (3600))
    minute = numberOfSeconds / 60
    second = numberOfSeconds - (60 * minute)

    startDate = GregorianDate(year, month, day, hour, minute, second)
  end function getStartDate

  !> Checks if a Date type has surpassed its end date.
  !!
  !! @param aDate Date object.
  !! @return True if current date is greater than end date, false otherwise.
  function hasEnded(aDate) result(ended)
    ! Input.
    type(Date), intent(in) :: aDate
    ! Output.
    logical                :: ended

    if (aDate%current%days .gt. aDate%finish%days) then
      ended = .true.
    else if (aDate%current%seconds .gt. aDate%finish%seconds .and. &
      aDate%current%days .ge. aDate%finish%days) then
      ended = .true.
    else
      ended = .false.
    end if
  end function hasEnded

  !> Increments the current date in a Date type by a given number of seconds.
  !!
  !! @param seconds Number of seconds to be added to the current date.
  !! @param aDate Date type to be incremented.
  subroutine incrementBySeconds(seconds, aDate)
    ! Input.
    integer,    intent(in)  :: seconds
    ! Output.
    type(Date), intent(out) :: aDate
    ! Additional variables.
    integer                 :: numberOfDays
    integer                 :: numberOfSeconds

    ! Check that the increment is positive.
    if(seconds .lt. 0) then
      call handleError('Negative input in incrementBySeconds().', &
        'DateUtils.f90')
    end if

    ! First we calculate the number of whole days contained in the input.
    numberOfDays = seconds / SECONDSPERDAY
    ! Then we calculate the leftover seconds.
    numberOfSeconds = seconds - (numberOfDays * SECONDSPERDAY)

    ! Check for overflow on seconds.
    if(numberOfseconds .ge. huge(numberOfseconds) - aDate%current%seconds) then
      call handleError('Integer overflow in seconds in incrementBySeconds().', &
        'DateUtils.f90')
    ! Check if we need to add an extra day
    else if (numberOfSeconds + aDate%current%seconds .ge. SECONDSPERDAY) then
      numberOfSeconds = numberOfSeconds - SECONDSPERDAY
      numberOfDays    = numberOfDays    + 1
    end if

    ! Store the additional seconds - here it can be a negative number.
    aDate%current%seconds = aDate%current%seconds + numberOfSeconds

    ! Check for overflow on days.
    if(numberOfDays .ge. huge(numberOfDays) - aDate%current%days) then
      call handleError('Integer overflow in days in incrementBySeconds().', &
        'DateUtils.f90')
    end if
    ! Store the additional days.
    aDate%current%days = aDate%current%days + numberOfDays

    ! Check if the iteration is over.
    aDate%iterationOver = hasEnded(aDate)
  end subroutine incrementBySeconds

  !> Generates a Date type from two gregorian dates.
  !!
  !! @param initial GregorianDate type containing the starting date.
  !! @param finish GregorianDate type containing the end date.
  !! @param aDate Date type corresponding to the period.
  subroutine makeDate(initial, finish, aDate)
    ! Input.
    type(GregorianDate), intent(in)  :: initial
    type(GregorianDate), intent(in)  :: finish
    ! Output.
    type(Date),          intent(out) :: aDate
    ! Additional variables.
    type(Time)                       :: finalTime
    type(Time)                       :: initialTime

    initialTime = generateTime(initial)
    finalTime   = generateTime(finish)

    aDate%start         = initialTime
    aDate%current       = initialTime
    aDate%finish        = finalTime
    aDate%iterationOver = hasEnded(aDate)
  end subroutine makeDate

  !> Generates a series of Date objects, each starting one day after the last.
  !! Each object has a duration defined by an user-defined number of hours.
  !!
  !! @param startDate Gregorian date for the first object.
  !! @param endDate Gregorian date for the last object.
  !! @param elapsedHours Number of hours covered by each Date object.
  !! @param sequence Array of Date objects as described above.
  subroutine makeDateSequence(startDate, endDate, elapsedHours, sequence)
    ! Input.
    type(GregorianDate),                   intent(in)  :: startDate
    type(GregorianDate),                   intent(in)  :: endDate
    integer,                               intent(in)  :: elapsedHours
    ! Output
    type(Date), dimension(:), allocatable, intent(out) :: sequence
    ! Additional variables.
    integer                                            :: i
    integer                                            :: iostat
    type(Date)                                         :: dateType
    type(GregorianDate)                                :: currentDate

    ! Allocate memory for the output array.
    if (allocated(sequence)) deallocate(sequence)
    allocate(sequence(getInterval(startDate, endDate)), stat=iostat)
    if (iostat .ne. 0) call handleError('makeDateSequence() could not '       &
      // 'properly allocate the Dates array.', 'DateUtils.f90')

    ! Create a Date object to control the array creation.
    call makeDate(startDate, endDate, dateType)

    ! Create the array.
    do i=1, size(sequence)
      currentDate = getCurrentDate(dateType)
      call makeInterval(currentDate, elapsedHours, sequence(i))
      call incrementBySeconds(SECONDSPERDAY, dateType)
    end do
  end subroutine makeDateSequence

  !> Generates a Date type that starts at a given gregorian date and lasts for
  !! an user-defined number of hours hours.
  !!
  !! @param initial GregorianDate type containing the starting date.
  !! @param elapsed Integer number of hours before the Date object is over.
  !! @param aDate Date type corresponding to the period.
  subroutine makeInterval(initial, elapsed, aDate)
    ! Input.
    type(GregorianDate), intent(in)  :: initial
    integer,             intent(in)  :: elapsed
    ! Output.
    type(Date),          intent(out) :: aDate
    ! Additional variables.
    type(Time)                       :: finalTime
    type(Time)                       :: initialTime

    ! Fill a Date object using only the initial date.
    initialTime = generateTime(initial)
    aDate%start         = initialTime
    aDate%current       = initialTime
    aDate%finish        = initialTime
    ! Increment it using a subroutine that checks for overflows.
    call incrementBySeconds(elapsed*3600, aDate)
    ! Fix the resulting object.
    aDate%finish  = aDate%current
    aDate%current = initialTime
    aDate%iterationOver = .false.
  end subroutine makeInterval

  !> Parses a string, replacing select date tags with the appropriate numerical
  !! equivalents from a GregorianDate type.<br>
  !! Tags are identified by a separator character and followed by a number of
  !! digits used to format the output.<br>
  !! For example: assuming the separator is '$', the string '$y4' would be
  !! replaced by the year, using 4 digits.
  !!
  !! @param input Base string including the tags.
  !! @param output Output string, where tags have been replaced by the date.
  !! @param separator Character used to identify tags.
  !! @param gregDate GregorianDate type containing the input Date.
  subroutine parseFileName(input, output, separator, gregDate, directory)
    ! Input.
    character,           intent(in)            :: separator
    character(*),        intent(in)            :: input
    type(GregorianDate), intent(in)            :: gregDate
    character(*),        intent(in),  optional :: directory
    ! Output.
    character(*),        intent(out)           :: output
    ! Additional variables.
    character                                  :: control
    character                                  :: ndigits
    character(len=10)                          :: frmt
    character(len=10)                          :: tag
    character(len=FILENAMESIZE)                :: current
    integer                                    :: offset

    if (present(directory)) then
      output = directory
      !
      if (output(len_trim(output):len_trim(output)) .ne. '/') then
        output = trim(directory) // '/'
      else
        output = trim(directory)
      end if
    else
      output = ''
    end if
    current = input
    do
      ! Look up the first occurance of the separator character.
      offset = scan(current, separator)
      ! If it isn't found, add the rest of the string to output and exit.
      if (offset .eq. 0) then
        output = trim(output) // trim(current)
        exit
      ! Otherwise, add everything that came before the separator to the output.
      else
        output = trim(output) // trim(current(1:offset-1))
      end if

      ! Check which tag needs to be replaced.
      control = current(offset+1:offset+1)
      ! Check how many digits should be used.
      ndigits = current(offset+2:offset+2)
      frmt = '(i'//ndigits//'.'//ndigits//')'
      ! Replace the tag.
      ch: select case(control)
        case('y')
          write (tag, trim(frmt)) gregDate%year
          output = trim(output) // trim(tag)
        case('m')
          write (tag, trim(frmt)) gregDate%month
          output = trim(output) // trim(tag)
        case('d')
          write (tag, trim(frmt)) gregDate%day
          output = trim(output) // trim(tag)
        case('h')
          write (tag, trim(frmt)) gregDate%hour
          output = trim(output) // trim(tag)
        case('n')
          write (tag, trim(frmt)) gregDate%minute
          output = trim(output) // trim(tag)
        case('s')
          write (tag, trim(frmt)) gregDate%second
          output = trim(output) // trim(tag)
      end select ch

      ! Cut out the part that has already been parsed.
      if (offset+3 .le. len_trim(current)) then
        current = current(offset+3:len_trim(current))
      else
        exit
      end if
    end do
  end subroutine parseFileName
  
  function formatDate(gregDate) result(dateString)
    ! Input.
    type(GregorianDate), intent(in) :: gregDate
    ! Output.
    character(len=15)               :: dateString
    character(len=26)               :: sformat

    sformat = '(i4.4,A,2(i2.2,A),2(i2.2))'

    write(dateString, sformat) gregDate%year, "-", gregDate%month, "-", &
      gregDate%day, "-", gregDate%hour, gregDate%minute
  end function formatDate

  function formatDateYYYYMMDDHHMM(gregDate) result(dateString)
    ! Input.
    type(GregorianDate), intent(in) :: gregDate
    ! Output.
    character(len=12)               :: dateString
    character(len=*), parameter     :: sformat = '(i4.4,4(i2.2))'

    write(dateString, sformat) gregDate%year, gregDate%month, &
      gregDate%day, gregDate%hour, gregDate%minute

  end function formatDateYYYYMMDDHHMM
  
  function gradsDate(gregDate) result(dateString)
    ! Input.
    type(GregorianDate), intent(in) :: gregDate
    ! Output.
    character(len=12)               :: dateString
    character(len=3)                :: monthString

    if (gregDate%month .eq. 1)       then 
      monthString = "JAN"
    else if (gregDate%month .eq. 2)  then 
    monthString = "FEB"
    else if (gregDate%month .eq. 3)  then
     monthString = "MAR"
    else if (gregDate%month .eq. 4)  then
     monthString = "APR"
    else if (gregDate%month .eq. 5)  then
     monthString = "MAY"
    else if (gregDate%month .eq. 6)  then
     monthString = "JUN"
    else if (gregDate%month .eq. 7)  then
     monthString = "JUL"
    else if (gregDate%month .eq. 8)  then
    monthString = "AUG"
    else if (gregDate%month .eq. 9)  then
     monthString = "SEP"
    else if (gregDate%month .eq. 10) then
     monthString = "OCT"
    else if (gregDate%month .eq. 11) then
     monthString = "NOV"
    else if (gregDate%month .eq. 12) then
     monthString = "DEC"
    end if

    write(dateString,999) gregDate%hour, gregDate%day, monthString,            &
                          gregDate%year
    999 format(i2.2, "Z", i2.2, a3, i4.4)
  end function gradsDate
  
end module date_utils
