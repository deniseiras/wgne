*args: partipicant case minuend subtrahend variable level year month day hour forecast
'reinit'
'set mpdset hires'
'set display color white'
'c'

directory='/rede/tupa_expdmd/aerosols'

* Participant's name.
model=subwrd(str,1)
* Study case and subcase.
mcase=subwrd(str,2)
minuend=subwrd(str,3)
subtrahend=subwrd(str,4)
* Variable name and vertical level.
var=subwrd(str,5)
vlvl=subwrd(str,6)
* Forecast date.
yy=subwrd(str,7)
mm=subwrd(str,8)
dd=subwrd(str,9)
hh=subwrd(str,10)
* Elapsed hours since start.
fct=subwrd(str,11)
* Custom scale parameters.
scale=subwrd(str,12)
minvalue=subwrd(str,13)
maxvalue=subwrd(str,14)
interval=subwrd(str,15)

if (mcase=smoke); 'set mpdset brmap_hires'; endif

* Set up the filename.
if (model=bsc)
  modeltitle='BSC'
  'sdfopen 'directory'/bsc/'mcase'/'minuend'/bsc_'minuend'_'yy''mm''dd'_reg.nc'
  'sdfopen 'directory'/bsc/'mcase'/'subtrahend'/bsc_'subtrahend'_'yy''mm''dd'_reg.nc'
endif

if (model=ecmwf)
  modeltitle='ECMWF'
  if (var=temp | var=rh | var=ttend)
    'sdfopen 'directory'/ecmwf/'mcase'/'minuend'/ecmwf_3d_'minuend'_'yy''mm''dd'.nc'
    'sdfopen 'directory'/ecmwf/'mcase'/'subtrahend'/ecmwf_3d_'subtrahend'_'yy''mm''dd'.nc'
  else
    'sdfopen 'directory'/ecmwf/'mcase'/'minuend'/ecmwf_2d_'minuend'_'yy''mm''dd'.nc'
    'sdfopen 'directory'/ecmwf/'mcase'/'subtrahend'/ecmwf_2d_'subtrahend'_'yy''mm''dd'.nc'
  endif
endif

if (model=jma)
  modeltitle='JMA'
  if (var=prec)
    'sdfopen 'directory'/jma/'mcase'/'minuend'/jma_conv_'yy''mm''dd''hh'.nc'
    'sdfopen 'directory'/jma/'mcase'/'subtrahend'/jma_conv_'yy''mm''dd''hh'.nc'
    'sdfopen 'directory'/jma/'mcase'/'minuend'/jma_lsp_'yy''mm''dd''hh'.nc'
    'sdfopen 'directory'/jma/'mcase'/'subtrahend'/jma_lsp_'yy''mm''dd''hh'.nc'
  else
    'sdfopen 'directory'/jma/'mcase'/'minuend'/jma_'var'_'yy''mm''dd''hh'.nc'
    'sdfopen 'directory'/jma/'mcase'/'subtrahend'/jma_'var'_'yy''mm''dd''hh'.nc'
  endif
endif

if (model=meteofrance)
  modeltitle='Meteo France'
  'open 'directory'/meteofrance/'mcase'/'minuend'/meteofrance_'yy''mm''dd''hh'.ctl'
  'open 'directory'/meteofrance/'mcase'/'subtrahend'/meteofrance_'yy''mm''dd''hh'.ctl'
endif

if (model=nasa)
  modeltitle='NASA'
  if (var=temp | var=rh | var=ttend)
    'sdfopen 'directory'/nasa/'mcase'/'minuend'/nasa_3d_'yy''mm''dd'_'hh'.nc'
    'sdfopen 'directory'/nasa/'mcase'/'subtrahend'/nasa_3d_'yy''mm''dd'_'hh'.nc'
  else
    'sdfopen 'directory'/nasa/'mcase'/'minuend'/nasa_2d_'yy''mm''dd'_'hh'.nc'
    'sdfopen 'directory'/nasa/'mcase'/'subtrahend'/nasa_2d_'yy''mm''dd'_'hh'.nc'
  endif
