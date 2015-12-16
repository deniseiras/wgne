module ecmwf_dust_new

    use date_utils
    implicit none

    character(*), parameter :: institution='ECMWF'
    character(*), parameter :: institutionCode='ecmwf' 
    character(*), parameter :: ccase='dust_new'

!    character(*), parameter :: subcase='direct'
    character(*), parameter :: subcase='noaerosols'

!    character(*), parameter :: comments='Dust storm on April 18, 2012. Forecast with aerosol interaction (direct effect only).' !Case and Subcase
    character(*), parameter :: comments='Dust storm on April 18, 2012. Forecast with no aerosol interaction.' !Case and Subcase

!dust
    type(GregorianDate), parameter :: date_start = GregorianDate(2012, 4, 13, 0, 0, 0), date_end   = GregorianDate(2012, 4, 23, 0, 0, 0)
    integer, parameter :: lonIn=720
    integer, parameter :: latIn=361
    integer, parameter :: levIn=60
    integer, parameter :: timeIn=41
    integer, parameter :: timeIn3d=41

    integer, parameter :: varVectorSize = 6

    character(*), parameter :: inputBaseVarsDir='/stornext/online8/exp-dmd/outputcasevars/stornext/online8/exp-dmd/aerosols/'
    character(*), parameter :: outputBaseDir='/scratchout/grupos/brams/home/denis.eiras/new_aerosols'
    character(*), parameter :: caseDir = institutionCode//'/'//ccase//'/'//subcase
    character(*), parameter :: inputVarsDir=inputBaseVarsDir//'/'//caseDir

    integer, parameter :: vars3dVectorSize = 1
    integer, parameter :: varNameSize = 30

    type var2dType
        character(len=varNameSize) nameIn
        real, dimension(lonIn,latIn,timeIn) :: value
        integer :: id
		character(len=100) longName
        character(len=10) units
    end type var2dType

    type var3dType
        character(len=varNameSize) nameIn
! ********* para ecmwf faço tempo a tempo devido a grande quantidd de memória 
        real, dimension(lonIn,latIn,levIn,1) :: value
        integer :: id
		character(len=100) longName
        character(len=10) units
    end type var2dType

    type(var2dType), allocatable, dimension(:) :: vars
    type(var3dType), allocatable, dimension(:) :: vars3d

contains

    subroutine initialize2dVars()
        implicit none

		print*, 'initializing 2d...'
        allocate(vars(varVectorSize)) !alterar p/ dust_new
 
	    vars(1)%nameIn='aod'
	    vars(1)%longName='Aerosol Optical Depth at 550nm'
        vars(1)%units=''

        vars(2)%nameIn='dlwf'
        vars(2)%longName='Longwave Downwelling Radiative Flux at the Surface'
        vars(2)%units='W/m^2'

        vars(3)%nameIn='dswf'
        vars(3)%longName='Shortwave Downwelling Radiative Flux at the Surface'
        vars(3)%units='W/m^2'

        vars(4)%nameIn='temp2m'
        vars(4)%longName='Temperature at 2m'
        vars(4)%units='K'

        vars(5)%nameIn='wdir'
        vars(5)%longName='Wind Direction at 10m'
        vars(5)%units='degrees'

        vars(6)%nameIn='wmag'
        vars(6)%longName='Wind Magnitude at 10m'
        vars(6)%units='m/s'

    end subroutine

    subroutine initialize3dVars()
        implicit none

		print*, 'initializing 3d...'
        allocate(vars3d(vars3dVectorSize))
        vars3d(1)%nameIn='temp'
		vars3d(1)%longName='air_temperature'
        vars3d(1)%units='K'
    end subroutine

    function getInput2dVarFileImpl(varName,dateStrDay) result (input2dFile)
		implicit none
		character(*), intent(in) :: varName
        character(*), intent(in) :: dateStrDay
        character(len=255), intent(out) :: input2dFile
		character(len=255) :: inputDir
        input2dFile=inputVarsDir//'/'//varName//'_'//institutionCode//'_2d_'//subcase//'_'//dateStrDay//'.nc'

    end function

    function getInput3dVarFileImpl(varName,dateStrDay) result (input3dFile)
		implicit none
		character(*), intent(in) :: varName
        character(*), intent(in) :: dateStrDay
        character(len=255), intent(out) :: input3dFile
		character(len=255) :: inputDir
        input3dFile=inputVarsDir//'/'//varName//'_'//institutionCode//'_3d_'//subcase//'_'//dateStrDay//'.nc'
    end function

end module ecmwf_dust_new
