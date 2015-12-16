function main(args)

    'reinit'
    'set display color white'
    'c'

    diroriginal='/stornext/online8/exp-dmd/aerosols'
    dirconvertido='/stornext/online8/exp-dmd/new_aerosols'

    model=subwrd(args,1)
    mcase=subwrd(args,2)
    scase=subwrd(args,3)

    if(mcase='dust')
        yy='2012'
        mm='04'
        ddp=13
        ddfinal=23
    else
        if(mcase='smoke')
            yy='2012'
            mm='09'
            ddp=05
            ddfinal=15
        else 
            if(mcase='pollution')
                yy='2013'
                mm='01'
                ddp=07
                ddfinal=21
            else
                say 'caso inválido: 'mcase
                'quit'
            endif
        endif
    endif

    hh='00'


    arq='avaliacao_'model'_'mcase'_'scase'.txt'
    while (ddp<=ddfinal)
        dd=''ddp
        if(math_strlen(dd)=1)
            dd='0'dd
        endif
        compare(dirconvertido,diroriginal,model,mcase,scase,yy,mm,dd,hh,arq)
* fecho os arquivos caso haja um retorno de exceção, senão fecho a cada inspecao de varivel em compare()
        'close 2'
        'close 1'
        ddp=ddp+1
    endwhile
    rc = close(arq)
    'quit'

return 

function compare(dirconvertido,diroriginal,model,mcase,scase,yy,mm,dd,hh,arq)

  fileconverted=dirconvertido'/'model'/'mcase'/r'hh'/'model'_'mcase'_'scase'_'yy''mm''dd''hh'00.nc'
  if(!fileExists(fileconverted) )
      msg('************************** VERIFICAR **********************************',arq)
      msg('Verificar arquivo convertido não existente 'fileconverted,arq)
      msg('************************** VERIFICAR **********************************',arq)
      return
   endif
   openFile(fileconverted)

  'set gxout print'
  'set prnopts %s 5 1'
  'q ctlinfo'
  allVars = ''
  resultaux = result
  msg(resultaux,arq)
  'close 1'

  i=6
  varsNum=0
  while (varsNum=0)
    tmp = sublin ( resultaux, i )
    i=i+1
    if (subwrd(tmp,1)='vars')
      varsNum = subwrd(tmp,2)
    endif
  endwhile

  lineVars=i-1
  while (i<=lineVars+varsNum)
    tmp = sublin(resultaux, i)
    var = subwrd(tmp,1)
    equalsStringPos=find(var,"=")
    if (equalsStringPos>0)
      var=substr(var,1,equalsStringPos-1)
    endif
    zlevels = subwrd(tmp,2)
    if (zlevels=0)
      zlevels=1
    endif

    vardisplay=getvardisplay(var,model,mcase,scase)
    if(vardisplay='')
      msg('************************** VERIFICAR **********************************',arq)
      msg('Variável não definida para conversão: 'var,arq)
      msg('***********************************************************************',arq)
      i=i+1
      continue
    endif
    fileoriginal=getoriginalfile(diroriginal,model,mcase,scase,yy,mm,dd,hh,var,vardisplay)
    if(!fileExists(fileoriginal) )
      msg('************************** VERIFICAR **********************************',arq)
      msg('Verificar arquivo original não existente 'fileoriginal,arq)
      msg('***********************************************************************',arq)
      i=i+1
      continue
    endif
    openFile(fileoriginal)
    'q file 1'
    msg(result,arq)

    openFile(fileconverted)
    'q file 2'
    msg(result,arq)

    ztRange(1)
    xmax1=_xmax
    ymax1=_ymax
    zmax1=_zmax
    tmax1=_tmax
    ztRange(2)
    xmax2=_xmax
    ymax2=_ymax
    zmax2=_zmax
    tmax2=_tmax
    if (model!='cptec')
        if (xmax1!=xmax2 | ymax1!=ymax2 | tmax1!=tmax2)
          msg('************************** VERIFICAR **********************************',arq)
          msg('***** DIMENSÕES DIVERGENTES! VERIFIQUE OS ARQUIVOS ABERTOS ACIMA ....',arq)
          msg('***********************************************************************',arq)
          i=i+1
          'close 2'
          'close 1'
          continue
        endif
    endif

    'set x 1 'xmax1
    'set y 1 'ymax1
    z=1
    msg('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',arq)
    msg('Comparando nova variável = 'var', com = 'zlevels' níveis',arq)
    msg('com a função sobre a variável original ... 'vardisplay,arq)
    msg('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',arq)

    'set gxout line'
    while (z<=zlevels)
      t=1
      while (t<=tmax1)
        'set z 'z
        'set t 't
        defvardisplay='define vardisp='vardisplay
        ''defvardisplay
        vardisplaystr='vardisp(t='t',z='z')'
        msg(vardisplaystr)
        'd 'vardisplaystr
        cada=sublin(result, 1)
        msg(cada,arq)
        if (subwrd(cada,1)='Constant'|cada='Cannot contour grid - all undefined values ')
          msg('Variável 'vardisplay' com todos valores constantes ou indefinidos',arq)
        else 
          varmin=subwrd(cada,2)
          varmax=subwrd(cada,4)
          if(valnum(varmin)='0')
              msg('************************** VERIFICAR **********************************',arq)
              msg(' Variável original referente à 'var' não encontrada...',arq)
              msg(' Erro grads: 'cada,arq)  
              msg('**********************************************************************',arq)
          else 
              variacao=math_abs(varmin)+math_abs(varmax)
              msg('Amplitude original de 'vardisplay': 'variacao,arq)
              defstr='define diferenca='var'.2(t='t',z='z')-vardisp'
              msg(defstr,arq)
              ''defstr
              execstr='d diferenca'
              msg(execstr,arq)
              ''execstr
              cada=sublin(result, 1)
              msg(cada,arq)
              if (subwrd(cada,1)='Operation')
                msg('************************** ERRO **********************************',arq)
                msg('Erro: 'cada,arq)
                msg('******************************************************************',arq)
                break
              endif
              if (subwrd(cada,1)='Constant' | subwrd(cada,1)='Cannot')
                msg('Diferenca = 0 ou todos valores undefined',arq)
              else
                if (variacao>0)
                  diffmin=subwrd(cada,2)
                  diffmin=math_abs(diffmin)
                  if (diffmin/variacao>0.01)
                    msg('************************** ERRO **********************************',arq)
                    msg(' Diferenca do menor valor > 1% - min='diffmin', min/amplitude='diffmin*100/variacao,arq)
                    msg('******************************************************************',arq)
                  else 
                    msg(' Diferenca do menor valor <= 1% - min='diffmin', min/amplitude='diffmin*100/variacao,arq)
                  endif
                  diffmax=subwrd(cada,4)
                  diffmax=math_abs(diffmax)
                  if (diffmax/variacao>0.01)
                    msg('************************** ERRO **********************************',arq)
                    msg(' Diferenca do maior valor > 1% - max='diffmax', max/amplitude='diffmax*100/variacao,arq)
                    msg('******************************************************************',arq)
                  else
                    msg(' Diferenca do maior valor <= 1% - max='diffmax', max/amplitude='diffmax*100/variacao,arq)
                  endif
                endif
              endif
          endif
        endif
        if(t=tmax1)
            t=t+1
        else
            t=t+(tmax1/2)
