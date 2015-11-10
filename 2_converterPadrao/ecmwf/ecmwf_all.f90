module ecmwf_all

    use date_utils
    implicit none

    character(*), parameter :: institution='ECMWF'
    character(*), parameter :: institutionCode='ecmwf' 
!    character(*), parameter :: ccase='dust_new'
!    character(*), parameter :: ccase='smoke'
    character(*), parameter :: ccase='pollution'

!    character(*), parameter :: subcase='direct'
    character(*), parameter :: subcase='noaerosols'

!    character(*), parameter :: comments='Dust storm on April 18, 2012. Forecast with aerosol interaction (direct effect only).' !Case and Subcase
!    character(*), parameter :: comments='Dust storm on April 18, 2012. Forecast with no aerosol interaction.' !Case and Subcase
!    character(*), parameter :: comments='Extreme biomass burning smoke in Brazil (the SAMBBA case). Forecast with aerosol interaction (direct effect only).' !Case and Subcase
!    character(*), parameter :: comments='Extreme biomass burning smoke in Brazil (the SAMBBA case). Forecast with no aerosol interaction.' !Case and Subcase
!    character(*), parameter :: comments='Extreme pollution in Beijing on January 1216, 2013. Forecast with aerosol interaction (direct effect only).' !Case and Subcase
    character(*), parameter :: comments='Extreme pollution in Beijing on January 1216, 2013. Forecast with no aerosol interaction.' !Case and Subcase

!dust
!    type(GregorianDate), parameter :: date_start = GregorianDate(2012, 4, 13, 0, 0, 0), date_end   = GregorianDate(2012, 4, 23, 0, 0, 0)
!    integer, parameter :: lonIn=720
!    integer, parameter :: latIn=361
!    integer, parameter :: levIn=9
!    integer, parameter :: timeIn=81
!    integer, parameter :: varVectorSize = 6
!smoke
!    type(GregorianDate), parameter :: date_start = GregorianDate(2012, 9, 5, 0, 0, 0), date_end   = GregorianDate(2012, 9, 15, 0, 0, 0)
!    integer, parameter :: lonIn=720
!    integer, parameter :: latIn=361
!    integer, parameter :: levIn=9
!    integer, parameter :: timeIn=81
!    integer, parameter :: varVectorSize = 8

!pollution
! ... para ecmwf pollution
    type(GregorianDate), parameter :: date_start = GregorianDate(2013, 1, 10, 0, 0, 0), date_end   = GregorianDate(2013, 1, 20, 0, 0, 0)
! outros casos ...
!    type(GregorianDate), parameter :: date_start = GregorianDate(2013, 1, 7, 0, 0, 0), date_end   = GregorianDate(2013, 1, 21, 0, 0, 0)

    integer, parameter :: lonIn=720
    integer, parameter :: latIn=361
    integer, parameter :: levIn=9
    integer, parameter :: timeIn=81
    integer, parameter :: varVectorSize = 8


    character(*), parameter :: inputBaseVarsDir='/stornext/online8/exp-dmd/outputcasevars/stornext/online8/exp-dmd/aerosols/'
    character(*), parameter :: outputBaseDir='/scratchout/grupos/brams/home/denis.eiras/new_aerosols'
    character(*), parameter :: caseDir = institutionCode//'/'//ccase//'/'//subcase
    character(*), parameter :: inputVarsDir=inputBaseVarsDir//'/'//caseDir

    integer, parameter :: vars3dVectorSize = 2
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
        real, dimension(lonIn,latIn,levIn,timeIn) :: value
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
	if (ccase=='dust_new') then
	    vars(1)%nameIn='aod'
	    vars(2)%nameIn='temp2m'
	    vars(3)%nameIn='dswf'
	    vars(4)%nameIn='dlwf'
	    vars(5)%nameIn='wdir'
	    vars(6)%nameIn='wmag'
 	else
            vars(1)%nameIn='aod'
            vars(2)%nameIn='temp2m'
            vars(3)%nameIn='dswf'
            vars(4)%nameIn='dlwf'
            vars(5)%nameIn='prec'
            vars(6)%nameIn='conv'
            vars(7)%nameIn='wdir'
	    vars(8)%nameIn='wmag'
	end if

    end subroutine

    subroutine initialize3dVars()
        implicit none
        allocate(vars3d(vars3dVectorSize))
        vars3d(1)%nameIn='temp'
	vars3d(1)%longName='air_temperature'
        vars3d(1)%units='K'

        vars3d(2)%nameIn='rh'
	vars3d(2)%longName='Relative humidity'
        vars3d(2)%units='%'

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
	input3dFile=inputVarsDir//'/'//varName//'_'//institutionCode//'_3d_'//institutionCode//'_3d_'//subcase//'_'//dateStrDay//'.nc'
    end function

end module ecmwf_all
