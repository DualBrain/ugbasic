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
;*                           STARTUP ROUTINE ON SID                            *
;*                                                                             *
;*                             by Marco Spedaletti                             *
;*                                                                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

WAVEFORM_TRIANGLE                           = $10
WAVEFORM_SAW                                = $20
WAVEFORM_RECTANGLE                          = $40
WAVEFORM_NOISE                              = $80

IMF_TOKEN_WAIT1								= $ff
IMF_TOKEN_WAIT2								= $fe
IMF_TOKEN_CONTROL							= $d0
IMF_TOKEN_PROGRAM_CHANGE					= $e0
IMF_TOKEN_NOTE								= $40

IMF_INSTRUMENT_ACOUSTIC_GRAND_PIANO			= $01
IMF_INSTRUMENT_BRIGHT_ACOUSTIC_PIANO		= $02
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
IMF_INSTRUMENT_LEAD_3_CALLIOPE				= $53
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

; X: CHANNEL
SIDEXPLOSION:
    TXA
    LDX WAVEFORM_NOISE
    JSR SIDPROGCTR
    LDX #2
    LDY #11
    JSR SIDPROGAD
    LDX #0
    LDY #1
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDGUNSHOT:
    TXA
    LDX WAVEFORM_NOISE
    JSR SIDPROGCTR
    LDX #2
    LDY #4
    JSR SIDPROGAD
    LDX #0
    LDY #1
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDPIANO:
    TXA
    LDX #$8C
    LDY #$0A
    JSR SIDPROGPULSE
    LDX #2
    LDY #11
    JSR SIDPROGAD
    LDX #5
    LDY #0
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDCLAVI:
    TXA
    LDX #0
    LDY #4
    JSR SIDPROGPULSE
    LDX #3
    LDY #3
    JSR SIDPROGAD
    LDX #14
    LDY #3
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDXYLOPHONE:
    TXA
    LDX WAVEFORM_RECTANGLE
    JSR SIDPROGCTR
    LDX #0
    LDY #10
    JSR SIDPROGAD
    LDX #4
    LDY #14
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDROCKORGAN:
    TXA
    LDX WAVEFORM_TRIANGLE
    JSR SIDPROGCTR
    LDX #3
    LDY #3
    JSR SIDPROGAD
    LDX #14
    LDY #14
    JSR SIDPROGSR
    RTS

; Waveform:      Pulse
; Pulse Width:   1800
; Attack:        0
; Decay:         10
; Sustain:       0
; Release:       10
; Release Point: 2
; Filter:        Yes
; Filter Mode:   L
; Resonance:     10
; Autofilter:    10

; X: CHANNEL
SIDGUITAR:
    TXA
    LDX #8
    LDY #7
    JSR SIDPROGPULSE
    LDX #0
    LDY #10
    JSR SIDPROGAD
    LDX #0
    LDY #10
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDGUITARMUTED:
    TXA
    LDX #128
    LDY #0
    JSR SIDPROGPULSE
    LDX #1
    LDY #2
    JSR SIDPROGAD
    LDX #4
    LDY #3
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDBASS:
    TXA
    LDX WAVEFORM_TRIANGLE
    JSR SIDPROGCTR
    LDX #2
    LDY #10
    JSR SIDPROGAD
    LDX #12
    LDY #14
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDVIOLIN:
    TXA
    LDX WAVEFORM_TRIANGLE + WAVEFORM_RECTANGLE
    JSR SIDPROGCTR
    LDX #128
    LDY #0
    JSR SIDPROGPULSE
    LDX #10
    LDY #8
    JSR SIDPROGAD
    LDX #10
    LDY #9
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDTIMPANI:
    TXA
    LDX WAVEFORM_NOISE
    JSR SIDPROGCTR
    LDX #3
    LDY #8
    JSR SIDPROGAD
    LDX #3
    LDY #8
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDTRUMPET:
    TXA
    LDX WAVEFORM_TRIANGLE
    JSR SIDPROGCTR
    LDX #0
    LDY #15
    JSR SIDPROGAD
    LDX #2
    LDY #6
    JSR SIDPROGSR
    RTS

; X: CHANNEL
SIDBANJO:
    TXA
    LDX WAVEFORM_SAW + WAVEFORM_TRIANGLE
    JSR SIDPROGCTR
    LDX #0
    LDY #9
    JSR SIDPROGAD
    LDX #0
    LDY #9
    JSR SIDPROGSR
    RTS

; Waveform:      Pulse
; Pulse Width:   2048
; Pulse Sweep:   20
; Attack:        0
; Decay:         8
; Sustain:       0
; Release:       8
; Release Point: 1
; Vib. Depth:    3
; Vib. Rate:     2
; Portamento:    85-90

SIDDRUMS:
    TXA
    LDX #0
    LDY #8
    JSR SIDPROGPULSE
    LDX #0
    LDY #8
    JSR SIDPROGAD
    LDX #0
    LDY #8
    JSR SIDPROGSR
    RTS

; A: PROGRAM, X: CHANNEL
SIDSETPROGRAM:

