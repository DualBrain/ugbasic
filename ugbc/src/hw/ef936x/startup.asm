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
;*                          STARTUP ROUTINE ON EF936X                          *
;*                                                                             *
;*                             by Marco Spedaletti                             *
;*                                                                             *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

CPUMEMMOVE
    CMPU #0
    BEQ CPUMEMMOVEDONE
CPUMEMMOVEL1
    LDA ,Y+
    STA ,X+
    LEAU -1,U
    CMPU #$0
    BNE CPUMEMMOVEL1
CPUMEMMOVEDONE
    RTS
    
EF936XSTARTUP
    LDU #COMMONPALETTE
    LDY #(BASE_SEGMENT+$DA)
    LDX #16
    ; LDA #0
    ; STA 1,Y
    CLR (BASE_SEGMENT+$DB)
EF936XSTARTUPL1
    PULU D
    STB ,Y
    STA ,Y
    LEAX -1,X
    BNE EF936XSTARTUPL1
    RTS

WAITVBL
	PSHS D,CC
	ORCC #$50
WAITVBL0X
	LDB BASE_SEGMENT+$E7
    BPL WAITVBL0X
WAITVBL1X
	LDB BASE_SEGMENT+$E7
    BMI WAITVBL1X
    ANDCC #$AF
	PULS D,CC
	RTS

