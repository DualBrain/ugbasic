/*****************************************************************************
 * ugBASIC - an isomorphic BASIC language compiler for retrocomputers        *
 *****************************************************************************
 * Copyright 2021-2023 Marco Spedaletti (asimov@mclink.it)
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

/****************************************************************************
 * CODE SECTION
 ****************************************************************************/

#ifdef __coco__

void coco_xpen( Environment * _environment, char * _destination ) {

    MAKE_LABEL

    outline0("LDA $FF60");    
    outline1("STA %s", address_displacement(_environment, _destination, "1"));
    outline0("LDA #0");
    outline1("STA %s", _destination);

}

void coco_ypen( Environment * _environment, char * _destination ) {

    MAKE_LABEL

    outline0("LDA $FF61");    
    outline1("STA %s", address_displacement(_environment, _destination, "1"));
    outline0("LDA #0");
    outline1("STA %s", _destination);
   
}

void coco_color_border( Environment * _environment, char * _color ) {

}

void coco_vscroll( Environment * _environment, int _displacement ) {

}

void coco_text_at( Environment * _environment, char * _text, char * _text_size, char * _pen, char * _paper ) {

}

void coco_cls( Environment * _environment, char * _pen, char * _paper ) {

}

void coco_inkey( Environment * _environment, char * _pressed, char * _key ) {

    MAKE_LABEL

    coco_scancode( _environment, _pressed, _key );

    outline1("LDA %s", _pressed );
    outline0("CMPA #0" );
    outline1("BEQ %sskip", label );
    outline1("LDA %s", _key );
    outline0("ANDA #$80" );
    outline0("CMPA #0" );
    outline1("BNE %snoascii", label );
    outline1("LDA %s", _key );
    outline0("CMPA $011d" );
    outline1("BNE %sdifferent", label );
    outline0("DEC $011f" );
    outline0("LDB $011f" );
    outline0("CMPB KBDRATE" );
    outline1("BEQ %sascii", label );
    outline0("LDA #0" );
    outline1("STA %s", _pressed );
    outline1("JMP %sdone", label );
    outhead1("%snoascii", label );
    outline0("LDA #0" );
    outline1("STA %s", _key );
    outline1("JMP %sdone", label );
    outhead1("%sdifferent", label );
    outline0("STA $011d" );
    outhead1("%sascii", label );
    outline0("LDB #0" );
    outline0("STB $011f" );
    outline1("JMP %sdone", label );
    outhead1("%sskip", label );
    outline0("LDA #0" );
    outline0("STA $011d" );
    outhead1("%sdone", label );

}

void coco_scancode( Environment * _environment, char * _pressed, char * _scancode ) {

    MAKE_LABEL

    deploy( scancode, src_hw_coco_scancode_asm );

    outline0("LDA #0" );
    outline1("STA %s", _pressed );
    outline1("STA %s", _scancode );

    outline0("JSR SCANCODE" );
    outline0("CMPA #0" );
    outline1("BEQ %snokey", label );
    outline1("STA %s", _scancode );
    outline0("LDA #$FF" );
    outline1("STA %s", _pressed );
    outhead1("%snokey", label );

}

void coco_key_pressed( Environment * _environment, char *_scancode, char * _result ) {

    MAKE_LABEL

    char nokeyLabel[MAX_TEMPORARY_STORAGE];
    sprintf( nokeyLabel, "%slabel", label );
    
    Variable * temp = variable_temporary( _environment, VT_BYTE, "(pressed)" );

    coco_scancode( _environment, temp->realName, _result );
    cpu_compare_8bit( _environment, _result, _scancode,  temp->realName, 1 );
    cpu_compare_and_branch_8bit_const( _environment, temp->realName, 0, nokeyLabel, 1 );
    cpu_store_8bit( _environment, _result, 0xff );
    cpu_jump( _environment, label );
    cpu_label( _environment, nokeyLabel );
    cpu_store_8bit( _environment, _result, 0x00 );
    cpu_label( _environment, label );

}

void coco_scanshift( Environment * _environment, char * _shifts ) {

    coco_keyshift( _environment, _shifts );
    
}

