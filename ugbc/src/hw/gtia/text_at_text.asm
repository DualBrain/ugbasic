; /*****************************************************************************
;  * ugBASIC - an isomorphic BASIC language compiler for retrocomputers        *
;  *****************************************************************************
;  * Copyright 2021-2024 Marco Spedaletti (asimov@mclink.it)
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
;*                      TEXT AT GIVEN POSITION ON GTIA                         *
;*                                                                             *
;*                             by Marco Spedaletti                             *
;*                                                                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

TEXTATTILEMODE:
    LDA TEXTSIZE
    BNE TEXTATTILEMODEGO
    RTS

TEXTATTILEMODEGO:
    LDA TEXTADDRESS
    STA COPYOFTEXTADDRESS
    LDA TEXTADDRESS+1
    STA COPYOFTEXTADDRESS+1
    LDA #0
    STA TABSTODRAW
    LDA COLORMAPADDRESS
    STA COPYOFCOLORMAPADDRESS
    LDA COLORMAPADDRESS+1
    STA COPYOFCOLORMAPADDRESS+1

    LDA CURRENTMODE
    CMP #2
    BNE TEXTATANTIC2X
    JMP TEXTATANTIC2
TEXTATANTIC2X:
    CMP #6
    BNE TEXTATANTIC6X
    JMP TEXTATANTIC6
TEXTATANTIC6X:    
    CMP #7
    BNE TEXTATANTIC7X
    JMP TEXTATANTIC7
TEXTATANTIC7X:    
    CMP #3
    BNE TEXTATANTIC3X
    JMP TEXTATANTIC3
TEXTATANTIC3X:    
    CMP #4
    BNE TEXTATANTIC4X
    JMP TEXTATANTIC4
TEXTATANTIC4X:    
    CMP #5
    BNE TEXTATANTIC5X
    JMP TEXTATANTIC5
TEXTATANTIC5X:
    RTS

CALCPOS:

    LDX YCURSYS
    BEQ CALCPOSSKIP
CALCPOSLOOP1:
    CLC
    LDA CURRENTTILESWIDTH
    ADC COPYOFTEXTADDRESS
    STA COPYOFTEXTADDRESS
    LDA #0
    ADC COPYOFTEXTADDRESS+1
    STA COPYOFTEXTADDRESS+1
    DEX
    BNE CALCPOSLOOP1

CALCPOSSKIP:
    CLC
    LDA XCURSYS
    ADC COPYOFTEXTADDRESS
    STA COPYOFTEXTADDRESS
    LDA #0
    ADC COPYOFTEXTADDRESS+1
    STA COPYOFTEXTADDRESS+1

    RTS

;-----------------------------------------------------------------------------
; TILE MODE
;-----------------------------------------------------------------------------

TEXTATANTIC6:
TEXTATANTIC7:
@INLINE PALETTEPRESERVE2C5 [_PEN], [#$0]
@INLINE PALETTEPRESERVE2C6 [_PEN], [#$0]
@INLINE PALETTEPRESERVE2C7 [_PEN], [#$0]
@INLINE PALETTEPRESERVE2C8 [_PEN], [#$0]
    JMP TEXTATANTICX

TEXTATANTIC3:
TEXTATANTIC2:
TEXTATANTIC4:
TEXTATANTIC5:
@INLINE PALETTEPRESERVE2C5 [_PEN], [#$0]
@INLINE PALETTEPRESERVE2C6 [_PAPER], [#$0]

TEXTATANTICX:
    JSR CALCPOS

    LDX TEXTSIZE
    LDY #$0
TEXTATLOOP2:

    LDA TABSTODRAW
    BEQ TEXTATNSKIPTAB
    JMP TEXTATSKIPTAB

TEXTATNSKIPTAB:
    LDA (TEXTPTR),Y

    CMP #$7f
    BEQ TEXTATTAB
    CMP #31
    BCS TEXTATXCC
    JMP TEXTATCC

TEXTATXCC:
    ; JSR PIPPO
    JSR TEXTATDECODE
    LDA SCREENCODE
    JMP TEXTATSP0

TEXTATTAB:
    LDA XCURSYS
TEXTATTAB2:
    CMP TABCOUNT
    BCC TEXTATTAB3
    SEC
    SBC TABCOUNT
    JMP TEXTATTAB2
TEXTATTAB3:
    STA TMPPTR
    LDA TABCOUNT
    SEC
    SBC TMPPTR
    STA TABSTODRAW
    JMP TEXTATNEXT

TEXTATCC:
    CMP #13
    BEQ TEXTATLF
    CMP #10
    BEQ TEXTATLF
    CMP #09
    BEQ TEXTATTAB
    CMP #01
    BEQ TEXTATPEN
    CMP #02
    BEQ TEXTATPAPER
    CMP #03
    BEQ TEXTATCMOVEPREPARE
    CMP #04
    BEQ TEXTATXAT
    CMP #05
    BEQ TEXTATCLS
    JMP TEXTATNEXT

TEXTATCLS:
    TYA
    PHA
    TXA
    PHA
    JSR CLS
    PLA
    TAX
    PLA
    TAY
    JMP TEXTATNEXT

TEXTATXAT:
    JMP TEXTATAT

TEXTATLF:
    INC TEXTPTR
    DEX
    JMP TEXTATNEXT2

TEXTATPEN:
    INC TEXTPTR
    DEX
    LDA (TEXTPTR), Y
    CMP #$FF
    BNE TEXTATPEN2
    LDA #$0
TEXTATPEN2:    
    STA _PEN
    INC TEXTPTR
    DEX
    JMP TEXTATNEXT

TEXTATPAPER:
    INC TEXTPTR
    DEX
    LDA (TEXTPTR), Y
    INC TEXTPTR
    DEX
    JMP TEXTATNEXT

TEXTATCMOVEPREPARE:
    INC TEXTPTR
    DEX
    LDA (TEXTPTR), Y
    STA CLINEX
    INC TEXTPTR
    DEX
    LDA (TEXTPTR), Y
    STA CLINEY

TEXTATCMOVE:
    CLC
    LDA CLINEX
    ADC XCURSYS
    CMP CONSOLEX1
    BCC TEXTATCMOVESKIPX
    CMP CONSOLEX2
    BCS TEXTATCMOVESKIPX
    STA XCURSYS
    LDA CLINEX

    CMP #$80
    BCC TEXTATCMOVEADDPX

TEXTATCMOVESUBPX:
    EOR #$FF
    CLC
    ADC #$1
    STA CLINEX
    SEC
    LDA COPYOFTEXTADDRESS
    SBC CLINEX
    STA COPYOFTEXTADDRESS
    LDA COPYOFTEXTADDRESS+1
    SBC #0
    STA COPYOFTEXTADDRESS+1

    JMP TEXTATCMOVESKIPX

TEXTATCMOVEADDPX:

    CLC
    ADC COPYOFTEXTADDRESS
    STA COPYOFTEXTADDRESS
    LDA #0
    ADC COPYOFTEXTADDRESS+1
    STA COPYOFTEXTADDRESS+1
    JMP TEXTATCMOVESKIPX

TEXTATCMOVESKIPX:

    CLC
    LDA CLINEY
    ADC YCURSYS
    CMP CONSOLEY1
    BCC TEXTATCMOVESKIPY
    CMP CONSOLEY2
    BCS TEXTATCMOVESKIPY
    STA YCURSYS

TEXTATCMOVEADDPY:
    TXA
    PHA
    LDA CLINEY
    CMP #$80
    BCC TEXTATCMOVELOOPYP
    JMP TEXTATCMOVELOOPYM

TEXTATCMOVELOOPYP:
    TAX
TEXTATCMOVELOOPY:

    CLC
    LDA CURRENTTILESWIDTH
    ADC COPYOFTEXTADDRESS
    STA COPYOFTEXTADDRESS
    LDA #0
    ADC COPYOFTEXTADDRESS+1
    STA COPYOFTEXTADDRESS+1

    DEX
    BNE TEXTATCMOVELOOPY
    PLA
    TAX
    JMP TEXTATCMOVESKIPY

TEXTATCMOVELOOPYM:
    EOR #$FF
    CLC
    ADC #$1
    STA CLINEY
    TAX
TEXTATCMOVELOOPY2:

    SEC
    LDA COPYOFTEXTADDRESS
    SBC CURRENTTILESWIDTH
    STA COPYOFTEXTADDRESS
    LDA COPYOFTEXTADDRESS+1
    SBC #0
    STA COPYOFTEXTADDRESS+1

    DEX
    BNE TEXTATCMOVELOOPY2
    PLA
    TAX
    JMP TEXTATCMOVESKIPY

TEXTATCMOVESKIPY:
    INC TEXTPTR
    DEY
    JMP TEXTATNEXT

TEXTATAT:
    INC TEXTPTR
    DEX
    LDA (TEXTPTR), Y
    SEC
    SBC XCURSYS
    ADC CONSOLEX1
    STA CLINEX
    INC TEXTPTR
    DEX
    LDA (TEXTPTR), Y
    SEC
    SBC YCURSYS
    ADC CONSOLEY1
    STA CLINEY
    JMP TEXTATCMOVE

TEXTATSP0:
    STA (COPYOFTEXTADDRESS),Y
    JMP TEXTATINCX

TEXTATSKIPTAB:
    DEC TABSTODRAW
    JMP TEXTATINCX

TEXTATINCX:
    INC XCURSYS
    DEX
    BNE TEXTATEND2X
    JMP TEXTATEND2
TEXTATEND2X:
    LDA XCURSYS
    CMP CONSOLEX2
    BEQ TEXTATNEXT
    BCS TEXTATNEXT2
    JMP TEXTATNEXT
TEXTATNEXT2:
    LDA CONSOLEX1
    STA XCURSYS
    INC YCURSYS
    LDA YCURSYS
    CMP CONSOLEY2
    BEQ TEXTATNEXT
    BCS TEXTATNEXT3
    JMP TEXTATNEXT
TEXTATNEXT3:

    LDA COPYOFTEXTADDRESS
    PHA
    LDA COPYOFTEXTADDRESS+1
    PHA

    LDA #$FE
    STA DIRECTION
    JSR VSCROLLT

    PLA
    STA COPYOFTEXTADDRESS+1
    PLA
    STA COPYOFTEXTADDRESS

    DEC YCURSYS
    SEC
    LDA COPYOFTEXTADDRESS
    SBC CURRENTTILESWIDTH
    STA COPYOFTEXTADDRESS
    LDA COPYOFTEXTADDRESS+1
    SBC #0
    STA COPYOFTEXTADDRESS+1

TEXTATNEXT:
    LDA TABSTODRAW
    BEQ TEXTATXLOOP2
    JMP TEXTATLOOP2
TEXTATXLOOP2:
    INY
    CPX #0
    BEQ TEXTATEND
    JMP TEXTATLOOP2
TEXTATEND2:
TEXTATEND:
    RTS