; General MIDI Level 1 Instrument Families
; The General MIDI Level 1 instrument sounds are grouped by families. 
; In each family are 8 specific instruments.

; 0 special -> drums!

SIDSETPROGRAM0:
    CMP #$0
    BNE SIDSETPROGRAM1
    JSR SIDDRUMS
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ACOUSTIC_GRAND_PIANO			= $01

; 1-8	Piano

SIDSETPROGRAM1:
    SBC #1
    BNE SIDSETPROGRAM2
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ACOUSTIC_GRAND_PIANO			= $01
SIDSETPROGRAM2:
    SBC #1
    BNE SIDSETPROGRAM3
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_BRIGHT_ACOUSTIC_PIANO			= $02
SIDSETPROGRAM3:
    SBC #1
    BNE SIDSETPROGRAM4
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ELECTRIC_GRAND_PIANO			= $03
SIDSETPROGRAM4:
    SBC #1
    BNE SIDSETPROGRAM5
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_HONKY_TONK_PIANO				= $04
SIDSETPROGRAM5:
    SBC #1
    BNE SIDSETPROGRAM6
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ELECTRIC_PIANO1				= $05
SIDSETPROGRAM6:
    SBC #1
    BNE SIDSETPROGRAM7
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ELECTRIC_PIANO2				= $06
SIDSETPROGRAM7:
    SBC #1
    BNE SIDSETPROGRAM8
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_HARPSICHORD					= $07
SIDSETPROGRAM8:
    SBC #1
    BNE SIDSETPROGRAM9
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_CLAVI						= $08


SIDSETPROGRAM9:
    SBC #1
    BNE SIDSETPROGRAMA
    JSR SIDCLAVI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_CELESTA						= $09
SIDSETPROGRAMA:
    SBC #1
    BNE SIDSETPROGRAMB
    JSR SIDXYLOPHONE
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_GLOCKENSPIEL					= $0A
SIDSETPROGRAMB:
    SBC #1
    BNE SIDSETPROGRAMC
    JSR SIDXYLOPHONE
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_MUSIC_BOX					= $0B
SIDSETPROGRAMC:
    SBC #1
    BNE SIDSETPROGRAMD
    JSR SIDXYLOPHONE
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_VIBRAPHONE					= $0C
SIDSETPROGRAMD:
    SBC #1
    BNE SIDSETPROGRAME
    JSR SIDXYLOPHONE
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_MARIMBA						= $0D
SIDSETPROGRAME:
    SBC #1
    BNE SIDSETPROGRAMF
    JSR SIDXYLOPHONE
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_XYLOPHONE					= $0E
SIDSETPROGRAMF:
    SBC #1
    BNE SIDSETPROGRAM10
    JSR SIDXYLOPHONE
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TUBULAR_BELLS				= $0F
SIDSETPROGRAM10:
    SBC #1
    BNE SIDSETPROGRAM11
    JSR SIDXYLOPHONE
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_DULCIMER						= $10
SIDSETPROGRAM11:
    SBC #1
    BNE SIDSETPROGRAM12
    JSR SIDROCKORGAN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_DRAWBAR_ORGAN				= $11
SIDSETPROGRAM12:
    SBC #1
    BNE SIDSETPROGRAM13
    JSR SIDROCKORGAN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PERCUSSIVE_ORGAN				= $12
SIDSETPROGRAM13:
    SBC #1
    BNE SIDSETPROGRAM14
    JSR SIDROCKORGAN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ROCK_ORGAN					= $13
SIDSETPROGRAM14:
    SBC #1
    BNE SIDSETPROGRAM15
    JSR SIDROCKORGAN
    JMP SIDSETPROGRAMNN   
; IMF_INSTRUMENT_CHURCH_ORGAN					= $14
SIDSETPROGRAM15:
    SBC #1
    BNE SIDSETPROGRAM16
    JSR SIDROCKORGAN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_REED_ORGAN					= $15
SIDSETPROGRAM16:
    SBC #1
    BNE SIDSETPROGRAM17
    JSR SIDROCKORGAN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ACCORDION					= $16
SIDSETPROGRAM17:
    SBC #1
    BNE SIDSETPROGRAM18
    JSR SIDROCKORGAN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_HARMONICA					= $17
SIDSETPROGRAM18:
    SBC #1
    BNE SIDSETPROGRAM19
    JSR SIDROCKORGAN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TANGO_ACCORDION				= $18
