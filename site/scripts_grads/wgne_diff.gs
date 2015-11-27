*args: partipicant case minuend subtrahend variable level year month day hour forecast
'reinit'
'set mpdset hires'
'set display color white'
'c'

* directory='/stornext/online8/exp-dmd/new_aerosols'
* str = 'nasa smoke interactive noaerosols temp2m 1 2012 09 05 00 0z07sep2012 default 0 0 0&ano=2013&mes=01&hr=2&rodada=00&mapext=-180+-90+180+90 0z07sep2012'

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
fctOriginal=subwrd(str,16)

if (mcase=smoke); 'set mpdset brmap_hires'; endif

* Set up the filename.
'sdfopen 'directory'/'model'/'mcase'/r'hh'/'model'_'mcase'_'minuend'_'yy''mm''dd''hh'00.nc'
'sdfopen 'directory'/'model'/'mcase'/r'hh'/'model'_'mcase'_'subtrahend'_'yy''mm''dd''hh'00.nc'

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
vardisplay=''var' - 'var'.2'

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
  'draw string 4.25 10.1 Forecast: 'fctOriginal
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
