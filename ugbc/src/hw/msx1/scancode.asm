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
;*                      SCAN CODE ROUTINE FOR MSX1                             *
;*                                                                             *
;*                             by Marco Spedaletti                             *
;*                                                                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

ROWSTATUS:
    DI
    LD C, A
    IN A, ($AA)
    AND $F0
    OR C
    OUT ($AA), A
    EI
    IN A, ($A9)    
    RET

ROWSSTATUS:
    LD A, 8
    LD B, A
ROWSSTATUSL1:
    LD A, B
    CALL ROWSTATUS
    CP $FF
    JR NZ, ROWSSTATUS1
    DEC B
    JR NZ, ROWSSTATUSL1
ROWSSTATUS0:
    LD A, 0
    RET
ROWSSTATUS1:
    LD A, $FF
    RET

WAITKEY:
    CALL ROWSSTATUS
    CP 0
    JR Z, WAITKEY
WAITKEY2:
    CALL ROWSSTATUS
    CP 0
    JR NZ, WAITKEY2
    RET

SCANCODERAW:
    PUSH BC
    PUSH DE
    PUSH HL
    LD HL,SCANCODEKM
    LD D, 10
    LD B, 0
SCANCODEROW:
    LD E, 8
    IN A, ($AA)
    AND $F0
    OR B
    OUT ($AA), A
    IN A, ($A9)
SCANCODE1:
    SRL A
    JR NC,SCANCODE2
    INC HL
    DEC E
    JR NZ,SCANCODE1
    INC B
    DEC D
    JR NZ,SCANCODEROW
    AND A
    POP HL
    POP DE
    POP BC
    RET
SCANCODE2:
    INC B
SCANCODE2L2:
    IN A, ($AA)
    AND $F0
    OR B
    OUT ($AA), A
    IN A, ($A9)
    INC B
    DEC D
    JR NZ, SCANCODE2L2
    LD A, (HL)
    POP HL
    POP DE
    POP BC
    RET

SCANCODE:
    CALL SCANCODERAW
    LD B, A

SCANCODEKEYPRESSED:
	LD A, (KBDCHAR)
    CMP B
    JR NZ, SCANCODEDIFF3

    LD A, (KBDDELAYC)
	CP 0
    JR Z, SCANCODEDIFF2

	SUB 1
    LD (KBDDELAYC), A
	CP 0
    JR NZ, SCANCODEDELAYED

SCANCODEDIFF2:
    LD A,  (KBDRATEC)
	CP 0
	JR Z, SCANCODEDIFF

	SUB 1
	LD (KBDRATEC), A
	CP 0
    JR Z, SCANCODEDIFF
    JP SCANCODEDELAYED

SCANCODEDIFF:
	LD A, B
	LD (KBDCHAR), A
	LD A, (KBDRATE)
	LD (KBDRATEC), A
	LD A, B
	JP SCANCODEKEYPRESSEDDONE

SCANCODEDIFF3:
	LD A, B
	LD (KBDCHAR), A
	LD A, (KBDRATE)
	LD (KBDRATEC), A
	LD A, (KBDDELAY)
	LD (KBDDELAYC), A
SCANCDENODELAY:
	LD A, B
    JP SCANCODEKEYPRESSEDDONE

SCANCODENO:
    LD A, 0
	LD (KBDCHAR), A
SCANCODEDELAYED:    
    ; JSR KBDWAITVBL
INKEYNO:
    LD A, 0
    JP SCANCODEKEYPRESSEDDONE

SCANCODEKEYPRESSEDDONE:
	RET


SCANCODEKM:
    DB "0", "1", "2", "3", "4", "5", "6", "7"
    DB "8", "9", "-", "=", "\\","[", "]", ";"
    DB "\"","~", "<", ">", "?", $00, "a", "b"
    DB "c", "d", "e", "f", "g", "h", "i", "j"
    DB "k", "l", "m", "n", "o", "p", "q", "r"
    DB "s", "t", "u", "v", "w", "x", "y", "z"
    DB $81, $82, $83, $84, $85, $F1, $F2, $F3
    DB $F4, $F5, $27, $09, $08, $86, $87, $0D
    DB " ", $88, $89, $90, $91, $92, $93, $94
    DB "*", "+", "/", "0", "1", "2", "3", "4"
    DB "5", "6", "7", "8", "9", "-", ",", "."

SCANCODEKMS:
    DB ")", "!", "@", "#", "$", "%", "^", "&"
    DB "*", "(", "_", "+", "|", "{", "}", ":"
    DB "'", "`", ",", ".", "/", $00, "A", "B"
    DB "C", "D", "E", "F", "G", "H", "I", "J"
    DB "K", "L", "M", "N", "O", "P", "Q", "R"
    DB "S", "T", "U", "V", "W", "X", "Y", "Z"
    DB $81, $82, $83, $84, $85, $F1, $F2, $F3
    DB $F4, $F5, $27, $09, $08, $86, $87, $0D
    DB " ", $88, $89, $90, $91, $92, $93, $94
    DB "*", "+", "/", "0", "1", "2", "3", "4"
    DB "5", "6", "7", "8", "9", "-", ",", "."
