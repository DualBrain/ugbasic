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
;*                         KEYBOARD MANAGEMENT ON ATARI                        *
;*                                                                             *
;*                             by Marco Spedaletti                             *
;*                                                                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

SCANCODEREAD:
	.BYTE $00, $00, $00, $00, $00, $00, $00, $00
    .BYTE $00, $00, $00, $00, $00, $00, $00, $00

SCANCODEPTR = $9

KEYBOARDBUFFERRESET:
    LDX #15
    LDA #$00
KEYBOARDBUFFERRESETL1:
    STA SCANCODEREAD, X
    DEX
    CPX #$FF
    RTS

; This routine will be called by IRQ when a key is pressd.

VKEYDREPLACEMENT:

    ; First of all, save the key "as is", and preserve
    ; the previous key pressed.

    LDA KEYBOARDACTUAL
    STA KEYBOARDPREVIOUS
    LDA $D209
    AND #$3F
    STA KEYBOARDACTUAL

    ; Then calculate what bitmask to use.

    AND #$07
    TAX
    LDA BITMASK, X
    TAX

    ; Now we calculate the offset for the keyboard buffer.

    LDA KEYBOARDACTUAL
    LSR
    LSR
    LSR
    TAY

    ; We update the keyboard buffer.

	LDA #<SCANCODEREAD
	STA SCANCODEPTR
	LDA #>SCANCODEREAD
	STA SCANCODEPTR+1
    TXA
    STA (SCANCODEPTR), Y 

VKEYDREPLACEMENTDONE:

    PLA
    RTI
    
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

KEYBOARDPRESSED: .BYTE 0

KEYBOARDMANAGER:

    ; Preserve used registers.

	PHA
	TYA
	PHA
	TXA
	PHA

    ; Save the previous key pressed.

KEYBOARDMANAGERDONE:

    INC KEYBOARDELAPSED

    ; Check if key is still pressed.

    LDA $D20F
    AND #$04
    BEQ KEYBOARDMANAGERDONEYES

    LDA KEYBOARDACTUAL
    STA KEYBOARDPREVIOUS
    LDA #$FF
    STA KEYBOARDACTUAL

KEYBOARDMANAGERDONEYES:

    ; Update the ASF.

    JSR KEYBOARDASF

    ; Restore the used registers.

	PLA
	TAX
	PLA
	TAY
	PLA

    JMP (OLDSVC0222)
	RTS

OLDSVC0222: .WORD $0

KEYBOARDACTUAL:          .BYTE $FF
KEYBOARDPREVIOUS:        .BYTE $FF

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

KEYBOARDDETECT:

    ; Check if any key has been pressed.

    LDA KEYBOARDACTUAL
    CMP #$FF
    BEQ KEYBOARDDETECTNONE

    ; A key has been pressed. Set the carry flag and check
    ; if it is the same as the previous pressed.

    ; CMP KEYBOARDPREVIOUS
    
    SEC

    RTS

KEYBOARDDETECTNONE:
    CLC
    RTS

KEYBOARDELAPSED:     .BYTE 0

@EMIT inputConfig.latency AS KEYBOARDLATENCY
@EMIT inputConfig.delay AS KEYBOARDDELAY
@EMIT inputConfig.release AS KEYBOARDRELEASE

KEYBOARDASFSTATE:    .BYTE 0

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

KEYBOARDLATENCYELAPSED:
    LDA KEYBOARDELAPSED
    CMP #KEYBOARDLATENCY
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

KEYBOARDRELEASEELAPSED:
    LDA KEYBOARDELAPSED
    CMP #KEYBOARDRELEASE
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

KEYBOARDDELAYELAPSED:
    LDA KEYBOARDELAPSED
    CMP #KEYBOARDDELAY
    RTS

; ----------------------------------------------------------------------------
; KEYBOARDASF
; ----------------------------------------------------------------------------
; This routine will implement the ASF for keyboard. It means that will check
; for events and change the state of the ASF.
;

KEYBOARDASF:

    ; Preserve used registers

    PHA
    TXA
    PHA

    ; Decode the actual state.

    LDX KEYBOARDASFSTATE
    CPX #0
    BEQ KEYBOARDASF0
    DEX
    BEQ KEYBOARDASF1
    DEX
    BEQ KEYBOARDASF2
    DEX
    BEQ KEYBOARDASF3
    JMP KEYBOARDASFDONE

    ; --------------
    ; STATE 0 - FREE
    ; --------------

KEYBOARDASF0:

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
    
KEYBOARDASFTO1:

    ; Reset the elapsed timer.

    LDX #0
    STX KEYBOARDELAPSED

    ; Set the state.

    LDX #1
    STX KEYBOARDASFSTATE

    JMP KEYBOARDASFDONE

    ; -----------------
    ; STATE 1 - PRESSED
    ; -----------------

KEYBOARDASF1:

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

    BCS KEYBOARDASFTO2

    ; We remain in state 1.

    JMP KEYBOARDASFDONE

    ; Move to state 0, and reset the elapsed 
    ; timer at the same time.

KEYBOARDASFTO0:

    ; Reset the elapsed timer.

    LDX #0
    STX KEYBOARDELAPSED

    ; Reset the state.

    STX KEYBOARDASFSTATE

    ; Reset the key buffer

    JSR KEYBOARDBUFFERRESET

    JMP KEYBOARDASFDONE

