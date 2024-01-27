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
 * "COSì COM'è", SENZA GARANZIE O CONDIZIONI DI ALCUN TIPO, esplicite o
 * implicite. Consultare la Licenza per il testo specifico che regola le
 * autorizzazioni e le limitazioni previste dalla medesima.
 ****************************************************************************/

/****************************************************************************
 * INCLUDE SECTION 
 ****************************************************************************/

#include "../ugbc.h"
#include <math.h>

static RGBi SYSTEM_PALETTE[] = {
        { 0x00, 0x00, 0x00, 0xff, 0, "BLACK", 0 },        
        { 0x00, 0x00, 0xff, 0xff, 1, "BLUE", 1 },
        { 0x88, 0x00, 0x00, 0xff, 2, "RED", 2 },
        { 0xff, 0x00, 0xff, 0xff, 3, "MAGENTA", 3 },
        { 0x00, 0xcc, 0x00, 0xff, 4, "GREEN", 4 },
        { 0xaa, 0xff, 0xe6, 0xff, 5, "CYAN", 5 },
        { 0xee, 0xee, 0x77, 0xff, 6, "YELLOW", 6 },
        { 0xff, 0xff, 0xff, 0xff, 7, "WHITE", 7 }
};

static RGBi * commonPalette;
static int lastUsedSlotInCommonPalette = 0;

/****************************************************************************
 * CODE SECTION
 ****************************************************************************/

#ifdef __zx__

static int calculate_image_size( Environment * _environment, int _width, int _height, int _mode ) {

    switch( _mode ) {

        case BITMAP_MODE_STANDARD:
        case TILEMAP_MODE_STANDARD:
            return 3 + ( ( _width >> 3 ) * _height ) + ( ( _width >> 3 ) * ( _height >> 3 ) );

    }

    return 0;

}

static int calculate_images_size( Environment * _environment, int _frames, int _width, int _height, int _mode ) {

    switch( _mode ) {

        case BITMAP_MODE_STANDARD:
        case TILEMAP_MODE_STANDARD:
            return 3 + ( 3 + ( ( _width >> 3 ) * _height ) + ( ( _width >> 3 ) * ( _height >> 3 ) ) ) * _frames;

    }

    return 0;

}

static int calculate_sequence_size( Environment * _environment, int _sequences, int _frames, int _width, int _height, int _mode ) {

    switch( _mode ) {

        case BITMAP_MODE_STANDARD:
        case TILEMAP_MODE_STANDARD:
            return 3 + ( ( 3 + ( ( _width >> 3 ) * _height ) + ( ( _width >> 3 ) * ( _height >> 3 ) ) ) * _frames ) * _sequences;

    }

    return 0;

}

void zx_color_border( Environment * _environment, char * _color ) {

    char port[MAX_TEMPORARY_STORAGE]; sprintf(port, "$%2.2x", PORT_COLOR_BORDER);

    z80_port_out( _environment, port, _color );

}

void zx_vscroll( Environment * _environment, int _displacement ) {

    outline1("LD A, $%2.2x", ( _displacement & 0xff ) );

    deploy( vars,src_hw_zx_vars_asm);
    deploy( vScroll,src_hw_zx_vscroll_asm );

    outline0("CALL VSCROLL");

}

void zx_text( Environment * _environment, char * _text, char * _text_size ) {

    deploy( vars,src_hw_zx_vars_asm);
    deploy( vScroll, src_hw_zx_vscroll_asm );
    deploy( textEncodedAt, src_hw_zx_text_at_asm );

    // z80_move_8bit( _environment, _tab, "TABCOUNT");

    outline1("LD A, (%s)", _text_size );
    outline0("LD C, A");
    outline0("LD B, 0");
    outline1("LD HL, (%s)", _text );
    outline0("CALL TEXTAT");

}

void zx_cls( Environment * _environment, char * _pen, char * _paper ) {

    deploy( vars,src_hw_zx_vars_asm);
    deploy( cls, src_hw_zx_cls_asm );

    if ( _pen ) {
        z80_move_8bit( _environment, _pen, "_PEN");
    }
    if ( _paper ) {
        z80_move_8bit( _environment, _paper, "_PAPER");
    }

    outline0("CALL CLS");

}

void zx_inkey( Environment * _environment, char * _pressed, char * _key ) {

    MAKE_LABEL

    outhead1("zxinkey%s:",label);
    outline0("LD A, 0");
    outline1("LD (%s), A", _pressed );
    outline1("LD (%s), A", _key );
    outline0("LD A, ($5C08)");
    outline0("CP 0");
    outline1("JR Z, %snokey", label );
    outline1("LD (%s), a", _key );
    outline0("LD A, $FF");
    outline1("LD (%s), A", _pressed );
    outline0("LD A, 0");
    outline0("LD ($5C08), A");
    outhead1("%snokey:", label );
   
}

void zx_scancode( Environment * _environment, char * _pressed, char * _scancode ) {

    MAKE_LABEL

    deploy( scancode, src_hw_zx_scancode_asm );

    outline0("LD A, 0");
    outline1("LD (%s), A", _scancode );
    outline1("LD (%s), A", _pressed );
    outline0("CALL SCANCODE");
    outline0("CP 0");
    outline1("JR Z,%snokey", label);
    outline1("LD (%s), A", _scancode );
    outline0("LD A, $FF");
    outline1("LD (%s), A", _pressed );
    outhead1("%snokey:", label );
   
}

