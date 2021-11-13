; /*****************************************************************************
;  * ugBASIC - an isomorphic BASIC language compiler for retrocomputers        *
;  *****************************************************************************
;  * Copyright 2021 Marco Spedaletti (asimov@mclink.it)
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

; singed A (unsigned B)
CPUMATHDIV28BIT_SIGNED
    TSTA
    BMI  CPUMATHDIV28BIT_NEG

; unsigned A, unsigned B
CPUMATHDIV28BIT
    SUBB  #8
    BGE   CPUMATHDIV28BITL0
    LDX   #CPUMATHDIV28BITL1-1
    NEGB
    JMP   B,X
CPUMATHDIV28BITL0
    CLRA
    RTS
CPUMATHDIV28BITL1
    LSRA
    LSRA
    LSRA
    LSRA
    LSRA
    LSRA
    LSRA
    RTS
    
; singed A (unsigned B)
; this one ensure that -1/2 gives 0
CPUMATHDIV28BIT_SIGNED_NEG
    NEGA
    BSR CPUMATHDIV28BIT
    NEGA
    RTS
