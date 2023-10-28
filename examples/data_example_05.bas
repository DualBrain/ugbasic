REM @english
REM EMBEDDED DATA USING DATA LOAD
REM
REM This small example will show how to use the ''DATA LOAD'' instruction.
REM We are using the ''READ SAFE'' variant.
REM 
REM @italian
REM INCLUDENDO DEI DATI USANDO L'ISTRUZIONE DATA LOAD
REM
REM Questo piccolo esempio mostra come usare l'istruzione ''DATA LOAD''.
REM In questo esempio usiamo la variante ''READ SAFE''.
REM
REM @include atari,atarixl,c128,c128z,c64,coco,coco3,coleco,cpc,d32,d64,mo5,msx1,pc128op,plus4,sc3000,sg1000,vg5000,vic20,zx

DATA LOAD "spock.csv" AS TEXT

DIM x1 AS POSITION, y1 AS POSITION, x2 AS POSITION, y2 AS POSITION
DO
    READ SAFE x1, SAFE y1, SAFE x2, SAFE y2
    PRINT x1;" ";y1;" ";x2;" ";y2
    WAIT KEY
    IF READ END THEN
        HALT
    ENDIF
LOOP