void zx_key_pressed( Environment * _environment, char *_scancode, char * _result ) {

    MAKE_LABEL

    char nokeyLabel[MAX_TEMPORARY_STORAGE];
    sprintf( nokeyLabel, "%slabel", label );
    
    Variable * temp = variable_temporary( _environment, VT_BYTE, "(pressed)" );

    zx_scancode( _environment, temp->realName, _result );
    cpu_compare_8bit( _environment, _result, _scancode,  temp->realName, 1 );
    cpu_compare_and_branch_8bit_const( _environment, temp->realName, 0, nokeyLabel, 1 );
    cpu_store_8bit( _environment, _result, 0xff );
    cpu_jump( _environment, label );
    cpu_label( _environment, nokeyLabel );
    cpu_store_8bit( _environment, _result, 0x00 );
    cpu_label( _environment, label );

}

void zx_scanshift( Environment * _environment, char * _shifts ) {

    // 653	
    // Shift key indicator. Bits:
    // Bit #0: 1 = One or more of left Shift, right Shift or Shift Lock is currently being pressed or locked.
    // Bit #1: 1 = Commodore is currently being pressed.
    // Bit #2: 1 = Control is currently being pressed.
    // NO SHIFT (0) - if no SHIFT key pressed;
    // LEFT SHIFT (1) - if the left SHIFT pressed;
    // RIGHT SHIFT (2) - if the right SHIFT pressed;
    // BOTH SHIFTS (3) - if both keys pressed.

    MAKE_LABEL

    deploy( scancode, src_hw_zx_scancode_asm );

    outline0("CALL SCANCODE");
    outline0("CP $f1");
    outline1("JR NZ,%snokey", label);
    outline0("LD A, $03");
    outline1("LD (%s), A", _shifts );
    outhead1("%snokey:", label );

}

void zx_keyshift( Environment * _environment, char * _shifts ) {

    // On the same way, KEY SHIFT is used to report the current status of those keys 
    // which cannot be detected by either INKEY$ or SCANCODE because they do not 
    // carry the relevant codes. These control keys cannot be tested individually, or a test can be set up for any combination of such keys pressed together. A single call to the KEY SHIFT function can test for all eventualities, by examining a bit map in the following format:

    MAKE_LABEL

    deploy( scancode, src_hw_zx_scancode_asm );

    outline0("CALL SCANCODE");
    outline0("CP $f1");
    outline1("JR NZ,%snokey", label);
    outline0("LD A, $03");
    outline1("LD (%s), A", _shifts );
    outhead1("%snokey:", label );

}

void zx_clear_key( Environment * _environment ) {

}

static int rgbConverterFunction( int _red, int _green, int _blue ) {
    
    int colorIndex = 0;
    int j = 0;
    unsigned int minDistance = 0xffffffff;

    RGBi rgb;
    rgb.red = _red;
    rgb.green = _green;
    rgb.blue = _blue;

    for (j = 0; j < sizeof(SYSTEM_PALETTE)/sizeof(RGBi); ++j) {
        int distance = rgbi_distance(&SYSTEM_PALETTE[j], &rgb);
        if (distance < minDistance) {
            minDistance = distance;
            colorIndex = j;
        }
    }

    return colorIndex;

}

/* <usermanual>
@keyword RGB

@target zx
</usermanual> */

