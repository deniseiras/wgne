module ecmwf_dust
    use netcdf
    use netcdf_utils
    implicit none

    character(*), parameter :: institution='ECMWF' !ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
    character(*), parameter :: institutionCode='ecmwf' !ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
    character(*), parameter :: ccase='dust'
    character(*), parameter :: subcase='direct'
    character(*), parameter :: comments='Dust storm on April 18, 2012. Forecast with no aerosol interaction.' !Case and Subcase
    integer, parameter :: varVectorSize = 8
    integer, parameter :: varNameSize = 30
    integer, parameter :: lonIn=720
    integer, parameter :: latIn=360
    integer, parameter :: levIn=9
    integer, parameter :: timeIn=81

    real(kind=8), dimension(timeIn) :: time_input
    real(kind=8), dimension(lonIn) :: lon_input
    real(kind=8), dimension(latIn) :: lat_input
    real, dimension(levIn) :: lev_input

!    character(*), parameter :: inputBaseDir='/stornext/online8/exp-dmd/aerosols'
!    character(*), parameter :: inputVarsDir='/stornext/online8/exp-dmd/wgne_converted/output/stornext/online8/exp-dmd/aerosols'
!    character(*), parameter :: outputBaseDir='/stornext/online8/exp-dmd/new_aerosols'
    character(*), parameter :: inputBaseDir='/home2/denis/magnitude'
    character(*), parameter :: inputBaseVarsDir='/home2/denis/output/home2/denis/magnitude'
    character(*), parameter :: outputBaseDir='/home2/denis/output/new_aerosols'


    type varType
        character(len=varNameSize) nameIn
        character(len=varNameSize) nameOut
        real, dimension(lonIn,latIn,timeIn) :: value

        integer :: id
    end type varType

    type(varType), allocatable, dimension(:) :: vars

    real :: rh(lonIn,latIn,levIn,timeIn)
    integer :: rhId
    real :: temp(lonIn,latIn,levIn,timeIn)
    integer :: tempId
    real :: ttend(lonIn,latIn,levIn,timeIn)
    integer :: ttendId

contains

    subroutine initialize2dVars()
        implicit none

        allocate(vars(varVectorSize))
        vars(1)%nameIn='aod'
        vars(2)%nameIn='temp2m'
        vars(3)%nameIn='dswf'
        vars(4)%nameIn='dlwf'
        vars(5)%nameIn='wdir'
        vars(6)%nameIn='wmag'

    end subroutine

    subroutine create3dVarsImpl(latId, levId, lonId, nc3did_in, ncid_out, timeId, varid_in)
        implicit none
        integer :: latId
        integer :: levId
        integer :: lonId
        integer :: nc3did_in
        integer :: ncid_out
        integer :: timeId
        real :: undef3d
        integer :: varid_in

        !        call check(nf90_get_att(ncid_in, nf90_global,"title", title))
        !        call check(nf90_put_att(ncid_out, nf90_global, "title", trim(title)))
        !        call check(nf90_get_att(ncid_in, nf90_global,"History", history))
        !        call check(nf90_put_att(ncid_out, nf90_global, "history", trim(history)))

        print*, "CRIANDO ATRIBUTOS DE VARIAVEIS 3D"

        !TEMPERATURA
        call check(nf90_inq_varid(nc3did_in,'t', varId_in))
        call check(nf90_get_var(nc3did_in, varId_in, temp))
        call check(nf90_get_att(nc3did_in, varId_in,"missing_value", undef3d))
        call check(nf90_def_var(ncid_out, 'temp', NF90_REAL, (/lonId, latId, levId, timeId/), tempId))
        call check(nf90_put_att(ncid_out, tempId, 'standard_name', 'temp'))
        call check(nf90_put_att(ncid_out, tempId, 'long_name', 'air_temperature'))
        call check(nf90_put_att(ncid_out, tempId, 'units', 'K'))
        call check(nf90_put_att(ncid_out, tempId, '_FillValue', undef3d))
        call check(nf90_put_att(ncid_out, tempId, 'coordinates', 'time, lev, lat, lon'))

        !UMIDADE RELATIVA
        call check(nf90_inq_varid(nc3did_in,'r', varId_in))
        call check(nf90_get_var(nc3did_in, varId_in, rh))
        call check(nf90_get_att(nc3did_in, varId_in,"missing_value", undef3d))
        call check(nf90_def_var(ncid_out, 'rh', NF90_REAL, (/lonId, latId, levId, timeId/), rhId))
        call check(nf90_put_att(ncid_out, rhId, 'standard_name', 'rh'))
        call check(nf90_put_att(ncid_out, rhId, 'long_name', 'relative_humidity_after_moist'))
        call check(nf90_put_att(ncid_out, rhId, 'units', '-'))
        call check(nf90_put_att(ncid_out, rhId, '_FillValue', undef3d))
        call check(nf90_put_att(ncid_out, rhId, 'coordinates', 'time, lev, lat, lon'))
    end subroutine

    subroutine write3dVarsImpl(nc3did_in, ncid_out)
        implicit none
        integer :: nc3did_in
        integer :: ncid_out

        print*, "ESCREVENDO VARIVEIS 3D"
        call check(nf90_put_var(ncid_out,tempId, temp))
        call check(nf90_put_var(ncid_out,rhId, rh))
        call closeFile(nc3did_in)
    end subroutine

end module ecmwf_dust
