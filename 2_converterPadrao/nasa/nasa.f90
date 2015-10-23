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
  use benchmarking
  use date_utils
use netcdf
implicit none
 integer :: i
 integer :: j
 integer :: t
 real :: undef
 integer :: ncid_in
 integer :: ncid_out
 integer :: lonId
 integer :: latId
 integer :: levId
 integer :: timeId
 integer :: varid_in
 integer :: varid_out
 character(len=255) :: output
 character(len=255) :: input
 integer, parameter :: lonIn=625
 integer, parameter :: latIn=320
 integer, parameter :: levIn=15
 integer, parameter :: timeIn=25
 real(kind=8), dimension(lonIn) :: lon_input
 real(kind=8), dimension(latIn) :: lat_input
 real, dimension(levIn) :: lev_input
 real(kind=8), dimension(timeIn) :: time_input
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
 real, dimension(lonIn,latIn,levIn,timeIn) :: ttend
 real, dimension(lonIn,latIn,levIn,timeIn) :: temp
 real, dimension(lonIn,latIn,levIn,timeIn) :: rh
 real, dimension(lonIn,latIn,timeIn) :: temp2m
 real, dimension(lonIn,latIn,timeIn) :: wdir
 real, dimension(lonIn,latIn,timeIn) :: wmag
 real, dimension(lonIn,latIn,timeIn) :: aod
 real, dimension(lonIn,latIn,timeIn) :: dustmass
 real, dimension(lonIn,latIn,timeIn) :: dswf
 real, dimension(lonIn,latIn,timeIn) :: dlwf
 integer :: tempId
 integer :: temp2mId
 integer :: rhId
 integer :: wdirId
 integer :: wmagId
 integer :: ttendId
 integer :: aodId
 integer :: dustmassId
 integer :: dswfId
 integer :: dlwfId
 character(*), parameter :: institution='Barcelona Supercomputing Center' !ECMWF, Japan Meteorological Agency, Météo France, NASA/Goddard, NCEP, NOAA
 character(*), parameter :: comments='Dust storm on April 18, 2012. Forecast with no aerosol interaction.' !Case and Subcase
 character(*), parameter :: dir='/stornext/online8/exp-dmd/aerosols/bsc/dust'
 character(*), parameter :: subcase='noaerosols'
 character(len=15)  :: date_string
 character(len=12)  :: grads_date
 type(Date)          :: period
 type(GregorianDate) :: date_current, date_start, date_end

  !gerador de datas
  date_start = GregorianDate(2012, 4, 13, 0, 0, 0)
  date_end   = GregorianDate(2012, 4, 23, 0, 0, 0)
  call makeDate(date_start, date_end, period)
  
  ! Loop through the period with 3-hour increments.
  do while (.not. period%iterationOver)
    ! Format the current date to strings matching IS and GrADS formats.
    date_string = formatDate(getCurrentDate(period))
    grads_date  = gradsDate (getCurrentDate(period))

		print*, trim(date_string)
    
    !nome de arquivp de entrada e saida
    output='bsc_'//trim(subcase)//'_'//date_string(1:4)//date_string(6:7)//date_string(9:10)//'.nc'

    input=trim(dir)//'/'//trim(subcase)//'/'//'bsc_'//trim(subcase)//'_'//date_string(1:4)//date_string(6:7)//date_string(9:10)//'_reg.nc'

		!cria arquivo de saida e abre arquivo de entrada
		print*, "CRIANDO ARQUIVO"
		call check(nf90_create(trim(output), NF90_CLOBBER, ncid_out))
		call check(nf90_open(trim(input), NF90_NOWRITE, ncid_in)) !abertura do dado 


		!cria dimensões e faz a leitura das variaveis de dimensões do diretóeio base

		print*, "CRIANDO ATRIBUTOS DIMENSÃO"
		!LONGITUDE
		call check(nf90_inq_varid(ncid_in, 'lon', varId_in))               !extrai valor original de longitude do arquivo
		call check(nf90_get_var(ncid_in, varId_in, lon_input)) 
		call check(nf90_def_dim(ncid_out,'lon', lonIn, lonOut))      
		call check(nf90_def_var(ncid_out, 'lon', NF90_REAL, lonOut, lonId))

		call check(nf90_put_att(ncid_out, lonId, 'standard_name', 'lon'))
		call check(nf90_put_att(ncid_out, lonId, 'long_name', 'longitude'))
		call check(nf90_put_att(ncid_out, lonId, 'units', 'degrees'))
		call check(nf90_put_att(ncid_out, lonId, 'axis', 'X'))


		!LATITUDE
		call check(nf90_inq_varid(ncid_in, 'lat', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, lat_input))
		call check(nf90_def_dim(ncid_out,'lat', latIn, latOut))
		call check(nf90_def_var(ncid_out, 'lat', NF90_REAL, latOut, latId))

		call check(nf90_put_att(ncid_out, latId, 'standard_name', 'lat'))
		call check(nf90_put_att(ncid_out, latId, 'long_name', 'latitude'))
		call check(nf90_put_att(ncid_out, latId, 'units', 'degrees'))
		call check(nf90_put_att(ncid_out, latId, 'axis', 'Y'))


		!NIVEIS
		call check(nf90_inq_varid(ncid_in, 'pres', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, lev_input))
		call check(nf90_def_dim(ncid_out, 'lev', levIn, levOut))
		call check( nf90_def_var(ncid_out, 'lev', NF90_REAL, levOut, levId))

		call check(nf90_put_att(ncid_out, levId, 'standard_name', 'lev'))
		call check(nf90_put_att(ncid_out, levId, 'long_name', 'levels'))
		call check(nf90_put_att(ncid_out, levId, 'units', 'hPa'))
		call check(nf90_put_att(ncid_out, levId, 'axis', 'Z'))

		!TEMPO
		call check(nf90_inq_varid(ncid_in, 'time', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, time_input))
		call check(nf90_def_dim(ncid_out, 'time', timeIn, timeOut))
		call check(nf90_def_var(ncid_out, 'time', NF90_REAL, timeOut, timeId))

		call check(nf90_put_att(ncid_out, timeId, 'long_name', 'time'))
		call check(nf90_put_att(ncid_out, timeId, 'standard_name', 'time'))

		call check( nf90_get_att(ncid_in, varid_in,'units', units)) !captura valor da unidade de tempo

		call check(nf90_put_att(ncid_out, timeId, 'units', trim(units)))
		call check(nf90_put_att(ncid_out, timeId, 'calendar', 'standard'))