void zx_initialization( Environment * _environment ) {

    variable_import( _environment, "CURRENTWIDTH", VT_POSITION, 256);
    variable_global( _environment, "CURRENTWIDTH" );
    variable_import( _environment, "CURRENTHEIGHT", VT_POSITION, 192  );
    variable_global( _environment, "CURRENTHEIGHT" );
    variable_import( _environment, "CURRENTTILES", VT_BYTE, 255 );
    variable_global( _environment, "CURRENTTILES" );
    variable_import( _environment, "CURRENTTILESWIDTH", VT_BYTE, 32 );
    variable_global( _environment, "CURRENTTILESWIDTH" );
    variable_import( _environment, "CURRENTTILESHEIGHT", VT_BYTE, 24 );
    variable_global( _environment, "CURRENTTILESHEIGHT" );
    variable_import( _environment, "FONTWIDTH", VT_BYTE, 8 );
    variable_global( _environment, "FONTWIDTH" );
    variable_import( _environment, "FONTHEIGHT", VT_BYTE, 8 );
    variable_global( _environment, "FONTHEIGHT" );

    SCREEN_MODE_DEFINE( BITMAP_MODE_STANDARD, 1, 192, 256, 2, 8, 8, "Standard Bitmap Mode" );
    SCREEN_MODE_DEFINE( TILEMAP_MODE_STANDARD, 0, 32, 25, 8, 8, 8, "(emulated) Standard Character Mode" );

    variable_import( _environment, "XGR", VT_POSITION, 0 );
    variable_global( _environment, "XGR" );
    variable_import( _environment, "YGR", VT_POSITION, 0 );
    variable_global( _environment, "YGR" );
    variable_import( _environment, "LINE", VT_WORD, (unsigned short)(0xffff) );
    variable_global( _environment, "LINE" );
    variable_import( _environment, "TABCOUNT", VT_BYTE, 4 );
    variable_global( _environment, "TABCOUNT" );

    variable_import( _environment, "CLIPX1", VT_POSITION, 0 );
    variable_global( _environment, "CLIPX1" );
    variable_import( _environment, "CLIPX2", VT_POSITION, 255 );
    variable_global( _environment, "CLIPX2" );
    variable_import( _environment, "CLIPY1", VT_POSITION, 0 );
    variable_global( _environment, "CLIPY1" );
    variable_import( _environment, "CLIPY2", VT_POSITION, 191 );
    variable_global( _environment, "CLIPY2" );

    variable_import( _environment, "ORIGINX", VT_POSITION, 0 );
    variable_global( _environment, "ORIGINX" );
    variable_import( _environment, "ORIGINY", VT_POSITION, 0 );
    variable_global( _environment, "ORIGINY" );

    variable_import( _environment, "RESOLUTIONX", VT_POSITION, 0 );
    variable_global( _environment, "RESOLUTIONX" );
    variable_import( _environment, "RESOLUTIONY", VT_POSITION, 0 );
    variable_global( _environment, "RESOLUTIONY" );
    
    variable_import( _environment, "XCURSYS", VT_SBYTE, 0 );
    variable_global( _environment, "XCURS" );
    variable_import( _environment, "YCURSYS", VT_SBYTE, 0 );
    variable_global( _environment, "YCURS" );
    variable_import( _environment, "TABCOUNT", VT_BYTE, 4 );
    variable_global( _environment, "TABCOUNT" );

    variable_import( _environment, "TILEX", VT_BYTE, 0 );
    variable_global( _environment, "TILEX" );
    variable_import( _environment, "TILEY", VT_BYTE, 0 );
    variable_global( _environment, "TILEY" );
    variable_import( _environment, "TILEX2", VT_BYTE, 0 );
    variable_global( _environment, "TILEX2" );
    variable_import( _environment, "TILET", VT_BYTE, 0 );
    variable_global( _environment, "TILET" );
    variable_import( _environment, "TILEW", VT_BYTE, 0 );
    variable_global( _environment, "TILEW" );
    variable_import( _environment, "TILEH", VT_BYTE, 0 );
    variable_global( _environment, "TILEH" );
    variable_import( _environment, "TILEW2", VT_BYTE, 0 );
    variable_global( _environment, "TILEW2" );
    variable_import( _environment, "TILEH2", VT_BYTE, 0 );
    variable_global( _environment, "TILEH2" );
    variable_import( _environment, "TILEA", VT_BYTE, 0 );
    variable_global( _environment, "TILEA" );
    variable_import( _environment, "TILEO", VT_WORD, 0 );
    variable_global( _environment, "TILEO" );

    variable_import( _environment, "CURRENTMODE", VT_BYTE, 0 );
    variable_global( _environment, "CURRENTMODE" );
    variable_import( _environment, "CURRENTTILEMODE", VT_BYTE, 1 );
    variable_global( _environment, "CURRENTTILEMODE" );
    
    cpu_move_16bit( _environment, "CURRENTWIDTH", "RESOLUTIONX" );
    cpu_move_16bit( _environment, "CURRENTHEIGHT", "RESOLUTIONY" );

    variable_import( _environment, "BLITIMAGEBLITTINGADDR", VT_ADDRESS, 0 );
    variable_global( _environment, "BLITIMAGEBLITTINGADDR" );
    variable_import( _environment, "BLITTMPPTR", VT_ADDRESS, 0 );
    variable_global( _environment, "BLITTMPPTR" );
    variable_import( _environment, "BLITTMPPTR2", VT_ADDRESS, 0 );
    variable_global( _environment, "BLITTMPPTR2" );

    variable_import( _environment, "FPSCRAP", VT_BUFFER, 16 );
    variable_global( _environment, "FPSCRAP" );

    variable_import( _environment, "TEXTADDRESS", VT_ADDRESS, 0 );
    variable_global( _environment, "TEXTADDRESS" );

    _environment->currentRgbConverterFunction = rgbConverterFunction;

    _environment->screenWidth = 256;
    _environment->screenHeight = 192;
    _environment->fontWidth = 8;
    _environment->fontHeight = 8;
    _environment->screenColors = COLOR_COUNT;

}

void zx_finalization( Environment * _environment ) {

}

void zx_screen_rows( Environment * _environment, char * _rows ) {

}

void zx_screen_columns( Environment * _environment, char * _columns ) {

}

int zx_screen_mode_enable( Environment * _environment, ScreenMode * _screen_mode ) {
    _environment->screenWidth = 256;
    _environment->screenHeight = 192;
    _environment->fontWidth = 8;
    _environment->fontHeight = 8;
    _environment->screenColors = 8;
}

void zx_bitmap_enable( Environment * _environment, int _width, int _height, int _colors ) {

    deploy( vars, src_hw_zx_vars_asm );

}

void zx_tilemap_enable( Environment * _environment, int _width, int _height, int _colors, int _tile_width, int _tile_height ) {
    
}

void zx_back( Environment * _environment ) {

    deploy( back, src_hw_zx_back_asm );

    outline0("CALL BACK");

}

