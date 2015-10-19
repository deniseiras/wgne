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

  geraPdf=0
  animate=0

  '!clear'
  msg('Iniciando...')

  dirs2RunFileName='./dirs2run.txt'
  dirs2RunFile=read(dirs2RunFileName)
  dirs2runLine1=sublin(dirs2RunFile,1)
   
  while(subwrd(dirs2runLine1,1)=0)

    dirs2runLine2=sublin(dirs2RunFile,2)
    centertype=subwrd(dirs2runLine2,1)
    magExp = getMagExp(centertype)
    wdirExp = getWdirExp(centertype)
    inputPathBase=subwrd(dirs2runLine2,2)
    fileMask=subwrd(dirs2runLine2,3)
    outputPathBase=subwrd(dirs2runLine2,4)

    fileListName='./filelist.tmp'
    
    '!find 'inputPathBase' -name 'fileMask' -printf "%h %f\n" > 'fileListName
*    '!basename -a 'inputPathBase'/'fileMask ' > 'fileListName
    
    fileListLines=read(fileListName)
    fileListLine1=sublin(fileListLines,1)

    while(subwrd(fileListLine1,1)=0)

      fileListLine2=sublin(fileListLines,2)
      pathIn=subwrd(fileListLine2,1)
      fileIn=subwrd(fileListLine2,2)
      outputPath=outputPathBase''pathIn
      '!mkdir -p 'outputPath
      msg(' ')
      msg('**********************************************************************')
      msg('Analisando arquivo 'fileIn'...')
      fileInSize=math_strlen(fileIn)
      fileExt=substr(fileIn,fileInSize-2,fileInSize)
      
      if(fileExt='.nc')
        msg('Detectado arquivo NETCDF')
        filePattern=substr(fileIn,1,fileInSize-3)
      else
        msg('Detectado arquivo CTL')
        filePattern=substr(fileIn,1,fileInSize-4)
      endif
      fileout=generateNetCdf(pathIn,fileIn,filePattern,fileExt,'wmag',magExp,'wdir',wdirExp,outputPath)
      fileListLines=read(fileListName)
      fileListLine1=sublin(fileListLines,1)

    endwhile
    rc=close(fileListName)

    dirs2RunFile=read(dirs2RunFileName)
    dirs2runLine1=sublin(dirs2RunFile,1)
  endwhile
  rc=close(dirs2RunFileName)

say
msg('************************************************')
msg(' Todos arquivos foram gerados na pasta 'outputPathBase)
msg(' Tenha um bom dia!')
msg('************************************************')
say

'quit'

***********************************************************************
* - lê o arquivo de entrada fileIn. Se não for arquivo SDF, tenta 
*   encontrar o CTL de mesmo nome. Caso encontre, gera o arquivo NetCdf
*   contendo a magnitude do vento
***********************************************************************
function generateNetCdf(inputPath,fileIn,filePattern,fileExt,varMagDef,magExp,varWdirDef,wdirExp,outputPath)
  
  fileToOpen=inputPath'/'fileIn
  openFile(fileToOpen,fileExt)
  'set gxout print'
  'set prnopts %s 5 1'
  'q ctlinfo'
  allVars =''
  resultaux = result
  say resultaux
  'close 1'

  openFile(fileToOpen,fileExt)
  'set gxout shaded'
  msg('gerando novo arquivo NetCdf 'fileout' ...')
  'set z 1'
  'set t 1 last'
  sdfwrite(outputPath,filePattern,varMagDef,magExp)
  sdfwrite(outputPath,filePattern,varWdirDef,wdirExp)

  i=6
  varsNum=0
  while(varsNum=0)
    tmp = sublin ( resultaux, i )
    i=i+1
    if(subwrd(tmp,1)='vars')
      varsNum = subwrd(tmp,2)
    endif
  endwhile

  lineVars=i-1
  while(i<=lineVars+varsNum)
    tmp = sublin(resultaux, i)
    var = subwrd(tmp,1)
    equalsStringPos=find(var,"=")
    if(equalsStringPos>0)
      var=substr(var,1,equalsStringPos-1)
    endif
    sdfwrite(outputPath,filePattern,var,var)
    i= i + 1
  endwhile
  'clear sdfwrite'
  'close 1'
return fileout

function openFile(fileToOpen,fileExt)
  if(fileExt='.nc')
    'sdfopen 'fileToOpen
  else
    if(!fileExists(fileToOpen) )
      msg('Nada a fazer: Não existe arquivo CTL 'fileToOpen)
      return 0
    endif
    'open 'fileToOpen
  endif
  msg('Arquivo 'fileToOpen' aberto')
return

function sdfwrite(outputPath,filePattern,varDef,varExp)
  fileout=outputPath'/'varDef'_'filePattern'.nc'
  msg('tentando remover arquivo NetCdf gerado anteriormente 'fileout'...')
  '!rm 'fileout
  'set sdfwrite 'fileout
  'define 'varDef'='varExp
  'sdfwrite 'varDef
  msg('Arquivo NetCdf 'fileout' gerado com sucesso!')
return

function fileExists(filename)
  fileExistsList='./fileexist.tmp'
  '!ls 'filename ' > 'fileExistsList
  file=read(fileExistsList)
  linha=sublin(file,2)
  ret=subwrd(linha,1)
  rc=close(fileExistsList)
  '!rm 'fileExistsList
return ret=filename

function msg(messg)
  say '>>>>> 'messg
return

function getMagExp(centertype)
  if(centertype='ecmwf'); magExp='mag(v10u,v10v)';endif
*    if(centertype='meteofrance'); magExp='mag(zwind,mwind)';endif
  if(centertype='meteofrance'); magExp='TEMP';endif
  if(centertype='nasa'|centertype='ncep'); magExp='mag(u10m,v10m)';endif
return magExp

function getWdirExp(centertype)
  if(centertype='ecmwf'); vardisplay='(180/3.14159) * atan2(v10u,v10v) + 180' ;endif
* if(centertype='meteofrance'); vardisplay='(180/3.14159) * atan2(ZWIND,MWIND) + 180';endif
  if(centertype='meteofrance'); vardisplay='TEMP';endif
  if(centertype='nasa'|centertype='ncep'); vardisplay='(180/3.14159) * atan2(u10m,v10m) + 180';endif
return vardisplay

function visualize(fileout,geraPdf,vardef,animate)
  'set gxout shaded'
  if(fileout!=0)
    msg('abrindo arquivo NetCdf para verificação ' fileout)
    'sdfopen 'fileout
    'clear'
    ztRange()
    if(animate)
      tt=_tmin
      while(tt<=_tmax)
        'set t 'tt
        'd 'vardef
        tt=tt+1
      endwhile
    else
      'q file'
      say result
      'set t '_tmin
      'd 'vardef
    endif
    if(geraPdf)
      filepdf=outputPath'/'filePattern'pdf'
      'gxyat -o 'filepdf
      msg('Gerado arquivo PDF com t = 1  para visualização: 'filepdf)
    endif
    'close 1'
  endif
return

function ztRange()
  'q file'
  tmp = sublin ( result, 5 )
  _zmin = 1
  _zmax = subwrd(tmp,9)
  _tmin = 1
  _tmax = subwrd(tmp,12)
return

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