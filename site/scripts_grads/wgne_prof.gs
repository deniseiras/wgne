*args: partipicant case subcase variable ilevel flevel year month day hour forecast lat lon
'reinit'
'set mpdset hires'
'set display color white'
'c'

directory='/stornext/online8/exp-dmd/new_aerosols'
str = 'nasa dust interactive temp 1 15 2012 04 13 00 15z13apr2012 35 30 default 0 0 0&ano=2013&mes=01&hr=2&rodada=00&mapext=-180+-90+180+90 15z13apr2012'

* Participant's name.
model=subwrd(str,1)
* Study case and subcase.
mcase=subwrd(str,2)
scase=subwrd(str,3)
* Variable name and vertical level.
var=subwrd(str,4)
vlvl=subwrd(str,5)
flvl=subwrd(str,6)
* Forecast date.
yy=subwrd(str,7)
mm=subwrd(str,8)
dd=subwrd(str,9)
hh=subwrd(str,10)
* Elapsed hours since start.
fct=subwrd(str,11)
* Coordinates.
fctlat=subwrd(str,12)
fctlon=subwrd(str,13)
* Custom scale parameters.
scale=subwrd(str,14)
minvalue=subwrd(str,15)
maxvalue=subwrd(str,16)
interval=subwrd(str,17)
fctOriginal=subwrd(str,18)

if (mcase=smoke); 'set mpdset brmap_hires'; endif
* Set up the filename.
'sdfopen 'directory'/'model'/'mcase'/'scase'/'model'_'mcase'_'scase'_'yy''mm''dd''hh'00.nc'

if (hh=12 & model!=meteofrance)
  'close 1'
endif

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

* Setting the forecast time.
'set time 'fct

* Configure vertical levels.
if(var=cloud | var=temp | var=rh | var=ttend)
  'set z 'vlvl' 'flvl
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
unittitle=''

* Configure the output image's colors, levels and title according to the variable.
if (var=cloud)
  vartitle='Cloud Drop Number Concentration'
  unittitle='cm-3'
  'set vrange 0 2'
endif

if (var=rh)
  vartitle='Relative Humidity'
  unittitle='%'
  'set vrange 0 100'
endif

if (var=temp)
  vartitle='Temperature'
  unittitle='K'
  'set vrange 150 325'
endif

if (var=ttend)
  vartitle='Temperature Tendency Associated to Radiative Flux'
  unittitle='K/s'
  'set vrange -0.3 0.3'
endif

*******************************************************************************
* Define the output variable.
if (var=cloud)
endif

vardisplay=var

* Check if a file was opened.
'q file'
test=subwrd(result, 1)

* Define a custom scale if needed.
if (scale=custom)
  'set vrange 'minvalue' 'maxvalue
  'set xaxis 'minvalue' 'maxvalue' 'interval
endif

* Create the image.
if (vardisplay='none' | test='No')
  'set string 1 c'
  'set strsiz 0.18'
  'draw string 4.25 5.5 FORECAST DATA UNAVAILABLE'
else
  if(model=jma)
    'set yflip on'
  endif

  'set parea 1 8 1.5 9.5'
  'set ccolor 31'
  'set cthick 8'
  'set cmark 3'
  'd 'vardisplay
  'draw ylab mb'
  'draw xlab 'unittitle

  'set strsiz 0.18'
  'set string 1 tc'
  'draw string 4.25 11 'vartitle
  'draw string 4.25 10.7 'modeltitle' 'aerotitle
  'draw string 4.25 10.1 Forecast: 'fctOriginal
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
  'draw string 4.25 9.8 Started:  'hh'Z'dd''mmm''yy
  'draw string 4.25 0.3 Latitude: 'fctlat', Longitude: 'fctlon
endif
