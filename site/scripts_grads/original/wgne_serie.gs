*args: partipicant case subcase variable level year month day hour lat lon
'reinit'
'set mpdset hires'
'set display color white'
'c'

directory='/rede/tupa_expdmd/aerosols'

* Participant's name.
model=subwrd(str,1)
* Study case and subcase.
mcase=subwrd(str,2)
scase=subwrd(str,3)
* Variable name and vertical level.
var=subwrd(str,4)
vlvl=subwrd(str,5)
* Forecast date.
yy=subwrd(str,6)
mm=subwrd(str,7)
dd=subwrd(str,8)
hh=subwrd(str,9)
* Coordinates.
fctlat=subwrd(str,10)
fctlon=subwrd(str,11)
* Custom scale parameters.
scale=subwrd(str,12)
minvalue=subwrd(str,13)
maxvalue=subwrd(str,14)
interval=subwrd(str,15)

if (mcase=smoke); 'set mpdset brmap_hires'; endif

* Set up the filename.
if (model=bsc)
  modeltitle='BSC'
  'sdfopen 'directory'/bsc/'mcase'/'scase'/bsc_'scase'_'yy''mm''dd'_reg.nc' 
endif

if (model=ecmwf)
  modeltitle='ECMWF'
  if (var=temp | var=rh | var=ttend)
    'sdfopen 'directory'/ecmwf/'mcase'/'scase'/ecmwf_3d_'scase'_'yy''mm''dd'.nc'
  else
    'sdfopen 'directory'/ecmwf/'mcase'/'scase'/ecmwf_2d_'scase'_'yy''mm''dd'.nc'
  endif
endif

if (model=jma)
  modeltitle='JMA'
  if (var=prec)
    'sdfopen 'directory'/jma/'mcase'/'scase'/jma_conv_'yy''mm''dd''hh'.nc'
    'sdfopen 'directory'/jma/'mcase'/'scase'/jma_lsp_'yy''mm''dd''hh'.nc'
  else
    'sdfopen 'directory'/jma/'mcase'/'scase'/jma_'var'_'yy''mm''dd''hh'.nc'
  endif
endif

if (model=meteofrance)
  modeltitle='Meteo France'
  'open 'directory'/meteofrance/'mcase'/'scase'/meteofrance_'yy''mm''dd''hh'.ctl' 
endif

if (model=ncep)
  modeltitle='NCEP'
  if (var=aod)
    'open 'directory'/ncep/'mcase'/'scase'/'yy''mm''dd''hh'/aodf'yy''mm''dd''hh'.ctl'
  else
    'open 'directory'/ncep/'mcase'/'scase'/'yy''mm''dd''hh'/pgbf'yy''mm''dd''hh'.ctl'
  endif
endif

if (model=nasa)
  modeltitle='NASA'
  if (var=temp | var=rh | var=ttend)
    'sdfopen 'directory'/nasa/'mcase'/'scase'/nasa_3d_'yy''mm''dd'_'hh'.nc'
  else
    'sdfopen 'directory'/nasa/'mcase'/'scase'/nasa_2d_'yy''mm''dd'_'hh'.nc'
  endif
endif

if (hh=12 & model!=meteofrance)
  'close 1'
  'close 2'
endif

'set t 1 last'

* Check for the presence of aerosols.
if (scase=direct)
  aero='direct'
  aerotitle='(direct effect only)'
endif
if (scase=indirect)
  aero='indirect'
  aerotitle='(indirect effect only)'
endif
if (scase=interactive)
  aero='aerosols'
  aerotitle='(with interactive aerosols)'
endif
if (scase=noaerosols)
  aero='noaerosols'
  aerotitle='(no aerosol interaction)'
endif

* Setting the coordinates.
'set lat 'fctlat
'set lon 'fctlon

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
'set grid on'
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

* Assume the variable doesn't exist.
vardisplay='none'

* Configure the output image's colors, levels and title according to the variable.
if (var=aod)
  vartitle='Aerosol Optical Depth at 550nm'
  unittitle=''
  'set vrange 0 5'
endif

if (var=cloud)
  vartitle='Cloud Drop Number Concentration'
  unittitle='cm-3'
  'set vrange 0 2'
endif

if (var=conv)
  vartitle='Precipitation (from Convective Parametrization)'
  unittitle='mm'
  'set vrange 0 50.8'
endif

if (var=dlwf)
  vartitle='Longwave Downwelling Radiative Flux at the Surface'
  unittitle='W/m^2'
  'set vrange 0 500'
endif

if (var=dswf)
  vartitle='Shortwave Downwelling Radiative Flux at the Surface'
  unittitle='W/m^2'
  'set vrange 0 1200'
endif