static Variable * zx_image_converter_bitmap_mode_standard( Environment * _environment, char * _source, int _width, int _height, int _depth, int _offset_x, int _offset_y, int _frame_width, int _frame_height, int _transparent_color, int _flags ) {

    (void)!_transparent_color;

    image_converter_asserts_free_height( _environment, _width, _height, _offset_x, _offset_y, &_frame_width, &_frame_height );

    RGBi * palette = malloc_palette( MAX_PALETTE );
    
    int paletteColorCount = rgbi_extract_palette(_environment, _source, _width, _height, _depth, palette, MAX_PALETTE, ( ( _flags & FLAG_EXACT ) ? 0 : 1 ) /* sorted */);

    if (paletteColorCount > 16) {
        CRITICAL_IMAGE_CONVERTER_TOO_COLORS( paletteColorCount );
    }

    int avoidColorRecalculation = 0;

    if (paletteColorCount<=2) {
        avoidColorRecalculation = 1;
    }

    int i, j, k;

    commonPalette = palette_match( palette, paletteColorCount, SYSTEM_PALETTE, sizeof(SYSTEM_PALETTE) / sizeof(RGBi) );
    commonPalette = palette_remove_duplicates( commonPalette, paletteColorCount, &paletteColorCount );

    if ( _transparent_color & 0x0f0000 ) {
        commonPalette = palette_promote_color_as_background( _transparent_color & 0xff, commonPalette, paletteColorCount );
    }
    if ( _transparent_color & 0xf00000 ) {
        commonPalette = palette_promote_color_as_foreground( ( _transparent_color >> 8 ) & 0xff, commonPalette, paletteColorCount, 8 );
        paletteColorCount = 8;
    }

    lastUsedSlotInCommonPalette = paletteColorCount;
    adilinepalette( "CPM1:%d", paletteColorCount, commonPalette );

    adilinepalette( "CPMS:%ld", sizeof(SYSTEM_PALETTE) / sizeof(RGBi), SYSTEM_PALETTE );

    Variable * result = variable_temporary( _environment, VT_IMAGE, 0 );
    result->originalColors = lastUsedSlotInCommonPalette;
    memcpy( result->originalPalette, commonPalette, lastUsedSlotInCommonPalette * sizeof( RGBi ) );
    
    int bufferSize = 2 + ( ( _frame_width >> 3 ) * _frame_height ) + ( ( _frame_width >> 3 ) * ( _frame_height >> 3 ) );
    // printf("bufferSize = %d\n", bufferSize );

    adiline3("BMP:%4.4x:%4.4x:%2.2x", _frame_width, _frame_height, BITMAP_MODE_DEFAULT );

    adilinebeginbitmap("BMD");

    char * buffer = malloc ( bufferSize );
    memset( buffer, 0, bufferSize );

    // Position of the pixel in the original image
    int image_x, image_y;
    
    // Position of the pixel, in terms of tiles
    int tile_x, tile_y;
    
    // Position of the pixel, in terms of offset and bitmask
    int offset, bitmask;

    // Color of the pixel to convert
    RGBi rgb;

    *(buffer) = ( _frame_width & 0xff );
    *(buffer+1) = ( _frame_width >> 8 ) & 0xff;
    *(buffer+2) = _frame_height;

    _source += ( ( _offset_y * _width ) + _offset_x ) * _depth;

    int * colorBackground = malloc( ( _frame_width >> 3 ) * sizeof( int ) );
    int * colorForeground = malloc( ( _frame_width >> 3 ) * sizeof( int ) );

    int step = 0;

    // Loop for all the source surface.
    for (image_y = 0; image_y < _frame_height; ++image_y) {

        for (image_x = 0; image_x < _frame_width; image_x+=8) {

            int colorIndex = 0;
            int xx;

            if ( ( image_y & 0x7 ) == 0 ) {

                if ( ( !avoidColorRecalculation ) ||
                     ( avoidColorRecalculation && ( image_y == 0 ) ) ) {
                
                    int colorIndexCount[16];
                    memset( colorIndexCount, 0, 16 * sizeof(int) );

                    for( xx = 0; xx < 8; ++xx ) {
                        // Take the color of the pixel
                        rgb.red = *_source;
                        rgb.green = *(_source + 1);
                        rgb.blue = *(_source + 2);
                        if ( _depth > 3 ) {
                            rgb.alpha = *(_source + 3);
                        } else {
                            rgb.alpha = 255;
                        }
                        if ( rgb.alpha == 0 ) {
                            rgb.red = 0;
                            rgb.green = 0;
                            rgb.blue = 0;
                        }

                        colorIndex = 0;

                        int minDistance = 9999;
                        for( int i=0; i<paletteColorCount; ++i ) {
                            int distance = rgbi_distance(&commonPalette[i], &rgb );
                            if ( distance < minDistance ) {
                                minDistance = distance;
                                colorIndex = commonPalette[i].index;
                            }
                        }

                        ++colorIndexCount[colorIndex];

                        _source += _depth;

                    }

                    _source -= 8 * ( _depth );

                    int colorBackgroundMax = 0;
                    colorBackground[image_x>>3] = 0;
                    int colorForegroundMax = 0;
                    colorForeground[image_x>>3] = 0;

                    if ( _transparent_color & 0x0f0000 ) {
                        colorBackground[image_x>>3] = ( _transparent_color & 0xff );
                    } else {
                        for( int xx = 0; xx<16; ++xx ) {
                            if ( colorIndexCount[xx] > colorBackgroundMax ) {
                                colorBackground[image_x>>3] = xx;
                                colorBackgroundMax = colorIndexCount[xx];
                            };
                        }

                        colorIndexCount[colorBackground[image_x>>3]] = 0;
                        
                    }
                    if ( _transparent_color & 0xf00000 ) {
                        colorForeground[image_x>>3] = ( _transparent_color & 0xff00 ) >> 8;
                    } else {
                        for( int xx = 0; xx<16; ++xx ) {
                            if ( colorIndexCount[xx] > colorForegroundMax ) {
                                colorForeground[image_x>>3] = xx;
                                colorForegroundMax = colorIndexCount[xx];
                            };
                        }

                        colorIndexCount[colorForeground[image_x>>3]] = 0;

                    }

                }   
            }

            for( xx = 0; xx < 8; ++xx ) {
                // Take the color of the pixel
                rgb.red = *_source;
                rgb.green = *(_source + 1);
                rgb.blue = *(_source + 2);
                if ( _depth > 3 ) {
                    rgb.alpha = *(_source + 3);
                } else {
                    rgb.alpha = 255;
                }
                if ( rgb.alpha == 0 ) {
                    rgb.red = 0;
                    rgb.green = 0;
                    rgb.blue = 0;
                }

                colorIndex = 0;

                int minDistance = 9999;
                for( int i=0; i<paletteColorCount; ++i ) {
                    int distance = rgbi_distance(&commonPalette[i], &rgb );
                    if ( distance < minDistance ) {
                        minDistance = distance;
                        colorIndex = commonPalette[i].index;
                    }
                }

                int offset = ( image_y * _frame_width>>3 ) + (image_x>>3);
                int bitmask = 1 << ( 7 - xx );

                if ( colorIndex != colorBackground[image_x>>3] ) {
                    adilinepixel(colorForeground[image_x>>3]);
                    *( buffer + offset + 3) |= bitmask;
                } else {
                    adilinepixel(colorBackground[image_x>>3]);
                    *( buffer + offset + 3) &= ~bitmask;
                }

                offset = ( ( image_y >> 3 ) * _frame_width>>3 ) + (image_x>>3);
                *( buffer + 3 + ( ( _frame_width >> 3 ) * _frame_height ) + offset ) = ( colorBackground[image_x>>3] << 3 ) | ( colorForeground[image_x>>3] ); 
                
                // if ( ! *( buffer + 2 + ( ( _frame_width >> 3 ) * _frame_height ) + offset ) ) {
                //     ++step;
                // }
                // *( buffer + 2 + ( ( _frame_width >> 3 ) * _frame_height ) + offset ) = (step&0xff);

                _source += _depth;

            }

        }

        _source += _depth * ( _width - _frame_width );

        // printf("\n" );

    }

    // printf("\n" );
    // printf("\n" );

    adilineendbitmap();

    // printf("----\n");

    variable_store_buffer( _environment, result->name, buffer, bufferSize, 0 );

    // printf("----\n");

    return result;

}

