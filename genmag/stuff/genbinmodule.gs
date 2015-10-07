
************* MODULO geracao BINARIOS

function ztRange()
  'q file'
  tmp = sublin ( result, 5 )
  _zmin = 1
  _zmax = subwrd(tmp,9)
  _tmin = 1
  _tmax = subwrd(tmp,12)
return

function graFromNetCdf(filepattern,filein,fileext,magExp,outputDir)
  fileout=outputDir'/mag_'filepattern'gra'
  msg('tentando remover arquivo grads 'fileout'...')
  '!rm 'fileout
  
  msg('abrindo arquivo NETCDF 'filein'...')
  'sdfopen 'filein
  'set gxout fwrite'
  'set fwrite 'fileout
  rc = ztRange()
  t=1
  msg('gerando '_tmax' tempos')
  while(t<=_tmax)
    'set t 't
    'd 'magExp
    t=t+1
  endwhile
  'disable fwrite'
  'close 1'
  msg('Arquivo grads gerado com sucesso!')
return

function graFromH5(filepattern,filein,fileext,magExp)
  fileout=outputDir'/mag_'filepattern'gra'
  msg('tentando remover arquivo grads 'fileout'...')
  '!rm 'fileout

  filectloriginal=substr(filepattern,1,22)'.ctl'
  newctl=substr(filepattern,1,math_strlen(filepattern)-1)'.ctl'
  msg('filectloriginal = 'filectloriginal
  msg('newctl='newctl)
  msg('abrindo arquivo H5 'filein'...')
  msg('tentando remover arquivo ctl intermediário (00h) 'newctl'...')
  '!rm 'newctl
  
  'open 'filectloriginal
  'set gxout print'
  'set prnopts %s 1 1'
  'q ctlinfo'
  resultaux=result
  pull pausee
  msg('gerando arquivo ctl intermediário (00h) 'newctl'...')
  tmp = 'dset 'filein
  write(newctl,tmp)
  pull pausee
  i=2
  while(i<200)*200 pra nao colocar while true
    tmp = sublin ( resultaux, i )
    write(newctl,tmp)
    pull pausee
    if(substr(tmp,1,7)='endvars')
      break
    endif
    i= i + 1
  endwhile
  close(newctl)
  'set gxout shaded'
  'close 1'

  'open 'newctl
  'set gxout fwrite'
  'set fwrite 'fileout
  rc = ztRange()
  t=1
  msg('gerando '_tmax' tempos')
  while(t<=_tmax)
    'set t 't
    'd 'magExp
    t=t+1
  endwhile
  'disable fwrite'
  'close 1'
  msg('Arquivo grads gerado com sucesso!')
return

********* geracao CTLS

function initCtlGen(filein,filectlout)
  msg('abrindo arquivo 'filein'...')
  'sdfopen 'filein
  msg('tentando remover arquivo ctl 'filectlout'...')
  '!rm 'filectlout
  'set gxout print'
  'set prnopts %s 1 1'
  'q ctlinfo'
return result


function ctlFromNetcdf(filepattern,filein,outputDir)
  filectlout=outputDir'/mag_'filepattern'ctl'
  resultaux=initCtlGen(filein,filectlout)
  
  tmp = sublin ( resultaux, 1 )
  tmp = 'dset ^mag_'filepattern'gra'
  write(filectlout,tmp)
  
  tmp = sublin ( resultaux, 2 )
  write(filectlout,tmp)
  tmp = sublin ( resultaux, 3 )
  write(filectlout,tmp)
  tmp = sublin ( resultaux, 5 )
  write(filectlout,tmp)
  tmp = sublin ( resultaux, 6 )
  write(filectlout,tmp)
  tmp = sublin ( resultaux, 7 )
  write(filectlout,tmp)
  tmp = sublin ( resultaux, 8 )
  write(filectlout,tmp)
  tmp='vars 1'
  write(filectlout,tmp)
  tmp='wmag  1 99  10 metre magnitude wind'
  write(filectlout,tmp)
  tmp='endvars'
  write(filectlout,tmp)
  close(filectlout)
  'set gxout shaded'
  'close 1'

return filectlout

function ctlFromHdf5(filepattern,filein,outputDir)
  filectlout=outputDir'/'filepattern'ctl'
  resultaux=initCtlGen(filein,filectlout)

  tmp = sublin ( resultaux, 1 )
  tmp = 'dset ^mag_'filepattern'gra'
  write(filectlout,tmp)
  
  i=2
  while(i<100)*100 pra nao colocar while true
    tmp = sublin ( resultaux, i )
    if(substr(tmp,1,4)='vars')
      break
    endif
    write(filectlout,tmp)
  endwhile

  tmp='vars 1'
  write(filectlout,tmp)
  tmp='wmag  1 99  10 metre magnitude wind'
  write(filectlout,tmp)
  tmp='endvars'
  write(filectlout,tmp)

  close(filectlout)
  'set gxout shaded'
  'close 1'

return filectlout




* novo ctl - formato

*dset ^ecmwf_2d_direct_20120905.gra
*title 
*undef -9.99e+33
*xdef 720 linear -180 0.5
*ydef 361 linear -90 0.5
*zdef 1 levels 0
*tdef 81 linear 00Z05SEP2012 180mn
*vars 1
*wmag  1 99  10 metre magnitude wind
*endvars

*q ctlinfo

*dset nasa_2d_20120413_00.nc
*title 
*undef 1e+15
*dtype netcdf
*xdef 193 linear 0 0.3125
*ydef 201 linear 0 0.25
*zdef 1 linear 0 1
*tdef 81 linear 00Z13APR2012 180mn
*vars 14


*ga-> q ctlinfo
*dset meteofrance_2012042312_%y4%m2%d2%h2.h5
*title ALADIN_DUST
*undef 1e+20
*xdef 340 linear 18.135 0.07
*ydef 340 linear 13.135 0.07
*zdef 15 levels 1000 975 950 900 850 800 750 700
* 600 500 400 300 200 100 50
*tdef 17 linear 12Z23APR2012 180mn
*vars 10
*/AOD=>aod  0  z,y,x  Aerosol Optical Depth at 550nm
*/HUM=>hum  15  z,y,x  Relative Humidity
*/MASSINTEG=>massinteg  0  z,y,x  Dust Aerosol Mass Column Integrated
*/SURFRAYSOL=>surfraysol  0  z,y,x  Shortwave Downwelling Radiative Flux at the Surface
*/SURFRAYTHR=>surfraythr  0  z,y,x  Longwave Downwelling Radiative Flux at the Surface
*/SURFTEMP=>surftemp  0  z,y,x  Temperature at 2m
*/TEMP=>temp  15  z,y,x  Temperature
*/TTENDRAD=>ttendrad  15  z,y,x  Temperature Tendency Associated to Total Radiative Flux Divergence
*/ZWIND=>zwind  0  z,y,x  Zonal Wind at 10m
*/MWIND=>mwind  0  z,y,x  Meridional Wind at 10m
*endvars
