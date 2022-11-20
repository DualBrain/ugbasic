; /*****************************************************************************
;  * ugBASIC - an isomorphic BASIC language compiler for retrocomputers        *
;  *****************************************************************************
;  * Copyright 2021-2022 Marco Spedaletti (asimov@mclink.it)
;  *
;  * Licensed under the Apache License, Version 2.0 (the "License");
;  * you may not use this file except in compliance with the License.
;  * You may obtain a copy of the License at
;  *
;  * http://www.apache.org/licenses/LICENSE-2.0
;  *
;  * Unless required by applicable law or agreed to in writing, software
;  * distributed under the License is distributed on an "AS IS" BASIS,
;  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;  * See the License for the specific language governing permissions and
;  * limitations under the License.
;  *----------------------------------------------------------------------------
;  * Concesso in licenza secondo i termini della Licenza Apache, versione 2.0
;  * (la "Licenza"); è proibito usare questo file se non in conformità alla
;  * Licenza. Una copia della Licenza è disponibile all'indirizzo:
;  *
;  * http://www.apache.org/licenses/LICENSE-2.0
;  *
;  * Se non richiesto dalla legislazione vigente o concordato per iscritto,
;  * il software distribuito nei termini della Licenza è distribuito
;  * "COSì COM'è", SENZA GARANZIE O CONDIZIONI DI ALCUN TIPO, esplicite o
;  * implicite. Consultare la Licenza per il testo specifico che regola le
;  * autorizzazioni e le limitazioni previste dalla medesima.
;  ****************************************************************************/
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                                                             *
;*                          IMAGES ROUTINE FOR CPC                             *
;*                                                                             *
;*                             by Marco Spedaletti                             *
;*                                                                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; IMAGET:     DB 0      -> A
; IMAGEX:     DB 0      -> E
; IMAGEY:     DB 0      -> D
; IMAGEW:     DB 0      -> C
; IMAGEH:     DB 0      -> B
; IMAGEH2:    DB 0      -> ?
; PTR:        DW 0      -> HL

; ----------------------------------------------------------------------------
; - Put image on bitmap
; ----------------------------------------------------------------------------

PUTIMAGE:

    LD A, (CURRENTTILEMODE)
    CP 1
    RET Z

    LD C, (HL)
    INC HL
    LD A, (HL)
    LD IXL, A
    INC HL
    LD B, (HL)
    INC HL

    DEC D
    PUSH DE

    LD A, (CURRENTMODE)
    CP 0
    JP Z, PUTIMAGE0
    CP 1
    JP Z, PUTIMAGE1
    CP 2
    JP Z, PUTIMAGE2
    CP 3
    JP Z, PUTIMAGE3
    POP DE
    RET

PUTIMAGE0:
PUTIMAGE3:

    SRL C

PUTIMAGE0L2:

    POP DE

    INC D

    PUSH DE

    PUSH HL
    CALL CPCVIDEOPOS
    LD DE, HL
    POP HL

    PUSH BC
PUTIMAGE0L1:
    LD A, (IMAGEF)
    AND $20
    CP $20
    JR Z, PUTIMAGE0L1T

    ; Calculate new pixels
    LD A, (HL)
    ; Draw them
    LD (DE),A

    JP PUTIMAGE0L1T0

PUTIMAGE0L1T:
    PUSH BC
    LD A, 0
    LD IXH, A
    LD A, (HL)
    AND $AA
    CP $0
    JR Z, PUTIMAGE0L1T2
    LD A, IXH
    OR $AA
    LD IXH, A
PUTIMAGE0L1T2:
    LD A, (HL)
    AND $55
    CP $0
    JR Z, PUTIMAGE0L1T3
    LD A, IXH
    OR $55
    LD IXH, A
PUTIMAGE0L1T3:
    LD A, IXH
    XOR $FF
    LD B, A
    LD A, (DE)
    AND B
    LD B, A
    LD A, (HL)
    AND IXH
    ORA B
    ; Draw them
    LD (DE),A
    POP BC

PUTIMAGE0L1T0:
    INC DE
    INC HL

    DEC C
    JR NZ, PUTIMAGE0L1
    LD A, IXL
    CP $0
    JR Z, PUTIMAGE0DONEROW
    DEC IXL
    LD A, $FF
    LD C, A
    JP PUTIMAGE0L1
PUTIMAGE0DONEROW:
    POP BC

    LD A, (IMAGEF)
    AND $41
    CP $41
    JR Z, PUTIMAGE0DONEROW2
    AND $40
    CP $40
    JR NZ, PUTIMAGE0DONEROW2
    OR $01
    LD (IMAGEF), A

    PUSH DE
    LD A, C
    LD E, A
    LD A, 0
    LD D, A
    AND A
    SBC HL, DE
    POP DE
    JP PUTIMAGE0L2

