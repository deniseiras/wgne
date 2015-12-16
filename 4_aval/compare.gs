* script para criação de arquivos .gra com magnitude e direção do vento 
* pode ser adaptado para gerar quaisquer outras variáveis
* 
* a partir de arquivos netcdf 
* Autor: denis.eiras@inpe.br

* opengrads -lc "genwmag.gs" (ou ./run.sh)
*
* parâmetros: nenhum
* 
* arquivo de entrada: dirs2run.txt
*   - cada linha no formato: centertype inputPathBase fileMask outputpathbase
*   - onde:
*     - centertype in (ecmwf, meteofrance, nasa, ncep)
*     - inputPathBase: diretório base a ser percorrido (os subdiretórios serão avaliados)
*     - fileMask: máscara de procura de arquivos
*     - outputpathbase: diretório base onde serão escrito os arquivos. O diretório final
*         será outputpathbase + diretório onde o arquivo foi encontrado. Por isso, 
*         normalmente o valor de outputpathbase será fixo.
*         Ex: outputpathbase = /home/output; inputPathBase = /home/input
*         Se o arquivo abc.ctl for encontrado for encontrado em /home/input/ncep/20150101,
*         o arquivo de saída será gravado em /home/output/home/input/ncep/20150101
* 
*     - Exemplo arquivo de entrada de entrada
* ecmwf       /home2/denis/magnitude/ecmwf  ecmwf*.nc         /home2/denis/output/
* meteofrance /home2/denis/magnitude        meteofrance*.ctl  /home2/denis/output/
* nasa        /home2/denis/magnitude/nasa   nasa*.nc          /home2/denis/output/
* ncep        /home2/denis/magnitude/ncep   pgbf*.ctl         /home2/denis/output/


function main(args)

   file1='dataout-initial-02h/POSPROCESS/out-A-2014-01-27-020000-g1.ctl'
*   file2='dataout-history-02h-from-01h/POSPROCESS/out-A-2014-01-27-020000-g1.ctl'
*   file2='dataout-history-02h-from-01h-parallel-bug-ok/POSPROCESS/out-A-2014-01-27-020000-g1.ctl'
   file2='dataout-history-02h-from-01h-parallel-bug-ok-08procs/POSPROCESS/out-A-2014-01-27-020000-g1.ctl'

   fileout=compare(file1,file2)

'quit'

function compare(file1,file2)
  'reinit'
  openFile(file1,'ctl')
  'set gxout print'
  'set prnopts %s 5 1'
  'q ctlinfo'
  allVars =''
  resultaux = result
  say resultaux

  i=6
  varsNum=0
  while(varsNum=0)
    tmp = sublin ( resultaux, i )
    i=i+1
    if(subwrd(tmp,1)='vars')
      varsNum = subwrd(tmp,2)
    endif
  endwhile

  openFile(file2,'ctl')
  'set gxout print'
  'set prnopts %s 5 1'
  lineVars=i-1
    ztRange()
    say 'Dimensoes xmax: '_xmax', ymax: '_ymax', zmax: '_zmax
  while(i<=lineVars+varsNum)
    tmp = sublin(resultaux, i)
    var = subwrd(tmp,1)
    zlevels = subwrd(tmp,2)
    if(zlevels=0)
      zlevels=1
    endif
    equalsStringPos=find(var,"=")
    if(equalsStringPos>0)
      var=substr(var,1,equalsStringPos-1)
    endif
    'set x 1 '_xmax
    'set y 1 '_ymax
    say ''
    z=1
    say 'var = 'var', z = 'zlevels
    'set gxout shaded'
    while(z<=zlevels)
      t=1
      while(t<=_tmax)
        'set z 'z
        'set t 't
        'd 'var
        cada=sublin(result, 1)
        if(subwrd(cada,1)='Constant')
          say 'OK'
        else 
          varmin=subwrd(cada,2)
          varmax=subwrd(cada,4)
          'd abs('varmin')+abs('varmax')'
          cada=sublin(result, 1)
          variacao=subwrd(cada,4)
          say 'variacao = 'variacao
          say ' z='z' t='t' -> d 'var'.2-'var
          'd abs('var'.2-'var')'
          cada=sublin(result, 1)
          say cada
          if(subwrd(cada,1)='Constant')
            say 'diferenca = 0'
          else
            varmin=subwrd(cada,2)
            if(variacao>0)
              if(varmin/variacao>0.01)
                say '********************************************* diferenca min > 1% --- 'varmin/variacao
              else 
                say 'diferenca min <= 1% --- 'varmin/variacao
              endif
              varmax=subwrd(cada,4)
              if(varmax/variacao>0.01)
                say '********************************************* diferenca max > 1% --- 'varmax/variacao
              else
                say 'diferenca max <= 1% --- 'varmax/variacao
              endif
            endif
          endif
        endif
        t=t+1
      endwhile
      z=z+1
    endwhile
    i= i + 1
  endwhile
  'close 2'
  'close 1'
return fileout

function openFile(fileToOpen,fileExt)
  if(fileExt='.nc')
    'sdfopen 'fileToOpen
  else
    'open 'fileToOpen
  endif
  msg('Arquivo 'fileToOpen' aberto')
return

function msg(messg)
  say '>>>>> 'messg
return

function ztRange()
  'q file'
  tmp = sublin ( result, 5 )
  _xmax = subwrd(tmp,3)
  _ymax = subwrd(tmp,6)
  _zmin = 1
  _zmax = subwrd(tmp,9)
  _tmin = 1
  _tmax = subwrd(tmp,12)
return

function fileExists(filename)
  fileExistsList='./fileexist.tmp'
  '!rm 'fileExistsList
  '!ls 'filename ' > 'fileExistsList
  file=read(fileExistsList)
  linha=sublin(file,2)
  ret=subwrd(linha,1)
  rc=close(fileExistsList)
return ret=filename

function find( str, char )
  ntmp = math_strlen( str )
  i = 1
  while( i <= ntmp )
    tmp = substr(str,i,1)
    if( tmp = char )
      return i
    endif
    i = i + 1
  endwhile
return -1

