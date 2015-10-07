PROJETO BUFR
 
Objetivo:

 Ler os arquivos .dat, gerados a partir dos arquivos do tipo BUFR, através do
 programa bufrscan (INPE) e gera arquivos de saída contendo os valores de n
 variáveis 

 Programa stationVars:

 Compilar: ./compile.sh

 Uso:
     ./generateVars.x <pathEntrada> <pathSaida> <numVariaveis>
 Ex: ./generateVars.x "/home/usr/dirEntrada" "/home/usr/dirSaida" 49