PUTIMAGE0DONEROW2:
    LD A, (IMAGEF)
    AND $FE
    LD (IMAGEF), A

    DEC B
    JP NZ, PUTIMAGE0L2
    
    LD A, 16
    LD B, A
    LD A, 0
    LD C, A

    LD A, (IMAGEF)
    AND $20
    CP $20
    JR NZ, PUTIMAGE0DONEROWL1

    INC HL
    INC C

PUTIMAGE0DONEROWL1:
    LD A, (HL)
    LD IXL, A
    LD IXH, C
    LD IYL, 1
    CALL CPCUPDATEPALETTE
    INC HL
    INC C
    LD A, C
    CP 16
    JR NZ, PUTIMAGE0DONEROWL1

    POP DE

    JP PUTIMAGEDONE

PUTIMAGE1:

    SRL C
    SRL C

PUTIMAGE1L2:

    POP DE

    INC D

    PUSH DE

    PUSH HL
    CALL CPCVIDEOPOS
    LD DE, HL
    POP HL

    PUSH BC
PUTIMAGE1L1:
    ; Calculate new pixels
    LD A, (HL)
    ; Draw them
    LD (DE),A

    INC DE
    INC HL

    DEC C
    JR NZ, PUTIMAGE1L1
    LD A, IXL
    CP $0
    JR Z, PUTIMAGE1DONEROW
    DEC IXL
    LD A, $FF
    LD C, A
    JP PUTIMAGE1L1
PUTIMAGE1DONEROW:
    POP BC

    LD A, (IMAGEF)
    AND $41
    CP $41
    JR Z, PUTIMAGE1DONEROW2
    AND $40
    CP $40
    JR NZ, PUTIMAGE1DONEROW2
    OR $01
    LD (IMAGEF), A

    PUSH DE
    LD A, C
    LD E, A
    LD A, 0
    LD D, A
    AND A
    SBC HL, DE
    POP DE
    JP PUTIMAGE0L2

PUTIMAGE1DONEROW2:
    LD A, (IMAGEF)
    AND $FE
    LD (IMAGEF), A

    DEC B
    JR NZ, PUTIMAGE1L2
    
    LD A, (HL)
    LD IXL, A
    LD IXH, 0
    LD IYL, 1
    CALL CPCUPDATEPALETTE

    INC HL

    LD A, (HL)
    LD IXL, A
    LD IXH, 1
    LD IYL, 1
    CALL CPCUPDATEPALETTE

    INC HL

    LD A, (HL)
    LD IXL, A
    LD IXH, 2
    LD IYL, 1
    CALL CPCUPDATEPALETTE

    INC HL

    LD A, (HL)
    LD IXL, A
    LD IXH, 3
    LD IYL, 1
    CALL CPCUPDATEPALETTE

    POP DE

    JP PUTIMAGEDONE

PUTIMAGE2:

    SRL C
    SRL C
    SRL C

PUTIMAGE2L2:

    POP DE

    INC D

    PUSH DE

    PUSH HL
    CALL CPCVIDEOPOS
    LD DE, HL
    POP HL

    PUSH BC
PUTIMAGE2L1:
    ; Calculate new pixels
    LD A, (HL)
    ; Draw them
    LD (DE),A

    INC DE
    INC HL

    DEC C
    JR NZ, PUTIMAGE2L1
    LD A, IXL
    CP $0
    JR Z, PUTIMAGE2DONEROW
    DEC IXL
    LD A, $FF
    LD C, A
    JP PUTIMAGE2L1
PUTIMAGE2DONEROW:
    POP BC

    LD A, (IMAGEF)
    AND $41
    CP $41
    JR Z, PUTIMAGE2DONEROW2
    AND $40
    CP $40
    JR NZ, PUTIMAGE2DONEROW2
    OR $01
    LD (IMAGEF), A

    PUSH DE
    LD A, C
    LD E, A
    LD A, 0
    LD D, A

    AND A
    SBC HL, DE
    POP DE
    JP PUTIMAGE0L2

PUTIMAGE2DONEROW2:
    LD A, (IMAGEF)
    AND $FE
    LD (IMAGEF), A

    DEC B
    JR NZ, PUTIMAGE2L2

    LD A, (HL)
    LD IXL, A
    LD IXH, 0
    LD IYL, 1
    CALL CPCUPDATEPALETTE

    INC HL

    LD A, (HL)
    LD IXL, A
    LD IXH, 1
    LD IYL, 1
    CALL CPCUPDATEPALETTE

    POP DE

    JP PUTIMAGEDONE

PUTIMAGEDONE:
    RET