void coco_keyshift( Environment * _environment, char * _shifts ) {

    MAKE_LABEL

    Variable * pressed = variable_temporary( _environment, VT_BYTE, "(pressed)" );
    Variable * scancode = variable_temporary( _environment, VT_BYTE, "(scancode)" );

    Variable * result = variable_temporary( _environment, VT_BYTE, "(result)");
    
    coco_scancode( _environment, pressed->realName, scancode->realName );

    outline1("LDA %s", result->realName );
    outline1("CMPA #$%2.2x", (unsigned char) KEY_SHIFT);
    outline0("BEQ %sshift");
    outline0("LDA #0");
    outline1("STA %s", _shifts);
    outline1("JMP %sdone", label );
    outhead1("%sshift", label);
    outline0("LDA #3");
    outline1("STA %s", _shifts);
    outline1("JMP %sdone", label );
    outhead1("%sdone", label );


}

void coco_clear_key( Environment * _environment ) {

    outline0("LDA #$0");
    outline0("LDX $35");
    outline0("STA ,X");

    outline0("LDA #$0");
    outline0("sta $87");

}

void coco_initialization( Environment * _environment ) {

}

int coco_screen_mode_enable( Environment * _environment, ScreenMode * _screen_mode ) {
    
}

void coco_bitmap_enable( Environment * _environment, int _width, int _height, int _colors ) {

}

void coco_tilemap_enable( Environment * _environment, int _width, int _height, int _colors, int _tile_width, int _tile_height ) {
    
}

void coco_back( Environment * _environment ) {

}

void coco_busy_wait( Environment * _environment, char * _timing ) {

    MAKE_LABEL

    outline1("LDD %s", _timing );
    outline0("LDX $0112");
    outline0("LEAX D, X");
    outhead1("%sfirst", label );
    outline0("CMPX $0112");
    outline1("BGT %sfirst", label);
}

void coco_irq_at( Environment * _environment, char * _label ) {

    outline0("ORCC #$10" );
    outline0("STX IRQSVC2+1" );
    outline1("LDX #%s", _label );
    outline0("STX IRQSVC2+1" );
    outline0("LDA #$bd" );
    outline0("STA IRQSVC2" );
    outline0("ANDCC #$EF" );
    
}

void coco_follow_irq( Environment * _environment ) {

    outline0("RTS" );
    
}


void coco_sys_call( Environment * _environment, int _destination ) {

    outline0("PSHS D");
    outline1("LDD #$%4.4x", _destination );
    outline0("STD SYSCALL0+1");
    outline0("PULS D");
    outline0("JSR SYSCALL");

}

void coco_timer_set_status_on( Environment * _environment, char * _timer ) {
    
    deploy( timer, src_hw_coco_timer_asm);

    if ( _timer ) {
        outline1("LDB %s", _timer );
    } else {
        outline0("LDB #0" );
    }
    outline0("LDA #$1" );
    outline0("STA MATHPTR0" );
    outline0("JSR TIMERSETSTATUS" );

}

void coco_timer_set_status_off( Environment * _environment, char * _timer ) {

    deploy( timer, src_hw_coco_timer_asm);

    if ( _timer ) {
        outline1("LDB %s", _timer );
    } else {
        outline0("LDB #0" );
    }
    outline0("LDA #$0" );
    outline0("STA MATHPTR0" );
    outline0("JSR TIMERSETSTATUS" );

}

void coco_timer_set_counter( Environment * _environment, char * _timer, char * _counter ) {

    deploy( timer, src_hw_coco_timer_asm);

    if ( _counter ) {
        outline1("LDD %s", _counter );
    } else {
        outline0("LDD #0" );
    }
    outline0("STD MATHPTR2");
    if ( _timer ) {
        outline1("LDB %s", _timer );
    } else {
        outline0("LDB #0" );
    }
    outline0("JSR TIMERSETCOUNTER" );

}

void coco_timer_set_init( Environment * _environment, char * _timer, char * _init ) {

    deploy( timer, src_hw_coco_timer_asm);

    outline1("LDD %s", _init );
    outline0("STD MATHPTR2");
    if ( _timer ) {
        outline1("LDB %s", _timer );
    } else {
        outline0("LDB #0" );
    }
    outline0("JSR TIMERSETINIT" );

}

void coco_timer_set_address( Environment * _environment, char * _timer, char * _address ) {

    deploy( timer, src_hw_coco_timer_asm);

    outline1("LDD #%s", _address );
    outline0("STD MATHPTR2");
    if ( _timer ) {
        outline1("LDB %s", _timer );
    } else {
        outline0("LDB #0" );
    }
    outline0("JSR TIMERSETADDRESS" );

}

#endif