/*****************************************************************************
 * ugBASIC - an isomorphic BASIC language compiler for retrocomputers        *
 *****************************************************************************
 * Copyright 2021-2024 Marco Spedaletti (asimov@mclink.it)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *----------------------------------------------------------------------------
 * Concesso in licenza secondo i termini della Licenza Apache, versione 2.0
 * (la "Licenza"); è proibito usare questo file se non in conformità alla
 * Licenza. Una copia della Licenza è disponibile all'indirizzo:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Se non richiesto dalla legislazione vigente o concordato per iscritto,
 * il software distribuito nei termini della Licenza è distribuito
 * "COSÌ COM'È", SENZA GARANZIE O CONDIZIONI DI ALCUN TIPO, esplicite o
 * implicite. Consultare la Licenza per il testo specifico che regola le
 * autorizzazioni e le limitazioni previste dalla medesima.
 ****************************************************************************/

/****************************************************************************
 * INCLUDE SECTION 
 ****************************************************************************/

#include "../../ugbc.h"

/****************************************************************************
 * CODE SECTION 
 ****************************************************************************/

Variable * joy_vars( Environment * _environment, char * _port ) {

    MAKE_LABEL

    Variable * port = variable_retrieve_or_define( _environment, _port, VT_BYTE, 0 );
    Variable * result = variable_temporary( _environment, VT_BYTE, "(result of JOY)" );

    deploy( joystick, src_hw_c64_joystick_asm );

    outline1("LDX %s", port->realName );
    outline1("BNE %sjoy2", label );

    outline1("%sjoy1:", label );
    outline0("LDA JOYSTICK0" );
    outline1("JMP %sendjoy", label );

    outline1("%sjoy2:", label );
    outline0("LDA JOYSTICK1" );
    outhead1("%sendjoy:", label );

    outline1("STA %s", result->realName );

    return result;

}

Variable * joy( Environment * _environment, int _port ) {

    MAKE_LABEL

    deploy( joystick, src_hw_c64_joystick_asm );

    Variable * result = variable_temporary( _environment, VT_BYTE, "(result of JOY)" );

    switch( _port ) {

        case 0:
            outline0("LDA JOYSTICK0" );
            break;

        case 1:
            outline0("LDA JOYSTICK1" );
            break;

    }

    outline1("STA %s", result->realName );

    return result;

}