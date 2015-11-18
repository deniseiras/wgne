!padrão de nome de arquivo:  modelo_subcaso_data.nc
!Ex: bsc_interactive_20130413.nc
!
!Nome dos institutos: Barcelona Supercomputing Center, ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
!
!Comentarios para o caso Dust: Dust storm on April 18, 2012.
!Comentarios para o caso Pollution: Extreme pollution in Beijing on January 1216, 2013.
!Comentarios para o caso Smoke: Extreme biomass burning smoke in Brazil (the SAMBBA case).
!
!Comentarios para o subcaso Noaerosol: Forecast with no aerosol interaction.
!Comentarios para o subcaso Direct: Forecast with aerosol interaction (direct effect only).
!Comentarios para o subcaso Indirect: Forecast with aerosol interaction (indirect effect only).
!!Comentarios para o subcaso Interactive: Forecast with aerosol interaction (direct and indirect effects).

!Ex::comments = "Dust storm on April 18, 2012. Forecast with aerosol interaction (direct and indirect effects)." ;

!    type(GregorianDate), parameter :: date_start = GregorianDate(2012, 4, 13, 0, 0, 0), date_end   = GregorianDate(2012, 4, 23, 0, 0, 0)
!    type(GregorianDate), parameter :: date_start = GregorianDate(2012, 9, 5, 0, 0, 0), date_end   = GregorianDate(2012, 9, 16, 0, 0, 0)

program create_netcdf
    use date_utils
    use netcdf
    use netcdf_utils
    use ncep

    implicit none
    character(len=*), parameter :: conventions = "CF-1.6"

    integer :: i
    integer :: j
    integer :: t
    integer :: ncid_out
    integer :: lonId
    integer :: latId
    integer :: levId
    integer :: timeId
    integer :: varid_in
    integer :: varid_out

    integer :: lonOut
    integer :: lon_varid
    integer :: latOut
    integer :: lat_varid
    integer :: levOut
    integer :: lev_varid
    integer :: timeOut
    integer :: time_varid
    character(len=1000) :: title
    character(len=1000) :: history
    character(len=12)  :: dateStrMinute
    character(len=8)  :: dateStrDay
    type(Date)          :: period
    type(GregorianDate) :: date_current
    character(len=255) :: outputFile
    character(len=255) :: outputDir
    character(len=255) :: input3dFile
    character(len=255) :: input2dFile

    call initialize2dVars()
    call initialize3dVars()
    !gerador de datas
    call makeDate(date_start, date_end, period)

