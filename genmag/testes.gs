

function main(args)

filelist='filelist.tmp'

'!rm'filelist
'!ls *.nc > 'filelist

i=1
while(i<10)
  filesindir=read(filelist)
  say sublin(filesindir,2)
  lin1=sublin(filesindir,1)
  say lin1

  if(subwrd(lin1,1)=0)
    break
  endif

  i=i+1
endwhile
say '----i='i
ret=close(filelist)
quit
