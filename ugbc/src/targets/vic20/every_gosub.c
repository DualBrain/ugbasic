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

/**
 * @brief Emit ASM code for <b>EVERY ... TICKS GOSUB ...</b>
 * 
 * Emit assembly code to initialize the EVERY subsystem.
 * 
 * @param _environment 
 * @param _timing 
 * @param _label 
 */
/* <usermanual>
@keyword EVERY...GOSUB

@target vic20
</usermanual> */
void every_ticks_gosub( Environment * _environment, char * _timing, char * _label, char * _timer ) {

    Variable * timing = variable_retrieve_or_define( _environment, _timing, VT_WORD, 0 );
    Variable * timer = NULL;
    char * timerRealName = NULL;
    if ( _timer ) {
        timer = variable_retrieve_or_define( _environment, _timer, VT_BYTE, 0 );
        timerRealName = timer->realName;
    }

    vic20_timer_set_address( _environment, timerRealName, _label );
    vic20_timer_set_counter( _environment, timerRealName, timing->realName );
    vic20_timer_set_init( _environment, timerRealName, timing->realName );

}
