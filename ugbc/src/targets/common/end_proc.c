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
 * @brief Emit code for <strong>END PROC</strong>
 * 
 * @param _environment Current calling environment
 * @param _value Value to the return
 */
/* <usermanual>
@keyword PROCEDURE...END PROC

@english
As an option, you can specify a value for the function to return. 
The value must be indicated in square brackets (''[...]''). 
The value will then be copied into the ''PARAM'' variable and 
returned by the call, if the call was made in the context of an expression.

@italian
Come opzione è possibile indicare un valore da restituire da parte 
della procedura. Il valore va indicato tra parentesi quadre. 
Il valore sarà, quindi, copiato nella variable ''PARAM'' e restituito 
dalla chiamata, se la chiamata è stata fatta nel contesto di una espressione.

@example &nbsp;
@example PROCEDURE hundred
@example END PROC[100]

</usermanual> */
void end_procedure( Environment * _environment, char * _value ) {

    if ( ! _environment->procedureName ) {
        CRITICAL_PROCEDURE_NOT_OPENED();
    }

    if ( _value ) {
        char paramName[MAX_TEMPORARY_STORAGE]; sprintf(paramName,"%s__PARAM", _environment->procedureName );
        Variable * value = variable_retrieve_or_define( _environment, _value, VT_WORD, 0 );
        Variable * param = variable_retrieve_or_define( _environment, paramName, value->type, 0 );
        variable_move( _environment, value->name, param->name );
    }

    char procedureAfterLabel[MAX_TEMPORARY_STORAGE]; sprintf(procedureAfterLabel, "%safter", _environment->procedureName );

    cpu_return( _environment );

    cpu_label( _environment, procedureAfterLabel );

    _environment->procedureName = NULL;

    Variable * current = _environment->procedureVariables;

    Variable * varLast = _environment->variables;
    if ( varLast ) {
        while( varLast->next ) {
            varLast = varLast->next;
        }
        varLast->next = current;
    } else {
        _environment->variables = current;
    }

    _environment->procedureVariables = NULL;

};

