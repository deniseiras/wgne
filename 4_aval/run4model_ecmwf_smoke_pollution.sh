
model='ecmwf'
export model

opengrads -lc "aval.gs ${model} smoke direct"
opengrads -lc "aval.gs ${model} smoke noaerosols"
opengrads -lc "aval.gs ${model} pollution direct"
opengrads -lc "aval.gs ${model} pollution noaerosols"