SIDSETPROGRAM19:
    SBC #1
    BNE SIDSETPROGRAM1A
    JSR SIDGUITAR
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ACOUSTIC_GUITAR_NYLON			= $19
SIDSETPROGRAM1A:
    SBC #1
    BNE SIDSETPROGRAM1B
    JSR SIDGUITAR
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ACOUSTIC_GUITAR_STEEL			= $1A
SIDSETPROGRAM1B:
    SBC #1
    BNE SIDSETPROGRAM1C
    JSR SIDGUITAR
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ELECTRIC_GUITAR_JAZZ			= $1B
SIDSETPROGRAM1C:
    SBC #1
    BNE SIDSETPROGRAM1D
    JSR SIDGUITAR
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ELECTRIC_GUITAR_CLEAN			= $1C
SIDSETPROGRAM1D:
    SBC #1
    BNE SIDSETPROGRAM1E
    JSR SIDGUITARMUTED
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ELECTRIC_GUITAR_MUTED			= $1D
SIDSETPROGRAM1E:
    SBC #1
    BNE SIDSETPROGRAM1F
    JSR SIDGUITAR
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_OVERDRIVEN_GUITAR			= $1E
SIDSETPROGRAM1F:
    SBC #1
    BNE SIDSETPROGRAM20
    JSR SIDGUITAR
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_DISTORTION_GUITAR			= $1F
SIDSETPROGRAM20:
    SBC #1
    BNE SIDSETPROGRAM21
    JSR SIDGUITAR
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_GUITAR_HARMONICS				= $20
SIDSETPROGRAM21:
    SBC #1
    BNE SIDSETPROGRAM22
    JSR SIDBASS
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ACOUSTIC_BASS				= $21
SIDSETPROGRAM22:
    SBC #1
    BNE SIDSETPROGRAM23
    JSR SIDBASS
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ELECTRIC_BASS_FINGER			= $22
SIDSETPROGRAM23:
    SBC #1
    BNE SIDSETPROGRAM24
    JSR SIDBASS
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ELECTRIC_BASS_PICK			= $23
SIDSETPROGRAM24:
    SBC #1
    BNE SIDSETPROGRAM25
    JSR SIDBASS
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FRETLESS_BASS				= $24
SIDSETPROGRAM25:
    SBC #1
    BNE SIDSETPROGRAM26
    JSR SIDBASS
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SLAP_BASS_1					= $25
SIDSETPROGRAM26:
    SBC #1
    BNE SIDSETPROGRAM27
    JSR SIDBASS
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SLAP_BASS_2					= $26
SIDSETPROGRAM27:
    SBC #1
    BNE SIDSETPROGRAM28
    JSR SIDBASS
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SYNTH_BASS_1					= $27
SIDSETPROGRAM28:
    SBC #1
    BNE SIDSETPROGRAM29
    JSR SIDBASS
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SYNTH_BASS_2					= $28
SIDSETPROGRAM29:
    SBC #1
    BNE SIDSETPROGRAM2A
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_VIOLIN						= $29
SIDSETPROGRAM2A:
    SBC #1
    BNE SIDSETPROGRAM2B
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_VIOLA						= $2A
SIDSETPROGRAM2B:
    SBC #1
    BNE SIDSETPROGRAM2C
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_CELLO						= $2B
SIDSETPROGRAM2C:
    SBC #1
    BNE SIDSETPROGRAM2D
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_CONTRABASS					= $2C
SIDSETPROGRAM2D:
    SBC #1
    BNE SIDSETPROGRAM2E
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TREMOLO_STRINGS				= $2D
SIDSETPROGRAM2E:
    SBC #1
    BNE SIDSETPROGRAM2F
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PIZZICATO_STRINGS			= $2E
SIDSETPROGRAM2F:
    SBC #1
    BNE SIDSETPROGRAM30
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ORCHESTRAL_HARP				= $2F
SIDSETPROGRAM30:
    SBC #1
    BNE SIDSETPROGRAM31
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TIMPANI						= $30
SIDSETPROGRAM31:
    SBC #1
    BNE SIDSETPROGRAM32
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_STRING_ENSEMBLE_1			= $31
SIDSETPROGRAM32:
    SBC #1
    BNE SIDSETPROGRAM33
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_STRING_ENSEMBLE_2			= $32
SIDSETPROGRAM33:
    SBC #1
    BNE SIDSETPROGRAM34
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SYNTHSTRINGS_1				= $33
SIDSETPROGRAM34:
    SBC #1
    BNE SIDSETPROGRAM35
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SYNTHSTRINGS_2				= $34
SIDSETPROGRAM35:
    SBC #1
    BNE SIDSETPROGRAM36
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_CHOIR_AAHS					= $35
SIDSETPROGRAM36:
    SBC #1
    BNE SIDSETPROGRAM37
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_VOICE_OOHS					= $36
SIDSETPROGRAM37:
    SBC #1
    BNE SIDSETPROGRAM38
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SYNTH_VOICE					= $37
SIDSETPROGRAM38:
    SBC #1
    BNE SIDSETPROGRAM39
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ORCHESTRA_HIT				= $38
SIDSETPROGRAM39:
    SBC #1
    BNE SIDSETPROGRAM3A
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TRUMPET						= $39
SIDSETPROGRAM3A:
    SBC #1
    BNE SIDSETPROGRAM3B
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TROMBONE						= $3A
SIDSETPROGRAM3B:
    SBC #1
    BNE SIDSETPROGRAM3C
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TUBA							= $3B
SIDSETPROGRAM3C:
    SBC #1
    BNE SIDSETPROGRAM3D
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_MUTED_TRUMPET				= $3C
SIDSETPROGRAM3D:
    SBC #1
    BNE SIDSETPROGRAM3E
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FRENCH_HORN					= $3D
SIDSETPROGRAM3E:
    SBC #1
    BNE SIDSETPROGRAM3F
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_BRASS_SECTION				= $3E
SIDSETPROGRAM3F:
    SBC #1
    BNE SIDSETPROGRAM40
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SYNTHBRASS_1					= $3F
SIDSETPROGRAM40:
    SBC #1
    BNE SIDSETPROGRAM41
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SYNTHBRASS_2					= $40
SIDSETPROGRAM41:
    SBC #1
    BNE SIDSETPROGRAM42
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SOPRANO_SAX					= $41
SIDSETPROGRAM42:
    SBC #1
    BNE SIDSETPROGRAM43
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ALTO_SAX						= $42
SIDSETPROGRAM43:
    SBC #1
    BNE SIDSETPROGRAM44
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TENOR_SAX					= $43
SIDSETPROGRAM44:
    SBC #1
    BNE SIDSETPROGRAM45
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_BARITONE_SAX					= $44
SIDSETPROGRAM45:
    SBC #1
    BNE SIDSETPROGRAM46
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_OBOE							= $45
SIDSETPROGRAM46:
    SBC #1
    BNE SIDSETPROGRAM47
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_ENGLISH_HORN					= $46
SIDSETPROGRAM47:
    SBC #1
    BNE SIDSETPROGRAM48
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_BASSOON						= $47
SIDSETPROGRAM48:
    SBC #1
    BNE SIDSETPROGRAM49
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_CLARINET						= $48
SIDSETPROGRAM49:
    SBC #1
    BNE SIDSETPROGRAM4A
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PICCOLO						= $49
SIDSETPROGRAM4A:
    SBC #1
    BNE SIDSETPROGRAM4B
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FLUTE						= $4A
SIDSETPROGRAM4B:
    SBC #1
    BNE SIDSETPROGRAM4C
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_RECORDER						= $4B
SIDSETPROGRAM4C:
    SBC #1
    BNE SIDSETPROGRAM4D
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PAN_FLUTE					= $4C
SIDSETPROGRAM4D:
    SBC #1
    BNE SIDSETPROGRAM4E
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_BLOWN_BOTTLE					= $4D
SIDSETPROGRAM4E:
    SBC #1
    BNE SIDSETPROGRAM4F
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SHAKUHACHI					= $4E
SIDSETPROGRAM4F:
    SBC #1
    BNE SIDSETPROGRAM50
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_WHISTLE						= $4F
SIDSETPROGRAM50:
    SBC #1
    BNE SIDSETPROGRAM51
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_OCARINA						= $50
SIDSETPROGRAM51:
    SBC #1
    BNE SIDSETPROGRAM52
    JSR SIDVIOLIN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_LEAD_1_SQUARE				= $51
