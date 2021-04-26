/*****************************************************************************
 * ugBASIC - an isomorphic BASIC language compiler for retrocomputers        *
 *****************************************************************************
 * Copyright 2021 Marco Spedaletti (asimov@mclink.it)
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
 * @brief Emit ASM code for <b>WAIT [int] CYCLES</b>
 * 
 * This function outputs a code that engages the CPU in a busy wait.
 * 
 * @param _environment Current calling environment
 * @param _timing Number of cycles to wait
 */
/* <usermanual>
@keyword WAIT

@target zx
</usermanual> */
void wait_cycles( Environment * _environment, int _timing ) {

    outline1("; WAIT %d", _timing);

    char timingString[16]; sprintf(timingString, "$%2.2x", _timing );

    z80_busy_wait( _environment, timingString );

}

/**
 * @brief Emit ASM code for <b>WAIT [int] CYCLES</b>
 * 
 * This function outputs a code that engages the CPU in a busy wait.
 * 
 * @param _environment Current calling environment
 * @param _timing Number of cycles to wait
 */
void wait_cycles_var( Environment * _environment, char * _timing ) {

    outline1("; WAIT %s", _timing);

    Variable * timing = variable_retrieve( _environment, _timing );
    if ( ! timing ) {
        CRITICAL("Internal error on WAIT [expression]");
    }
    
    z80_busy_wait( _environment, timing->realName );

}

/**
 * @brief Emit ASM code for <b>WAIT # [integer] TICKS</b>
 * 
 * This function outputs a code that engages the CPU in a busy wait.
 * 
 * @param _environment Current calling environment
 * @param _timing Number of cycles to wait
 */
void wait_ticks( Environment * _environment, int _timing ) {

    outline1("; WAIT %d TICKS", _timing);

    char timingString[16]; sprintf(timingString, "$%2.2x", _timing );

    MAKE_LABEL

    outline1("LD BC, %s", timingString);
    outhead1("%s:", label);
    outline0("HALT");
    outline0("DEC BC");
    outline0("LD A,B");
    outline0("OR C");
    outline1("JR Z, %s", label);

}

/**
 * @brief Emit ASM code for <b>WAIT [expression] TICKS</b>
 * 
 * This function outputs a code that engages the CPU in a busy wait.
 * 
 * @param _environment Current calling environment
 * @param _timing Number of cycles to wait
 */
void wait_ticks_var( Environment * _environment, char * _timing ) {

    outline1("; WAIT %s", _timing);

    MAKE_LABEL

    Variable * timing = variable_retrieve( _environment, _timing );
    if ( ! timing ) {
        CRITICAL("Internal error on WAIT [expression]");
    }
    
    outline1("LD BC, (%s)", timing->realName);
    outhead1("%s:", label);
    outline0("HALT");
    outline0("DEC BC");
    outline0("LD A,B");
    outline0("OR C");
    outline1("JR Z, %s", label);

}

/**
 * @brief Emit ASM code for <b>WAIT # [integer] MS</b>
 * 
 * This function outputs a code that engages the CPU in a busy wait.
 * 
 * @param _environment Current calling environment
 * @param _timing Number of cycles to wait
 */
void wait_milliseconds( Environment * _environment, int _timing ) {

    outline1("; WAIT %d MILLISECONDS", _timing);

    char timingString[16]; sprintf(timingString, "#$%2.2x", _timing >> 4 );

    wait_ticks( _environment, _timing >> 4 );

}

/**
 * @brief Emit ASM code for <b>WAIT [expression] MILLISECONDS</b>
 * 
 * This function outputs a code that engages the CPU in a busy wait.
 * 
 * @param _environment Current calling environment
 * @param _timing Number of cycles to wait
 */
void wait_milliseconds_var( Environment * _environment, char * _timing ) {

    outline1("; WAIT %s MILLISECONDS", _timing);

    MAKE_LABEL

    Variable * timing = variable_retrieve( _environment, _timing );
    if ( ! timing ) {
        CRITICAL("Internal error on WAIT [expression]");
    }

    Variable * temp = variable_cast( _environment, timing->name, VT_BYTE );

    variable_div2_const( _environment, temp->name, 4 );

    wait_ticks_var( _environment, temp->name );
    
}