Variable * zx_image_converter( Environment * _environment, char * _data, int _width, int _height, int _depth, int _offset_x, int _offset_y, int _frame_width, int _frame_height, int _mode, int _transparent_color, int _flags ) {

    switch( _mode ) {

        case BITMAP_MODE_STANDARD:
        case TILEMAP_MODE_STANDARD:

            return zx_image_converter_bitmap_mode_standard( _environment, _data, _width, _height, _depth, _offset_x, _offset_y, _frame_width, _frame_height, _transparent_color, _flags );

            break;
    }

    WARNING_IMAGE_CONVERTER_UNSUPPORTED_MODE( _mode );

    return zx_new_image( _environment, 8, 8, BITMAP_MODE_STANDARD );

}

static void zx_load_image_address_to_other_register( Environment * _environment, char * _register, char * _source, char * _sequence, char * _frame, int _frame_size, int _frame_count ) {

    outline2("LD %s, %s", _register, _source );
    if ( _sequence ) {

        outline0("LD DE, $0003" );
        outline0("ADD HL, DE" );
        if ( strlen(_sequence) == 0 ) {

        } else {
            outline0("PUSH HL" );
            outline1("LD A, (%s)", _sequence );
            outline0("LD L, A" );
            outline0("LD H, 0" );
            outline0("ADD HL, HL" );
            outline0("LD DE, HL" );
            outline1("LD HL, OFFSETS%4.4x", _frame_size * _frame_count );
            outline0("ADD HL, DE" );
            outline0("LD A, (HL)" );
            outline0("LD E, A" );
            outline0("INC HL" );
            outline0("LD A, (HL)" );
            outline0("LD D, A" );
            outline0("POP HL" );
            outline0("ADD HL, DE" );
        }

        if ( _frame ) {
            if ( strlen(_frame) == 0 ) {

            } else {
                outline0("PUSH HL" );
                outline1("LD A, (%s)", _frame );
                outline0("LD L, A" );
                outline0("LD H, 0" );
                outline0("ADD HL, HL" );
                outline0("LD DE, HL" );
                outline1("LD HL, OFFSETS%4.4x", _frame_size );
                outline0("ADD HL, DE" );
                outline0("LD A, (HL)" );
                outline0("LD E, A" );
                outline0("INC HL" );
                outline0("LD A, (HL)" );
                outline0("LD D, A" );
                outline0("POP HL" );
                outline0("ADD HL, DE" );
            }
        }

    } else {

        if ( _frame ) {
            outline0("LD DE, $0003" );
            outline0("ADD HL, DE" );
            if ( strlen(_frame) == 0 ) {

            } else {
                outline0("PUSH HL" );
                outline1("LD A, (%s)", _frame );
                outline0("LD L, A" );
                outline0("LD H, 0" );
                outline0("ADD HL, HL" );
                outline0("LD DE, HL" );
                outline1("LD HL, OFFSETS%4.4x", _frame_size );
                outline0("ADD HL, DE" );
                outline0("LD A, (HL)" );
                outline0("LD E, A" );
                outline0("INC HL" );
                outline0("LD A, (HL)" );
                outline0("LD D, A" );
                outline0("POP HL" );
                outline0("ADD HL, DE" );
            }
        }

    }

}

static void zx_load_image_address_to_register( Environment * _environment, char * _register, Resource * _source, char * _sequence, char * _frame, int _frame_size, int _frame_count ) {

    if ( !_sequence && !_frame ) {
        if ( _source->isAddress ) {
            outline1("LD HL, (%s)", _source->realName );
        } else {
            outline1("LD HL, %s", _source->realName );
        }
    } else {
        if ( _source->isAddress ) {
            outline1("LD HL, (%s)", _source->realName );
        } else {
            outline1("LD HL, %s", _source->realName );
        }

        if ( _sequence ) {
            outline0("LD DE, $0003" );
            outline0("ADD HL, DE" );
            if ( strlen(_sequence) == 0 ) {

            } else {
                outline1("LD A, (%s)", _sequence );
                outline0("PUSH HL" );
                outline0("POP IX" );
                outline1("CALL %soffsetsequence", _source->realName );
            }
            if ( _frame ) {
                if ( strlen(_frame) == 0 ) {

                } else {
                    outline1("LD A, (%s)", _frame );
                    outline0("PUSH HL" );
                    outline0("POP IX" );
                    outline1("CALL %soffsetframe", _source->realName );
                }
            }

        } else {

            if ( _frame ) {
                outline0("LD DE, $0003" );
                outline0("ADD HL, DE" );
                if ( strlen(_frame) == 0 ) {

                } else {
                    outline0("PUSH HL" );
                    outline0("POP IX" );
                    outline1("LD A, (%s)", _frame );
                    outline1("CALL %soffsetframe", _source->realName );
                }
            }

        }

    }
    if ( _register ) {
        outline1("LD (%s), HL", _register );
    }

}