SIDSETPROGRAM52:
    SBC #1
    BNE SIDSETPROGRAM53
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_LEAD_2_SAWTOOTH				= $52
SIDSETPROGRAM53:
    SBC #1
    BNE SIDSETPROGRAM54
    JSR SIDXYLOPHONE
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_LEAD_3_CALLIOPE				= $53
SIDSETPROGRAM54:
    SBC #1
    BNE SIDSETPROGRAM55
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_LEAD_4_CHIFF					= $54
SIDSETPROGRAM55:
    SBC #1
    BNE SIDSETPROGRAM56
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_LEAD_5_CHARANG				= $55
SIDSETPROGRAM56:
    SBC #1
    BNE SIDSETPROGRAM57
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_LEAD_6_VOICE					= $56
SIDSETPROGRAM57:
    SBC #1
    BNE SIDSETPROGRAM58
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_LEAD_7_FIFTHS				= $57
SIDSETPROGRAM58:
    SBC #1
    BNE SIDSETPROGRAM59
; IMF_INSTRUMENT_LEAD_8_BASS_LEAD				= $58
SIDSETPROGRAM59:
    SBC #1
    BNE SIDSETPROGRAM5A
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PAD_1_NEW_AGE				= $59
SIDSETPROGRAM5A:
    SBC #1
    BNE SIDSETPROGRAM5B
    JSR SIDTRUMPET
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PAD_2_WARM					= $5A
SIDSETPROGRAM5B:
    SBC #1
    BNE SIDSETPROGRAM5C
    JSR SIDROCKORGAN
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PAD_3_POLYSYNTH				= $5B
SIDSETPROGRAM5C:
    SBC #1
    BNE SIDSETPROGRAM5D
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PAD_4_CHOIR					= $5C
SIDSETPROGRAM5D:
    SBC #1
    BNE SIDSETPROGRAM5E
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PAD_5_BOWED					= $5D
SIDSETPROGRAM5E:
    SBC #1
    BNE SIDSETPROGRAM5F
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PAD_6_METALLIC				= $5E
SIDSETPROGRAM5F:
    SBC #1
    BNE SIDSETPROGRAM60
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PAD_7_HALO					= $5F
SIDSETPROGRAM60:
    SBC #1
    BNE SIDSETPROGRAM61
    JSR SIDPIANO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_PAD_8_SWEEP					= $60