*            t=t+1
            t=math_int(t)
            if(t>tmax1)
                t=tmax1
            endif
        endif
      endwhile
      if(z=zlevels)
        z=z+1
      else 
          z=z+(zlevels/2)
*          z=z+1
          z=math_int(z)
          if(z>zlevels)
            z=zlevels
          endif
      endif
    endwhile
    i= i + 1
    'close 2'
    'close 1'
  endwhile
return


function ztRange(filenum)
  'q file 'filenum
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
  while (i <= ntmp)
    tmp = substr(str,i,1)
    if (tmp = char)
      return i
    endif
    i = i + 1
  endwhile
return -1


function getvardisplay(var,model,mcase,scase)

    vardisplay=''
    if (var=aod)
      if (model=bsc); vardisplay='dust_aod_550'; endif
      if (model=ecmwf & mcase=dust)
        if (scase=direct)
            vardisplay='aod550sfc'
        else
            vardisplay='duaod550'
        endif
      endif
      if (model=ecmwf & mcase=pollution); vardisplay='omaod550+bcaod550+suaod550'; endif
      if (model=ecmwf & mcase=smoke); vardisplay='omaod550+bcaod550'; endif
      if (model=jma); vardisplay='od550aer' ; endif
      if (model=meteofrance & scase=interactive); vardisplay='AOD'; endif
      if (model=nasa); vardisplay='totexttau' ; endif
      if (model=ncep); vardisplay='aod' ; endif
      if (model=cptec); vardisplay='aot550' ; endif
    endif

    if (var=cloud)
    endif

    if (var=conv)
      if (model=ecmwf); vardisplay='(cp-cp(t-1))*1000'; endif
      if (model=jma); vardisplay='3*3600*ppci'; endif
      if (model=nasa); vardisplay='3*3600*preccon'; endif
      if (model=ncep); vardisplay='conv'; endif
      if (model=cptec); vardisplay='(acccon - acccon(t-1))'; endif
    endif

    if (var=dlwf)
      if (model=bsc); vardisplay='rlwin'; endif
      if (model=ecmwf)
        if (mcase=dust & scase=direct)
            'define dlwf=(strdsfc - strdsfc(t-1))/10800'
            vardisplay='dlwf'
        else
            'define dlwf=(strd - strd(t-1))/10800'
            vardisplay='dlwf'
        endif
      endif
      if (model=jma); vardisplay='dlwb' ; endif
      if (model=meteofrance)
        'define dlwf=(surfraythr - surfraythr(t-1))/10800'
        vardisplay='dlwf'
      endif
      if (model=nasa); vardisplay='lwgnt*(-1)' ; endif
      if (model=ncep); vardisplay='dlwf' ; endif
      if (model=cptec); vardisplay='rlong'; endif
    endif

    if (var=dswf)
      if (model=bsc); vardisplay='rswin'; endif
      if (model=ecmwf)
        if (mcase=dust & scase=direct)
            'define dswf=(ssrdsfc - ssrdsfc(t-1))/10800'
            vardisplay='dswf'
        else
        'define dswf=(ssrd - ssrd(t-1))/10800'
        vardisplay='dswf'
        endif
      endif
      if (model=jma); vardisplay='dswb' ; endif
      if (model=meteofrance)
        'define dswf=(surfraysol - surfraysol(t-1))/10800'
        vardisplay='dswf'
      endif
      if (model=nasa); vardisplay='swgnt' ; endif
      if (model=ncep); vardisplay='dswf' ; endif
      if (model=cptec); vardisplay='rshort'; endif
    endif

    if (var=aeromass)
      if (model=jma); vardisplay='loadaer*1000' ; endif
      if (model=nasa); vardisplay='(bccmass+ducmass+occmass+so4cmass+sscmass)*1000'; endif
      if (model=cptec); vardisplay='pmint*1000' ; endif
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
      if (model=ecmwf); vardisplay='(cp+lsp-cp(t-1)-lsp(t-1))*1000'; endif
      if (model=jma); vardisplay='3*3600*(ppci+ppli.2)'; endif
      if (model=nasa); vardisplay='3*3600*prectot' ; endif
      if (model=ncep); vardisplay='prec' ; endif
      if (model=cptec); vardisplay='precip-precip(t-1)'; endif
    endif

    if (var=rh)
      if (model=bsc); vardisplay='rh*100'; endif
      if (model=ecmwf)
          if (mcase=dust & scase=direct)
          else
              vardisplay='r'
         endif
      endif
      if (model=jma); vardisplay='rh' ; endif
      if (model=meteofrance); vardisplay='HUM*100'; endif
      if (model=nasa); vardisplay='rh' ; endif
      if (model=ncep); vardisplay='rh' ; endif
      if (model=cptec); vardisplay='rh'; endif
    endif

    if (var=temp)
      if (model=bsc); vardisplay='tsl'; endif
      if (model=ecmwf)
        vardisplay='t'
      endif
      if (model=jma); vardisplay='t'; endif
      if (model=meteofrance); vardisplay='TEMP'; endif
      if (model=nasa); vardisplay='t'; endif
      if (model=ncep); vardisplay='temp'; endif
      if (model=cptec); vardisplay='tempk'; endif
    endif

    if (var=temp2m)
      if (model=bsc); vardisplay='t2'; endif
      if (model=ecmwf & mcase=dust)
        if (scase=direct)
            vardisplay='no2tsfc'
        else
            vardisplay='v2t'
        endif
      endif
      if (model=jma); vardisplay='ta' ; endif
      if (model=meteofrance); vardisplay='SURFTEMP' ; endif
      if (model=nasa); vardisplay='t2m' ; endif
      if (model=ncep); vardisplay='temp2m' ; endif
      if (model=cptec); vardisplay='t2mj+273.15' ; endif

    endif

    if (var=ttend)
      if (model=bsc); vardisplay='rtt'; endif
      if (model=meteofrance); vardisplay='TTENDRAD' ; endif
      if (model=nasa); vardisplay='dtdtrad' ; endif
      if (model=ncep); vardisplay='srh'; endif
    endif

    if (var=wdir)
      if (model=bsc); vardisplay='dir10'; endif
      if (model=ecmwf & mcase=dust)
        if (scase=direct)
            vardisplay='(180/3.14159) * atan2(no10usfc,no10vsfc) + 180'
        else
            vardisplay='(180/3.14159) * atan2(v10u,v10v) + 180'
        endif
      endif
      if (model=jma); vardisplay='wdir'; endif
      if (model=meteofrance); vardisplay='(180/3.14159) * atan2(ZWIND,MWIND) + 180'; endif
      if (model=nasa); vardisplay='(180/3.14159) * atan2(u10m,v10m) + 180'; endif
      if (model=ncep); vardisplay='(180/3.14159) * atan2(u10m,v10m) + 180'; endif
      if (model=cptec); vardisplay='(180/3.14159) * atan2(u10mj,v10mj) + 180'; endif
    endif

    if (var=wmag)
      if (model=bsc); vardisplay='spd10'; endif
      if (model=ecmwf & mcase=dust)
        if (scase=direct)
            vardisplay='mag(no10usfc,no10vsfc)'
        else
            vardisplay='mag(v10u,v10v)'
        endif
      endif
      if (model=jma); vardisplay='u10'; endif
      if (model=meteofrance); vardisplay='mag(ZWIND,MWIND)'; endif
      if (model=nasa); vardisplay='mag(u10m,v10m)'; endif
      if (model=ncep); vardisplay='mag(u10m,v10m)'; endif
      if (model=cptec); vardisplay='mag(u10mj,v10mj)'; endif
    endif

    if (var=td2mj)
        if (model=cptec); vardisplay='td2mj'; endif
    endif

