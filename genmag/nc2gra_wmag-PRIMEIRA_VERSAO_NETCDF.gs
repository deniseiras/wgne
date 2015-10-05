* script para criação de arquivos .gra com magnitude do vento
* a partir de arquivos netcdf 
* Autor: denis.eiras@inpe.br

* run nc2gra_wmag.gs <file.nc>
*
* parâmetros: 
* file.nc - arquivo netcdf

function main(args)

filein=subwrd(args,1)
fileinsize=math_strlen(filein)
filepattern=substr(filein,1,fileinsize-2)

generate_gra(filepattern,filein)
filectl=generate_ctl(filepattern,filein)

'set gxout shaded'
'open 'filectl
'q file'
say result
'd wmag'
say 'Visualizando arquivo, pressione ENTER para sair. Tenha um bom dia!'
pull pausee
'quit'


function ztrange()
  'q file'
  tmp = sublin ( result, 5 )
  _zmin = 1
  _zmax = subwrd(tmp,9)
  _tmin = 1
  _tmax = subwrd(tmp,12)
return

function gettype()
  prompt 'Informe o tipo de arquivo e pressione ENTER. '
  prompt '1-ecmwf, 2-meteofrance, 3-nasa, 4-ncep: '
  pull centertype
  if(centertype=1); mag_exp='mag(v10u,v10v)';endif
  if(centertype=2); mag_exp='mag(ZWIND,MWIND)';endif
  if(centertype=3|centertype=4); mag_exp='mag(u10m,v10m)';endif
return mag_exp

function generate_gra(filepattern,filein)
  say 'abrindo arquivo NETCDF 'filein'...'
  'sdfopen 'filein
  fileout=filepattern'gra'
  '!rm 'fileout
  say 'tentando remover arquivo grads 'fileout'...'
  mag_exp = gettype()

  'set gxout fwrite'
  'set fwrite 'fileout
  rc = ztrange()
  t=1
  say 'gerando '_tmax' tempos'
  while(t<=_tmax)
    'set t 't
    'd 'mag_exp
    t=t+1
  endwhile
  'close 1'
  say ' Arquivo grads gerado com sucesso! Pressione ENTER para visualizar'
  pull pausee
return

function generate_ctl(filepattern,filein)
  say 'abrindo arquivo NETCDF 'filein'...'
  'sdfopen 'filein
  filectlout=filepattern'ctl'
  say 'tentando remover arquivo ctl 'filectlout'...'
  '!rm 'filectlout

  'set gxout print'
  'set prnopts %s 5 1'
  'q ctlinfo'

  resultaux = result
  tmp = sublin ( resultaux, 1 )
  tmp = substr(tmp,1,math_strlen(tmp)-2)'gra'
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