void zx_put_image( Environment * _environment, Resource * _image, char * _x, char * _y, char * _frame, char * _sequence, int _frame_size, int _frame_count, char * _flags ) {

    // currently unused
    (void)!_flags;

    MAKE_LABEL

    deploy( vars, src_hw_zx_vars_asm);
    deploy( putimage, src_hw_zx_put_image_asm );

    zx_load_image_address_to_register( _environment, NULL, _image, _sequence, _frame, _frame_size, _frame_count );

    outline1("LD A, (%s)", _x );
    outline0("LD (IMAGEX), A" );
    outline1("LD A, (%s)", _y );
    outline0("LD (IMAGEY), A" );
    outline1("LD A, (%s)", _flags );
    outline0("LD (IMAGEF), A" );
    outline1("LD A, (%s)", address_displacement( _environment, _flags, "1") );
    outline0("LD (IMAGET), A" );

    outline0("CALL PUTIMAGE");

}

void zx_blit_image( Environment * _environment, char * _sources[], int _source_count, char * _blit, char * _x, char * _y, char * _frame, char * _sequence, int _frame_size, int _frame_count, int _flags ) {

    deploy( zxvars, src_hw_zx_vars_asm);
    deploy( blitimage, src_hw_zx_blit_image_asm );

    if ( _source_count > 2 ) {
        CRITICAL_BLIT_TOO_MUCH_SOURCES( );
    }

    MAKE_LABEL

    outhead1("blitimage%s:", label);
    if ( _source_count > 0 ) {
        Resource resource;
        resource.realName = strdup( _sources[0] );
        resource.type = VT_IMAGE;
        zx_load_image_address_to_register( _environment, NULL, &resource, _sequence, _frame, _frame_size, _frame_count );
    } else {
        outline0( "LD HL, 0" );
    }

    outline0("DI");
    outline0("EXX");
    outline0("EI");

    if ( _source_count > 1 ) {
        Resource resource;
        resource.realName = strdup( _sources[1] );
        resource.type = VT_IMAGE;
        zx_load_image_address_to_register( _environment, NULL, &resource, _sequence, _frame, _frame_size, _frame_count );
    } else {
        outline0( "LD HL, 0" );
    }

    outline1("LD DE, %s", _blit );

    outline0("DI");
    outline0("EXX");
    outline0("EI");

    outline1("LD A, (%s)", _x );
    outline0("LD (IMAGEX), A" );
    outline1("LD A, (%s)", _y );
    outline0("LD (IMAGEY), A" );
    outline1("LD A, $%2.2x", (_flags & 0Xff) );
    outline0("LD (IMAGEF), A" );
    outline1("LD A, $%2.2x", ((_flags>>8) & 0Xff) );
    outline0("LD (IMAGET), A" );

    outline0("CALL BLITIMAGE");

}


Variable * zx_new_image( Environment * _environment, int _width, int _height, int _mode ) {

    deploy( vars, src_hw_zx_vars_asm );

    int size = calculate_image_size( _environment, _width, _height, _mode );

    if ( ! size ) {
        CRITICAL_NEW_IMAGE_UNSUPPORTED_MODE( _mode );
    }

    Variable * result = variable_temporary( _environment, VT_IMAGE, "(new image)" );

    char * buffer = malloc ( size );
    memset( buffer, 0, size );

    *(buffer) = ( _width & 0xff );
    *(buffer+1) = ( ( _width >> 8 ) & 0xff );
    *(buffer+2) = _height;

    result->valueBuffer = buffer;
    result->size = size;
    
    return result;

}

Variable * zx_new_images( Environment * _environment, int _frames, int _width, int _height, int _mode ) {

    deploy( vars, src_hw_zx_vars_asm );

    int size = calculate_images_size( _environment, _frames, _width, _height, _mode );
    int frameSize = calculate_image_size( _environment, _width, _height, _mode );

    if ( ! size ) {
        CRITICAL_NEW_IMAGES_UNSUPPORTED_MODE( _mode );
    }

    Variable * result = variable_temporary( _environment, VT_IMAGES, "(new images)" );

    char * buffer = malloc ( size );
    memset( buffer, 0, size );

    *(buffer) = _frames;
    *(buffer+1) = ( _width & 0xff );
    *(buffer+2) = ( _width >> 8 ) & 0xff;
    for( int i=0; i<_frames; ++i ) {
        *(buffer+3+(i*frameSize)) = ( _width & 0xff );
        *(buffer+3+(i*frameSize)+1) = ( ( _width >> 8 ) & 0xff );
        *(buffer+3+(i*frameSize)+2) = ( _height & 0xff );
    }

    result->valueBuffer = buffer;
    result->frameSize = frameSize;
    result->size = size;
    result->frameCount = _frames;
    
    return result;

}

