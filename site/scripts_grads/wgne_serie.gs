*args: partipicant case subcase variable level year month day hour lat lon
'reinit'
'set mpdset hires'
'set display color white'
'c'

* directory='/stornext/online8/exp-dmd/new_aerosols'
* str = 'nasa dust interactive temp 1 2012 04 13 00 35 30 default 0 0 0&ano=2013&mes=01&hr=2&rodada=00&mapext=-180+-90+180+90'

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
'sdfopen 'directory'/'model'/'mcase'/r'hh'/'model'_'mcase'_'scase'_'yy''mm''dd''hh'00.nc'

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

vardisplay=var

if (var=cloud)
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