endif

if (model=ncep)
  modeltitle='NCEP'
  if (var=aod)
    'open 'directory'/ncep/'mcase'/'minuend'/'yy''mm''dd''hh'/aodf'yy''mm''dd''hh'.ctl'
    'open 'directory'/ncep/'mcase'/'subtrahend'/'yy''mm''dd''hh'/aodf'yy''mm''dd''hh'.ctl'
  else
    'open 'directory'/ncep/'mcase'/'minuend'/'yy''mm''dd''hh'/pgbf'yy''mm''dd''hh'.ctl'
    'open 'directory'/ncep/'mcase'/'subtrahend'/'yy''mm''dd''hh'/pgbf'yy''mm''dd''hh'.ctl'
  endif
endif

if (hh=12 & model!=meteofrance)
  'close 1'
  'close 2'
  'close 3'
  'close 4'
endif

* Set the time.
'set time 'fct

* Check for the presence of aerosols.
if (minuend=direct)
  aerom='DE'
endif
if (minuend=indirect)
  aerom='IE'
endif
if (minuend=interactive)
  aerom='IA'
endif
if (minuend=noaerosols)
  aerom='XA'
endif

if (subtrahend=direct)
  aeros='DE'
endif
if (subtrahend=indirect)
  aeros='IE'
endif
if (subtrahend=interactive)
  aeros='IA'
endif
if (subtrahend=noaerosols)
  aeros='XA'
endif

aerotitle='('aerom' - 'aeros')'

* Setting the grid boundaries.
if (mcase=dust)
  if (model=jma)
    ilon=0
    flon=59.625
    ilat=0.28081
    flat=49.7035
  else
    if (model=meteofrance)
      ilon=18.135
      flon=41.865 
      ilat=13.135
      flat=36.865
    else
      ilon=0
      flon=60
      ilat=0
      flat=50
    endif
  endif
* Meteo France grid is smaller.
* Remove these comments to plot all models in the same (smaller) grid.
*  ilon=18.135
*  flon=41.865 
*  ilat=13.135
*  flat=36.865
endif

if (mcase=pollution)
  if (model=jma)
    ilon=86.0625
    flon=145.688 
    ilat=10.39
    flat=69.9218
  else
    ilon=86
    flon=146
    ilat=10
    flat=70
  endif
endif

if (mcase=smoke)
  if (model=jma)
    ilon=270
    flon=329.625
    ilat=-39.5943
    flat=19.9376
  else
    ilon=270
    flon=330
    ilat=-40
    flat=20
  endif
endif

'set lat 'ilat' 'flat''
'set lon 'ilon' 'flon''

* Configure vertical level.
if(var=cloud | var=temp | var=rh | var=ttend)
  if (model=jma)
    'q file'
    maxlvl=sublin(result, 5)
    maxlvl=subwrd(maxlvl, 9)
    jlvl=maxlvl-vlvl+1
    'set z 'jlvl
  else
    'set z 'vlvl
  endif
  'q dims'
  presslev=sublin(result,   4)
  presslev=subwrd(presslev, 6)
endif

* Set up color and display options.
'set parea 1 7.5 1 10'
'set gxout shaded'
'set grads off'
'set grid off'
'set xlopts 1 4 0.15'
'set ylopts 1 4 0.15'

