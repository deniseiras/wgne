BUFR 
SVN
https://svn.cptec.inpe.br/mbufrtools/branches/basic_version

export MBUFR_TABLES=/home2/denis/dev/basic_version/bufrtables


BUFFER to ASC:

????
~/bin/bufrascii -i synop_1_20120415.bufr -o saida.txt

GERA ARQUIVOS DAT DIA a DIA, HORA A HORA, MIN a MIN
~/bin/bufrascii synop_1_20120415.bufr 0 0


/home2/denis/bin/bufrdump -i synop_1_20120415.bufr -o saida -m 2