Variable * zx_new_sequence( Environment * _environment, int _sequences, int _frames, int _width, int _height, int _mode ) {

    deploy( vars, src_hw_zx_vars_asm );

    int size2 = calculate_sequence_size( _environment, _sequences, _frames, _width, _height, _mode );
    int size = calculate_images_size( _environment, _frames, _width, _height, _mode );
    int frameSize = calculate_image_size( _environment, _width, _height, _mode );

    if ( ! size ) {
        CRITICAL_NEW_IMAGES_UNSUPPORTED_MODE( _mode );
    }

    Variable * result = variable_temporary( _environment, VT_SEQUENCE, "(new sequence)" );

    char * buffer = malloc ( size2 );
    memset( buffer, 0, size2 );

    *(buffer) = _frames;
    *(buffer+1) = _width;
    *(buffer+2) = _sequences;
    for( int i=0; i<(_frames*_sequences); ++i ) {
        *(buffer+3+(i*frameSize)) = ( _width & 0xff );
        *(buffer+3+(i*frameSize)+1) = ( ( _width >> 8 ) & 0xff );
        *(buffer+3+(i*frameSize)+2) = ( _height & 0xff );
    }

    result->valueBuffer = buffer;
    result->frameSize = frameSize;
    result->size = size;
    result->frameCount = _frames;
    
    return result;

}

void zx_get_image( Environment * _environment, char * _image, char * _x, char * _y, char * _frame, char * _sequence, int _frame_size, int _frame_count, int _palette ) {
    
    MAKE_LABEL

    deploy( vars, src_hw_zx_vars_asm);
    deploy( getimage, src_hw_zx_get_image_asm );

    zx_load_image_address_to_other_register( _environment, "HL", _image, _sequence, _frame, _frame_size, _frame_count );

    outline1("LD A, (%s)", _x );
    outline0("LD (IMAGEX), A" );
    outline1("LD A, (%s)", _y );
    outline0("LD (IMAGEY), A" );
    outline1("LD A, $%2.2x", _palette & 0xff );
    outline0("LD (IMAGET), A" );

    outline0("CALL GETIMAGE");

}

void zx_scroll( Environment * _environment, int _dx, int _dy ) {

};

void zx_put_tile( Environment * _environment, char * _tile, char * _x, char * _y ) {

    deploy( zxvars, src_hw_zx_vars_asm);
    deploy( tiles, src_hw_zx_tiles_asm );

    outline1("LD A, (%s)", _tile );
    outline0("LD (TILET), A" );
    outline1("LD A, (%s)", _x );
    outline0("LD (TILEX), A" );
    outline1("LD A, (%s)", _y );
    outline0("LD (TILEY), A" );
    outline0("LD A, 1" );
    outline0("LD (TILEW), A" );
    outline0("LD (TILEH), A" );
    outline0("LD (TILEW2), A" );
    outline0("LD (TILEH2), A" );

    outline0("CALL PUTTILE");

}

void zx_move_tiles( Environment * _environment, char * _tile, char * _x, char * _y ) {

    Variable * tile = variable_retrieve( _environment, _tile );
    Variable * x = variable_retrieve( _environment, _x );
    Variable * y = variable_retrieve( _environment, _y );

    deploy( zxvars, src_hw_zx_vars_asm);
    deploy( tiles, src_hw_zx_tiles_asm );

    int size = ( tile->originalWidth >> 3 ) * ( tile->originalHeight >> 3 );

    if ( size ) {
        outline1("LD HL, OFFSETS%4.4x", size );
        outline0("LD A, L" );
        outline0("LD (TILEO), A" );
        outline0("LD A, H" );
        outline0("LD (TILEO+1), A" );
    } else {
        outline0("LD A, 0" );
        outline0("LD (TILEO), A" );
        outline0("LD (TILEO+1), A" );
    }

    outline1("LD A, (%s)", tile->realName );
    outline0("LD (TILET), A" );
    outline1("LD A, (%s)", x->realName );
    outline0("LD (TILEX), A" );
    outline1("LD A, (%s)", y->realName );
    outline0("LD (TILEY), A" );
    outline1("LD A, (%s)", address_displacement(_environment, tile->realName, "1") );
    outline0("LD (TILEW), A" );
    outline0("LD (TILEW2), A" );
    outline1("LD A, (%s)", address_displacement(_environment, tile->realName, "2") );
    outline0("LD (TILEH), A" );
    outline0("LD (TILEH2), A" );
    outline1("LD A, (%s)", address_displacement(_environment, tile->realName, "3") );
    outline0("LD (TILEA), A" );

    outline0("CALL MOVETILE");

}

void zx_put_tiles( Environment * _environment, char * _tile, char * _x, char * _y, char *_w, char *_h ) {

    deploy( zxvars, src_hw_zx_vars_asm);
    deploy( tiles, src_hw_zx_tiles_asm );

    outline1("LD A, (%s)", _tile );
    outline0("LD (TILET), A" );
    outline1("LD A, (%s)", _x );
    outline0("LD (TILEX), A" );
    outline1("LD A, (%s)", _y );
    outline0("LD (TILEY), A" );
    outline1("LD A, (%s)", address_displacement(_environment, _tile, "1") );
    outline0("LD (TILEW), A" );
    if ( _w ) {
        outline1("LD A, (%s)", _w );
    }
    outline0("LD (TILEW2), A" );
    outline1("LD A, (%s)", address_displacement(_environment, _tile, "2") );
    outline0("LD (TILEH), A" );
    if ( _h ) {
        outline1("LD A, (%s)", _h );
    }
    outline0("LD (TILEH2), A" );

    outline0("CALL PUTTILE");

}

void zx_tile_at( Environment * _environment, char * _x, char * _y, char * _result ) {

    deploy( zxvars, src_hw_zx_vars_asm);
    deploy( tiles, src_hw_zx_tiles_asm );

    outline1("LD A, (%s)", _x );
    outline0("LD (TILEX), A" );
    outline1("LD A, (%s)", _y );
    outline0("LD (TILEY), A" );

    outline0("CALL TILEAT");

    outline0("LD A, (TILET)" );
    outline1("LD (%s), A", _result );

}

