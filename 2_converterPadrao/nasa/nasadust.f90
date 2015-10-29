module nasadust
    use netcdf
    use netcdf_utils
    implicit none
    character(*), parameter :: institution='NASA/Goddard' !ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
    character(*), parameter :: institutionCode='nasa' !ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
    character(*), parameter :: ccase='dust'
    character(*), parameter :: subcase='interactive'
    character(*), parameter :: comments='Dust storm on April 18, 2012. Forecast with no aerosol interaction.' !Case and Subcase
    integer, parameter :: varVectorSize = 16
    integer, parameter :: varNameSize = 30
    integer, parameter :: lonIn=193
    integer, parameter :: latIn=201
    integer, parameter :: levIn=15
    integer, parameter :: timeIn=81
    real, parameter :: undef = 1.e+15
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
        vars(1)%nameIn='bccmass'
        vars(2)%nameIn='ducmass'
        vars(3)%nameIn='lwgnt'
        vars(4)%nameIn='occmass'
        vars(5)%nameIn='preccon'
        vars(6)%nameIn='preclsc'
        vars(7)%nameIn='prectot'
        vars(8)%nameIn='so4cmass'
        vars(9)%nameIn='sscmass'
        vars(10)%nameIn='swgnt'
        vars(11)%nameIn='t2m'
        vars(12)%nameIn='totexttau'
        vars(13)%nameIn='u10m'
        vars(14)%nameIn='v10m'
        vars(15)%nameIn='wdir'
        vars(16)%nameIn='wmag'

        vars(1)%nameOut='bccmass'
        vars(2)%nameOut='ducmass'
        vars(3)%nameOut='lwgnt'
        vars(4)%nameOut='occmass'
        vars(5)%nameOut='preccon'
        vars(6)%nameOut='preclsc'
        vars(7)%nameOut='prectot'
        vars(8)%nameOut='so4cmass'
        vars(9)%nameOut='sscmass'
        vars(10)%nameOut='swgnt'
        vars(11)%nameOut='t2m'
        vars(12)%nameOut='totexttau'
        vars(13)%nameOut='u10m'
        vars(14)%nameOut='v10m'
        vars(15)%nameOut='wdir'
        vars(16)%nameOut='wmag'
    end subroutine

    subroutine create3dVarsImpl(latId, levId, lonId, nc3did_in, ncid_out, timeId, undef, varid_in)
        implicit none
        integer :: latId
        integer :: levId
        integer :: lonId
        integer :: nc3did_in
        integer :: ncid_out
        integer :: timeId
        real :: undef
        integer :: varid_in

        !        call check(nf90_get_att(ncid_in, nf90_global,"title", title))
        !        call check(nf90_put_att(ncid_out, nf90_global, "title", trim(title)))
        !        call check(nf90_get_att(ncid_in, nf90_global,"History", history))
        !        call check(nf90_put_att(ncid_out, nf90_global, "history", trim(history)))

        print*, "CRIANDO ATRIBUTOS DE VARIAVEIS 3D"

        call check(nf90_inq_varid(nc3did_in,'dtdtrad', varId_in))
        call check(nf90_get_var(nc3did_in, varId_in, ttend))
        call check(nf90_def_var(ncid_out, 'ttend', NF90_REAL, (/lonId, latId, levId, timeId/), ttendId))

        call check(nf90_put_att(ncid_out, ttendId, 'standard_name', 'ttend'))
        call check(nf90_put_att(ncid_out, ttendId, 'long_name', 'tendency_of_air_temperature_due_to_radiation'))
        call check(nf90_put_att(ncid_out, ttendId, 'units', 'K/s'))
        call check(nf90_put_att(ncid_out, ttendId, '_FillValue', undef))
        call check(nf90_put_att(ncid_out, ttendId, 'coordinates', 'time, lev, lat, lon'))

        !TEMPERATURA
        call check(nf90_inq_varid(nc3did_in,'t', varId_in))
        call check(nf90_get_var(nc3did_in, varId_in, temp))
        call check(nf90_def_var(ncid_out, 'temp', NF90_REAL, (/lonId, latId, levId, timeId/), tempId))

        call check(nf90_put_att(ncid_out, tempId, 'standard_name', 'temp'))
        call check(nf90_put_att(ncid_out, tempId, 'long_name', 'air_temperature'))
        call check(nf90_put_att(ncid_out, tempId, 'units', ''))
        call check(nf90_put_att(ncid_out, tempId, '_FillValue', undef))
        call check(nf90_put_att(ncid_out, tempId, 'coordinates', 'time, lev, lat, lon'))

        !UMIDADE RELATIVA
        call check(nf90_inq_varid(nc3did_in,'rh', varId_in))
        call check(nf90_get_var(nc3did_in, varId_in, rh))
        call check(nf90_def_var(ncid_out, 'rh', NF90_REAL, (/lonId, latId, levId, timeId/), rhId))

        call check(nf90_put_att(ncid_out, rhId, 'standard_name', 'rh'))
        call check(nf90_put_att(ncid_out, rhId, 'long_name', 'relative_humidity_after_moist'))
        call check(nf90_put_att(ncid_out, rhId, 'units', ''))
        call check(nf90_put_att(ncid_out, rhId, '_FillValue', undef))
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

end module nasadust