if (var=aeromass)
  vartitle='Total Aerosol Mass Column Integrated'
  unittitle='g/m^2'
  'set vrange 0.01 0.5'
endif

if (var=bcmass)
  vartitle='Black Carbon Mass Column Integrated'
  unittitle='g/m^2'
  'set vrange 0.01 0.3'
endif

if (var=ocmass)
  vartitle='Organic Carbon Column Mass Density'
  unittitle='g/m^2'
  cl='0.01 0.03 0.06 0.09 0.12 0.15 0.18 0.21 0.24 0.27 0.30 0.35'
  'set vrange 0.01 0.3'
endif

if (var=so4mass)
  vartitle='SO4 Salt Column Mass Density'
  unittitle='g/m^2'
  'set vrange 0.01 0.3'
endif

if (var=saltmass)
  vartitle='Sea Salt Column Mass Density'
  unittitle='g/m^2'
  'set vrange 0.01 0.3'
endif

if (var=dustmass)
  vartitle='Dust Aerosol Mass Column Integrated'
  unittitle='g/m^2'
  'set vrange 0.1 4'
endif

if (var=prec)
  vartitle='Total Precipitation'
  unittitle='mm'
  'set vrange 0 50'
endif

if (var=rh)
  vartitle='Relative Humidity'
  unittitle='%'
  'set vrange 0 100'
endif

if (var=temp)
  vartitle='Temperature'
  unittitle='K'
  if (mcase=pollution)
    'set vrange 240 315'
  else
    'set vrange 265 325'
  endif
endif

if (var=temp2m)
  vartitle='Temperature at 2m'
  unittitle='K'
  if (mcase=pollution)
    'set vrange 240 315'
  else
    'set vrange 265 325'
  endif
endif

if (var=ttend)
  vartitle='Temperature Tendency Associated to Radiative Flux'
  unittitle='K/s'
  'set vrange -0.3 0.3'
endif

if (var=wdir)
  vartitle='Wind Direction at 10m'
  unittitle='degrees'
  'set vrange 0 360'
endif

if (var=wmag)
  vartitle='Wind Magnitude at 10m'
  unittitle='m/s'
  'set vrange 0 10'
endif

*******************************************************************************
* Define the output variable.
if (var=aod)
  if (model=bsc); vardisplay='dust_aod_550'; endif
  if (model=ecmwf & mcase=dust); vardisplay='duaod550'; endif
  if (model=ecmwf & mcase=pollution); vardisplay='omaod550+bcaod550+suaod550'; endif
  if (model=ecmwf & mcase=smoke); vardisplay='omaod550+bcaod550'; endif
  if (model=jma); vardisplay='od550aer' ; endif
  if (model=meteofrance & scase=interactive); vardisplay='AOD'; endif
  if (model=nasa); vardisplay='totexttau' ; endif
  if (model=ncep); vardisplay='aod' ; endif
endif

if (var=cloud)
endif

if (var=conv)
  if (model=ecmwf)
    'define conv=cp-cp(t-1)'
    vardisplay='1000*(conv)'
  endif
  if (model=jma); vardisplay='3*3600*ppci'; endif
  if (model=nasa); vardisplay='3*3600*preccon' ; endif
  if (model=ncep); vardisplay='conv' ; endif
endif

if (var=dlwf)
  if (model=bsc); vardisplay='rlwin'; endif
  if (model=ecmwf)
    'define dlwf=(strd - strd(t-1))/10800'
    vardisplay='dlwf'
  endif
  if (model=jma); vardisplay='dlwb' ; endif
  if (model=meteofrance)
    'define dlwf=(surfraythr - surfraythr(t-1))/10800'
    vardisplay='dlwf'
  endif
  if (model=nasa); vardisplay='lwgnt*(-1)' ; endif
  if (model=ncep); vardisplay='dlwf' ; endif
endif

if (var=dswf)
  if (model=bsc); vardisplay='rswin'; endif
  if (model=ecmwf)
    'define dswf=(ssrd - ssrd(t-1))/10800'
    vardisplay='dswf'
  endif
  if (model=jma); vardisplay='dswb' ; endif
  if (model=meteofrance)
    'define dswf=(surfraysol - surfraysol(t-1))/10800'
    vardisplay='dswf'
  endif
  if (model=nasa); vardisplay='swgnt' ; endif
  if (model=ncep); vardisplay='dswf' ; endif
endif

if (var=aeromass)
  if (model=jma); vardisplay='loadaer*1000' ; endif
  if (model=nasa); vardisplay='(bccmass+ducmass+occmass+so4cmass+sscmass)*1000'; endif
endif

if (var=bcmass)
  if (model=nasa); vardisplay='bccmass*1000'; endif
endif

if (var=ocmass)
  if (model=nasa); vardisplay='occmass*1000'; endif