!###################################################################################################
		!criando variaveis e adicionando valores

		print*, "CRIANDO ATRIBUTOS DE VARIAVEIS 2D"
		!VARIAVEL 3D   -> TIME, LAT, LON

		!TEMPERATURA 2 METROS


		call check(nf90_inq_varid(ncid_in,'t2', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, temp2m))     !Extração e gravação de dado de temperatura a 2 metros na bariavel temp2m
		call check(nf90_get_att(ncid_in, varId_in,"_FillValue", undef))
		call check(nf90_def_var(ncid_out, 'temp2m', NF90_REAL, (/lonId, latId, timeId/), temp2mId))

		call check(nf90_put_att(ncid_out, temp2mId, 'standard_name', 'temp2m'))
		call check(nf90_put_att(ncid_out, temp2mId, 'long_name', 'temperature at 2m'))
		call check(nf90_put_att(ncid_out, temp2mId, 'units', 'K'))
		call check(nf90_put_att(ncid_out, temp2mId, '_FillValue', undef))
		call check(nf90_put_att(ncid_out, temp2mId, 'coordinates', 'time, lat, lon'))

		!WDIR

		call check(nf90_inq_varid(ncid_in,'dir10', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, wdir))
		call check(nf90_def_var(ncid_out, 'wdir', NF90_REAL, (/lonId, latId, timeId/), wdirId))

		call check(nf90_put_att(ncid_out, wdirId, 'standard_name', 'wdir'))
		call check(nf90_put_att(ncid_out, wdirId, 'long_name', 'wind direction at 10m'))
		call check(nf90_put_att(ncid_out, wdirId, 'units', 'degrees'))
		call check(nf90_put_att(ncid_out, wdirId, '_FillValue', undef))
		call check(nf90_put_att(ncid_out, wdirId, 'coordinates', 'time, lat, lon'))

		!WMAG

		call check(nf90_inq_varid(ncid_in,'spd10', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, wmag))
		call check(nf90_def_var(ncid_out, 'wmag', NF90_REAL, (/lonId, latId, timeId/), wmagId))

		call check(nf90_put_att(ncid_out, wmagId, 'standard_name', 'wmag'))
		call check(nf90_put_att(ncid_out, wmagId, 'long_name', 'wind magnitude at 10m'))
		call check(nf90_put_att(ncid_out, wmagId, 'units', 'degrees'))
		call check(nf90_put_att(ncid_out, wmagId, '_FillValue', undef))
		call check(nf90_put_att(ncid_out, wmagId, 'coordinates', 'time, lat, lon'))

		!AOD

		call check(nf90_inq_varid(ncid_in,'dust_aod_550', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, aod))
		call check(nf90_def_var(ncid_out, 'aod', NF90_REAL, (/lonId, latId, timeId/), aodId))

		call check(nf90_put_att(ncid_out, aodId, 'standard_name', 'aod'))
		call check(nf90_put_att(ncid_out, aodId, 'long_name', 'aerosol optical depth at 550nm'))
		call check(nf90_put_att(ncid_out, aodId, 'units', '-'))
		call check(nf90_put_att(ncid_out, aodId, '_FillValue', undef))
		call check(nf90_put_att(ncid_out, aodId, 'coordinates', 'time, lat, lon'))


		!DUST

		call check(nf90_inq_varid(ncid_in,'dust_load', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, dustmass))
		call check(nf90_def_var(ncid_out, 'dustmass', NF90_REAL, (/lonId, latId, timeId/), dustmassId))

		call check(nf90_put_att(ncid_out, dustmassId, 'standard_name', 'dustmass'))
		call check(nf90_put_att(ncid_out, dustmassId, 'long_name', 'dust aerosol mass column integrated'))
		call check(nf90_put_att(ncid_out, dustmassId, 'units', 'g/m^2'))
		call check(nf90_put_att(ncid_out, dustmassId, '_FillValue', undef))
		call check(nf90_put_att(ncid_out, dustmassId, 'coordinates', 'time, lat, lon'))


		!DSWF
		call check(nf90_inq_varid(ncid_in,'rswin', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, dswf))
		call check(nf90_def_var(ncid_out, 'dswf', NF90_REAL, (/lonId, latId, timeId/), dswfId))

		call check(nf90_put_att(ncid_out, dswfId, 'standard_name', 'dswf'))
		call check(nf90_put_att(ncid_out, dswfId, 'long_name', 'shortwave downwelling radiative flux at the surface'))
		call check(nf90_put_att(ncid_out, dswfId, 'units', 'W/m^2'))
		call check(nf90_put_att(ncid_out, dswfId, '_FillValue', undef))
		call check(nf90_put_att(ncid_out, dswfId, 'coordinates', 'time, lat, lon'))

		!DLWF
		call check(nf90_inq_varid(ncid_in,'rlwin', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, dlwf))
		call check(nf90_def_var(ncid_out, 'dlwf', NF90_REAL, (/lonId, latId, timeId/), dlwfId))

		call check(nf90_put_att(ncid_out, dlwfId, 'standard_name', 'dswf'))
		call check(nf90_put_att(ncid_out, dlwfId, 'long_name', 'longwave downwelling radiative flux at the surface'))
		call check(nf90_put_att(ncid_out, dlwfId, 'units', 'W/m^2'))
		call check(nf90_put_att(ncid_out, dlwfId, '_FillValue', undef))
		call check(nf90_put_att(ncid_out, dlwfId, 'coordinates', 'time, lat, lon'))




		print*, "CRIANDO ATRIBUTOS DE VARIAVEIS 3D"
		!VARIAVEL 4D   -> TIME, LEV, LAT, LON

		!TENDENCIA
		call check(nf90_inq_varid(ncid_in,'rtt', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, ttend))
		call check(nf90_def_var(ncid_out, 'ttend', NF90_REAL, (/lonId, latId, levId, timeId/), ttendId))

		call check(nf90_put_att(ncid_out, ttendId, 'standard_name', 'ttend'))
		call check(nf90_put_att(ncid_out, ttendId, 'long_name', 'temperature tendency associated to the total radiative flux divergence'))
		call check(nf90_put_att(ncid_out, ttendId, 'units', 'K/s'))
		call check(nf90_put_att(ncid_out, ttendId, '_FillValue', undef))
		call check(nf90_put_att(ncid_out, ttendId, 'coordinates', 'time, lev, lat, lon'))

		!TEMPERATURA
		call check(nf90_inq_varid(ncid_in,'tsl', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, temp))
		call check(nf90_def_var(ncid_out, 'temp', NF90_REAL, (/lonId, latId, levId, timeId/), tempId))

		call check(nf90_put_att(ncid_out, tempId, 'standard_name', 'temp'))
		call check(nf90_put_att(ncid_out, tempId, 'long_name', 'temperature'))
		call check(nf90_put_att(ncid_out, tempId, 'units', 'K'))
		call check(nf90_put_att(ncid_out, tempId, '_FillValue', undef))
		call check(nf90_put_att(ncid_out, tempId, 'coordinates', 'time, lev, lat, lon'))

		!UMIDADE RELATIVA
		call check(nf90_inq_varid(ncid_in,'rh', varId_in))
		call check(nf90_get_var(ncid_in, varId_in, rh))
		call check(nf90_def_var(ncid_out, 'rh', NF90_REAL, (/lonId, latId, levId, timeId/), rhId))

		call check(nf90_put_att(ncid_out, rhId, 'standard_name', 'rh'))
		call check(nf90_put_att(ncid_out, rhId, 'long_name', 'relative humidity'))
		call check(nf90_put_att(ncid_out, rhId, 'units', '-'))
		call check(nf90_put_att(ncid_out, rhId, '_FillValue', undef))
		call check(nf90_put_att(ncid_out, rhId, 'coordinates', 'time, lev, lat, lon'))


