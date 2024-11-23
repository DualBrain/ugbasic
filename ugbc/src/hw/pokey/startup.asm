; /*****************************************************************************
;  * ugBASIC - an isomorphic BASIC language compiler for retrocomputers        *
;  *****************************************************************************
;  * Copyright 2021-2024 Marco Spedaletti (asimov@mclink.it)
;  *
;  * Licensed under the Apache License, Version 2.0 (the "License");
;  * you may not use this file eXcept in compliance with the License.
;  * You may obtain a copy of the License at
;  *
;  * http://www.apache.org/licenses/LICENSE-2.0
;  *
;  * Unless required by applicable law or agreed to in writing, software
;  * distributed under the License is distributed on an "AS IS" BASIS,
;  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either eXpress or implied.
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
;*                           STARTUP ROUTINE ON POKEY                            *
;*                                                                             *
;*                             by Marco Spedaletti                             *
;*                                                                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

IMF_TOKEN_WAIT1								= $ff
IMF_TOKEN_WAIT2								= $fe
IMF_TOKEN_CONTROL							= $d0
IMF_TOKEN_PROGRAM_CHANGE					= $e0
IMF_TOKEN_NOTE								= $40

IMF_INSTRUMENT_ACOUSTIC_GRAND_PIANO			= $01
IMF_INSTRUMENT_BRIGHT_ACOUSTIC_PIANO			= $02
IMF_INSTRUMENT_ELECTRIC_GRAND_PIANO			= $03
IMF_INSTRUMENT_HONKY_TONK_PIANO				= $04
IMF_INSTRUMENT_ELECTRIC_PIANO1				= $05
IMF_INSTRUMENT_ELECTRIC_PIANO2				= $06
IMF_INSTRUMENT_HARPSICHORD					= $07
IMF_INSTRUMENT_CLAVI						= $08
IMF_INSTRUMENT_CELESTA						= $09
IMF_INSTRUMENT_GLOCKENSPIEL					= $0A
IMF_INSTRUMENT_MUSIC_BOX					= $0B
IMF_INSTRUMENT_VIBRAPHONE					= $0C
IMF_INSTRUMENT_MARIMBA						= $0D
IMF_INSTRUMENT_XYLOPHONE					= $0E
IMF_INSTRUMENT_TUBULAR_BELLS				= $0F
IMF_INSTRUMENT_DULCIMER						= $10
IMF_INSTRUMENT_DRAWBAR_ORGAN				= $11
IMF_INSTRUMENT_PERCUSSIVE_ORGAN				= $12
IMF_INSTRUMENT_ROCK_ORGAN					= $13
IMF_INSTRUMENT_CHURCH_ORGAN					= $14
IMF_INSTRUMENT_REED_ORGAN					= $15
IMF_INSTRUMENT_ACCORDION					= $16
IMF_INSTRUMENT_HARMONICA					= $17
IMF_INSTRUMENT_TANGO_ACCORDION				= $18
IMF_INSTRUMENT_ACOUSTIC_GUITAR_NYLON			= $19
IMF_INSTRUMENT_ACOUSTIC_GUITAR_STEEL			= $1A
IMF_INSTRUMENT_ELECTRIC_GUITAR_JAZZ			= $1B
IMF_INSTRUMENT_ELECTRIC_GUITAR_CLEAN			= $1C
IMF_INSTRUMENT_ELECTRIC_GUITAR_MUTED			= $1D
IMF_INSTRUMENT_OVERDRIVEN_GUITAR			= $1E
IMF_INSTRUMENT_DISTORTION_GUITAR			= $1F
IMF_INSTRUMENT_GUITAR_HARMONICS				= $20
IMF_INSTRUMENT_ACOUSTIC_BASS				= $21
IMF_INSTRUMENT_ELECTRIC_BASS_FINGER			= $22
IMF_INSTRUMENT_ELECTRIC_BASS_PICK			= $23
IMF_INSTRUMENT_FRETLESS_BASS				= $24
IMF_INSTRUMENT_SLAP_BASS_1					= $25
IMF_INSTRUMENT_SLAP_BASS_2					= $26
IMF_INSTRUMENT_SYNTH_BASS_1					= $27
IMF_INSTRUMENT_SYNTH_BASS_2					= $28
IMF_INSTRUMENT_VIOLIN						= $29
IMF_INSTRUMENT_VIOLA						= $2A
IMF_INSTRUMENT_CELLO						= $2B
IMF_INSTRUMENT_CONTRABASS					= $2C
IMF_INSTRUMENT_TREMOLO_STRINGS				= $2D
IMF_INSTRUMENT_PIZZICATO_STRINGS			= $2E
IMF_INSTRUMENT_ORCHESTRAL_HARP				= $2F
IMF_INSTRUMENT_TIMPANI						= $30
IMF_INSTRUMENT_STRING_ENSEMBLE_1			= $31
IMF_INSTRUMENT_STRING_ENSEMBLE_2			= $32
IMF_INSTRUMENT_SYNTHSTRINGS_1				= $33
IMF_INSTRUMENT_SYNTHSTRINGS_2				= $34
IMF_INSTRUMENT_CHOIR_AAHS					= $35
IMF_INSTRUMENT_VOICE_OOHS					= $36
IMF_INSTRUMENT_SYNTH_VOICE					= $37
IMF_INSTRUMENT_ORCHESTRA_HIT				= $38
IMF_INSTRUMENT_TRUMPET						= $39
IMF_INSTRUMENT_TROMBONE						= $3A
IMF_INSTRUMENT_TUBA							= $3B
IMF_INSTRUMENT_MUTED_TRUMPET				= $3C
IMF_INSTRUMENT_FRENCH_HORN					= $3D
IMF_INSTRUMENT_BRASS_SECTION				= $3E
IMF_INSTRUMENT_SYNTHBRASS_1					= $3F
IMF_INSTRUMENT_SYNTHBRASS_2					= $40
IMF_INSTRUMENT_SOPRANO_SAX					= $41
IMF_INSTRUMENT_ALTO_SAX						= $42
IMF_INSTRUMENT_TENOR_SAX					= $43
IMF_INSTRUMENT_BARITONE_SAX					= $44
IMF_INSTRUMENT_OBOE							= $45
IMF_INSTRUMENT_ENGLISH_HORN					= $46
IMF_INSTRUMENT_BASSOON						= $47
IMF_INSTRUMENT_CLARINET						= $48
IMF_INSTRUMENT_PICCOLO						= $49
IMF_INSTRUMENT_FLUTE						= $4A
IMF_INSTRUMENT_RECORDER						= $4B
IMF_INSTRUMENT_PAN_FLUTE					= $4C
IMF_INSTRUMENT_BLOWN_BOTTLE					= $4D
IMF_INSTRUMENT_SHAKUHACHI					= $4E
IMF_INSTRUMENT_WHISTLE						= $4F
IMF_INSTRUMENT_OCARINA						= $50
IMF_INSTRUMENT_LEAD_1_SQUARE				= $51
IMF_INSTRUMENT_LEAD_2_SAWTOOTH				= $52
IMF_INSTRUMENT_LEAD_3_CALLIOPE				= $A7
IMF_INSTRUMENT_LEAD_4_CHIFF					= $54
IMF_INSTRUMENT_LEAD_5_CHARANG				= $55
IMF_INSTRUMENT_LEAD_6_VOICE					= $56
IMF_INSTRUMENT_LEAD_7_FIFTHS				= $57
IMF_INSTRUMENT_LEAD_8_BASS_LEAD				= $58
IMF_INSTRUMENT_PAD_1_NEW_AGE				= $59
IMF_INSTRUMENT_PAD_2_WARM					= $5A
IMF_INSTRUMENT_PAD_3_POLYSYNTH				= $5B
IMF_INSTRUMENT_PAD_4_CHOIR					= $5C
IMF_INSTRUMENT_PAD_5_BOWED					= $5D
IMF_INSTRUMENT_PAD_6_METALLIC				= $5E
IMF_INSTRUMENT_PAD_7_HALO					= $5F
IMF_INSTRUMENT_PAD_8_SWEEP					= $60
IMF_INSTRUMENT_FX_1_RAIN					= $61
IMF_INSTRUMENT_FX_2_SOUNDTRACK				= $62
IMF_INSTRUMENT_FX_3_CRYSTAL					= $63
IMF_INSTRUMENT_FX_4_ATMOSPHERE				= $64
IMF_INSTRUMENT_FX_5_BRIGHTNESS				= $65
IMF_INSTRUMENT_FX_6_GOBLINS					= $66
IMF_INSTRUMENT_FX_7_ECHOES					= $67
IMF_INSTRUMENT_FX_8_SCI_FI					= $68
IMF_INSTRUMENT_SITAR						= $69
IMF_INSTRUMENT_BANJO						= $6A
IMF_INSTRUMENT_SHAMISEN						= $6B
IMF_INSTRUMENT_KOTO							= $6C
IMF_INSTRUMENT_KALIMBA						= $6D
IMF_INSTRUMENT_BAG_PIPE						= $6E
IMF_INSTRUMENT_FIDDLE						= $6F
IMF_INSTRUMENT_SHANAI						= $70
IMF_INSTRUMENT_TINKLE_BELL					= $71
IMF_INSTRUMENT_AGOGO						= $72
IMF_INSTRUMENT_STEEL_DRUMS					= $73
IMF_INSTRUMENT_WOODBLOCK					= $74
IMF_INSTRUMENT_TAIKO_DRUM					= $75
IMF_INSTRUMENT_MELODIC_TOM					= $76
IMF_INSTRUMENT_SYNTH_DRUM					= $77
IMF_INSTRUMENT_REVERSE_CYMBAL				= $78
IMF_INSTRUMENT_GUITAR_FRET_NOISE			= $79
IMF_INSTRUMENT_BREATH_NOISE					= $7A
IMF_INSTRUMENT_SEASHORE						= $7B
IMF_INSTRUMENT_BIRD_TWEET					= $7C
IMF_INSTRUMENT_TELEPHONE_RING				= $7D
IMF_INSTRUMENT_HELICOPTER					= $7E
IMF_INSTRUMENT_APPLAUSE						= $7F
IMF_INSTRUMENT_GUNSHOT						= $80

@IF deployed.music
    POKEYJIFFIES = $09 ; $0A
    POKEYTMPPTR2 = $03 ; $04
    POKEYTMPPTR = $05 ; $06
@ENDIF

POKEYSETVOL:
    PHA
    LSR
    BCC POKEYSETVOL0X
    PHA
    JSR POKEYSETVOL0
    PLA
POKEYSETVOL0X:
    LSR
    BCC POKEYSETVOL1X
    PHA
    JSR POKEYSETVOL1
    PLA
POKEYSETVOL1X:
    LSR
    BCC POKEYSETVOL2X
    PHA
    JSR POKEYSETVOL2
    PLA
POKEYSETVOL2X:
    LSR
    BCC POKEYSETVOL3X
    PHA
    JSR POKEYSETVOL3
    PLA
POKEYSETVOL3X:
    PLA
    RTS
POKEYSETVOL0:
    LDA POKEYAUDC0
    AND #$F0
    STA $D201
    STA POKEYAUDC0
    TXA
    STA POKEYVOL0
    ORA POKEYAUDC0
    STA $D201
    STA POKEYAUDC0
    RTS
POKEYSETVOL1:
    LDA POKEYAUDC1
    AND #$F0
    STA $D203
    STA POKEYAUDC1
    TXA
    STA POKEYVOL1
    ORA POKEYAUDC1
    STA $D203
    STA POKEYAUDC1
    RTS
POKEYSETVOL2:
    LDA POKEYAUDC2
    AND #$F0
    STA $D205
    STA POKEYAUDC2
    TXA
    STA POKEYVOL2
    ORA POKEYAUDC2
    STA $D205
    STA POKEYAUDC2
    RTS
POKEYSETVOL3:
    LDA POKEYAUDC3
    AND #$F0
    STA $D207
    STA POKEYAUDC3
    TXA
    STA POKEYVOL3
    ORA POKEYAUDC3
    STA $D207
    STA POKEYAUDC3
    RTS

POKEYFREQ:
    JSR POKEYCALCFREQ
    LSR
    BCC POKEYFREQ0X
    JSR POKEYFREQ0T
POKEYFREQ0X:
    LSR
    BCC POKEYFREQ1X
    JSR POKEYFREQ1T
POKEYFREQ1X:
    LSR
    BCC POKEYFREQ2X
    JSR POKEYFREQ2T
POKEYFREQ2X:
    RTS

POKEYCALCFREQ:
    PHA
    TXA
    STA MATHPTR0
    TYA
    STA MATHPTR1

    ROL MATHPTR0
    ASL MATHPTR1
    ROL MATHPTR0
    ASL MATHPTR1
    ROL MATHPTR0
    ASL MATHPTR1
    ROL MATHPTR0
    ASL MATHPTR1
    ROL MATHPTR0
    ASL MATHPTR1
    ROL MATHPTR0
    ASL MATHPTR1
    ROL MATHPTR0
    ASL MATHPTR1
    ROL MATHPTR0
    ASL MATHPTR1

    SEC
    LDA #$FF
    SBC MATHPTR0
    TAX
    LDA #$0
    TAY
    PLA
    RTS

POKEYPROGDIST:
    LSR
    BCC POKEYPROGDIST0X
    PHA
    JSR POKEYPROGDIST0
    PLA
POKEYPROGDIST0X:
    LSR
    BCC POKEYPROGDIST1X
    PHA
    JSR POKEYPROGDIST1
    PLA
POKEYPROGDIST1X:
    LSR
    BCC POKEYPROGDIST2X
    PHA
    JSR POKEYPROGDIST2
    PLA
POKEYPROGDIST2X:
    LSR
    BCC POKEYPROGDIST3X
    PHA
    JSR POKEYPROGDIST3
    PLA
POKEYPROGDIST3X:
    RTS

POKEYPROGDIST0:
    LDA POKEYAUDC0
    AND #$0F
    STA $D201
    STA POKEYAUDC0
    TXA
    ASL
    ASL
    ASL
    ASL
    ORA POKEYAUDC0
    STA $D201
    STA POKEYAUDC0
    RTS
POKEYPROGDIST1:
    LDA POKEYAUDC1
    AND #$0F
    STA $D203
    STA POKEYAUDC1
    TXA
    ASL
    ASL
    ASL
    ASL
    ORA POKEYAUDC1
    STA $D203
    STA POKEYAUDC1
    RTS
POKEYPROGDIST2:
    LDA POKEYAUDC2
    AND #$0F
    STA $D205
    STA POKEYAUDC2
    TXA
    ASL
    ASL
    ASL
    ASL
    ORA POKEYAUDC2
    STA $D205
    STA POKEYAUDC2
    RTS
POKEYPROGDIST3:
    LDA POKEYAUDC3
    AND #$0F
    STA $D207
    STA POKEYAUDC3
    TXA
    ASL
    ASL
    ASL
    ASL
    ORA POKEYAUDC3
    STA $D207
    STA POKEYAUDC3
    RTS

POKEYFREQ0:
    JSR POKEYCALCFREQ
POKEYFREQ0T:
    JMP POKEYPROGFREQ0

POKEYFREQ1:
    JSR POKEYCALCFREQ
POKEYFREQ1T:
    JMP POKEYPROGFREQ1

POKEYFREQ2:
    JSR POKEYCALCFREQ
POKEYFREQ2T:
    JMP POKEYPROGFREQ2

POKEYPROGFREQ:
    LSR
    BCC POKEYPROGFREQ0X
    JSR POKEYPROGFREQ0
POKEYPROGFREQ0X:
    LSR
    BCC POKEYPROGFREQ1X
    JSR POKEYPROGFREQ1
POKEYPROGFREQ1X:
    LSR
    BCC POKEYPROGFREQ2X
    JSR POKEYPROGFREQ2
POKEYPROGFREQ2X:
    LSR
    BCC POKEYPROGFREQ3X
    JSR POKEYPROGFREQ3
POKEYPROGFREQ3X:
    RTS

POKEYPROGFREQ0:
    STX $D200
    RTS

POKEYPROGFREQ1:
    STX $D202
    RTS

POKEYPROGFREQ2:
    STX $D204
    RTS

POKEYPROGFREQ3:
    STX $D206
    RTS

POKEYSETDURATION:
    LSR
    BCC POKEYSETDURATION0X
    JSR POKEYSETDURATION0
POKEYSETDURATION0X:
    LSR
    BCC POKEYSETDURATION1X
    JSR POKEYSETDURATION1
POKEYSETDURATION1X:
    LSR
    BCC POKEYSETDURATION2X
    JSR POKEYSETDURATION2
POKEYSETDURATION2X:
    LSR
    BCC POKEYSETDURATION3X
    JSR POKEYSETDURATION3
POKEYSETDURATION3X:
    RTS

POKEYSETDURATION0:
    STX POKEYTIMER
    RTS

POKEYSETDURATION1:
    STX POKEYTIMER+1
    RTS

POKEYSETDURATION2:
    STX POKEYTIMER+2
    RTS

POKEYSETDURATION3:
    STX POKEYTIMER+3
    RTS

POKEYWAITDURATION:
    LSR
    BCC POKEYWAITDURATION0X
    JSR POKEYWAITDURATION0
POKEYWAITDURATION0X:
    LSR
    BCC POKEYWAITDURATION1X
    JSR POKEYWAITDURATION1
POKEYWAITDURATION1X:
    LSR
    BCC POKEYWAITDURATION2X
    JSR POKEYWAITDURATION2
POKEYWAITDURATION2X:
    LSR
    BCC POKEYWAITDURATION3X
    JSR POKEYWAITDURATION3
POKEYWAITDURATION3X:
    RTS

POKEYWAITDURATION0:
    LDX POKEYTIMER
    BNE POKEYWAITDURATION0
    RTS

POKEYWAITDURATION1:
    LDX POKEYTIMER+1
    BNE POKEYWAITDURATION1
    RTS

POKEYWAITDURATION2:
    LDX POKEYTIMER+2
    BNE POKEYWAITDURATION2
    RTS

POKEYWAITDURATION3:
    LDX POKEYTIMER+3
    BNE POKEYWAITDURATION3
    RTS

POKEYSTARTUP:
    LDA #$A0
    STA $D201
    STA $D203
    STA $D205
    STA $D207
    LDA #<POKEYFREQTABLE
    STA POKEYTMPPTR2
    LDA #>POKEYFREQTABLE
    STA POKEYTMPPTR2+1
    LDA #$0
    STA POKEYTMPPTR
    STA POKEYTMPPTR+1
@IF deployed.music
    STA POKEYJIFFIES
    STA POKEYJIFFIES+1
@ENDIF

    LDX #$0A
    JSR POKEYPROGDIST
    LDA #0
    STA $D208
    RTS

POKEYSTART:
    LSR
    BCC POKEYSTART0X
    PHA
    JSR POKEYSTART0
    PLA
POKEYSTART0X:
    LSR
    BCC POKEYSTART1X
    PHA
    JSR POKEYSTART1
    PLA
POKEYSTART1X:
    LSR
    BCC POKEYSTART2X
    PHA
    JSR POKEYSTART2
    PLA
POKEYSTART2X:
    LSR
    BCC POKEYSTART3X
    PHA
    JSR POKEYSTART3
    PLA
POKEYSTART3X:
    RTS

POKEYSTART0:
    LDA POKEYAUDC0
    AND #$F8
    ORA POKEYVOL0
    STA $D201
    STA POKEYAUDC0
    RTS

POKEYSTART1:
    LDA POKEYAUDC1
    AND #$F8
    ORA POKEYVOL1
    STA $D203
    STA POKEYAUDC1
    RTS

POKEYSTART2:
    LDA POKEYAUDC2
    AND #$F8
    ORA POKEYVOL2
    STA $D205
    STA POKEYAUDC2
    RTS

POKEYSTART3:
    LDA POKEYAUDC3
    AND #$F8
    ORA POKEYVOL3
    STA $D207
    STA POKEYAUDC3
    RTS

POKEYSTOP:
    LSR
    BCC POKEYSTOP0X
    JSR POKEYSTOP0
POKEYSTOP0X:
    LSR
    BCC POKEYSTOP1X
    JSR POKEYSTOP1
POKEYSTOP1X:
    LSR
    BCC POKEYSTOP2X
    JSR POKEYSTOP2
POKEYSTOP2X:
    LSR
    BCC POKEYSTOP3X
    JSR POKEYSTOP3
POKEYSTOP3X:
    RTS

POKEYSTOP0:
    LDA POKEYAUDC0
    AND #$F0
    STA $D201
    STA POKEYAUDC0
    RTS

POKEYSTOP1:
    LDA POKEYAUDC1
    AND #$F0
    STA $D203
    STA POKEYAUDC1
    RTS

POKEYSTOP2:
    LDA POKEYAUDC2
    AND #$F0
    STA $D205
    STA POKEYAUDC2
    RTS

POKEYSTOP3:
    LDA POKEYAUDC3
    AND #$F0
    STA $D207
    STA POKEYAUDC3
    RTS

POKEYTIMERMANAGER:
    PHA
    LDA POKEYTIMER
    BEQ POKEYTIMERMANAGER0
    DEC POKEYTIMER
    BNE POKEYTIMERMANAGER0
    JSR POKEYSTOP0
POKEYTIMERMANAGER0:
    LDA POKEYTIMER+1
    BEQ POKEYTIMERMANAGER1
    DEC POKEYTIMER+1
    BNE POKEYTIMERMANAGER1
    JSR POKEYSTOP1
POKEYTIMERMANAGER1:
    LDA POKEYTIMER+2
    BEQ POKEYTIMERMANAGER2
    DEC POKEYTIMER+2
    BNE POKEYTIMERMANAGER2
    JSR POKEYSTOP2
POKEYTIMERMANAGER2:
    LDA POKEYTIMER+3
    BEQ POKEYTIMERMANAGER3
    DEC POKEYTIMER+3
    BNE POKEYTIMERMANAGER3
    JSR POKEYSTOP3
POKEYTIMERMANAGER3:
    PLA
    RTS