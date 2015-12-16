
model='cptec'
export model

opengrads -lc "aval.gs ${model} smoke direct"
opengrads -lc "aval.gs ${model} smoke noaerosols"


