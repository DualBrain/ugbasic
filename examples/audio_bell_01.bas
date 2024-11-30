﻿REM @english
REM AUDIO GENERATION PLAY THE BELL
REM
REM This small example will emit a bell-like sound.
REM 
REM @italian
REM AUDIO E MUSICA SUONARE IL CAMPANELLO
REM
REM Questo piccolo esempio emetterà un suono simile a una campana.
REM

    CLS

    FOR f=0 TO 107
        PRINT "BELL ";f
        BELL f
        WAIT (f/10+1)*1000 MS
    NEXT
