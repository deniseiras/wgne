!padrão de nome de arquivo:  modelo_subcaso_data.nc
!Ex: bsc_interactive_20130413.nc
!
!Nome dos institutos: Barcelona Supercomputing Center, ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
!
!Comentarios para o caso Dust: Dust storm on April 18, 2012.
!Comentarios para o caso Pollution: Extreme pollution in Beijing on January 12-16, 2013.
!Comentarios para o caso Smoke: Extreme biomass burning smoke in Brazil (the SAMBBA case).
!
!Comentarios para o subcaso Noaerosol: Forecast with no aerosol interaction.
!Comentarios para o subcaso Direct: Forecast with aerosol interaction (direct effect only).
!Comentarios para o subcaso Indirect: Forecast with aerosol interaction (indirect effect only).
!!Comentarios para o subcaso Interactive: Forecast with aerosol interaction (direct and indirect effects).

!Ex::comments = "Dust storm on April 18, 2012. Forecast with aerosol interaction (direct and indirect effects)." ;

program create_netcdf
    use date_utils
    use netcdf

    implicit none

!+++++++++++++++++++++++++++++ DEFINIR PARÂMETROS ++++++++++++++++++++++++++++++++++++++++++
    real, parameter :: undef = 1.e+15
    integer, parameter :: lonIn=193
    integer, parameter :: latIn=201
    integer, parameter :: levIn=15
    integer, parameter :: timeIn=81
    character(*), parameter :: institution='NASA/Goddard' !ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
    character(*), parameter :: institutionCode='nasa' !ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
    character(*), parameter :: ccase='dust'
    character(*), parameter :: subcase='interactive'
    character(*), parameter :: comments='Dust storm on April 18, 2012. Forecast with no aerosol interaction.' !Case and Subcase

!    character(*), parameter :: inputBaseDir='/stornext/online8/exp-dmd/aerosols'
!    character(*), parameter :: inputVarsDir='/stornext/online8/exp-dmd/wgne_converted/output/stornext/online8/exp-dmd/aerosols'
!    character(*), parameter :: outputBaseDir='/stornext/online8/exp-dmd/new_aerosols'

    character(*), parameter :: inputBaseDir='/home2/denis/magnitude'
    character(*), parameter :: inputBaseVarsDir='/home2/denis/output/home2/denis/magnitude'
    character(*), parameter :: outputBaseDir='/home2/denis/output/new_aerosols'
    integer, parameter :: varVectorSize = 16
    integer, parameter :: varNameSize = 30
!+++++++++++++++++++++++++++++ DEFINIR PARÂMETROS ++++++++++++++++++++++++++++++++++++++++++

    type varType
        character(len=varNameSize) nameIn
        character(len=varNameSize) nameOut
        real, dimension(lonIn,latIn,timeIn) :: value
        integer :: id
    end type varType

    type(varType), allocatable, dimension(:) :: vars

    integer :: i
    integer :: j
    integer :: t
    integer :: nc3did_in
    integer :: nc2did_in
    integer :: ncid_out
    integer :: lonId
    integer :: latId
    integer :: levId
    integer :: timeId
    integer :: varid_in
    integer :: varid_out
    real(kind=8), dimension(timeIn) :: time_input
    real, dimension(levIn) :: lev_input
    real(kind=8), dimension(lonIn) :: lon_input
    real(kind=8), dimension(latIn) :: lat_input
    real :: undefAux

    integer :: lonOut
    integer :: lon_varid
    integer :: latOut
    integer :: lat_varid
    integer :: levOut
    integer :: lev_varid
    integer :: timeOut
    integer :: time_varid
    character(len=1000) :: conventions
    character(len=1000) :: title
    character(len=1000) :: history
    character(len=30) :: units

    real, dimension(lonIn,latIn,levIn,timeIn) :: ttend
    real, dimension(lonIn,latIn,levIn,timeIn) :: temp
    real, dimension(lonIn,latIn,levIn,timeIn) :: rh
    integer :: ttendId
    integer :: tempId
    integer :: rhId

!    real, dimension(lonIn,latIn,timeIn) :: temp2m
!    real, dimension(lonIn,latIn,timeIn) :: wdir
!    real, dimension(lonIn,latIn,timeIn) :: wmag
!    real, dimension(lonIn,latIn,timeIn) :: aod
!    real, dimension(lonIn,latIn,timeIn) :: dustmass
!    real, dimension(lonIn,latIn,timeIn) :: dswf
!    real, dimension(lonIn,latIn,timeIn) :: dlwf

