
model=$1
export model

opengrads -lc "aval.gs ${model} dust interactive"
opengrads -lc "aval.gs ${model} dust noaerosols"
opengrads -lc "aval.gs ${model} smoke interactive"
opengrads -lc "aval.gs ${model} smoke noaerosols"
opengrads -lc "aval.gs ${model} pollution interactive"
opengrads -lc "aval.gs ${model} pollution noaerosols"