SIDSETPROGRAM61:
    SBC #1
    BNE SIDSETPROGRAM62
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FX_1_RAIN					= $61
SIDSETPROGRAM62:
    SBC #1
    BNE SIDSETPROGRAM63
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FX_2_SOUNDTRACK				= $62
SIDSETPROGRAM63:
    SBC #1
    BNE SIDSETPROGRAM64
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FX_3_CRYSTAL					= $63
SIDSETPROGRAM64:
    SBC #1
    BNE SIDSETPROGRAM65
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FX_4_ATMOSPHERE				= $64
SIDSETPROGRAM65:
    SBC #1
    BNE SIDSETPROGRAM66
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FX_5_BRIGHTNESS				= $65
SIDSETPROGRAM66:
    SBC #1
    BNE SIDSETPROGRAM67
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FX_6_GOBLINS					= $66
SIDSETPROGRAM67:
    SBC #1
    BNE SIDSETPROGRAM68
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FX_7_ECHOES					= $67
SIDSETPROGRAM68:
    SBC #1
    BNE SIDSETPROGRAM69
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FX_8_SCI_FI					= $68
SIDSETPROGRAM69:
    SBC #1
    BNE SIDSETPROGRAM6A
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SITAR						= $69
SIDSETPROGRAM6A:
    SBC #1
    BNE SIDSETPROGRAM6B
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_BANJO						= $6A
SIDSETPROGRAM6B:
    SBC #1
    BNE SIDSETPROGRAM6C
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SHAMISEN						= $6B
SIDSETPROGRAM6C:
    SBC #1
    BNE SIDSETPROGRAM6D
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_KOTO							= $6C
SIDSETPROGRAM6D:
    SBC #1
    BNE SIDSETPROGRAM6E
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_KALIMBA						= $6D
SIDSETPROGRAM6E:
    SBC #1
    BNE SIDSETPROGRAM6F
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_BAG_PIPE						= $6E
SIDSETPROGRAM6F:
    SBC #1
    BNE SIDSETPROGRAM70
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_FIDDLE						= $6F
SIDSETPROGRAM70:
    SBC #1
    BNE SIDSETPROGRAM71
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SHANAI						= $70
SIDSETPROGRAM71:
    SBC #1
    BNE SIDSETPROGRAM72
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TINKLE_BELL					= $71
SIDSETPROGRAM72:
    SBC #1
    BNE SIDSETPROGRAM73
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_AGOGO						= $72
SIDSETPROGRAM73:
    SBC #1
    BNE SIDSETPROGRAM74
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_STEEL_DRUMS					= $73
SIDSETPROGRAM74:
    SBC #1
    BNE SIDSETPROGRAM75
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_WOODBLOCK					= $74
SIDSETPROGRAM75:
    SBC #1
    BNE SIDSETPROGRAM76
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TAIKO_DRUM					= $75
SIDSETPROGRAM76:
    SBC #1
    BNE SIDSETPROGRAM77
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_MELODIC_TOM					= $76
SIDSETPROGRAM77:
    SBC #1
    BNE SIDSETPROGRAM78
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SYNTH_DRUM					= $77
SIDSETPROGRAM78:
    SBC #1
    BNE SIDSETPROGRAM79
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_REVERSE_CYMBAL				= $78
SIDSETPROGRAM79:
    SBC #1
    BNE SIDSETPROGRAM7A
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_GUITAR_FRET_NOISE			= $79
SIDSETPROGRAM7A:
    SBC #1
    BNE SIDSETPROGRAM7B
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_BREATH_NOISE					= $7A
SIDSETPROGRAM7B:
    SBC #1
    BNE SIDSETPROGRAM7C
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_SEASHORE						= $7B
SIDSETPROGRAM7C:
    SBC #1
    BNE SIDSETPROGRAM7D
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_BIRD_TWEET					= $7C
SIDSETPROGRAM7D:
    SBC #1
    BNE SIDSETPROGRAM7E
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_TELEPHONE_RING				= $7D
SIDSETPROGRAM7E:
    SBC #1
    BNE SIDSETPROGRAM7F
    JSR SIDBANJO
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_HELICOPTER					= $7E
SIDSETPROGRAM7F:
    SBC #1
    BNE SIDSETPROGRAM80
    JSR SIDTIMPANI
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_APPLAUSE						= $7F
SIDSETPROGRAM80:
    SBC #1
    BNE SIDSETPROGRAM81
    JSR SIDGUNSHOT
    JMP SIDSETPROGRAMNN
; IMF_INSTRUMENT_GUNSHOT						= $80
SIDSETPROGRAM81:
SIDSETPROGRAMNN:
    RTS

SIDSTARTUP:
    LDA #$7
    LDX #$32
    JSR SIDPROGCTR
    LDA #$7
    LDX #1
    LDY #1
    JSR SIDPROGAD
    LDA #$7
    LDX #2
    LDY #6
    JSR SIDPROGSR
    LDA #<SIDFREQTABLE
    STA SIDTMPPTR2
    LDA #>SIDFREQTABLE
    STA SIDTMPPTR2+1
    LDA #$0
    STA SIDTMPPTR
    STA SIDTMPPTR+1
    STA SIDJIFFIES
    STA SIDJIFFIES+1
    RTS