!    integer :: temp2mId
!    integer :: wdirId
!    integer :: wmagId
!    integer :: aodId
!    integer :: dustmassId
!    integer :: dswfId
!    integer :: dlwfId

    ! character(*), parameter :: inputDir='/home2/denis/magnitude/nasa/dust/noaerosols'
    ! character(*), parameter :: inputDir='/home2/denis/magnitude/nasa/pollution/interactive'
    ! character(*), parameter :: inputDir='/home2/denis/magnitude/nasa/pollution/noaerosols'
    ! character(*), parameter :: inputDir='/home2/denis/magnitude/nasa/smoke/interactive'
    ! character(*), parameter :: inputDir='/home2/denis/magnitude/nasa/smoke/noaerosols'

    character(len=12)  :: dateStrMinute
    character(len=8)  :: dateStrDay
    type(Date)          :: period
    type(GregorianDate) :: date_current, date_start, date_end
    character(len=255) :: outputFile
    character(len=255) :: outputDir
    character(len=255) :: inputDir
    character(len=255) :: inputVarsDir
    character(len=255) :: input3dFile
    character(len=255) :: input2dFile
    character(len=255) :: caseDir

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

    !gerador de datas
    date_start = GregorianDate(2012, 4, 13, 0, 0, 0)
    date_end   = GregorianDate(2012, 4, 13, 0, 0, 0)
    call makeDate(date_start, date_end, period)
  