!    ! Loop through the period with increments.
    do while (.not. period%iterationOver)
        ! Format the current date to strings matching IS and GrADS formats.
        dateStrMinute = formatDateYYYYMMDDHHMM(getCurrentDate(period))
        dateStrDay = dateStrMinute

	print*, ".~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~.~'~"
	print*, institution,' - ',institutionCode,' - ',ccase,' - ',subcase
	print*, comments

        print*, "CRIANDO ARQUIVO DE SAÍDA"
        outputDir=trim(outputBaseDir)//'/'//trim(caseDir)
	call system("mkdir -p "//outputDir)
        outputFile=trim(outputDir)//'/'//institutionCode//'_'//ccase//'_'//subcase//'_'//dateStrMinute//'.nc'
        call createFile(ncid_out, outputFile)
        
        call create3dAtributes(dateStrDay,latIn,levIn,lonIn,timeIn3d,lat_input,latId,lev_input,levId,&
            lon_input,lonId,ncid_out,time_input,timeId)

	call create3dVars(dateStrDay, institutionCode, latId, lonId, timeId, levId, ncid_out, vars3d, vars3dVectorSize)

        call create2dVars(dateStrDay, institutionCode, latId, lonId, timeId, ncid_out, vars, varVectorSize)

        call createGlobalAtributes(comments, conventions, institution, ncid_out)

        print*, "FINALIZANDO DEFINICAO DE VARIAVIES"
        call check(nf90_enddef(ncid_out))

        call write3dAtributes(latIn, levIn, lonIn, timeIn3d, lat_input, latId, lev_input, levId, lon_input, lonId, ncid_out,&
            time_input, timeId)

        print*, "ESCREVENDO VARIVEIS 3D"
        do i = 1, vars3dVectorSize
            call check(nf90_put_var(ncid_out,vars3d(i)%id, vars3d(i)%value))
        end do

        print*, "ESCREVENDO VARIVEIS 2D"
        do i = 1, varVectorSize
            call check(nf90_put_var(ncid_out,vars(i)%id, vars(i)%value))
        end do

        call closeFile(ncid_out)
        ! (3*3600, period)saida a cada 3 horas    (24*3600, period)=> saida a diaria
        call incrementBySeconds(24*3600, period)

    enddo
contains

    subroutine create2dVars(dateStrDay, institutionCode, latId, lonId, timeId, ncid_out,&
        vars, varVectorSize)
        implicit none
        character(len=8), intent(in) :: dateStrDay
        character(*), intent(in) :: institutionCode
        integer, intent(in) :: latId
        integer, intent(in) :: lonId
        integer, intent(in) :: timeId
        integer, intent(in) :: ncid_out
        type(var2dType), intent(inout), allocatable, dimension(:) :: vars
        integer, intent(in) :: varVectorSize

        real :: undef2d
        integer :: varid_in
        character(len=255) :: input2dFile
        integer :: i
        integer :: nc2did_in

        print*, "CRIANDO ATRIBUTOS DE VARIAVEIS 2D"
        do i = 1, varVectorSize
	    input2dFile=getInput2dVarFileImpl(trim(vars(i)%nameIn),dateStrDay)	
            call openFile(nc2did_in, input2dFile)
            call check(nf90_inq_varid(nc2did_in,trim(vars(i)%nameIn), varId_in))
            call check(nf90_get_var(nc2did_in, varId_in, vars(i)%value))
            call check(nf90_get_att(nc2did_in, varId_in,"_FillValue", undef2d))
!            call check(nf90_get_att(nc2did_in, varId_in,"missing_value", undef2d))
            call check(nf90_def_var(ncid_out, trim(vars(i)%nameIn), NF90_REAL, (/lonId, latId, timeId/), vars(i)%id))
            call check(nf90_put_att(ncid_out, vars(i)%id, 'standard_name', trim(vars(i)%nameIn)))
            call check(nf90_put_att(ncid_out, vars(i)%id, 'coordinates', 'time, lat, lon'))
            call check(nf90_put_att(ncid_out, vars(i)%id, '_FillValue', undef2d))
            call closeFile(nc2did_in)
        end do
    end subroutine

    subroutine create3dVars(dateStrDay,institutionCode,latId,lonId,timeId,levId,ncid_out,vars3d,vars3dVectorSize)
        implicit none
        character(len=8), intent(in) :: dateStrDay
        character(*), intent(in) :: institutionCode
        integer, intent(out) :: latId
        integer, intent(out) :: lonId
        integer, intent(out) :: timeId
        integer, intent(out) :: levId
        integer, intent(in) :: ncid_out
        type(var3dType), intent(inout), allocatable, dimension(:) :: vars3d
        integer, intent(in) :: vars3dVectorSize

        real :: undef3d
        integer :: varid_in
        character(len=255) :: input3dFile
        integer :: i
        integer :: nc3did_in

        print*, "CRIANDO ATRIBUTOS DE VARIAVEIS 3D"
        do i = 1, vars3dVectorSize
	    input3dFile=getInput3dVarFileImpl(trim(vars3d(i)%nameIn),dateStrDay)	
            call openFile(nc3did_in, input3dFile)
            call check(nf90_inq_varid(nc3did_in,trim(vars3d(i)%nameIn), varId_in))
            call check(nf90_get_var(nc3did_in, varId_in, vars3d(i)%value))
!            call check(nf90_get_att(nc3did_in, varId_in,"missing_value", undef3d))
            call check(nf90_get_att(nc3did_in, varId_in,"_FillValue", undef3d))
            call check(nf90_def_var(ncid_out, trim(vars3d(i)%nameIn), NF90_REAL, (/lonId, latId, levId, timeId/), vars3d(i)%id))
            call check(nf90_put_att(ncid_out, vars3d(i)%id, '_FillValue', undef3d))
            call check(nf90_put_att(ncid_out, vars3d(i)%id, 'standard_name', trim(vars3d(i)%nameIn)))
            call check(nf90_put_att(ncid_out, vars3d(i)%id, 'long_name', trim(vars3d(i)%longName)))
            call check(nf90_put_att(ncid_out, vars3d(i)%id, 'units', trim(vars3d(i)%units)))
            call check(nf90_put_att(ncid_out, vars3d(i)%id, 'coordinates', 'time, lev, lat, lon'))
            call closeFile(nc3did_in)
        end do
    end subroutine

    subroutine create3dAtributes(dateStrDay,latIn,levIn,lonIn,timeIn3d,lat_input,latId,lev_input,levId,&
        lon_input,lonId,ncid_out,time_input,timeId)
        implicit none
	character(len=8), intent(in) :: dateStrDay
        integer, intent(in) :: latIn
        integer, intent(in) :: levIn
        integer, intent(in) :: lonIn
        integer, intent(in) :: timeIn3d
        real(kind=8), intent(out) :: lat_input(latIn)
        integer, intent(out) :: latId
        real, intent(out) :: lev_input(levIn)
        integer, intent(out) :: levId
        real(kind=8), intent(out) :: lon_input(lonIn)
        integer, intent(out) :: lonId
        integer, intent(in):: ncid_out
        real(kind=8), intent(out) :: time_input(timeIn3d)
        integer, intent(out) :: timeId
	integer :: nc3did_in
        integer :: nc2did_in

        integer :: latOut
        integer :: levOut
        integer :: lonOut
        integer :: timeOut
        character(len=30) :: units
        integer :: varid_in

	
        print*, "CRIANDO ATRIBUTOS 3D"
	!todos arquivos têm mesmas características, pego o primeiro
        input3dFile=getInput3dVarFileImpl(trim(vars3d(1)%nameIn),dateStrDay)
        input2dFile=getInput2dVarFileImpl(trim(vars(1)%nameIn),dateStrDay)
        call openFile(nc3did_in,input3dFile)
	call openFile(nc2did_in,input2dFile)

        !TEMPO
        call check(nf90_inq_varid(nc2did_in, 'time', varId_in))
        call check(nf90_get_var(nc2did_in, varId_in, time_input))
        call check(nf90_def_dim(ncid_out, 'time', timeIn, timeOut))
        call check(nf90_def_var(ncid_out, 'time', NF90_REAL, timeOut, timeId))
        call check(nf90_put_att(ncid_out, timeId, 'long_name', 'time'))
        call check(nf90_put_att(ncid_out, timeId, 'standard_name', 'time'))
        call check(nf90_get_att(nc2did_in, varid_in,'units', units)) 
        call check(nf90_put_att(ncid_out, timeId, 'units', trim(units)))
        call check(nf90_put_att(ncid_out, timeId, 'calendar', 'standard'))
        !NIVEIS
        call check(nf90_inq_varid(nc3did_in, 'lev', varId_in))
!        call check(nf90_inq_varid(nc3did_in, 'levels', varId_in)) !!!!!! pode mudar, assim como longitude ...
!        call check(nf90_inq_varid(nc3did_in, 'level', varId_in))

        call check(nf90_get_var(nc3did_in, varId_in, lev_input))
        call check(nf90_def_dim(ncid_out, 'lev', levIn, levOut))
        call check( nf90_def_var(ncid_out, 'lev', NF90_REAL, levOut, levId))
        call check(nf90_put_att(ncid_out, levId, 'standard_name', 'lev'))
        call check(nf90_put_att(ncid_out, levId, 'long_name', 'Level'))
        call check(nf90_put_att(ncid_out, levId, 'units', 'hPa'))
        call check(nf90_put_att(ncid_out, levId, 'axis', 'Z'))
        !LONGITUDE
        call check(nf90_inq_varid(nc3did_in, 'lon', varId_in))
!        call check(nf90_inq_varid(nc3did_in, 'longitude', varId_in))          
          
        call check(nf90_get_var(nc3did_in, varId_in, lon_input))
        call check(nf90_def_dim(ncid_out,'lon', lonIn, lonOut))
        call check(nf90_def_var(ncid_out, 'lon', NF90_REAL, lonOut, lonId))
        call check(nf90_put_att(ncid_out, lonId, 'standard_name', 'lon'))
        call check(nf90_put_att(ncid_out, lonId, 'long_name', 'Longitude'))
        call check(nf90_put_att(ncid_out, lonId, 'units', 'degrees_east'))
        call check(nf90_put_att(ncid_out, lonId, 'axis', 'X'))
        !LATITUDE
        call check(nf90_inq_varid(nc3did_in, 'lat', varId_in))
!        call check(nf90_inq_varid(nc3did_in, 'latitude', varId_in))

        call check(nf90_get_var(nc3did_in, varId_in, lat_input))
        call check(nf90_def_dim(ncid_out,'lat', latIn, latOut))
        call check(nf90_def_var(ncid_out, 'lat', NF90_REAL, latOut, latId))
        call check(nf90_put_att(ncid_out, latId, 'standard_name', 'lat'))
        call check(nf90_put_att(ncid_out, latId, 'long_name', 'Latitude'))
        call check(nf90_put_att(ncid_out, latId, 'units', 'degrees_north'))
        call check(nf90_put_att(ncid_out, latId, 'axis', 'Y'))
    end subroutine

    subroutine write3dAtributes(latIn,levIn,lonIn,timeIn3d,lat_input,latId,lev_input,levId,lon_input,lonId,ncid_out,&
        time_input,timeId)
        implicit none
        integer, intent(in) :: latIn
        integer, intent(in) :: levIn
        integer, intent(in) :: lonIn
        integer, intent(in) :: timeIn3d
        real(kind=8), intent(in) :: lat_input(latIn)
        integer, intent(in) :: latId
        real, intent(in) :: lev_input(levIn)
        integer, intent(in) :: levId
        real(kind=8), intent(in) :: lon_input(lonIn)
        integer, intent(in) :: lonId
        integer, intent(in) :: ncid_out
        real(kind=8), intent(in) :: time_input(timeIn3d)
        integer, intent(in) :: timeId

        print*, "ESCREVENDO VARIVEIS DE DIMENSÃO 3d"
        call check(nf90_put_var(ncid_out, lonId, lon_input))
        call check(nf90_put_var(ncid_out, latId, lat_input))
        call check(nf90_put_var(ncid_out, levId, lev_input))
        call check(nf90_put_var(ncid_out,timeId, time_input))
    end subroutine

    subroutine createGlobalAtributes(comments, conventions, institution, ncid_out)
        implicit none
        character(*), intent(in) :: comments
        character(*), intent(in) :: conventions
        character(*), intent(in) :: institution
        integer, intent(in):: ncid_out

        print*, "CRIANDO ATRIBUTOS GLOBAIS"
        call check(nf90_put_att(ncid_out, nf90_global, "institution", trim(institution)))
        call check(nf90_put_att(ncid_out, nf90_global, "comments", trim(comments)))
        call check(nf90_put_att(ncid_out, nf90_global, "Conventions", conventions))
    end subroutine


end program create_netcdf