endif

if (var=so4mass)
  if (model=nasa); vardisplay='so4cmass*1000'; endif
endif

if (var=saltmass)
  if (model=nasa); vardisplay='sscmass*1000'; endif
endif

if (var=dustmass)
  if (model=bsc); vardisplay='dust_load*1000'; endif
  if (model=jma); vardisplay='loaddust*1000' ; endif
  if (model=meteofrance & scase=interactive); vardisplay='MASSINTEG*1000' ; endif
  if (model=nasa); vardisplay='ducmass*1000' ; endif
endif

if (var=prec)
  if (model=ecmwf)
    'define prec=(cp+lsp-cp(t-1)-lsp(t-1))*1000'
    vardisplay='prec'
  endif
  if (model=jma); vardisplay='3*3600*(ppci+ppli.2)'; endif
  if (model=nasa); vardisplay='3*3600*prectot' ; endif
  if (model=ncep); vardisplay='prec' ; endif
endif

if (var=rh)
  if (model=bsc); vardisplay='rh*100'; endif
  if (model=ecmwf); vardisplay='r'; endif
  if (model=jma); vardisplay='rh' ; endif
  if (model=meteofrance); vardisplay='HUM*100'; endif
  if (model=nasa); vardisplay='rh' ; endif
  if (model=ncep); vardisplay='rh' ; endif
endif

if (var=temp)
  if (model=bsc); vardisplay='tsl'; endif
  if (model=ecmwf); vardisplay='t'; endif
  if (model=jma); vardisplay=t; endif
  if (model=meteofrance); vardisplay='TEMP'; endif
  if (model=nasa); vardisplay='t'; endif
  if (model=ncep); vardisplay='temp'; endif
endif

if (var=temp2m)
  if (model=bsc); vardisplay='t2'; endif
  if (model=ecmwf); vardisplay='v2t'; endif
  if (model=jma); vardisplay='ta' ; endif
  if (model=meteofrance); vardisplay='SURFTEMP' ; endif
  if (model=nasa); vardisplay='t2m' ; endif
  if (model=ncep); vardisplay='temp2m' ; endif
endif

if (var=ttend)
  if (model=bsc); vardisplay='rtt'; endif
  if (model=meteofrance); vardisplay='TTENDRAD' ; endif
  if (model=nasa); vardisplay='dtdtrad' ; endif
  if (model=ncep); vardisplay='srh'; endif
endif

if (var=wdir)
*  wdir = (180/3.14159) * atan2(u,v) + 180
  if (model=bsc); vardisplay='dir10'; endif
  if (model=ecmwf); vardisplay='(180/3.14159) * atan2(v10u,v10v) + 180'; endif
  if (model=jma); vardisplay='wdir'; endif
  if (model=meteofrance); vardisplay='(180/3.14159) * atan2(ZWIND,MWIND) + 180'; endif
  if (model=nasa); vardisplay='(180/3.14159) * atan2(u10m,v10m) + 180'; endif
  if (model=ncep); vardisplay='(180/3.14159) * atan2(u10m,v10m) + 180'; endif
endif

if (var=wmag)
  if (model=bsc); vardisplay='spd10'; endif
  if (model=ecmwf); vardisplay='mag(v10u,v10v)'; endif
  if (model=jma); vardisplay='u10'; endif
  if (model=meteofrance); vardisplay='mag(ZWIND,MWIND)'; endif
  if (model=nasa); vardisplay='mag(u10m,v10m)'; endif
  if (model=ncep); vardisplay='mag(u10m,v10m)'; endif
endif

* Check if a file was opened.
'q file'
test=subwrd(result, 1)

*Create a custom scale if needed.
if (scale=custom)
  'set vrange 'minvalue' 'maxvalue
  'set yaxis 'minvalue' 'maxvalue' 'interval
endif

* Create the image.
if (vardisplay='none' | test='No')
  'set string 1 c'
  'set strsiz 0.18'
  'draw string 4.25 5.5 FORECAST DATA UNAVAILABLE'
else
  'set parea 1 8 1.5 9.5'
  'set ccolor 31'
  'set cthick 8'
  'set cmark 3'
  'd 'vardisplay
  'draw ylab 'unittitle

  'set strsiz 0.18'
  'set string 1 tc'
  'draw string 4.25 10.6 'vartitle
  'draw string 4.25 10.3 'modeltitle' 'aerotitle
  'q dims'
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
  'draw string 4.25 9.8 Forecast Started:  'hh'Z'dd''mmm''yy
  'draw string 4.25 0.4 Latitude: 'fctlat', Longitude: 'fctlon
  if (var=cloud | var=temp | var=rh | var=ttend)
    'draw string 4.25 0.7 Pressure Level: 'presslev'mb'
  endif
endif