* Rainbow colors
* purple
'set rgb 20 51 0 102'
* dark purple
'set rgb 21 0 51 102'
* dark blue
'set rgb 22 51 51 204'
* medium blue
'set rgb 23 51 102 204'
* light blue
'set rgb 24 102 153 255'
* aqua
'set rgb 25 102 204 153'
* dark green
'set rgb 26 51 153 51'
* yellowish green
'set rgb 27  102 204 51'
* light yellow
'set rgb 28 255 204 51'
* dark yellow
'set rgb 29 204 153 0'
* orange
'set rgb 30 204 102 0'
* red
'set rgb 31 204 0 0'
* pink
'set rgb 32 204 51 102'
* dark pink
'set rgb 33 102 0 51'
* darkest green
'set rgb 34 0 51 0'
* darker green
'set rgb 35 51 102 0'
* dark red
'set rgb 36 102 0 0'
* dark orange
'set rgb 37 204 51 0'

* Assume variable doesn't exist.
vardisplay='none'

* Configure the output image's colors, levels and title according to the variable.
if (var=aod)
  vartitle='Aerosol Optical Depth at 550nm'
  unittitle=''
  cl='-1 -0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 1'
  cc='20 21 22 23 24 25 35 26 27 28 29 30 37 31 36 32'
endif

if (var=cloud)
  vartitle='Cloud Drop Number Concentration'
  unittitle='cm-3'
  cl='0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1'
  cc='20 22 23 25 26 27 28 29 30 31 32'
endif

if (var=conv)
  vartitle='Precipitation (from Convective Parametrization)'
  unittitle='mm'
  cl='-4 -3 -2 -1.5 -1 -0.5  0 0.5  1 1.5  2  3 4'
  cc='20 21 22 24 25 35 26 27 28 29 30 31 36 32'
endif

if (var=dlwf)
  vartitle='Longwave Downwelling Radiative Flux at the Surface'
  unittitle='W/m^2'
  cl='-20 -15 -10 -7.5 -5 -2.5 0 2.5 5 7.5 10 15 20'
  cc='20 21 22 24 25 35 26 27 28 29 30 31 36 32'
endif

if (var=dswf)
  vartitle='Shortwave Downwelling Radiative Flux at the Surface'
  unittitle='W/m^2'
  cl='-20 -15 -10 -7.5 -5 -2.5 0 2.5 5 7.5 10 15 20'
  cc='20 21 22 24 25 35 26 27 28 29 30 31 36 32'
endif

if (var=aeromass)
  vartitle='Total Aerosol Mass Column Integrated'
  unittitle='g/m^2'
  cl='-0.05 -0.04 -0.03 -0.02 -0.01 0 0.01 0.02 0.03 0.04 0.05'
  cc='20 21 22 23 25 26 27 28 29 30 31 32'
endif

if (var=dustmass)
  vartitle='Dust Aerosol Mass Column Integrated'
  unittitle='g/m^2'
  cl='-0.05 -0.04 -0.03 -0.02 -0.01 0 0.01 0.02 0.03 0.04 0.05'
  cc='20 21 22 23 25 26 27 28 29 30 31 32'
endif

if (var=prec)
  vartitle='Total Precipitation'
  unittitle='mm'
  cl='-4 -3 -2 -1.5 -1 -0.5  0 0.5  1 1.5  2  3 4'
  cc='20 21 22 24 25 35 26 27 28 29 30 31 36 32'
endif

if (var=rh)
  vartitle='Relative Humidity'
  unittitle='%'
  cl='-4 -3 -2 -1.5 -1 -0.5  0 0.5  1 1.5  2  3 4'
  cc='20 21 22 24 25 35 26 27 28 29 30 31 36 32'
endif

if (var=temp)
  vartitle='Temperature'
  unittitle='K'
  cl='-4 -3 -2 -1.5 -1 -0.5  0 0.5  1 1.5  2  3 4'
  cc='20 21 22 24 25 35 26 27 28 29 30 31 36 32'  
endif

if (var=temp2m)
  vartitle='Temperature at 2m'
  unittitle='K'
  cl='-4 -3 -2 -1.5 -1 -0.5  0 0.5  1 1.5  2  3 4'
  cc='20 21 22 24 25 35 26 27 28 29 30 31 36 32'
endif

