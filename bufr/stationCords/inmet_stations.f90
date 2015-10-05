!> @brief   Handles the reading of station data provided by CPTEC.
!! @details CPTEC provides a set of ASCII files containing data from automated
!!  observation stations[1]. Three kinds of stations are included in these
!!  files: SYNOP, METAR, and PCD. Time interval between each file is one hour. 
!! 
!! Each line after the header contains data for a single station, with '-999.0'
!!  used as the undefined/missing value. The string '000' in between values is
!!  only a separator and can be  disregarded.
!!  A typical line contains, in order:
!!  - Year of measurement
!!  - Month of measurement
!!  - Day of measurement
!!  - Hour of measurement (in 24 hour format, i.e.: 2100 for 9:00PM)
!!  - Station ID
!!  - Latitude of station [-90 to +90]
!!  - Longitude of station [-180 to +180]
!!  - Altitude of station [m]
!!  - Wind speed [m/s]
!!  - '000'
!!  - Wind direction [degrees]
!!  - '000'
!!  - Temperature at 2m from the surface [ C] 0
!!  - '000'
!!  - Dew point [ C] 0
!!  - '000'
!!  - STN pressure [Pa]
!!  - '000'
!!  - Sea level pressure [Pa]
!!  - '000'
!!  - Precipitation (6-hour accumulation) [mm]
!!  - '000'
!!  - Cloud cover [%]
!!  - '000'
!!  - * Incident shortwave radiation at the surface [kJ/m2]
!!  - * '000'
!!
!! Note that the last two values (shortwave radiation and its asssociated '000'
!!  separator) only occur in INMET stations. These can be identified by means of
!!  their station ID, which will always start with an 'A'.
!!
!! [1] The number of stations per file is usually different due to quality 
!! control done by CPTEC and data availability in certain regions.
!!
!! @author Antonio Maurício Zarzur <mauricio.zarzur@gmail.com>

module inmet_stations
  use benchmarking

  implicit none
  
contains
  !> Obtains the number of relevant lines in an IS station file.
  function getNumberOfStations(filename) result(lines)
    character(:), allocatable :: filename
    integer            :: lines
    integer            :: variables, l
    integer            :: is_unit
    
    is_unit = getFreeUnit()
    
    ! Obtain the number of lines in the station file.
  	open(is_unit, file=trim(filename))
  
	  ! Skip the header.
  	read(is_unit,*)
	  read(is_unit,*) variables
	  do l=1, variables
  	  read(is_unit,*)
	  end do
  	read(is_unit,*)
  
	  lines = 0
  	do
      read(is_unit,*,end=404)
      lines = lines + 1
    end do
    404 rewind(is_unit)
    
    close(is_unit)
  end function getNumberOfStations

  subroutine msg(message)   
    character(len=*), intent(in) :: message
    print*, message
  end subroutine msg  
  
end module inmet_stations