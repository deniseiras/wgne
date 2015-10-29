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
    use netcdf_utils
    use nasadust

    implicit none
    character(len=*), parameter :: conventions = "CF-1.6"

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
    character(len=30) :: units
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

    call initialize2dVars()
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

        call create3dAtributes(latIn, levIn, lonIn, timeIn, lat_input, latId, latOut, lev_input, levId, levOut, &
            lon_input, lonId, lonOut, nc3did_in, ncid_out, time_input, timeId, timeOut, units, varid_in)
        call createGlobalAtributes(comments, conventions, institution, nc3did_in, ncid_out)

        call create3dVarsImpl(latId, levId, lonId, nc3did_in, ncid_out, timeId, varid_in)

        call create2dVars(dateStrDay, i, input2dFile, inputVarsDir, institutionCode, latId, lonId, nc2did_in, ncid_out, timeId,&
            varid_in, vars, varVectorSize)


        print*, "FINALIZANDO DEFINICAO DE VARIAVIES"
        call check(nf90_enddef(ncid_out))

        call write3dAtributes(latIn, levIn, lonIn, timeIn, lat_input, latId, lev_input, levId, lon_input, lonId, ncid_out,&
            time_input, timeId)
        call write3dVarsImpl(nc3did_in, ncid_out)

        print*, "ESCREVENDO VARIVEIS 2D"
        do i = 1, varVectorSize
            call check(nf90_put_var(ncid_out,vars(i)%id, vars(i)%value))
        end do
    
        ! (3*3600, period)saida a cada 3 horas    (24*3600, period)=> saida a diaria

        call closeFile(ncid_out)

        call incrementBySeconds(24*3600, period)
    enddo
contains

    subroutine create3dAtributes(latIn, levIn, lonIn, timeIn, lat_input, latId, latOut, lev_input, levId, levOut,&
        lon_input, lonId, lonOut, nc3did_in, ncid_out, time_input, timeId, timeOut, units, varid_in)
        implicit none
        integer :: latIn
        integer :: levIn
        integer :: lonIn
        integer :: timeIn
        real(kind=8) :: lat_input(latIn)
        integer :: latId
        integer :: latOut
        real :: lev_input(levIn)
        integer :: levId
        integer :: levOut
        real(kind=8) :: lon_input(lonIn)
        integer :: lonId
        integer :: lonOut
        integer :: nc3did_in
        integer :: ncid_out
        real(kind=8) :: time_input(timeIn)
        integer :: timeId
        integer :: timeOut
        character(len=30) :: units
        integer :: varid_in
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
    end subroutine

    subroutine createGlobalAtributes(comments, conventions, institution, nc3did_in, ncid_out)
        implicit none
        character(*) :: comments
        character(*) :: conventions
        character(*) :: institution
        integer :: nc3did_in
        integer :: ncid_out

        print*, "CRIANDO ATRIBUTOS GLOBAIS"

        call check(nf90_put_att(ncid_out, nf90_global, "institution", trim(institution)))
        call check(nf90_put_att(ncid_out, nf90_global, "comments", trim(comments)))
        call check(nf90_put_att(ncid_out, nf90_global, "Conventions", conventions))
    end subroutine

    subroutine create2dVars(dateStrDay, i, input2dFile, inputVarsDir, institutionCode, latId, lonId, nc2did_in, ncid_out,&
        timeId, varid_in, vars, varVectorSize)
        implicit none
        character(len=8) :: dateStrDay
        integer :: i
        character(len=255) :: input2dFile
        character(len=255) :: inputVarsDir
        character(*) :: institutionCode
        integer :: latId
        integer :: lonId
        integer :: nc2did_in
        integer :: ncid_out
        integer :: timeId
        real :: undef2d
        integer :: varid_in
        type(varType), allocatable, dimension(:) :: vars
        integer :: varVectorSize

        print*, "CRIANDO ATRIBUTOS DE VARIAVEIS 2D"
        do i = 1, varVectorSize
            input2dFile=trim(inputVarsDir)//'/'//trim(vars(i)%nameIn)//'_'//institutionCode//'_2d_'//dateStrDay//'_00.nc'
            call openFile(nc2did_in, input2dFile)
            call check(nf90_inq_varid(nc2did_in,vars(i)%nameIn, varId_in))
            call check(nf90_get_var(nc2did_in, varId_in, vars(i)%value))
            call check(nf90_get_att(nc2did_in, varId_in,"_FillValue", undef2d))

            call check(nf90_def_var(ncid_out, vars(i)%nameOut, NF90_REAL, (/lonId, latId, timeId/), vars(i)%id))
            call check(nf90_put_att(ncid_out, vars(i)%id, 'standard_name', vars(i)%nameOut))
            call check(nf90_put_att(ncid_out, vars(i)%id, 'coordinates', 'time, lat, lon'))
            call check(nf90_put_att(ncid_out, vars(i)%id, '_FillValue', undef2d))
            call closeFile(nc2did_in)
        end do
    end subroutine

    subroutine write3dAtributes(latIn, levIn, lonIn, timeIn, lat_input, latId, lev_input, levId, lon_input, lonId, ncid_out,&
        time_input, timeId)
        implicit none
        integer :: latIn
        integer :: levIn
        integer :: lonIn
        integer :: timeIn
        real(kind=8) :: lat_input(latIn)
        integer :: latId
        real :: lev_input(levIn)
        integer :: levId
        real(kind=8) :: lon_input(lonIn)
        integer :: lonId
        integer :: ncid_out
        real(kind=8) :: time_input(timeIn)
        integer :: timeId

        print*, "ESCREVENDO VARIVEIS DE DIMENSÃO 3d"
        call check(nf90_put_var(ncid_out, lonId, lon_input))
        call check(nf90_put_var(ncid_out, latId, lat_input))
        call check(nf90_put_var(ncid_out, levId, lev_input))
        call check(nf90_put_var(ncid_out,timeId, time_input))
    end subroutine


end program create_netcdf