if (var=ttend)
  vartitle='Temperature Tendency Associated to Radiative Flux'
  unittitle='K/s'
  cl='-0.3 -0.25 -0.15 -0.1 -0.05 0 0.05 0.1 0.15 0.2 0.25 0.3'
  cc='20 21 22 23 24 25 26 27 28 29 30 31 32'
endif

if (var=wdir)
  vartitle='Wind Direction at 10m'
  unittitle='degrees'
  cl='-4 -3 -2 -1.5 -1 -0.5  0 0.5  1 1.5  2  3 4'
  cc='20 21 22 24 25 35 26 27 28 29 30 31 36 32'
*  wdir = (180/3.14159) * atan2(u,v) + 180
endif

if (var=wmag)
  vartitle='Wind Magnitude at 10m'
  unittitle='m/s'
  cl='-4 -3 -2 -1.5 -1 -0.5  0 0.5  1 1.5  2  3 4'
  cc='20 21 22 24 25 35 26 27 28 29 30 31 36 32'
endif

*******************************************************************************
* Define the output variable.
if (var=aod)
  if (model=bsc); vardisplay='dust_aod_550 - dust_aod_550.2'; endif
  if (model=ecmwf & mcase=dust); vardisplay='duaod550 - duaod550.2'; endif
  if (model=ecmwf & mcase=pollution)
    vardisplay='omaod550+bcaod550+suaod550-omaod550.2-bcaod550.2-suaod550.2'
  endif
  if (model=ecmwf & mcase=smoke)
    vardisplay='omaod550+bcaod550-omaod550.2-bcaod550.2'
  endif
  if (model=jma); vardisplay='od550aer - od550aer.2' ; endif
  if (model=nasa); vardisplay='totexttau - totexttau.2' ; endif
  if (model=ncep); vardisplay='aod - aod.2' ; endif
endif

if (var=cloud)
endif

if (var=conv)
  if (model=ecmwf)
    'define cp1=(cp-cp(t-1))*1000'
    'define cp2=(cp.2-cp.2(t-1))*1000'
    vardisplay='cp1 - cp2'
  endif
  if (model=jma); vardisplay='3*3600*(ppci - ppci.2)'; endif
  if (model=nasa); vardisplay='(preccon - preccon.2)*3*3600' ; endif
  if (model=ncep); vardisplay='conv - conv.2' ; endif
endif

if (var=dlwf)
  if (model=bsc); vardisplay='rlwin - rlwin.2'; endif
  if (model=ecmwf)
    'define dlwf1=(strd - strd(t-1))/10800'
    'define dlwf2=(strd.2 - strd.2(t-1))/10800'
    vardisplay='dlwf1 - dlwf2'
  endif
  if (model=jma); vardisplay='dlwb - dlwb.2' ; endif
  if (model=meteofrance)
    'define dlwf1=(surfraythr - surfraythr(t-1))/10800'
    'define dlwf2=(surfraythr.2 - surfraythr.2(t-1))/10800'
    vardisplay='dlwf1 - dlwf2'
  endif
  if (model=nasa); vardisplay='lwgnt*(-1) - lwgnt.2*(-1)'; endif
  if (model=ncep); vardisplay='dlwf - dlwf.2' ; endif
endif

if (var=dswf)
  if (model=bsc); vardisplay='rswin - rswin.2'; endif
  if (model=ecmwf)
    'define dswf1=(ssrd - ssrd(t-1))/10800'
    'define dswf2=(ssrd.2 - ssrd.2(t-1))/10800'
    vardisplay='dswf1 - dswf2'
  endif
  if (model=jma); vardisplay='dswb - dswb.2' ; endif
  if (model=meteofrance)
    'define dswf1=(surfraysol - surfraysol(t-1))/10800'
    'define dswf2=(surfraysol.2 - surfraysol.2(t-1))/10800'
    vardisplay='dswf1 - dswf2'
  endif
  if (model=nasa); vardisplay='swgnt - swgnt.2' ; endif
  if (model=ncep); vardisplay='dswf - dswf.2' ; endif