SIDSTART:
    LSR
    BCC SIDSTART0X
    JSR SIDSTART0
SIDSTART0X:
    LSR
    BCC SIDSTART1X
    JSR SIDSTART1
SIDSTART1X:
    LSR
    BCC SIDSTART2X
    JSR SIDSTART2
SIDSTART2X:
    RTS

SIDSTART0:
    PHA
    LDA SIDSHADOW
    AND #$F7
    ORA #$1
    STA SIDSHADOW
    STA $D404
    PLA
    LDX #15
    JMP SIDSTARTVOL

SIDSTART1:
    PHA
    LDA SIDSHADOW+1
    AND #$F7
    ORA #$1
    STA SIDSHADOW+1
    STA $D40B
    PLA
    LDX #15
    JMP SIDSTARTVOL

SIDSTART2:
    PHA
    LDA SIDSHADOW+2
    AND #$F7
    ORA #$1
    STA SIDSHADOW+2
    STA $D412
    PLA
    LDX #15
    JMP SIDSTARTVOL

SIDSTARTVOL:
    STX $D418
    RTS

SIDFREQ:
    JSR SIDCALCFREQ
    LSR
    BCC SIDFREQ0X
    JSR SIDFREQ0T
SIDFREQ0X:
    LSR
    BCC SIDFREQ1X
    JSR SIDFREQ1T
SIDFREQ1X:
    LSR
    BCC SIDFREQ2X
    JSR SIDFREQ2T
SIDFREQ2X:
    RTS

SIDCALCFREQ:
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

    LDA MATHPTR0
    TAX
    LDA MATHPTR1
    TAY
    PLA
    RTS

SIDFREQ0:
    JSR SIDCALCFREQ
SIDFREQ0T:
    JMP SIDPROGFREQ0

SIDFREQ1:
    JSR SIDCALCFREQ
SIDFREQ1T:
    JMP SIDPROGFREQ1

SIDFREQ2:
    JSR SIDCALCFREQ
SIDFREQ2T:
    JMP SIDPROGFREQ2

SIDPROGFREQ:
    LSR
    BCC SIDPROGFREQ0X
    JSR SIDPROGFREQ0
SIDPROGFREQ0X:
    LSR
    BCC SIDPROGFREQ1X
    JSR SIDPROGFREQ1
SIDPROGFREQ1X:
    LSR
    BCC SIDPROGFREQ2X
    JSR SIDPROGFREQ2
SIDPROGFREQ2X:
    RTS

SIDPROGFREQ0:
    PHA
    STX $D400
    STY $D401
    LDA SIDSHADOW
    ORA #$1
    STA SIDSHADOW
    STA $D404
    PLA
    RTS

SIDPROGFREQ1:
    PHA
    STX $D407
    STY $D408
    LDA SIDSHADOW+1
    ORA #$1
    STA SIDSHADOW+1
    STA $D40B
    PLA
    RTS

SIDPROGFREQ2:
    PHA
    STX $D40E
    STY $D40F
    LDA SIDSHADOW+2
    ORA #$1
    STA SIDSHADOW+2
    STA $D412
    PLA
    RTS

SIDPROGPULSE:
    LSR
    BCC SIDPROGPULSE0X
    JSR SIDPROGPULSE0
SIDPROGPULSE0X:
    LSR
    BCC SIDPROGPULSE1X
    JSR SIDPROGPULSE1
SIDPROGPULSE1X:
    LSR
    BCC SIDPROGPULSE2X
    JSR SIDPROGPULSE2
SIDPROGPULSE2X:
    RTS

SIDPROGPULSE0:
    PHA
    STX $D402
    STY $D403
    LDA #$42
    STA SIDSHADOW
    STA $D404
    PLA
    RTS

SIDPROGPULSE1:
    PHA
    STX $D409
    STY $D40A
    LDA #$42
    STA SIDSHADOW+1
    STA $D40B
    PLA
    RTS

SIDPROGPULSE2:
    PHA
    STX $D410
    STY $D411
    LDA #$42
    STA SIDSHADOW+2
    STA $D412
    PLA
    RTS

SIDPROGCTR:
    LSR
    BCC SIDPROGCTR0X
    JSR SIDPROGCTR0
SIDPROGCTR0X:
    LSR
    BCC SIDPROGCTR1X
    JSR SIDPROGCTR1
SIDPROGCTR1X:
    LSR
    BCC SIDPROGCTR2X
    JSR SIDPROGCTR2
SIDPROGCTR2X:
    RTS

SIDPROGCTR0:
    STX SIDSHADOW
    STX $D404
    RTS

SIDPROGCTR1:
    STX SIDSHADOW+1
    STX $D40B
    RTS

SIDPROGCTR2:
    STX SIDSHADOW+2
    STX $D412
    RTS