KEYBOARDASFTO2:

    ; Reset the elapsed timer.

    LDX #0
    STX KEYBOARDELAPSED

    ; Set the state.

    LDX #2
    STX KEYBOARDASFSTATE

    JMP KEYBOARDASFDONE

    ; -----------------
    ; STATE 2 - PRESSED
    ; -----------------

KEYBOARDASF2:

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

    BCS KEYBOARDASFTO3

    ; We remain in state 2.

    JMP KEYBOARDASFDONE

    ; Move to state 3, and reset the elapsed 
    ; timer at the same time.

KEYBOARDASFTO3:

    ; Reset the elapsed timer.

    LDX #0
    STX KEYBOARDELAPSED

    ; Set the next state.

    LDX #3
    STX KEYBOARDASFSTATE

    JMP KEYBOARDASFDONE

    ; -------------------
    ; STATE 3 - CONTINUED
    ; -------------------

KEYBOARDASF3:

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

    BCS KEYBOARDASFTO2

    ; We remain in state 3.

    JMP KEYBOARDASFDONE

KEYBOARDASFDONE:

    ; Restore used registers

    PLA
    TAX
    PLA

    RTS

; ----------------------------------------------------------------------------
; WAITKEY
; ----------------------------------------------------------------------------
; This routine will wait for a key press. It means that it will, first, wait
; for the passing FREE(0)->PRESSED(1). Since the keyboard could already have
; a key pressed, we must also wait for FREE(0) state, first.

WAITKEY:
    LDA KEYBOARDASFSTATE
    BEQ WAITKEY1
WAITKEY0:
    LDA KEYBOARDASFSTATE
    BNE WAITKEY0
WAITKEY1:
    LDA KEYBOARDASFSTATE
    BEQ WAITKEY1
    RTS

; ----------------------------------------------------------------------------
; WAITKEYRELEASE
; ----------------------------------------------------------------------------
; This routine will wait for a key press AND for a release. It means that it 
; will, first, WAITKEY. Then, it will wait for a FREE(0) state.

WAITKEYRELEASE:
    JSR WAITKEY
WAITKEYRELEASE0:
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

KEYSTATE:

	LDA #<SCANCODEREAD
	STA TMPPTR
	LDA #>SCANCODEREAD
	STA TMPPTR+1

    TXA
    LSR
    LSR
    LSR
    TAY
    TXA
    AND #$07
    TAX
    LDA (TMPPTR), Y

KEYSTATEL1:
    LSR
    BCS KEYSTATE10
    CPX #0
    BEQ KEYSTATE10
    DEX
    JMP KEYSTATEL1

KEYSTATE10:
    RTS

; ----------------------------------------------------------------------------
; SCANCODE
; ----------------------------------------------------------------------------
; This routine can be called to retrieve the key pressed. It will not disturb
; the hardware, since it will use the KEYBOARDACTUAL value.
;
; Return values:
; - A : KEYBOARDACTUAL

SCANCODE:
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

ASCIICODE:
    JSR SCANCODE
    TAY
	LDA #<KEYBOARDMAP
	STA TMPPTR
	LDA #>KEYBOARDMAP
	STA TMPPTR+1
	LDA (TMPPTR),Y
    RTS

KEYBOARDMAP:
    .BYTE   'L',    'J',    ';',    $81,    $82,    'K',    '+',    '*'
    .BYTE   'O',    $00,    'P',    'U',     13,    'I',    '-',    '='
    .BYTE   'V',    $88,    'C',    $83,    $84,    'B',    'X',    'Z'
    .BYTE   '4',    'O',    '3',    '6',    $89,    '5',    '2',    '1'
    .BYTE   ',',    ' ',    '.',    'N',    $00,    'M',    '/',    $00
    .BYTE   'R',    $00,    'E',    'Y',    $09,    'T',    'W',    'Q'
    .BYTE   '9',    $00,    '0',    '7',    $08,    '8',    '<',    '>'
    .BYTE   'F',    'H',    'D',    $00,    $89,    'G',    'S',    'A'

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

KEYPRESS:
    LDY KEYBOARDASFSTATE
    CPY #0
    BEQ KEYSINGLE0
    DEY
    BEQ KEYSINGLE1
    DEY
    BEQ KEYSINGLE2
    DEY
    BEQ KEYSINGLE3

KEYSINGLE0:
KEYSINGLE2:
    CLC
    RTS

KEYSINGLE1:
KEYSINGLE3:
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

KEYPRESSED:
    LDY KEYBOARDASFSTATE
    CPY #0
    BEQ KEYPRESSED0
    DEY
    BEQ KEYPRESSED1
    DEY
    BEQ KEYPRESSED2
    DEY
    BEQ KEYPRESSED3

KEYPRESSED0:
KEYPRESSED2:
    LDA #$FF
    RTS

KEYPRESSED1:
KEYPRESSED3:
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

WAITKEY02:
    LDX KEYBOARDASFSTATE
    CPX #1
    BEQ WAITKEY02
    CPX #3
    BEQ WAITKEY02
    RTS

INKEY:
    JSR KEYPRESSED
    CMP #$FF
    BEQ INKEY0
    TAY
	LDA #<KEYBOARDMAP
	STA TMPPTR
	LDA #>KEYBOARDMAP
	STA TMPPTR+1
	LDA (TMPPTR),Y
    JSR WAITKEY02
    RTS
INKEY0:
    LDA #0
    RTS