return vardisplay

function getoriginalfile(diroriginal,model,mcase,scase,yy,mm,dd,hh,var,varold)
    fileorig=''
    if (model='bsc')
      fileorig=diroriginal'/bsc/'mcase'/'scase'/bsc_'scase'_'yy''mm''dd'_reg.nc' 
    endif

    if (model='ecmwf')
      if (var='temp' | var='rh' | var='ttend')
        fileorig=diroriginal'/ecmwf/'mcase'/'scase'/ecmwf_3d_'scase'_'yy''mm''dd'.nc'
      else
        fileorig=diroriginal'/ecmwf/'mcase'/'scase'/ecmwf_2d_'scase'_'yy''mm''dd'.nc'
      endif
    endif

    if (model='jma')
      if (mcase='dust' & scase='noaerosols')
          if (var='prec')
            fileorig=diroriginal'/jma/'mcase'/'scase'/jma_conv_'yy''mm''dd''hh'.nc'
          else
            fileorig=diroriginal'/jma/'mcase'/'scase'/jma_'varold'_'yy''mm''dd''hh'.nc'
	  endif
      else
        jmaprefix='snp'
        if(varold='rh' | varold='rlong' | varold='rshrt' | varold='t')
           jmaprefix='avr'
        endif
        if (mcase='dust')
            fileorig=diroriginal'/jma/new/'mcase'/'scase'/'varold'_'jmaprefix'_3hr.NAfrica.'yy''mm''dd''hh'.nc'
        endif
        if (mcase='smoke')
            fileorig=diroriginal'/jma/new/'mcase'/'scase'/'varold'_'jmaprefix'_3hr.SAmerica.'yy''mm''dd''hh'.nc'
        endif
        if (mcase='pollution')
            fileorig=diroriginal'/jma/new/'mcase'/'scase'/'varold'_'jmaprefix'_3hr.EAsia.'yy''mm''dd''hh'.nc'
        endif

      endif
    endif

    if (model='ncep')
      if (var='aod')
        fileorig=diroriginal'/ncep/'mcase'/'scase'/'yy''mm''dd''hh'/aodf'yy''mm''dd''hh'.ctl'
      else
        fileorig=diroriginal'/ncep/'mcase'/'scase'/'yy''mm''dd''hh'/pgbf'yy''mm''dd''hh'.ctl'
      endif
    endif

    if (model='nasa')
      if (var='temp'|var='rh'|var='ttend')
        fileorig=diroriginal'/nasa/'mcase'/'scase'/nasa_3d_'yy''mm''dd'_'hh'.nc'
      else
        fileorig=diroriginal'/nasa/'mcase'/'scase'/nasa_2d_'yy''mm''dd'_'hh'.nc'
      endif
    endif

    if (model='cptec')
        if(scase='direct')
            fileorig=diroriginal'/cptec/aerosol/'dd'00/BRAMS-A-'yy'-'mm'-'dd'-'hh'0000-g1.ctl'
        endif
        if(scase='noaerosols')
            fileorig=diroriginal'/cptec/noaerosol/'dd'00/BRAMS-A-'yy'-'mm'-'dd'-'hh'0000-g1.ctl'
        endif

    endif

return fileorig

function msg(texto,arq)
    say texto
    rc=write(arq,texto)
return

function fileExists(filename)
  fileExistsList='./fileexist.tmp'
  '!rm 'fileExistsList
  '!ls 'filename ' > 'fileExistsList
  file=read(fileExistsList)
  linha=sublin(file,2)
  ret=subwrd(linha,1)
  rc=close(fileExistsList)
  say 'fileexists retorno: 'ret',filename='filename
return ret=filename

function openFile(fileToOpen)
  fileInSize=math_strlen(fileToOpen)
  fileExt=substr(fileToOpen,fileInSize-2,fileInSize)
  if(fileExt='.nc')
    'sdfopen 'fileToOpen
  else
    'open 'fileToOpen
  endif
return


