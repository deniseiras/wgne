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
    casetype=subwrd(dirs2runLine2,2)
    inputPathBase=subwrd(dirs2runLine2,3)
    fileMask=subwrd(dirs2runLine2,4)
    outputPathBase=subwrd(dirs2runLine2,5)

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
      fileToOpen=pathIn'/'fileIn
      if(centertype='nasa')
        fileout=genNasaAll(fileToOpen,filePattern,fileExt,outputPath)
      endif
      if(centertype='ncep')
          fileout=genNcepAll(fileToOpen,filePattern,fileExt,outputPath)
      endif
      if(centertype='ecmwf')
        if(casetype='dust')
          fileout=genEcmwfDust(fileToOpen,filePattern,fileExt,outputPath)
        endif
        if(casetype='smoke')
          fileout=genEcmwfSmoke(fileToOpen,filePattern,fileExt,outputPath)
        endifif(casetype='pollution')
          fileout=genEcmwfPoll(fileToOpen,filePattern,fileExt,outputPath)
        endif
      endif
      sdfwrite(outputPath,filePattern,'wmag',magExp,fileToOpen,fileExt)
      sdfwrite(outputPath,filePattern,'wdir',wdirExp,fileToOpen,fileExt)

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
* - lê o arquivo de entrada e escreve as variaveis convertidas no padrao
***********************************************************************
function genNasaAll(fileToOpen,filePattern,fileExt,outputPath)
  'reinit'

  sdfwrite(outputPath,filePattern,'bcmass','bccmass*1000',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'aeromass','(bccmass+ducmass+occmass+so4cmass+sscmass)*1000',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'dustmass','ducmass*1000',fileToOpen,fileExt)

  sdfwrite(outputPath,filePattern,'dlwf','lwgnt*(-1)',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'ocmass','occmass*1000',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'conv','3*3600*preccon',fileToOpen,fileExt)
*  sdfwrite(outputPath,filePattern,'preclsc','preclsc',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'prec','3*3600*prectot',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'so4mass','so4cmass*1000',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'saltmass','sscmass*1000',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'dswf','swgnt',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'temp2m','t2m',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'aod','totexttau',fileToOpen,fileExt)
return fileout

***********************************************************************
* - lê o arquivo de entrada e escreve as variaveis convertidas no padrao
***********************************************************************
function genNcepAll(fileToOpen,filePattern,fileExt,outputPath)
  'reinit'
  sdfwrite(outputPath,filePattern,'conv','conv',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'prec','prec',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'dlwf','dlwf',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'dswf','dswf',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'lwrh','lwrh',fileToOpen,fileExt)
* sdfwrite(outputPath,filePattern,'lsprec','lsprec',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'rh','rh',fileToOpen,fileExt)
* sdfwrite(outputPath,filePattern,'sph2m','sph2m',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'ttend','srh',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'temp','temp',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'temp2m','temp2m',fileToOpen,fileExt)
return fileout

***********************************************************************
* - lê o arquivo de entrada e escreve as variaveis convertidas no padrao
***********************************************************************
function genEcmwfDust(fileToOpen,filePattern,fileExt,outputPath)
  'reinit'
  sdfwrite(outputPath,filePattern,'aod','duaod550',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'temp2m','v2t',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'dswf','(ssrd - ssrd(t-1))/10800',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'dlwf','(strd - strd(t-1))/10800',fileToOpen,fileExt)
return fileout

***********************************************************************
* - lê o arquivo de entrada e escreve as variaveis convertidas no padrao
***********************************************************************
function genEcmwfSmoke(fileToOpen,filePattern,fileExt,outputPath)
  'reinit'
  sdfwrite(outputPath,filePattern,'aod','omaod550+bcaod550',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'temp2m','v2t',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'dswf','(ssrd - ssrd(t-1))/10800',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'dlwf','(strd - strd(t-1))/10800',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'prec','(cp+lsp-cp(t-1)-lsp(t-1))*1000',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'conv','(cp-cp(t-1))*1000',fileToOpen,fileExt)
return fileout

***********************************************************************
* - lê o arquivo de entrada e escreve as variaveis convertidas no padrao
***********************************************************************
function genEcmwfPoll(fileToOpen,filePattern,fileExt,outputPath)
  'reinit'
  sdfwrite(outputPath,filePattern,'aod','omaod550+bcaod550+suaod550',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'temp2m','v2t',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'dswf','(ssrd - ssrd(t-1))/10800',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'dlwf','(strd - strd(t-1))/10800',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'prec','(cp+lsp-cp(t-1)-lsp(t-1))*1000',fileToOpen,fileExt)
  sdfwrite(outputPath,filePattern,'conv','(cp-cp(t-1))*1000',fileToOpen,fileExt)
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

function sdfwrite(outputPath,filePattern,varDef,varExp,fileToOpen,fileExt)
  fileout=outputPath'/'varDef'_'filePattern'.nc'
  msg('tentando remover arquivo NetCdf gerado anteriormente 'fileout'...')
  '!rm 'fileout
  msg('gerando novo arquivo NetCdf 'fileout' ...')
  openFile(fileToOpen,fileExt)
  'set gxout shaded'
  ztRange()
  say 'Dimensoes xmax: '_xmax', ymax: '_ymax', zmax: '_zmax
  'set x 1 '_xmax
  'set y 1 '_ymax
  'set z 1 1'
  'set t 1 last'
  'define 'varDef'='varExp
  'set sdfwrite 'fileout
  'sdfwrite 'varDef
  'clear sdfwrite'
  'close 1'
  msg('Arquivo NetCdf 'fileout' gerado com sucesso!')
  visualize(fileout,0,varDef,0)
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

function msg(messg)
  say '>>>>> 'messg
return

function getMagExp(centertype)
  if(centertype='ecmwf'); magExp='mag(v10u,v10v)';endif
  if(centertype='meteofrance'); magExp='mag(zwind,mwind)';endif
  if(centertype='nasa'|centertype='ncep'); magExp='mag(u10m,v10m)';endif
return magExp

function getWdirExp(centertype)
  if(centertype='ecmwf'); vardisplay='(180/3.14159) * atan2(v10u,v10v) + 180' ;endif
  if(centertype='meteofrance'); vardisplay='(180/3.14159) * atan2(zwind,mwind) + 180';endif
  if(centertype='nasa'|centertype='ncep'); vardisplay='(180/3.14159) * atan2(u10m,v10m) + 180';endif
return vardisplay

function visualize(fileout,geraPdf,varDef,animate)
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
        'd 'varDef
        tt=tt+1
      endwhile
    else
      'q file'
      say result
      'set t '_tmin
      'd 'varDef
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
  _xmax = subwrd(tmp,3)
  _ymax = subwrd(tmp,6)
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