SIDPROGAD:
    LSR
    BCC SIDPROGAD0X
    JSR SIDPROGAD0
SIDPROGAD0X:
    LSR
    BCC SIDPROGAD1X
    JSR SIDPROGAD1
SIDPROGAD1X:
    LSR
    BCC SIDPROGAD2X
    JSR SIDPROGAD2
SIDPROGAD2X:
    RTS

SIDPROGAD0:
    PHA
    TXA
    ASL
    ASL
    ASL
    ASL
    STA MATHPTR0
    TYA
    AND #$0F
    ORA MATHPTR0
    STA $D405
    PLA
    RTS

SIDPROGAD1:
    PHA
    TXA
    ASL
    ASL
    ASL
    ASL
    STA MATHPTR0
    TYA
    AND #$0F
    ORA MATHPTR0
    STA $D40C
    PLA
    RTS

SIDPROGAD2:
    PHA
    TXA
    ASL
    ASL
    ASL
    ASL
    STA MATHPTR0
    TYA
    AND #$0F
    ORA MATHPTR0
    STA $D413
    PLA
    RTS

SIDPROGSR:
    LSR
    BCC SIDPROGSR0X
    JSR SIDPROGSR0
SIDPROGSR0X:
    LSR
    BCC SIDPROGSR1X
    JSR SIDPROGSR1
SIDPROGSR1X:
    LSR
    BCC SIDPROGSR2X
    JSR SIDPROGSR2
SIDPROGSR2X:
    RTS

SIDPROGSR0:
    PHA
    TXA
    ASL
    ASL
    ASL
    ASL
    STA MATHPTR0
    TYA
    AND #$0F
    ORA MATHPTR0
    STA $D406
    PLA
    RTS

SIDPROGSR1:
    PHA
    TXA
    ASL
    ASL
    ASL
    ASL
    STA MATHPTR0
    TYA
    AND #$0F
    ORA MATHPTR0
    STA $D40D
    PLA
    RTS

SIDPROGSR2:
    PHA
    TXA
    ASL
    ASL
    ASL
    ASL
    STA MATHPTR0
    TYA
    AND #$0F
    ORA MATHPTR0
    STA $D414
    PLA
    RTS

SIDSTOP:
    LSR
    BCC SIDSTOP0X
    JSR SIDSTOP0
SIDSTOP0X:
    LSR
    BCC SIDSTOP1X
    JSR SIDSTOP1
SIDSTOP1X:
    LSR
    BCC SIDSTOP2X
    JSR SIDSTOP2
SIDSTOP2X:
    RTS

SIDSTOP0:
    PHA
    LDA #$08
    STA SIDSHADOW
    STA $D404
    PLA
    RTS

SIDSTOP1:
    PHA
    LDA #$08
    STA SIDSHADOW+1
    STA $D40B
    PLA
    RTS

SIDSTOP2:
    PHA
    LDA #$08
    STA SIDSHADOW+2
    STA $D412
    PLA
    RTS

SIDSETDURATION:
    LSR
    BCC SIDSETDURATION0X
    JSR SIDSETDURATION0
SIDSETDURATION0X:
    LSR
    BCC SIDSETDURATION1X
    JSR SIDSETDURATION1
SIDSETDURATION1X:
    LSR
    BCC SIDSETDURATION2X
    JSR SIDSETDURATION2
SIDSETDURATION2X:
    RTS

SIDSETDURATION0:
    STX SIDTIMER
    RTS

SIDSETDURATION1:
    STX SIDTIMER+1
    RTS

SIDSETDURATION2:
    STX SIDTIMER+2
    RTS

SIDWAITDURATION:
    LSR
    BCC SIDWAITDURATION0X
    JSR SIDWAITDURATION0
SIDWAITDURATION0X:
    LSR
    BCC SIDWAITDURATION1X
    JSR SIDWAITDURATION1
SIDWAITDURATION1X:
    LSR
    BCC SIDWAITDURATION2X
    JSR SIDWAITDURATION2
SIDWAITDURATION2X:
    RTS

SIDWAITDURATION0:
    LDX SIDTIMER
    BNE SIDWAITDURATION0
    RTS

SIDWAITDURATION1:
    LDX SIDTIMER+1
    BNE SIDWAITDURATION1
    RTS

SIDWAITDURATION2:
    LDX SIDTIMER+2
    BNE SIDWAITDURATION2
    RTS

MUSICPLAYERRESET:
    LDA #$0
    STA SIDJIFFIES
    STA SIDTMPOFS
    LDA #$1
    STA SIDMUSICREADY
    LDA SIDTMPPTR_BACKUP
    STA SIDTMPPTR
    LDA SIDTMPPTR_BACKUP+1
    STA SIDTMPPTR+1
    LDA SIDLASTBLOCK_BACKUP
    STA SIDLASTBLOCK
    LDA SIDBLOCKS_BACKUP
    STA SIDBLOCKS
    BEQ MUSICPLAYERRESET3
    LDA #$FF
    JMP MUSICPLAYERRESET2
MUSICPLAYERRESET3:
    LDA SIDLASTBLOCK_BACKUP
