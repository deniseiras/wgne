
model='jma'
export model

opengrads -lc "aval.gs ${model} dust interactive"
opengrads -lc "aval.gs ${model} dust noaerosols"
opengrads -lc "aval.gs ${model} dust indirect"
opengrads -lc "aval.gs ${model} smoke interactive"
opengrads -lc "aval.gs ${model} smoke noaerosols"
opengrads -lc "aval.gs ${model} smoke direct"
opengrads -lc "aval.gs ${model} smoke indirect"
opengrads -lc "aval.gs ${model} pollution interactive"
opengrads -lc "aval.gs ${model} pollution noaerosols"
opengrads -lc "aval.gs ${model} pollution direct"
opengrads -lc "aval.gs ${model} pollution indirect"