void zx_use_tileset( Environment * _environment, char * _tileset ) {

    deploy( zxvars, src_hw_zx_vars_asm);
    deploy( tiles, src_hw_zx_tiles_asm );

    outline1("LD A, (%s)", _tileset );

    outline0("CALL USETILESET");

}

Variable * zx_get_raster_line( Environment * _environment ) {

    Variable * result = variable_temporary( _environment, VT_WORD, "(raster line)" );

    variable_store( _environment, result->name, 261 );

    return result;
    
}

void zx_slice_image( Environment * _environment, char * _image, char * _frame, char * _sequence, int _frame_size, int _frame_count, char * _destination ) {

}

void zx_sys_call( Environment * _environment, int _destination ) {

    outline1("CALL $%4.4x", _destination );

}

int zx_palette_extract( Environment * _environment, char * _data, int _width, int _height, int _depth, int _flags, RGBi * _palette ) {

    int paletteColorCount = rgbi_extract_palette(_environment, _data, _width, _height, _depth, _palette, MAX_PALETTE, ( ( _flags & FLAG_EXACT ) ? 0 : 1 ) /* sorted */);

    memcpy( _palette, palette_match( _palette, paletteColorCount, SYSTEM_PALETTE, sizeof(SYSTEM_PALETTE) / sizeof(RGBi) ), paletteColorCount * sizeof( RGBi ) );

    int uniquePaletteCount = 0;

    memcpy( _palette, palette_remove_duplicates( _palette, paletteColorCount, &uniquePaletteCount ), paletteColorCount * sizeof( RGBi ) );

    return uniquePaletteCount;

}

void zx_irq_at( Environment * _environment, char * _label ) {

    outline0("DI" );
    outline1("LD DE, %s", _label );
    outline0("LD HL, IRQVECTOR" );
    outline0("LD A, $c3" );
    outline0("LD (HL), A" );
    outline0("INC HL" );
    outline0("LD A, E" );
    outline0("LD (HL), A" );
    outline0("INC HL" );
    outline0("LD A, D" );
    outline0("LD (HL), A" );
    outline0("LD A, 1" );
    outline0("LD (IRQVECTORREADY), A" );
    outline0("EI" );
    
}

void zx_follow_irq( Environment * _environment ) {

    // Variable * irq = variable_retrieve_or_define( _environment, "irq", VT_ADDRESS, 0 );

    // outline1("LD HL, (%s)", irq->realName );
    // outline0("JP (HL)" );
    
    outline0("RET" );

}

void zx_hscroll_line( Environment * _environment, int _direction ) {

    deploy( textHScrollLine, src_hw_zx_hscroll_asm);

    outline0("LD A, (YCURSYS)" );
    outline0("LD B, A" );
    outline1("LD A, $%2.2x", ( _direction & 0xff ) );

    outline0("CALL HSCROLLLINE");

}

void zx_timer_set_status_on( Environment * _environment, char * _timer ) {
    
    deploy( timer, src_hw_z80_timer_asm);

    if ( _timer ) {
        outline1("LD A, (%s)", _timer );
        outline0("LD A, B" );
    } else {
        outline0("LD B, 0" );
    }
    outline0("LD A, 1" );
    outline0("LD C, A" );
    outline0("CALL TIMERSETSTATUS" );

}

void zx_timer_set_status_off( Environment * _environment, char * _timer ) {

    deploy( timer, src_hw_z80_timer_asm);

    if ( _timer ) {
        outline1("LD A, (%s)", _timer );
        outline0("LD A, B" );
    } else {
        outline0("LD B, 0" );
    }
    outline0("LD A, 0" );
    outline0("LD C, A" );
    outline0("CALL TIMERSETSTATUS" );


}

void zx_timer_set_counter( Environment * _environment, char * _timer, char * _counter ) {

    deploy( timer, src_hw_z80_timer_asm);

    if ( _counter ) {
        outline1("LD A, (%s)", _counter );
        outline0("LD IXL, A" );
        outline1("LD A, (%s)", address_displacement( _environment, _counter, "1" ) );
        outline0("LD IXH, A" );
    } else {
        outline0("LD IX, 0" );
    }
    if ( _timer ) {
        outline1("LD A, (%s)", _timer );
        outline0("LD B, A" );
    } else {
        outline0("LD B, 0" );
    }
    outline0("CALL TIMERSETCOUNTER" );

}

void zx_timer_set_init( Environment * _environment, char * _timer, char * _init ) {

    deploy( timer, src_hw_z80_timer_asm);

    if ( _init ) {
        outline1("LD A, (%s)", _init );
        outline0("LD IXL, A" );
        outline1("LD A, (%s)", address_displacement( _environment, _init, "1" ) );
        outline0("LD IXH, A" );
    } else {
        outline0("LD IX, 0" );
    }
    if ( _timer ) {
        outline1("LD A, (%s)", _timer );
        outline0("LD B, A" );
    } else {
        outline0("LD B, 0" );
    }
    outline0("CALL TIMERSETINIT" );

}

void zx_timer_set_address( Environment * _environment, char * _timer, char * _address ) {

    deploy( timer, src_hw_z80_timer_asm);

    if ( _address ) {
        outline1("LD HL, %s", _address );
        outline0("LD A, L" );
        outline0("LD IXL, A" );
        outline0("LD A, H" );
        outline0("LD IXH, A" );
    } else {
        outline0("LD IX, 0" );
    }
    if ( _timer ) {
        outline1("LD A, (%s)", _timer );
        outline0("LD B, A" );
    } else {
        outline0("LD B, 0" );
    }
    outline0("CALL TIMERSETADDRESS" );

}

#endif