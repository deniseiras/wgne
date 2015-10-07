*script para criação de arquivos .gra do macc com umidade
*relativa geradas a partir de umidade especifica
*Autor: Valter Oliveira <valter.oliveira@cptec.inpe.br>
*run bsc2gra.gs ecmwf_2d_direct_20120905.nc

function main(args)
filein=subwrd(args,1)
ano=substr(filein,17,4)
mes=substr(filein,21,2)
dia=substr(filein,23,2)
fileout='ecmwf_2d_direct_' ano mes dia'.gra'

*declaração de array de niveis verticais

'sdfopen 'filein
'set gxout fwrite'
'set fwrite 'fileout

z=1
'set z 'z
t=1
while (t<=81)
'set t 't
*while (z<=1)
'clear'
*'d mag(v10u,v10v)'
'd v10u'
*z=z+1
*endwhile
*say t
t=t+1
endwhile
'quit'