!##############################################################################################
		!atributos globais do arquivo (status-completo)
		print*, "CRIANDO ATRIBUTOS GLOBAIS"

		call check(nf90_put_att(ncid_out, nf90_global, "Conventions", "CF-1.6"))

		call check( nf90_get_att(ncid_in, nf90_global,"title", title))
		call check(nf90_put_att(ncid_out, nf90_global, "title", trim(title)))

		call check(nf90_put_att(ncid_out, nf90_global, "institution", trim(institution)))

		call check(nf90_get_att(ncid_in, nf90_global,"History", history))
		call check(nf90_put_att(ncid_out, nf90_global, "history", trim(history)))

		call check(nf90_put_att(ncid_out, nf90_global, "comments", trim(comments)))

!########################################################################################

		!Finaliza definição de variaveis
		call check(nf90_enddef(ncid_out))

!##########################################################################################
		!gravando dados nas variavel
		print*, "ESCREVENDO VARIVEIS DE DIMENSÃO"
		call check(nf90_put_var(ncid_out, lonId, lon_input))
		call check(nf90_put_var(ncid_out, latId, lat_input))
		call check(nf90_put_var(ncid_out, levId, lev_input))
		call check(nf90_put_var(ncid_out,timeId, time_input))
!#############################################################################################
		!Escrevendo variaveis no arquvo
		print*, "ESCREVENDO VARIVEIS 2D"

		call check(nf90_put_var(ncid_out,temp2mId, temp2m))
		call check(nf90_put_var(ncid_out,wdirId, wdir))
		call check(nf90_put_var(ncid_out,wmagId, wmag))
		call check(nf90_put_var(ncid_out,aodId, aod))

		where(dustmass .ne. undef)
				dustmass(:,:,:)=dustmass(:,:,:)*1000
		end where
		call check(nf90_put_var(ncid_out,dustmassId,dustmass ))
		call check(nf90_put_var(ncid_out,dswfId, dswf))
		call check(nf90_put_var(ncid_out,dlwfId, dlwf))

		print*, "ESCREVENDO VARIVEIS 3D"

		call check(nf90_put_var(ncid_out,ttendId, ttend))
		call check(nf90_put_var(ncid_out,tempId, temp))
		call check(nf90_put_var(ncid_out,rhId, rh))
!############################################################################################
		!fecha os arquivos
		print*, "FECHANDO O ARQUIVO"

		call check(nf90_close(ncid_in))
		call check(nf90_close(ncid_out))

   	call incrementBySeconds(24*3600, period) ! (3*3600, period)saida a cada 3 horas    (24*3600, period)=> saida a diaria
  enddo

!caminho dos dados originais do meteofrance
!/scratchin/grupos/catt-brams/home/mauricio.zarzur/WGNE/meteofrance/output_dust/r00

end program create_netcdf

!subrotina 
subroutine check(status)
use netcdf
implicit none
	integer, intent (in) :: status

		if(status /= nf90_noerr) then
  		print *, trim(nf90_strerror(status))
  		stop "Stopped"
		end if
end subroutine check
