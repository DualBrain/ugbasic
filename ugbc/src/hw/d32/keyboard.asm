; /*****************************************************************************
;  * ugBASIC - an isomorphic BASIC language compiler for retrocomputers        *
;  *****************************************************************************
;  * Copyright 2021-2024 Marco Spedaletti (asimov@mclink.it)
;  *
;  * Licensed under the Apache License, Version 2.0 (the "License");
;  * you may not use this file except in compliance with the License.
;  * You may obtain a copy of the License at
;  *
;  * http//www.apache.org/licenses/LICENSE-2.0
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
;*                          KEYBOARD MANAGEMENT ON D32                         *
;*                                                                             *
;*                             by Marco Spedaletti                             *
;*                                                                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

SCANCODEREAD
	FCB $00, $00, $00, $00, $00, $00, $00, $00, $00
SCANCODEREADE

SCANCODEPOSITIONPRECALCULATED
    fcb $0, $0, $0, $0, $0, $0, $0
    fcb $1, $1, $1, $1, $1, $1, $1
    fcb $2, $2, $2, $2, $2, $2, $2
    fcb $3, $3, $3, $3, $3, $3, $3
    fcb $4, $4, $4, $4, $4, $4, $4
    fcb $5, $5, $5, $5, $5, $5, $5
    fcb $6, $6, $6, $6, $6, $6, $6
    fcb $7, $7, $7, $7, $7, $7, $7
    fcb $8, $8, $8, $8, $8, $8, $8

; ----------------------------------------------------------------------------
; KEYBOARDMANAGER
; ----------------------------------------------------------------------------
; This routine will be called during IRQ, and it will take some actions.
; First of all, the KEYBOARDACTUAL will be put to $FF (no key pressed).
; Then, hardware keyboard matrix will be decoded and stored it into the
; memory locations. If any key is pressed, it will be decoded and put into
; KEYBOARDACTUAL. Finally, the elapsed timer will be increased. Moreover,
; the ASF will be moved one step forward.

; This routine will decode the actual key.
;   Input: A - bitmap of key pressed
;          X - starting value of key pressed
;   Ouput: -
;   Changes: KEYBOARDACTUAL, KEYBOARDPREVIOUS, KEYBOARDASFSTATE

KEYBOARDPRESSED FCB 0
KEYBOARDTEMP FCB 0

KEYBOARDMANAGER

    PSHS D
    PSHS X

    ; Reset the key press detector.

    CLR KEYBOARDPRESSED
    CLR KEYBOARDTEMP

    LDA #$FF
    STA $FF02
    LDX #SCANCODEREAD
    LDA #$FE
SCANCODE0
    STA $FF02
    LDB $FF00
    EORB #$FF
    STB ,X+
    ANDB #$7F
    CMPB #$0
    BEQ SCANCODENEXT

    PSHS D

    TFR B, A
SCANCODENEXT2A
    TFR A, B
    ANDA #1
    CMPA #1
    BNE SCANCODENEXT2

    INC KEYBOARDPRESSED
    LDA KEYBOARDACTUAL 
    STA KEYBOARDPREVIOUS
    LDA KEYBOARDTEMP
    STA KEYBOARDACTUAL 
    
    JMP SCANCODENEXT3
SCANCODENEXT2
    TFR B, A
    LSRA
    INC KEYBOARDPRESSED
    INC KEYBOARDTEMP
    CMPA #0
    BNE SCANCODENEXT2A

SCANCODENEXT3

    PULS D

SCANCODENEXT
    LDB KEYBOARDTEMP
    ADDB #8
    STB KEYBOARDTEMP

    ORCC #$01
    ROLA
    CMPX #SCANCODEREADE
    BLS SCANCODE0
SCANCODEE

    LDA KEYBOARDPRESSED
    BNE SCANCODEE2
    LDA KEYBOARDPREVIOUS
    STA KEYBOARDTEMP
    LDA #$FF
    STA KEYBOARDACTUAL

SCANCODEE2

    ; Increase the elapsed timer.

    INC KEYBOARDELAPSED

    ; Update the ASF.

    JSR KEYBOARDASF

    ; Restore the used registers.

    PULS X
    PULS D
    RTS

KEYBOARDACTUAL          FCB $FF
KEYBOARDPREVIOUS        FCB $FF

; ----------------------------------------------------------------------------
; KEYBOARDDETECT
; ----------------------------------------------------------------------------
; This routine can be called to dectect if any key has been pressed. The
; actual key is read by KEYBOARD MANAGER that runs on IRQ, and the actual
; and previous values are stored by it.
;
; Return values:
; - C : key pressed (1) or not (0)
; - Z : key is equal to the previous detection (1) or different (0)
;
; The four values allowed by keyboard state machine follows:
;
; - DETECT (white): C = 0, Z = any
; - DETECT (green): C = 1, Z = 1
; - DETECT (red)  : C = 1, Z = 0

KEYBOARDDETECT

    ; Check if any key has been pressed.

    LDA KEYBOARDACTUAL
    CMPA #$FF
    BEQ KEYBOARDDETECTNONE

    ; A key has been pressed. Set the carry flag and check
    ; if it is the same as the previous pressed.

    ; CMP KEYBOARDPREVIOUS
    
    ORCC #$01
    RTS

KEYBOARDDETECTNONE
    ANDCC #$FE
    RTS

KEYBOARDELAPSED     FCB 0

@EMIT inputConfig.latency AS KEYBOARDLATENCY
@EMIT inputConfig.delay AS KEYBOARDDELAY
@EMIT inputConfig.release AS KEYBOARDRELEASE

KEYBOARDASFSTATE    FCB 0

; ----------------------------------------------------------------------------
; KEYBOARDLATENCYELAPSED
; ----------------------------------------------------------------------------
; This routine can be called to dectect if the latency time has elapsed.
; The KEYBOARDELAPSED timer is incremented by IRQ.
;
; Return values:
; - C : latency elapsed (1) or not (0)
;
; The four values allowed by keyboard state machine follows:
;
; - LATENCYELAPSED (white): C = 0
; - LATENCYELAPSED (green): C = 1

KEYBOARDLATENCYELAPSED
    LDA KEYBOARDELAPSED
    CMPA #KEYBOARDLATENCY
    RTS

; ----------------------------------------------------------------------------
; KEYBOARDRELEASEELAPSED
; ----------------------------------------------------------------------------
; This routine can be called to dectect if the release time has elapsed.
; The KEYBOARDELAPSED timer is incremented by IRQ.
;
; Return values:
; - C : release elapsed (1) or not (0)
;
; The four values allowed by keyboard state machine follows:
;
; - RELEASEELAPSED (white): C = 0
; - RELEASEELAPSED (green): C = 1

KEYBOARDRELEASEELAPSED
    LDA KEYBOARDELAPSED
    CMPA #KEYBOARDRELEASE
    RTS
    
; ----------------------------------------------------------------------------
; KEYBOARDDELAYLAPSED
; ----------------------------------------------------------------------------
; This routine can be called to dectect if the delay time has elapsed.
; The KEYBOARDELAPSED timer is incremented by IRQ.
;
; Return values:
; - C : delay elapsed (1) or not (0)
;
; The four values allowed by keyboard state machine follows:
;
; - DELAYELAPSED (white): C = 0
; - DELAYELAPSED (green): C = 1

KEYBOARDDELAYELAPSED
    LDA KEYBOARDELAPSED
    CMPA #KEYBOARDDELAY
    RTS

; ----------------------------------------------------------------------------
; KEYBOARDASF
; ----------------------------------------------------------------------------
; This routine will implement the ASF for keyboard. It means that will check
; for events and change the state of the ASF.
;

KEYBOARDASF

    ; Preserve used registers

    PSHS X
    PSHS D

    ; Decode the actual state.

    LDA KEYBOARDASFSTATE
    CMPA #0
    BEQ KEYBOARDASF0
    DECA
    BEQ KEYBOARDASF1
    DECA
    BEQ KEYBOARDASF2
    DECA
    BEQ KEYBOARDASF3
    JMP KEYBOARDASFDONE

    ; --------------
    ; STATE 0 - FREE
    ; --------------

KEYBOARDASF0

    ; We just check for detection of a key.
    ; It means both a key pressed (KEYBOARDDETECT green) 
    ; and a different key pressed from the previous
    ; one (KEYBOARDDETECT red)

    JSR KEYBOARDDETECT

    ; If no key has been detected, we can remain
    ; in this state.

    BCC KEYBOARDASFDONE

    ; Move to state 1, and reset the elapsed 
    ; timer at the same time.
    
KEYBOARDASFTO1

    ; Reset the elapsed timer.

    LDA #0
    STA KEYBOARDELAPSED

    ; Set the state.

    LDA #1
    STA KEYBOARDASFSTATE

    JMP KEYBOARDASFDONE

    ; -----------------
    ; STATE 1 - PRESSED
    ; -----------------

KEYBOARDASF1

    ; We just check for detection of a key.
    ; It means both a key pressed (KEYBOARDDETECT green) 
    ; and a different key pressed from the previous
    ; one (KEYBOARDDETECT red).
    
    JSR KEYBOARDDETECT

    ; If the no key has been pressed, 
    ; we go back to state 0.

    BCC KEYBOARDASFTO0

    ; ; If a different key has been pressed, 
    ; ; we go back to state 0.

    ; BEQ KEYBOARDASFTO0

    ; Chek for latency elapsed.

    JSR KEYBOARDLATENCYELAPSED

    ; If latency has passed, we move to the 
    ; state 2.

    BCC KEYBOARDASFTO2

    ; We remain in state 1.

    JMP KEYBOARDASFDONE

    ; Move to state 0, and reset the elapsed 
    ; timer at the same time.

KEYBOARDASFTO0

    ; Reset the elapsed timer.

    LDA #0
    STA KEYBOARDELAPSED

    ; Reset the state.

    STA KEYBOARDASFSTATE

    JMP KEYBOARDASFDONE

KEYBOARDASFTO2

    ; Reset the elapsed timer.

    LDA #0
    STA KEYBOARDELAPSED

    ; Set the state.

    LDA #2
    STA KEYBOARDASFSTATE

    JMP KEYBOARDASFDONE

    ; -----------------
    ; STATE 2 - PRESSED
    ; -----------------

KEYBOARDASF2

    ; We just check for detection of a key.
    ; It means both a key pressed (KEYBOARDDETECT green) 
    ; and a different key pressed from the previous
    ; one (KEYBOARDDETECT red).
    
    JSR KEYBOARDDETECT

    ; If the no key has been pressed, 
    ; we go back to state 0.

    BCC KEYBOARDASFTO0

    ; ; If a different key has been pressed, 
    ; ; we go back to state 0.

    ; BEQ KEYBOARDASFTO0

    ; Chek for release elapsed.

    JSR KEYBOARDRELEASEELAPSED

    ; If released has passed, we move to the 
    ; state 3.

    BCC KEYBOARDASFTO3

    ; We remain in state 2.

    JMP KEYBOARDASFDONE

    ; Move to state 3, and reset the elapsed 
    ; timer at the same time.

KEYBOARDASFTO3

    ; Reset the elapsed timer.

    LDA #0
    STA KEYBOARDELAPSED

    ; Set the next state.

    LDA #3
    STA KEYBOARDASFSTATE

    JMP KEYBOARDASFDONE

    ; -------------------
    ; STATE 3 - CONTINUED
    ; -------------------

KEYBOARDASF3

    ; We just check for detection of a key.
    ; It means both a key pressed (KEYBOARDDETECT green) 
    ; and a different key pressed from the previous
    ; one (KEYBOARDDETECT red).
    
    JSR KEYBOARDDETECT

    ; If the no key has been pressed, 
    ; we go back to state 0.

    BCC KEYBOARDASFTO0

    ; ; If a different key has been pressed, 
    ; ; we go back to state 0.

    ; BEQ KEYBOARDASFTO0

    ; Chek for delay elapsed.

    JSR KEYBOARDDELAYELAPSED

    ; If delay has passed, we move to the 
    ; state 2.

    BCC KEYBOARDASFTO2

    ; We remain in state 3.

    JMP KEYBOARDASFDONE

KEYBOARDASFDONE

    ; Restore used registers

    PULS D
    PULS X

    RTS

; ----------------------------------------------------------------------------
; WAITKEY
; ----------------------------------------------------------------------------
; This routine will wait for a key press. It means that it will, first, wait
; for the passing FREE(0)->PRESSED(1). Since the keyboard could already have
; a key pressed, we must also wait for FREE(0) state, first.

WAITKEY
    LDA KEYBOARDASFSTATE
    BEQ WAITKEY1
WAITKEY0
    LDA KEYBOARDASFSTATE
    BNE WAITKEY0
WAITKEY1
    LDA KEYBOARDASFSTATE
    BEQ WAITKEY1
    RTS

; ----------------------------------------------------------------------------
; WAITKEYRELEASE
; ----------------------------------------------------------------------------
; This routine will wait for a key press AND for a release. It means that it 
; will, first, WAITKEY. Then, it will wait for a FREE(0) state.

WAITKEYRELEASE
    JSR WAITKEY
WAITKEYRELEASE0
    LDA KEYBOARDASFSTATE
    BNE WAITKEYRELEASE0
    RTS

; ----------------------------------------------------------------------------
; KEYSTATE
; ----------------------------------------------------------------------------
; This routine can be called to detect if any key has been pressed. It does
; not disturb the hardware but it will use the memory map, that has been
; refreshed by the last IRQ.
;
; Input:
; - X : key to check
;
; Return values:
; - C : key pressed (1) or not (0)

KEYSTATE

    LDX #SCANCODEPOSITIONPRECALCULATED
    LDB A, X
	LDX #SCANCODEREAD
    LDB B,X
    ANDA #$07

KEYSTATEL1
    LSRB
    BCS KEYSTATE10
    CMPA #0
    BEQ KEYSTATE10
    DECA
    JMP KEYSTATEL1

KEYSTATE10
    RTS

; ----------------------------------------------------------------------------
; SCANCODE
; ----------------------------------------------------------------------------
; This routine can be called to retrieve the key pressed. It will not disturb
; the hardware, since it will use the KEYBOARDACTUAL value.
;
; Return values:
; - A : KEYBOARDACTUAL

SCANCODE
    LDA KEYBOARDACTUAL
    RTS

; ----------------------------------------------------------------------------
; ASCIICODE
; ----------------------------------------------------------------------------
; This routine can be called to retrieve the key pressed, converted into 
; ASCII code. It will not disturb the hardware, since it will use SCANCODE.
;
; Return values:
; - A : ASCII value

ASCIICODE
    JSR SCANCODE
	LDX #KEYBOARDMAP
    TFR A, B
	LDA B, X
    RTS

KEYBOARDMAP
    fcb '0','8','@','H','P','X',$0d,$00     ; // UNUSED
    fcb '1','9','A','I','Q','Y',$F9,$00     ; // CLR, UNUSED
    fcb '2','*','B','J','R','Z',$00,$00     ; // BRK, UNUSED
    fcb '3',',','C','K','S',$FA,$00,$00     ; // UP, UNUSED, UNUSED
    fcb '4','-','D','L','T',$FB,$00,$00     ; // DOWN, UNUSED, UNUSED
    fcb '5',$00,'E','M','U',$FC,$00,$00     ; // ??, .., LEFT, UNUSED, UNUSED
    fcb '6','/','F','N','V',$FD,$00,$00     ; // RIGHT, UNUSED, UNUSED
    fcb '7',' ','G','O','W',' ',$00,$FE     ; // UNUSED, SHIFT
    
; ----------------------------------------------------------------------------
; KEYPRESS
; ----------------------------------------------------------------------------
; This routine can be called to retrieve if a specific key is pressed, 
; counting the ASF state. It will return the value only in the duty cycle.
;
; Input:
; - X : key to check
;
; Return values:
; - C : key pressed (1) or not (0)

KEYPRESS
    LDA KEYBOARDASFSTATE
    BEQ KEYSINGLE0
    DECA
    BEQ KEYSINGLE1
    DECA
    BEQ KEYSINGLE2
    DECA
    BEQ KEYSINGLE3

KEYSINGLE0
KEYSINGLE2
    ANDCC #$FE
    RTS

KEYSINGLE1
KEYSINGLE3
    JSR KEYSTATE
    RTS

; ----------------------------------------------------------------------------
; KEYPRESSED
; ----------------------------------------------------------------------------
; This routine can be called to retrieve the pressed key, counting the ASF 
; state. It will return the value only in the duty cycle.
;
; Return values:
; - A : KEYBOARDACTUAL only if KEYBOARDASFSTATE = 1 or 3

KEYPRESSED
    LDA KEYBOARDASFSTATE
    BEQ KEYPRESSED0
    DECA
    BEQ KEYPRESSED1
    DECA
    BEQ KEYPRESSED2
    DECA
    BEQ KEYPRESSED3

KEYPRESSED0
KEYPRESSED2
    LDA #$FF
    RTS

KEYPRESSED1
KEYPRESSED3
    LDA KEYBOARDACTUAL
    RTS

; ----------------------------------------------------------------------------
; INKEY
; ----------------------------------------------------------------------------
; This routine can be called to retrieve the pressed key, counting the ASF 
; state, and converted to ASCII. It will return the value only in 
; the duty cycle.
;
; Return values:
; - A : ASCII CODE of KEYBOARDACTUAL only if KEYBOARDASFSTATE = 1 or 3

WAITKEY02
    PSHS D
WAITKEY02L1
    LDA KEYBOARDASFSTATE
    CMPA #1
    BEQ WAITKEY02L1
    CMPA #3
    BEQ WAITKEY02L1
    PULS D
    RTS

INKEY
    JSR KEYPRESSED
    CMPA #$FF
    BEQ INKEY0
	LDX #KEYBOARDMAP
    LDB A, X
    TFR B, A
    JSR WAITKEY02
    RTS
INKEY0
    LDA #0
    RTS