MUSICPLAYERRESET2:
    STA SIDTMPLEN
    RTS

; This is the entry point for music play routine
; using the interrupt. 
MUSICPLAYER:
    PHP
    PHA
    LDA SIDMUSICREADY
    BEQ MUSICPLAYERQ
    LDA SIDMUSICPAUSE
    BEQ MUSICPLAYERQ2
    TXA
    PHA
    TYA
    PHA
    JSR MUSICPLAYERR
    PLA
    TAY
    PLA
    TAX
    JMP MUSICPLAYERQ2
MUSICPLAYERQ:
    LDA SIDTIMER
    BEQ MUSICPLAYERQ0
    DEC SIDTIMER
    BNE MUSICPLAYERQ0
    JSR SIDSTOP0
MUSICPLAYERQ0:
    LDA SIDTIMER+1
    BEQ MUSICPLAYERQ1
    DEC SIDTIMER+1
    BNE MUSICPLAYERQ1
    JSR SIDSTOP1
MUSICPLAYERQ1:
    LDA SIDTIMER+2
    BEQ MUSICPLAYERQ2
    DEC SIDTIMER+2
    BNE MUSICPLAYERQ2
    JSR SIDSTOP2
MUSICPLAYERQ2:
    PLA
    PLP
    RTS

MUSICPLAYERR:

; This is the entry point to wait until the waiting jiffies
; are exausted.
MUSICPLAYERL1:
    LDA SIDJIFFIES
    BEQ MUSICPLAYERL1B
    DEC SIDJIFFIES
    RTS

; This is the entry point to read the next instruction.
MUSICPLAYERL1B:
    ; Read the next byte.
    JSR MUSICREADNEXTBYTE

    ; Is the file NOT finished?
    CPX #$0
    BNE MUSICPLAYERL1X

    ; Let's stop the play!
    LDA #$0
    STA SIDMUSICREADY
    STA SIDTMPPTR
    STA SIDTMPPTR+1
    STA SIDJIFFIES
    RTS

; This is the entry point to decode the instruction
; (contained into the A register).
MUSICPLAYERL1X:
    ASL
    BCS MUSICPLAYERL1X0
    JMP MUSICWAIT
MUSICPLAYERL1X0:
    ASL
    BCS MUSICPLAYERL1X0A
    JMP MUSICSETPROGRAM
MUSICPLAYERL1X0A:
    ASL
    BCS MUSICPLAYERL1X1
    JMP MUSICNOTEON
MUSICPLAYERL1X1:
    ASL
    BCS MUSICPLAYERL1X2
    JMP MUSICNOTEOFF
MUSICPLAYERL1X2:
    RTS

MUSICWAIT:
    LSR
    STA SIDJIFFIES
    RTS

MUSICSETPROGRAM:
    LSR
    LSR
    TAX
    JSR MUSICREADNEXTBYTE
    JSR SIDSETPROGRAM
    RTS    

MUSICNOTEOFF:
    LSR
    LSR
    LSR
    LSR
    JSR SIDSTOP
    RTS    

MUSICNOTEON:
    LSR
    LSR
    LSR
    PHA
    JSR MUSICREADNEXTBYTE
    ASL
    TAY
    LDA (SIDTMPPTR2),Y
    TAX
    INY
    LDA (SIDTMPPTR2),Y
    TAY
    PLA
    JSR SIDPROGFREQ
    RTS

; This routine has been added in order to read the
; next byte in a "blocked" byte stream.
MUSICREADNEXTBYTE:
    ; Let's check if we arrived at the end of the block.
    ; In that case, we must "load" the next block (or end
    ; the reading).
    LDY SIDTMPOFS
    CPY SIDTMPLEN
    BEQ MUSICREADNEXTBYTELE

MUSICREADNEXTBYTE2:
    LDX #$ff
    LDA (SIDTMPPTR), Y
    INY
    STY SIDTMPOFS
    RTS

; This is the entry point if a block (256 or less bytes)
; is finished, and we must move forward to the next block.
MUSICREADNEXTBYTELE:
    ; Is file finished?
    LDA SIDBLOCKS
    BEQ MUSICREADNEXTBYTEEND

    ; Increment the base address by 256
    INC SIDTMPPTR+1

    ; Decrement the number of remaining blocks
    DEC SIDBLOCKS

    ; If remaining blocks are 0, the last block
    ; length is different from 256 bytes.
    BEQ MUSICPLAYERLE2

    ; Remaining block is 256 bytes lenght.
    LDY #$FF
    STY SIDTMPLEN

    ; Put the index to 0
    LDY #$0
    STY SIDTMPOFS

    JMP MUSICREADNEXTBYTE2

    ; Remaining block is <256 bytes lenght.
MUSICPLAYERLE2:
    LDY SIDLASTBLOCK
    STY SIDTMPLEN

    ; Put the index to 0
    LDY #$0
    STY SIDTMPOFS

    JMP MUSICREADNEXTBYTE2

MUSICREADNEXTBYTEEND:
    LDX #$0
    RTS
