module ncep
    use date_utils
    implicit none

    character(*), parameter :: institution='NCEP'
    character(*), parameter :: institutionCode='ncep' 
!    character(*), parameter :: ccase='dust'
!    character(*), parameter :: ccase='smoke'
    character(*), parameter :: ccase='pollution'
    character(*), parameter :: subcase='interactive'
!    character(*), parameter :: subcase='noaerosols'

!    character(*), parameter :: comments='Dust storm on April 18, 2012. Forecast with aerosol interaction (direct and indirect effects).' !Case and Subcase
!    character(*), parameter :: comments='Dust storm on April 18, 2012. Forecast with no aerosol interaction.' !Case and Subcase
!    character(*), parameter :: comments='Extreme biomass burning smoke in Brazil (the SAMBBA case). Forecast with aerosol interaction (direct and indirect effects).' !Case and Subcase
!    character(*), parameter :: comments='Extreme biomass burning smoke in Brazil (the SAMBBA case). Forecast with no aerosol interaction.' !Case and Subcase
    character(*), parameter :: comments='Extreme pollution in Beijing on January 1216, 2013. Forecast with aerosol interaction (direct and indirect effects).' !Case and Subcase
!    character(*), parameter :: comments='Extreme pollution in Beijing on January 1216, 2013. Forecast with no aerosol interaction.' !Case and Subcase

!dust
!    type(GregorianDate), parameter :: date_start = GregorianDate(2012, 4, 13, 0, 0, 0), date_end   = GregorianDate(2012, 4, 23, 0, 0, 0)
!    integer, parameter :: lonIn=360
!    integer, parameter :: latIn=181
!    integer, parameter :: levIn=47
!    integer, parameter :: timeIn=81
!    integer, parameter :: timeIn3d=81
!smoke
!    type(GregorianDate), parameter :: date_start = GregorianDate(2012, 9, 5, 0, 0, 0), date_end   = GregorianDate(2012, 9, 15, 0, 0, 0)
!    integer, parameter :: lonIn=360
!    integer, parameter :: latIn=181
!    integer, parameter :: levIn=47
!    integer, parameter :: timeIn=41
!    integer, parameter :: timeIn3d=41
!pollution
    type(GregorianDate), parameter :: date_start = GregorianDate(2013, 1, 7, 0, 0, 0), date_end   = GregorianDate(2013, 1, 21, 0, 0, 0)
    integer, parameter :: lonIn=360
    integer, parameter :: latIn=181
    integer, parameter :: levIn=47
    integer, parameter :: timeIn=81
    integer, parameter :: timeIn3d=81

    character(*), parameter :: inputBaseVarsDir='/stornext/online8/exp-dmd/outputcasevars/stornext/online8/exp-dmd/aerosols/'
    character(*), parameter :: outputBaseDir='/scratchout/grupos/brams/home/denis.eiras/new_aerosols'
    character(*), parameter :: caseDir = institutionCode//'/'//ccase//'/'//subcase
    character(*), parameter :: inputVarsDir=inputBaseVarsDir//'/'//caseDir

    integer, parameter :: varVectorSize = 7
    integer, parameter :: vars3dVectorSize = 3
    integer, parameter :: varNameSize = 30

    real(kind=8), dimension(timeIn) :: time_input
    real(kind=8), dimension(lonIn) :: lon_input
    real(kind=8), dimension(latIn) :: lat_input
    real, dimension(levIn) :: lev_input

    type var2dType
        character(len=varNameSize) nameIn
        real, dimension(lonIn,latIn,timeIn) :: value
        integer :: id
    end type var2dType

    type var3dType
        character(len=varNameSize) nameIn
        real, dimension(lonIn,latIn,levIn,timeIn3d) :: value
        integer :: id
	character(len=100) longName
        character(len=10) units
    end type var2dType

    type(var2dType), allocatable, dimension(:) :: vars
    type(var3dType), allocatable, dimension(:) :: vars3d

contains

    subroutine initialize2dVars()
        implicit none
        allocate(vars(varVectorSize))
        vars(1)%nameIn='aod'
        vars(2)%nameIn='conv'
        vars(3)%nameIn='prec'
        vars(4)%nameIn='dlwf'
        vars(5)%nameIn='dswf'
        vars(6)%nameIn='temp2m'
        vars(7)%nameIn='wdir'
        vars(8)%nameIn='wmag'
    end subroutine

    subroutine initialize3dVars()
        implicit none
        allocate(vars3d(vars3dVectorSize))
        vars3d(1)%nameIn='ttend'
	vars3d(1)%longName='tendency_of_air_temperature_due_to_radiation'
        vars3d(1)%units='K/s'

        vars3d(2)%nameIn='temp'
	vars3d(2)%longName='air_temperature'
        vars3d(2)%units='K'

        vars3d(3)%nameIn='rh'
	vars3d(3)%longName='relative_humidity_after_moist'
        vars3d(3)%units='-'

    end subroutine

    function getInput2dVarFileImpl(varName,dateStrDay) result (input2dFile)
	implicit none
	character(*), intent(in) :: varName
        character(*), intent(in) :: dateStrDay
        character(len=255), intent(out) :: input2dFile
	if(varName=='aod') then
	        input2dFile=inputVarsDir//'/'//dateStrDay//'00/'//varName//'_'//institutionCode//'_2d_'//'aodf'//dateStrDay//'00.nc'
	else
	        input2dFile=inputVarsDir//'/'//dateStrDay//'00/'//varName//'_'//institutionCode//'_2d_'//'pgbf'//dateStrDay//'00.nc'
        endif
    end function

    function getInput3dVarFileImpl(varName,dateStrDay) result (input3dFile)
	implicit none
	character(*), intent(in) :: varName
        character(*), intent(in) :: dateStrDay
        character(len=255), intent(out) :: input3dFile
        input3dFile=inputVarsDir//'/'//dateStrDay//'00/'//varName//'_'//institutionCode//'_3d_'//'pgbf'//dateStrDay//'00.nc'
    end function

end module ncep
