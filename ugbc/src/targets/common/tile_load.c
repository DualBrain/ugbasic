/*****************************************************************************
 * ugBASIC - an isomorphic BASIC language compiler for retrocomputers        *
 *****************************************************************************
 * Copyright 2021-2022 Marco Spedaletti (asimov@mclink.it)
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
#include "../../stb_image.h"

/****************************************************************************
 * CODE SECTION 
 ****************************************************************************/

/**
 * @brief Emit code for <strong>TILE LOAD(...)</strong>
 * 
 * @param _environment Current calling environment
 * @param _filename Filename to read into buffer
 * @param _mode Mode to use to convert data
 */
/* <usermanual>
@keyword TILE LOAD

@english
The ''TILE LOAD'' command allows you to load an image and to convert it into
an ''TILE''.

The command support a set of modern image format, like:

  * JPEG baseline & progressive
  * PNG 1/2/4/8/16-bit-per-channel
  * TGA
  * BMP (non-1bpp, non-RLE)
  * PSD (composited view only, no extra channels, 8/16 bit-per-channel)
  * GIF
  * HDR (radiance rgbE format)
  * PIC (Softimage PIC)
  * PNM (PPM and PGM binary only)

The image will be converted into a way that can be efficiently drawn
on the screen using the tiles.

Since it is possible to load only one file of the same type at a time, it is necessary 
to be able to indicate an "alias" with which to exceed this limit. In this regard, there is also
the ''AS'' syntax, which allows you to load the same file several times but with different names.

@italian
Il comando ''TILE LOAD'' permette di caricare un file immagine, e di convertirlo
in una ''TILE''. Il secondo parametro è la modalità grafica da usare
per convertire il dato (per default, è il modo corrente).

Il comando supporta una serie di formati moderni:

  * JPEG baseline & progressive
  * PNG 1/2/4/8/16-bit-per-canale
  * TGA
  * BMP (non-1bpp, non-RLE)
  * PSD (vista composita, nessun canale extra, 8/16 bit-per-canale)
  * GIF
  * HDR (formato radiance rgbE)
  * PIC (Softimage PIC)
  * PNM (solo formato binario PPM e PGM)

L'immagine verrà convertita in un modo che possa essere disegnata in modo efficiente
sullo schermo. Potrebbe essere convertita in una tavolozza indicizzata, e potrebbe essere
anche ridimensionata.

Dal momento in cui è possibile caricare un solo file dello stesso tipo alla volta, 
è necessario poter indicare un "alias" con cui superare questo limite. A tal riguardo 
esiste anche la sintassi ''AS'', che permette di caricare più volte lo stesso file 
ma con nomi diversi.

@syntax = TILE LOAD([filename])

@example starship = TILE LOAD("starship.png")

@target all
</usermanual> */
Variable * tile_load( Environment * _environment, char * _filename, int _flags ) {

    if ( _environment->tenLinerRulesEnforced ) {
        CRITICAL_10_LINE_RULES_ENFORCED( "TILE LOAD");
    }
    
    int width = 0;
    int height = 0;
    int depth = 3;

    char * lookedFilename = image_load_asserts( _environment, _filename );

    unsigned char* source = stbi_load(lookedFilename, &width, &height, &depth, 0);

    if ( !source ) {
        CRITICAL_TILE_LOAD_UNKNOWN_FORMAT( _filename );
    }

    if ( width != 8 ) {
        CRITICAL_TILE_INVALID_WIDTH( width );
    }

    if ( height != 8 ) {
        CRITICAL_TILE_INVALID_HEIGHT( height );
    }

    if( _flags & FLAG_FLIP_X ) {
        source = image_flip_x( _environment, source, width, height );
    }
    if( _flags & FLAG_FLIP_Y ) {
        source = image_flip_y( _environment, source, width, height );
    }

    Variable * index = variable_temporary( _environment, VT_TILE, "(tile index)" );

    Variable * realImage = image_converter( _environment, source, 8, 8, 0, 0, 8, 8, BITMAP_MODE_DEFAULT, 0, _flags );

    stbi_image_free(source);

    if ( ! _environment->descriptors ) {
        _environment->descriptors = malloc( sizeof( TileDescriptors ) );
        _environment->descriptors->count = 0;
        _environment->descriptors->first = 0;
        _environment->descriptors->firstFree = _environment->descriptors->first;
        _environment->descriptors->lastFree = 128;
    }

    int tile = tile_allocate( _environment->descriptors, realImage->valueBuffer + 2 );

    if ( tile == -1 ) {
        CRITICAL_CANNOT_ALLOCATE_MORE_TILE();
    }    

    cpu_store_8bit( _environment, index->realName, tile );

    return index;

}