endif

if (var=aeromass)
  if (model=jma); vardisplay='(loadaer - loadaer.2)*1000' ; endif
  if (model=nasa)
    'define aeromass1=bccmass+ducmass+occmass+so4cmass+sscmass'
    'define aeromass2=bccmass.2+ducmass.2+occmass.2+so4cmass.2+sscmass.2'
    vardisplay='(aeromass1-aeromass2)*1000'
  endif
endif

if (var=bcmass)
  if (model=nasa); vardisplay='(bccmass-bccmass.2)*1000'; endif
endif

if (var=ocmass)
  if (model=nasa); vardisplay='(occmass-occmass.2)*1000'; endif
endif

if (var=so4mass)
  if (model=nasa); vardisplay='(so4cmass-so4cmass.2)*1000'; endif
endif

if (var=saltmass)
  if (model=nasa); vardisplay='(sscmass-sscmass.2)*1000'; endif
endif

if (var=dustmass)
  if (model=bsc); vardisplay='(dust_load - dust_load.2)*1000'; endif
  if (model=jma); vardisplay='(loaddust - loaddust.2)*1000' ; endif
  if (model=nasa); vardisplay='(ducmass - ducmass.2)*1000' ; endif
endif

if (var=prec)
  if (model=ecmwf)
    'define prec1=(cp-cp(t-1)+lsp-lsp(t-1))*1000'
    'define prec2=(cp.2-cp.2(t-1)+lsp.2-lsp.2(t-1))*1000'
    vardisplay='prec1 - prec2'
  endif
  if (model=jma); vardisplay='3*3600*(ppci + ppli.3 - ppci.2 -ppli.4)'; endif
  if (model=nasa); vardisplay='(prectot - prectot.2)*3*3600' ; endif
  if (model=ncep); vardisplay='prec - prec.2' ; endif
endif

if (var=rh)
  if (model=bsc); vardisplay='100*(rh - rh.2)'; endif
  if (model=ecmwf); vardisplay='r - r.2'; endif
  if (model=jma); vardisplay='rh - rh.2' ; endif
  if (model=meteofrance); vardisplay='100*(HUM - HUM.2)'; endif
  if (model=nasa); vardisplay='rh - rh.2' ; endif
  if (model=ncep); vardisplay='rh - rh.2' ; endif
endif

if (var=temp)
  if (model=bsc); vardisplay='tsl - tsl.2'; endif
  if (model=ecmwf); vardisplay='t - t.2'; endif
  if (model=jma); vardisplay='t - t.2'; endif
  if (model=meteofrance); vardisplay='TEMP - TEMP.2'; endif
  if (model=nasa); vardisplay='t - t.2'; endif
  if (model=ncep); vardisplay='temp - temp.2'; endif  
endif

if (var=temp2m)
  if (model=bsc); vardisplay='t2 - t2.2'; endif
  if (model=ecmwf); vardisplay='v2t - v2t.2'; endif
  if (model=jma); vardisplay='ta - ta.2' ; endif
  if (model=meteofrance); vardisplay='SURFTEMP - SURFTEMP.2' ; endif
  if (model=nasa); vardisplay='t2m - t2m.2' ; endif
  if (model=ncep); vardisplay='temp2m - temp2m.2' ; endif
endif

if (var=ttend)
  if (model=bsc); vardisplay='rtt - rtt.2'; endif
  if (model=meteofrance); vardisplay='TTENDRAD - TTENDRAD.2' ; endif
  if (model=nasa); vardisplay='dtdtrad - dtdtrad.2' ; endif
  if (model=ncep); vardisplay='srh - srh.2'; endif
endif