!    ! Loop through the period with increments.
    do while (.not. period%iterationOver)
        ! Format the current date to strings matching IS and GrADS formats.
        dateStrMinute = formatDateYYYYMMDDHHMM(getCurrentDate(period))
        dateStrDay = dateStrMinute

        print*, trim(dateStrMinute)
        caseDir=institutionCode//'/'//ccase//'/'//subcase
        inputDir=inputBaseDir//'/'//caseDir
        inputVarsDir=inputBaseVarsDir//'/'//caseDir
	    outputDir=trim(outputBaseDir)//'/'//trim(caseDir)

        print*, outputDir
    	call system("mkdir -p "//outputDir)


        ! criando arquivo de saída
        outputFile=trim(outputDir)//'/'//institutionCode//'_'//ccase//'_'//subcase//'_'//dateStrMinute//'.nc'
        call createFile(ncid_out, outputFile)

        input3dFile=trim(inputDir)//'/'//institutionCode//'_3d_'//dateStrDay//'_00.nc'
        call openFile(nc3did_in,input3dFile)
        print*, "CRIANDO ATRIBUTOS 3D DIMENSÃO"
        !TEMPO
        call check(nf90_inq_varid(nc3did_in, 'time', varId_in))
        call check(nf90_get_var(nc3did_in, varId_in, time_input))
        call check(nf90_def_dim(ncid_out, 'time', timeIn, timeOut))
        call check(nf90_def_var(ncid_out, 'time', NF90_REAL, timeOut, timeId))

        call check(nf90_put_att(ncid_out, timeId, 'long_name', 'time'))
        call check(nf90_put_att(ncid_out, timeId, 'standard_name', 'time'))

        call check(nf90_get_att(nc3did_in, varid_in,'units', units)) !captura valor da unidade de tempo
        call check(nf90_put_att(ncid_out, timeId, 'units', trim(units)))
        call check(nf90_put_att(ncid_out, timeId, 'calendar', 'standard'))

        !NIVEIS
        call check(nf90_inq_varid(nc3did_in, 'levels', varId_in))
        call check(nf90_get_var(nc3did_in, varId_in, lev_input))
        call check(nf90_def_dim(ncid_out, 'lev', levIn, levOut))
        call check( nf90_def_var(ncid_out, 'lev', NF90_REAL, levOut, levId))

        call check(nf90_put_att(ncid_out, levId, 'standard_name', 'lev'))
        call check(nf90_put_att(ncid_out, levId, 'long_name', 'Level'))
        call check(nf90_put_att(ncid_out, levId, 'units', 'hPa'))
        call check(nf90_put_att(ncid_out, levId, 'axis', 'Z'))

        !LONGITUDE
        call check(nf90_inq_varid(nc3did_in, 'longitude', varId_in))               !extrai valor original de longitude do arquivo
        call check(nf90_get_var(nc3did_in, varId_in, lon_input))
        call check(nf90_def_dim(ncid_out,'lon', lonIn, lonOut))
        call check(nf90_def_var(ncid_out, 'lon', NF90_REAL, lonOut, lonId))

        call check(nf90_put_att(ncid_out, lonId, 'standard_name', 'lon'))
        call check(nf90_put_att(ncid_out, lonId, 'long_name', 'Longitude'))
        call check(nf90_put_att(ncid_out, lonId, 'units', 'degrees_east'))
        call check(nf90_put_att(ncid_out, lonId, 'axis', 'X'))

        !LATITUDE
        call check(nf90_inq_varid(nc3did_in, 'latitude', varId_in))
        call check(nf90_get_var(nc3did_in, varId_in, lat_input))
        call check(nf90_def_dim(ncid_out,'lat', latIn, latOut))
        call check(nf90_def_var(ncid_out, 'lat', NF90_REAL, latOut, latId))

        call check(nf90_put_att(ncid_out, latId, 'standard_name', 'lat'))
        call check(nf90_put_att(ncid_out, latId, 'long_name', 'Latitude'))
        call check(nf90_put_att(ncid_out, latId, 'units', 'degrees_north'))
        call check(nf90_put_att(ncid_out, latId, 'axis', 'Y'))

        print*, "CRIANDO ATRIBUTOS GLOBAIS"

        call check(nf90_put_att(ncid_out, nf90_global, "institution", trim(institution)))
        call check(nf90_put_att(ncid_out, nf90_global, "comments", trim(comments)))
        call check(nf90_get_att(nc3did_in, nf90_global,"Conventions", conventions))
        call check(nf90_put_att(ncid_out, nf90_global, "Conventions", conventions))

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

        print*, "CRIANDO ATRIBUTOS DE VARIAVEIS 2D"
        do i = 1, varVectorSize
            input2dFile=trim(inputVarsDir)//'/'//trim(vars(i)%nameIn)//'_'//institutionCode//'_2d_'//dateStrDay//'_00.nc'
            call openFile(nc2did_in, input2dFile)
            call check(nf90_inq_varid(nc2did_in,vars(i)%nameIn, varId_in))
            call check(nf90_get_var(nc2did_in, varId_in, vars(i)%value))
            call check(nf90_get_att(nc2did_in, varId_in,"_FillValue", undefAux))
            call check(nf90_def_var(ncid_out, vars(i)%nameOut, NF90_REAL, (/lonId, latId, timeId/), vars(i)%id))

            call check(nf90_put_att(ncid_out, vars(i)%id, 'standard_name', vars(i)%nameOut))
!            call check(nf90_put_att(ncid_out, temp2mId, 'long_name', 'temperature at 2m'))
!            call check(nf90_put_att(ncid_out, temp2mId, 'units', 'K'))
            call check(nf90_put_att(ncid_out, vars(i)%id, '_FillValue', undefAux))
            call check(nf90_put_att(ncid_out, vars(i)%id, 'coordinates', 'time, lat, lon'))
            call closeFile(nc2did_in)
        end do

        print*, "FINALIZANDO DEFINICAO DE VARIAVIES"
        call check(nf90_enddef(ncid_out))

        print*, "ESCREVENDO VARIVEIS DE DIMENSÃO"
        call check(nf90_put_var(ncid_out, lonId, lon_input))
        call check(nf90_put_var(ncid_out, latId, lat_input))
        call check(nf90_put_var(ncid_out, levId, lev_input))
        call check(nf90_put_var(ncid_out,timeId, time_input))

        print*, "ESCREVENDO VARIVEIS 3D"
        call check(nf90_put_var(ncid_out,ttendId, ttend))
        call check(nf90_put_var(ncid_out,tempId, temp))
        call check(nf90_put_var(ncid_out,rhId, rh))
        call closeFile(nc3did_in)

        print*, "ESCREVENDO VARIVEIS 2D"
        do i = 1, varVectorSize
            call check(nf90_put_var(ncid_out,vars(i)%id, vars(i)%value))
        end do
    
        ! (3*3600, period)saida a cada 3 horas    (24*3600, period)=> saida a diaria

        call closeFile(ncid_out)

        call incrementBySeconds(24*3600, period)
    enddo
contains

    subroutine closeFile(ncId)
        implicit none
        integer, intent(in) :: ncId
        print*, "FECHANDO ARQUIVO ", ncId
        call check(nf90_close(ncId))
    end subroutine closeFile

    subroutine openFile(ncid, inputFile)
        implicit none
        character(len=255), intent(in) :: inputFile
        integer, intent(inout) :: ncid
        print *, "ABRINDO ARQUIVO ", trim(inputFile)
        call check(nf90_open(trim(inputFile), NF90_NOWRITE, ncid))
        print*, "ARQUIVO ABERTO: ", trim(inputFile), ncid
    end subroutine openFile

    subroutine createFile(ncid, outputFile)
        implicit none
        integer,intent(inout) :: ncid
        character(len=255), intent(in) :: outputFile
        print*, "CRIANDO ARQUIVO ", outputFile
        call check(nf90_create(trim(outputFile), NF90_CLOBBER, ncid))
    end subroutine createFile

    subroutine check(status)
        implicit none
        integer, intent (in) :: status
        if(status /= nf90_noerr) then
            print *, trim(nf90_strerror(status))
            print *, status
            stop "Stopped"
        end if
    end subroutine check

end program create_netcdf
