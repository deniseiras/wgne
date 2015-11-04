module nasa
    use date_utils
    use netcdf
    use netcdf_utils
    implicit none

    character(*), parameter :: institution='NASA/Goddard' !ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
    character(*), parameter :: institutionCode='nasa' !ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
    character(*), parameter :: ccase='pollution'
!    character(*), parameter :: subcase='interactive'
    character(*), parameter :: subcase='noaerosols'
    character(*), parameter :: comments='Extreme pollution in Beijing on January 1216, 2013. Forecast with no aerosol interaction.' !Case and Subcase
!dust
!    type(GregorianDate), parameter :: date_start = GregorianDate(2012, 4, 13, 0, 0, 0), date_end   = GregorianDate(2012, 4, 23, 0, 0, 0)
!    integer, parameter :: lonIn=193
!    integer, parameter :: latIn=201
!    integer, parameter :: levIn=15
!    integer, parameter :: timeIn=81
!smoke
!    type(GregorianDate), parameter :: date_start = GregorianDate(2012, 9, 5, 0, 0, 0), date_end   = GregorianDate(2012, 9, 16, 0, 0, 0)
!    integer, parameter :: lonIn=193
!    integer, parameter :: latIn=241
!    integer, parameter :: levIn=15
!    integer, parameter :: timeIn=6
!pollution
    type(GregorianDate), parameter :: date_start = GregorianDate(2013, 1, 7, 0, 0, 0), date_end   = GregorianDate(2013, 1, 21, 0, 0, 0)
    integer, parameter :: lonIn=194
    integer, parameter :: latIn=241
    integer, parameter :: levIn=15
    integer, parameter :: timeIn=81

    character(*), parameter :: inputBaseDir='/stornext/online8/exp-dmd/aerosols'
    character(*), parameter :: inputBaseVarsDir='/stornext/online8/exp-dmd/outputcasevars/stornext/online8/exp-dmd/aerosols/'
    character(*), parameter :: outputBaseDir='/scratchout/grupos/brams/home/denis.eiras/new_aerosols'
    integer, parameter :: varVectorSize = 14
    integer, parameter :: varNameSize = 30


    real(kind=8), dimension(timeIn) :: time_input
    real(kind=8), dimension(lonIn) :: lon_input
    real(kind=8), dimension(latIn) :: lat_input
    real, dimension(levIn) :: lev_input

    type varType
        character(len=varNameSize) nameIn
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
        vars(1)%nameIn='bcmass'
        vars(2)%nameIn='aeromass'
        vars(3)%nameIn='dustmass'
        vars(4)%nameIn='dlwf'
        vars(5)%nameIn='ocmass'
        vars(6)%nameIn='conv' !n tem no wgne_disp
        vars(7)%nameIn='prec'
        vars(8)%nameIn='so4mass'
        vars(9)%nameIn='saltmass'
        vars(10)%nameIn='dswf'
        vars(11)%nameIn='temp2m'
        vars(12)%nameIn='aod'
        vars(13)%nameIn='wdir'
        vars(14)%nameIn='wmag'

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

        call check(nf90_inq_varid(nc3did_in,'dtdtrad', varId_in))
        call check(nf90_get_var(nc3did_in, varId_in, ttend))
        call check(nf90_get_att(nc3did_in, varId_in,"missing_value", undef3d))
        call check(nf90_def_var(ncid_out, 'ttend', NF90_REAL, (/lonId, latId, levId, timeId/), ttendId))
        call check(nf90_put_att(ncid_out, ttendId, 'standard_name', 'ttend'))
        call check(nf90_put_att(ncid_out, ttendId, 'long_name', 'tendency_of_air_temperature_due_to_radiation'))
        call check(nf90_put_att(ncid_out, ttendId, 'units', 'K/s'))
        call check(nf90_put_att(ncid_out, ttendId, '_FillValue', undef3d))
        call check(nf90_put_att(ncid_out, ttendId, 'coordinates', 'time, lev, lat, lon'))

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
        call check(nf90_inq_varid(nc3did_in,'rh', varId_in))
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
        call check(nf90_put_var(ncid_out,ttendId, ttend))
        call check(nf90_put_var(ncid_out,tempId, temp))
        call check(nf90_put_var(ncid_out,rhId, rh))
        call closeFile(nc3did_in)
    end subroutine

end module nasa