if (var=wdir)
*  wdir = (180/3.14159) * atan2(u,v) + 180
  if (model=bsc); vardisplay='dir10 - dir10.2'; endif
  if (model=ecmwf)
    'define wdir1 = (180/3.14159) * atan2(v10u,v10v) + 180'
    'define wdir2 = (180/3.14159) * atan2(v10u.2,v10v.2) + 180'
    vardisplay='wdir1 - wdir2'
  endif
  if (model=jma); vardisplay='wdir - wdir.2'; endif
  if (model=meteofrance)
    'define wdir1 = (180/3.14159) * atan2(ZWIND,MWIND) + 180'
    'define wdir2 = (180/3.14159) * atan2(ZWIND.2,MWIND.2) + 180'
    vardisplay='wdir1 - wdir2'
  endif
  if (model=nasa)
    'define wdir1 = (180/3.14159) * atan2(u10m,v10m) + 180'
    'define wdir2 = (180/3.14159) * atan2(u10m.2,v10m.2) + 180'
    vardisplay='wdir1 - wdir2'
  endif
  if (model=ncep)
    'define wdir1 = (180/3.14159) * atan2(u10m,v10m) + 180'
    'define wdir2 = (180/3.14159) * atan2(u10m.2,v10m.2) + 180'
    vardisplay='wdir1 - wdir2'
  endif
endif

if (var=wmag)
  if (model=bsc); vardisplay='spd10 - spd10.2'; endif
  if (model=ecmwf); vardisplay='mag(v10u,v10v) - mag(v10u.2,v10v.2)'; endif
  if (model=jma); vardisplay='u10 - u10.2'; endif
  if (model=meteofrance); vardisplay='mag(ZWIND,MWIND) - mag(ZWIND.2,MWIND.2)'; endif
  if (model=nasa); vardisplay='mag(u10m,v10m) - mag(u10m.2,v10m.2)'; endif
  if (model=ncep); vardisplay='mag(u10m,v10m) - mag(u10m.2,v10m.2)'; endif
endif

* Check if a file was opened.
'q file'
test=subwrd(result, 1)

'q file 2'
test2=subwrd(result, 1)

* Create a custom scale if needed.
if (scale=custom)
  cl=''
  curvalue=minvalue

  while (curvalue < maxvalue)
    cl=cl' 'curvalue
    curvalue=curvalue+interval
  endwhile
  cl=cl' 'maxvalue
endif

* Create the image.
if (vardisplay='none' | test='No' | test2='No')
  'set string 1 c'
  'set strsiz 0.18'
  'draw string 4.25 5.5 FORECAST DATA UNAVAILABLE'
else
  'set gxout shaded'
  'set parea 0.5 8 1.5 9.5'
  'set clevs 'cl
  'set rbcols 'cc
  'd 'vardisplay
  'set strsiz 0.10'
  'cbarn'

  'set parea 0.5 8 1.5 9.5'
  'set string 1 tc'
  'set strsiz 0.18'
  'draw string 4.25 10.9 'vartitle
  'draw string 4.25 10.6 'modeltitle' 'aerotitle
  'draw string 4.25 10.1 Forecast: 'fct
  if (mm=01); mmm='JAN' ; endif
  if (mm=02); mmm='FEB' ; endif
  if (mm=03); mmm='MAR' ; endif
  if (mm=04); mmm='APR' ; endif
  if (mm=05); mmm='MAY' ; endif
  if (mm=06); mmm='JUN' ; endif
  if (mm=07); mmm='JUL' ; endif
  if (mm=08); mmm='AUG' ; endif
  if (mm=09); mmm='SEP' ; endif
  if (mm=10); mmm='OCT' ; endif
  if (mm=11); mmm='NOV' ; endif
  if (mm=12); mmm='DEC' ; endif
  'draw string 4.25 9.8 Started:  'hh'Z'dd''mmm''yy
  if (var=cloud | var=temp | var=rh | var=ttend)
    'draw string 4.25 1.2 Pressure Level: 'presslev'mb'
  endif
  'draw string 4.25 0.3 'unittitle
endif
