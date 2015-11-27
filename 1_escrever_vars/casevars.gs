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
*     - Dimensão: 2d ou 3d
*     - Caso: dust/smoke/pollution
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
*nasa   2d       dust            /home2/denis/magnitude/nasa/dust         nasa_2d*.nc       /home2/denis/output
*ecmwf  2d       dust            /home2/denis/magnitude/ecmwf/dust        ecmwf_2d*.nc      /home2/denis/output
*ncep   2d       dust            /home2/denis/magnitude/ncep/dust         pgbf*.ctl         /home2/denis/output
*ncep   3d       dust            /home2/denis/magnitude/ncep/dust         aod*.ctl         /home2/denis/output
*nasa   2d       smoke            /home2/denis/magnitude/nasa/smoke       nasa_2d*.nc       /home2/denis/output
*ecmwf  2d       smoke            /home2/denis/magnitude/ecmwf/smoke      ecmwf_2d*.nc      /home2/denis/output
*ncep   2d       smoke            /home2/denis/magnitude/ncep/smoke       pgbf*.ctl         /home2/denis/output
*ncep   3d       smoke            /home2/denis/magnitude/ncep/smoke       aod*.ctl         /home2/denis/output
*nasa   2d       pollution        /home2/denis/magnitude/nasa/pollution   nasa_2d*.nc       /home2/denis/output
*ecmwf  2d       pollution        /home2/denis/magnitude/ecmwf/pollution  ecmwf_2d*.nc      /home2/denis/output
*ncep   2d       pollution        /home2/denis/magnitude/ncep/pollution   pgbf*.ctl         /home2/denis/output
*ncep   3d       pollution        /home2/denis/magnitude/ncep/pollution   aod*.ctl         /home2/denis/output


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

    dimType=subwrd(dirs2runLine2,2)
    casetype=subwrd(dirs2runLine2,3)
    inputPathBase=subwrd(dirs2runLine2,4)
    fileMask=subwrd(dirs2runLine2,5)
    outputPathBase=subwrd(dirs2runLine2,6)

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
        if(dimType='2d')
          fileout=genNasaAll(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
          sdfwrite(outputPath,filePattern,'wmag',magExp,fileToOpen,fileExt,centertype,dimType)
          sdfwrite(outputPath,filePattern,'wdir',wdirExp,fileToOpen,fileExt,centertype,dimType)
        else
          fileout=genNasa3dAll(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
        endif
      endif
      if(centertype='ncep')
        if(dimType='2d')
          if(substr(filePattern,1,3)='aod')
          'reinit'
            sdfwrite(outputPath,filePattern,'aod','aod',fileToOpen,fileExt,centertype,dimType)
          else
            fileout=genNcep2dAll(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
            sdfwrite(outputPath,filePattern,'wmag',magExp,fileToOpen,fileExt,centertype,dimType)
            sdfwrite(outputPath,filePattern,'wdir',wdirExp,fileToOpen,fileExt,centertype,dimType)
          endif
        else
          fileout=genNcep3dAll(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
        endif
      endif
      if(centertype='ecmwf')
        if(casetype='dust_new')
          if(dimType='2d')
            fileout=genEcmwfDustNew(pathIn,fileIn,filePattern,fileExt,outputPath,centertype,dimType)
          else 
            fileout=genEcmwfDustN3d(pathIn,fileIn,filePattern,fileExt,outputPath,centertype,dimType)
          endif
        endif
        if(casetype='smoke')
          if(dimType='2d')
            fileout=genEcmwfSmoke(pathIn,fileIn,filePattern,fileExt,outputPath,centertype,dimType)
          else
            fileout=genEcmwfSmoke3d(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
          endif
        endif
        if(casetype='pollution')
          if(dimType='2d')
            fileout=genEcmwfPoll(pathIn,fileIn,filePattern,fileExt,outputPath,centertype,dimType)
          else
            fileout=genEcmwfPoll3d(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
          endif
        endif
      endif
      
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
function genNasaAll(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
  'reinit'

  sdfwrite(outputPath,filePattern,'bcmass','bccmass*1000',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'aeromass','(bccmass+ducmass+occmass+so4cmass+sscmass)*1000',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'dustmass','ducmass*1000',fileToOpen,fileExt,centertype,dimType)

  sdfwrite(outputPath,filePattern,'dlwf','lwgnt*(-1)',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'ocmass','occmass*1000',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'conv','3*3600*preccon',fileToOpen,fileExt,centertype,dimType)
*  sdfwrite(outputPath,filePattern,'preclsc','preclsc',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'prec','3*3600*prectot',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'so4mass','so4cmass*1000',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'saltmass','sscmass*1000',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'dswf','swgnt',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'temp2m','t2m',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'aod','totexttau',fileToOpen,fileExt,centertype,dimType)
return fileout

***********************************************************************
* - lê o arquivo de entrada 3d e escreve as variaveis convertidas no padrao
***********************************************************************
function genNasa3dAll(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
  'reinit'
  sdfwrite(outputPath,filePattern,'ttend','dtdtrad',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'temp','t',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'rh','rh',fileToOpen,fileExt,centertype,dimType)
return fileout

***********************************************************************
* - lê o arquivo de entrada 2d e escreve as variaveis convertidas no padrao
***********************************************************************
function genNcep2dAll(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
  'reinit'

***** nao usados ...
* sdfwrite(outputPath,filePattern,'lsprec','lsprec',fileToOpen,fileExt,centertype,dimType)
* sdfwrite(outputPath,filePattern,'sph2m','sph2m',fileToOpen,fileExt,centertype,dimType)

  sdfwrite(outputPath,filePattern,'conv','conv',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'prec','prec',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'dlwf','dlwf',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'dswf','dswf',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'temp2m','temp2m',fileToOpen,fileExt,centertype,dimType)
return fileout

***********************************************************************
* - lê o arquivo de entrada 3d e escreve as variaveis convertidas no padrao
***********************************************************************
function genNcep3dAll(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
  'reinit'
  sdfwrite(outputPath,filePattern,'ttend','srh',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'temp','temp',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'rh','rh',fileToOpen,fileExt,centertype,dimType)
return fileout

************************************************************************
* lê o arquivo de entrada e escreve as variaveis convertidas no padrao *
************************************************************************
function genEcmwfDustNew(pathIn,fileIn,filePattern,fileExt,outputPath,centertype,dimType)
  'reinit'

* direct  
  fileNameAux=substr(fileIn,1,13)
  if(fileNameAux='macc_gaub_2t_')
    fileToOpen=pathIn'/'fileIn
    sdfwrite(outputPath,filePattern,'temp2m','no2tsfc',fileToOpen,fileExt,centertype,dimType)
  endif

* macc_gaub_10u_20120419.ctl e macc_gaub_10v_20120419.ctl
* mag(no10usfc.2,no10vsfc)
  if(fileNameAux='macc_gaub_10u') 
    fileFinal=substr(fileIn,14,26) 
    file1=pathIn'/macc_gaub_10u'fileFinal
    file2=pathIn'/macc_gaub_10v'fileFinal
    openFile(file1,fileExt)
    openFile(file2,fileExt)
    sdfwrite2(outputPath,filePattern,'wmag','mag(no10usfc,no10vsfc.2)',centertype,dimType)
    sdfwrite2(outputPath,filePattern,'wdir', '(180/3.14159) * atan2(no10usfc,no10vsfc.2) + 180',centertype,dimType)
    'close 2'
    'close 1'
  endif
  if(fileNameAux='macc_gaub_aod') 
    fileToOpen=pathIn'/'fileIn
    sdfwrite(outputPath,filePattern,'aod','aod550sfc',fileToOpen,fileExt,centertype,dimType)
  endif
  if(fileNameAux='macc_gaub_ssr') 
*   macc_gaub_ssrd_20120418.ctl
    fileFinal=substr(fileIn,15,27) 
    file1=pathIn'/macc_gaub_ssrd'fileFinal
    file2=pathIn'/macc_gaub_strd'fileFinal
    openFile(file1,fileExt)
    openFile(file2,fileExt)
    sdfwrite2(outputPath,filePattern,'dswf','(ssrdsfc - ssrdsfc(t-1))/10800',centertype,dimType)
    sdfwrite2(outputPath,filePattern,'dlwf','(strdsfc.2 - strdsfc.2(t-1))/10800',centertype,dimType)
    'close 2'
    'close 1'
  endif

* noaerosol
  if(fileNameAux='macc_gau8_2t_')
    fileToOpen=pathIn'/'fileIn
    sdfwrite(outputPath,filePattern,'temp2m','no2tsfc',fileToOpen,fileExt,centertype,dimType)
  endif

* macc_gaub_10u_20120419.ctl e macc_gaub_10v_20120419.ctl
* mag(no10usfc.2,no10vsfc)
  if(fileNameAux='macc_gau8_10u') 
    fileFinal=substr(fileIn,14,26) 
    file1=pathIn'/macc_gau8_10u'fileFinal
    file2=pathIn'/macc_gau8_10v'fileFinal
    openFile(file1,fileExt)
    openFile(file2,fileExt)
    sdfwrite2(outputPath,filePattern,'wmag','mag(no10usfc,no10vsfc.2)',centertype,dimType)
    sdfwrite2(outputPath,filePattern,'wdir', '(180/3.14159) * atan2(no10usfc,no10vsfc.2) + 180',centertype,dimType)
    'close 2'
    'close 1'
  endif
  if(fileNameAux='macc_gau8_aod') 
    fileToOpen=pathIn'/'fileIn
    sdfwrite(outputPath,filePattern,'aod','aod550sfc',fileToOpen,fileExt,centertype,dimType)
  endif
  if(fileNameAux='macc_gau8_ssr') 
*   macc_gaub_ssrd_20120418.ctl
    fileFinal=substr(fileIn,15,27) 
    file1=pathIn'/macc_gau8_ssrd'fileFinal
    file2=pathIn'/macc_gau8_strd'fileFinal
    openFile(file1,fileExt)
    openFile(file2,fileExt)
    sdfwrite2(outputPath,filePattern,'dswf','(ssrdsfc - ssrdsfc(t-1))/10800',centertype,dimType)
    sdfwrite2(outputPath,filePattern,'dlwf','(strdsfc.2 - strdsfc.2(t-1))/10800',centertype,dimType)
    'close 2'
    'close 1'
  endif

return fileout


***********************************************************************
* - lê o arquivo de entrada e escreve as variaveis convertidas no padrao
***********************************************************************
function genEcmwfSmoke(fileToOpen,fileIn,filePattern,fileExt,outputPath,centertype,dimType)
  'reinit'
  sdfwrite(outputPath,filePattern,'aod','omaod550+bcaod550',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'temp2m','v2t',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'dswf','(ssrd - ssrd(t-1))/10800',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'dlwf','(strd - strd(t-1))/10800',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'prec','(cp+lsp-cp(t-1)-lsp(t-1))*1000',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'conv','(cp-cp(t-1))*1000',fileToOpen,fileExt,centertype,dimType)
return fileout

***********************************************************************
* - lê o arquivo de entrada e escreve as variaveis convertidas no padrao
***********************************************************************
function genEcmwfPoll(fileToOpen,fileIn,filePattern,fileExt,outputPath,centertype,dimType)
  'reinit'
  sdfwrite(outputPath,filePattern,'aod','omaod550+bcaod550+suaod550',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'temp2m','v2t',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'dswf','(ssrd - ssrd(t-1))/10800',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'dlwf','(strd - strd(t-1))/10800',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'prec','(cp+lsp-cp(t-1)-lsp(t-1))*1000',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'conv','(cp-cp(t-1))*1000',fileToOpen,fileExt,centertype,dimType)
return fileout


***********************************************************************
* - lê o arquivo de entrada 3d e escreve as variaveis convertidas no padrao
***********************************************************************
function genEcmwfDustN3d(pathIn,fileIn,filePattern,fileExt,outputPath,centertype,dimType)
  'reinit'
  fileNameAux=substr(fileIn,1,12)
  if(fileNameAux='macc_gaub_t_'|fileNameAux='macc_gau8_t_')
    fileToOpen=pathIn'/'fileIn
    sdfwrite(outputPath,filePattern,'temp','tmphlev',fileToOpen,fileExt,centertype,dimType)
  endif
  return fileout
***********************************************************************
* - lê o arquivo de entrada 3d e escreve as variaveis convertidas no padrao
***********************************************************************
function genEcmwfSmoke3d(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
  'reinit'
  sdfwrite(outputPath,filePattern,'temp','t',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'rh','r',fileToOpen,fileExt,centertype,dimType)
return fileout
***********************************************************************
* - lê o arquivo de entrada 3d e escreve as variaveis convertidas no padrao
***********************************************************************
function genEcmwfPoll3d(fileToOpen,filePattern,fileExt,outputPath,centertype,dimType)
  'reinit'
  sdfwrite(outputPath,filePattern,'temp','t',fileToOpen,fileExt,centertype,dimType)
  sdfwrite(outputPath,filePattern,'rh','r',fileToOpen,fileExt,centertype,dimType)
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


function sdfwrite(outputPath,filePattern,varDef,varExp,fileToOpen,fileExt,centertype,dimType)
  fileout=outputPath'/'varDef'_'centertype'_'dimType'_'filePattern'.nc'
  msg('tentando remover arquivo NetCdf gerado anteriormente 'fileout'...')
  '!rm 'fileout
  msg('gerando novo arquivo NetCdf 'fileout' ...')
  openFile(fileToOpen,fileExt)
  'set gxout shaded'
  ztRange()
  say 'Dimensoes xmax: '_xmax', ymax: '_ymax', zmax: '_zmax
  'set x 1 '_xmax
  'set y 1 '_ymax
  if(dimType='3d')
    'set z 1 '_zmax
  else
    'set z 1 1'
  endif
  'set t 1 last'
  'define 'varDef'='varExp
  'set sdfwrite 'fileout
  'sdfwrite 'varDef
  'clear sdfwrite'
  'close 1'
  msg('Arquivo NetCdf 'fileout' gerado com sucesso!')
  visualize(fileout,0,varDef,0)
return

function sdfwrite2(outputPath,filePattern,varDef,varExp,centertype,dimType)
  fileout=outputPath'/'varDef'_'centertype'_'dimType'_'filePattern'.nc'
  msg('tentando remover arquivo NetCdf gerado anteriormente 'fileout'...')
  '!rm 'fileout
  msg('gerando novo arquivo NetCdf 'fileout' ...')
  'set gxout shaded'
  ztRange()
  say 'Dimensoes xmax: '_xmax', ymax: '_ymax', zmax: '_zmax
  'set x 1 '_xmax
  'set y 1 '_ymax
  if(dimType='3d')
    'set z 1 '_zmax
  else
    'set z 1 1'
  endif
  'set t 1 last'
  'define 'varDef'='varExp
  'set sdfwrite 'fileout
  'sdfwrite 'varDef
  'clear sdfwrite'
  msg('Arquivo NetCdf 'fileout' gerado com sucesso!')
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
  if(centertype='meteofrance'); magExp='mag(zwind,mwind)';endif
  if(centertype='nasa'|centertype='ncep'); magExp='mag(u10m,v10m)';endif
return magExp

function getWdirExp(centertype)
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