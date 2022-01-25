; "Tensor Trzaskowskiego" for Atari 8-bit by mgr_inz_rafal

; This project is licensed under "THE BEER-WARE LICENSE" (Revision 42).
; rchabowski@gmail.com wrote this project. As long as you retain this
; notice you can do whatever you want with this stuff.
; If we meet some day, and you think this stuff is worth it,
; you can buy me a beer in return.

	; Selected ATARI registes
	icl "include\atari.inc"

; These use some stack
STACK_STARTED_WITH_KUTKA_OVERRIDE equ $100

FONT_SLOT_1 equ $1800
FONT_SLOT_2 equ FONT_SLOT_1+1024
FONT_SLOT_END equ FONT_SLOT_2+1024
CREDITCOLSTART	equ $00
CREDITCOLEND	equ	CREDITCOLSTART+$0f
LEVELFLIPDELAY	equ %00000011
MENU_CURSOR_DELAY equ %00000111
MENU_SWITCH_DELAY equ %00001010
SOURCEDECO 		equ $ff-8*3
TARGETDECO 		equ $b0
PMGDECOOFFSET 	equ 12
DIGITOFFSET		equ 6
SHADOWOFFSET 	equ 60
TITLEOFFSET 	equ 60+20
MAPCOUNT 		equ 51
MUSICPLAYER		equ $a300
MAPSIZE			equ	12
SCWIDTH 		equ 20
MARGIN 			equ	(SCWIDTH-MAPSIZE)/2
TOPMARG			equ 16
LFTMARG			equ 80
MV_IDLE			equ 0	  ; Element not moving
MV_MRGH			equ	1	  ; Element is moving right
MV_MLFT			equ	2	  ; Element is moving left
MV_MUP			equ	3	  ; Element is moving up
MV_MBTM			equ	4	  ; Element is moving bottom
MV_CTRD			equ 4	  ; Single move distance when falling down
MV_CTR			equ 8	  ; Single move distance when moving left or right
C_PLAYR			equ	$5d	  ; Player color
C_OBSTA			equ	$76	  ; Obstacles
C_WALL1			equ	$54	  ; Wall #1
C_WALL2			equ	$14	  ; Wall #2
GS_GRAV			equ	0	  ; Making sure everything is on the ground
GS_PLAY			equ	1	  ; Player movement
GS_FIN			equ	2	  ; Level completed
ROT_CTR			equ	20	  ; Delay between rotations
PL_CHR			equ 1	  ; Player character
CS_FADEOUT		equ 0	  ; Credits are fading out
CS_FADEIN		equ 1	  ; Credits are fading in
CS_SHOW			equ	2	  ; Credits are being shown
MAP_STORAGE		equ $d800 ; Maps stored under the OS
FONTS_STORAGE	equ $c000 ; 4 fonts
MENU_ITEM_OFFSET equ (40/2-12/2)
MS_MAIN			equ 1
MS_INSTRUCTION  equ 2
MS_OPTIONS		equ 3
MAIN_MENU_LABEL_LEN equ 18
PERSISTENCY_BANK_CTL equ $d500
PERSISTENCY_BANK_START equ PERSISTENCY_BANK_END-7
PERSISTENCY_BANK_END equ $3f
SAVE_SLOT_LEN 	equ 780 ; See 'memory_map.txt'
CART_RAM_SIZE   equ $2000
CART_RAM_START	equ $a000
CART_RAM_END	equ CART_RAM_START+CART_RAM_SIZE
SAVES_PER_SLOT	equ CART_RAM_SIZE/SAVE_SLOT_LEN
LAST_SAVE_SLOT_ADDRESS equ CART_RAM_START+SAVES_PER_SLOT*SAVE_SLOT_LEN-SAVE_SLOT_LEN
SAVE_SLOT_OCCUPIED_MARK equ $bb
SCORE_SPRITE_START equ 113-4
SCORE_DLI_LINE equ $6b
REDUCER_START_POS equ $ff/2-4-19
REDUCER_END_POS equ $10

.zpvar   .byte  any_moved
.zpvar	.byte	stop_intermission
.zpvar	.byte	antic_tmp
.zpvar	.word	curmap
.zpvar	.word	curmapname
.zpvar	.word	ptr0
.zpvar	.word	ptr1
.zpvar	.word	ptr2
.zpvar	.word	ptr3
.zpvar	.byte	px
.zpvar	.byte	ppx
.zpvar	.byte	psx
.zpvar	.byte	py
.zpvar	.byte	ppy
.zpvar	.byte	pby
.zpvar	.byte	psy
.zpvar	.byte	mvstate
.zpvar  .byte   movable
.zpvar	.byte	target
.zpvar	.byte	collectibles
.zpvar	.byte	repaint
.zpvar	.byte	direction	; 0 - N, 1 - W, 2 - S, 3 - E
.zpvar	.byte	ludek_offset
.zpvar	.byte	ludek_face	; 0 - L, 1 - R
.zpvar  .byte   ntsc
.zpvar  .byte   ntsc_music_conductor
.zpvar  .byte	rmt_player_halt
.zpvar	.byte   menu_cursor_index
.zpvar	.byte   options_cursor_index
.zpvar  .word	current_menu
.zpvar  .byte   menu_state
.zpvar  .byte	level_rotation
.zpvar	.byte   language
.zpvar  .word   options_screen_ptr	; TODO[RC]: Can use any of the "in-game" ZP variables
.zpvar  .word   main_menu_screen_ptr	; TODO[RC]: Can use any of the "in-game" ZP variables
.zpvar  .byte   dont_touch_menu
.zpvar	.word	ZX5_OUTPUT
.zpvar	.word	copysrc 
.zpvar	.word	len      
.zpvar	.word	pnb      
.zpvar	.word	current_persistency_address	; ...$BA
.zpvar  .byte   last_true_player_pos

; Rest of ZP
; $CB - $DC - RMT player


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; BEGIN: TENSOR LOGO G2F ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/***************************************/
/*  Use MADS http://mads.atari8.info/  */
/*  Mode: GED- (bitmap mode)           */
/***************************************/

	icl "include\tensor5.h"

	org $00

zc	.ds ZCOLORS

	org $f0

fcnt	.ds 2
fadr	.ds 2
fhlp	.ds 2
cloc	.ds 1
regA	.ds 1
regX	.ds 1
regY	.ds 1

WIDTH	= 40
HEIGHT	= 30

; ---	BASIC switch OFF
	org $2000\ mva #$ff portb\ rts\ ini $2000

; ---	Load some data into the $D800 region (second OS ROM block)
	org $2000
.rept MAPCOUNT #+1
COMPRESSED_MAP:1 equ *-$2000 + MAP_STORAGE
	ins "maps\v:1.map.kloc"
.endr
ENGLISH_LEVEL_NAMES equ *-$2000 + MAP_STORAGE		
		ins "data\level_names_en.obx.kloc"
ENGLISH_LEVEL_NAMES_END equ *-$2000 + MAP_STORAGE		
DECORATION_DATA equ *-$2000 + MAP_STORAGE		
		ins "data\decoration.pmg.kloc"
DECORATION_DATA_END equ *-$2000 + MAP_STORAGE		
MAPS_END equ *
MAPS_END_IN_STORAGE equ MAPS_END + MAP_STORAGE - $2000

COPY_UNDER_OS
	lda #0
	sta DMACTL
	sei
	lda #0
	sta NMIEN
	lda #$fe
	sta PORTB

; Copy target
	lda <MAP_STORAGE
	sta $80
	lda >MAP_STORAGE
	sta $81

; Copy source
	lda <$2000
	sta $82
	lda >$2000
	sta $83

	ldy #0
@	lda ($82),y
	sta ($80),y
	inw $80
	inw $82

	lda $82
	cmp <MAPS_END
	bne @-
	lda $83
	cmp >MAPS_END
	bne @-

COPY_DONE
	lda #$ff
	sta PORTB
	lda #$40
	sta NMIEN
	cli

	rts
	ini COPY_UNDER_OS

; ---	Load some data into the $C000 region (first OS ROM block)
	org $2000
CREDITS_FONT equ *-$2000 + FONTS_STORAGE		
		ins "fonts\credits3.fnt.kloc"
CREDITS_FONT_END equ *-$2000 + FONTS_STORAGE		
TITLE_FONT equ *-$2000 + FONTS_STORAGE
		ins "fonts\BZZZ1.FNT.kloc"
TITLE_FONT_END equ *-$2000 + FONTS_STORAGE		
GAME_FONT equ *-$2000 + FONTS_STORAGE		
		ins "fonts\fontek.fnt.kloc"
GAME_FONT_END equ *-$2000 + FONTS_STORAGE		
DIGITS_FONT equ *-$2000 + FONTS_STORAGE		
		ins "fonts\digits.fnt.kloc"
DIGITS_FONT_END equ *-$2000 + FONTS_STORAGE		
GAME_FONT_2 equ *-$2000 + FONTS_STORAGE		
		ins "fonts\fontek2.fnt.kloc"
GAME_FONT_2_END equ *-$2000 + FONTS_STORAGE		
POLISH_LEVEL_NAMES equ *-$2000 + FONTS_STORAGE		
		ins "data\level_names.obx.kloc"
POLISH_LEVEL_NAMES_END equ *-$2000 + FONTS_STORAGE		
FONTS_END equ *


COPY_UNDER_OS_FONTS
	sei
	lda #0
	sta NMIEN
	lda #$fe
	sta PORTB

; Copy target
	lda <FONTS_STORAGE
	sta $80
	lda >FONTS_STORAGE
	sta $81

; Copy source
	lda <$2000
	sta $82
	lda >$2000
	sta $83

	ldy #0
@	lda ($82),y
	sta ($80),y
	inw $80
	inw $82

	lda $82
	cmp <FONTS_END
	bne @-
	lda $83
	cmp >FONTS_END
	bne @-

COPY_FONTS_DONE
	lda #$ff
	sta PORTB
	lda #$40
	sta NMIEN
	cli

	rts
	ini COPY_UNDER_OS_FONTS

; ---	MAIN PROGRAM
	org $2000
scr	ins "data\tensor5.raw" +0,+0,3520
MODUL
		opt h-
		ins "music\TENSOR.rmt"
		opt h+
	
	org $3900-3+1087
TITLE_TOP_BORDER
	dta b(62)
:38	dta b(125)
	dta b(93)
TITLE_BOTTOM_BORDER
	dta b(91)
:1	dta b(125)
	dta b(125)

	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)
	dta b(125)

	dta b(125)
:12	dta b(125)

	dta b(126)
	dta b(72)
	dta b(73)
	dta b(127)
	dta b(125)
	dta b(92)
MENU_0_DATA
	dta b(124),d'              Graj                    ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'              Opcje                   ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'              Instrukcja              ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'              Wyjscie                 ',b(124)
LUDEK_DATA
		dta b($62)
		dta b($16)
		dta b($38)
		dta b($18)
		dta b($70)
		dta b($30)
		dta b($70)
		dta b($00)
		
		dta b($30)
		dta b($1C)
		dta b($18)
		dta b($18)
		dta b($10)
		dta b($38)
		dta b($18)
		dta b($38)
		
		dta b($18)
		dta b($18)
		dta b($1C)
		dta b($18)
		dta b($10)
		dta b($38)
		dta b($18)
		dta b($38)

		dta b($0C)
		dta b($30)
		dta b($18)
		dta b($18)
		dta b($10)
		dta b($38)
		dta b($18)
		dta b($38)

AMYGDALA_DATA_5	; Miecz
	dta b(0),b(192),b(160),b(84),b(44),b(24),b(52),b(2),b($64),b($74)

AMYGDALA_DATA_6	; Pierscionek
	dta b(0),b(60),b(24),b(52),b(82),b(64),b(66),b(52),b($a6),b($b6)

AMYGDALA_DATA_7	; Robak
	dta b(0),b(146),b(130),b(84),b(16),b(88),b(16),b(56),b($34),b($44)

scr_head     .he 00 00 00 00 00 00 00 c1 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 42 00 03 04 05 06 87 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 08 09 0a 0b 0c 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 4d 00 0e 0f 10 d1 d2 00 93 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 d4 15 d4 00 00 00 00 00 00 00 00 00 00 00
 	.he 00 00 00 00 00 16 17 18 99 9a 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 1b 5c 9d 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 1e 1f a0 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 61+128 62+128 63+128 00+128 64+128 65+128 66+128 67+128 68+128 00 00 00 00 00 00 00 00
	.he 00 00 00 00 69 6a 6b 6c 6d 6e 6f 79+128 00 00 00 00 00 00 00 00
	.he 00 00 00 70+128 71+128 72+128 73+128 74+128 75+128 76+128 77+128 78+128 00 00 00 00 00 00 00 00

MENU_0_DATA_EN
	dta b(124),d'              Play                    ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'              Options                 ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'              Info                    ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'              Quit                    ',b(124)

MENU_1_DATA
	dta b(124),d'     Przyspieszenie  grawitacyjne     ',b(124)
	dta b(124),d'          '
GRAVITY_LABEL
	dta d'     POTEZNE      '*
	dta d'          ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'           Obrot  pieczary            ',b(124)
	dta b(124),d'          '
ROTATION_LABEL
	dta d'    ANIMOWANY     '
	dta d'          ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'        Jezyk stosowany w grze        ',b(124)
	dta b(124),d'              '
LANGUAGE_LABEL
	dta d'  POLSKI '
	dta d'               ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                Powrot                ',b(124)

MENU_1_DATA_EN
	dta b(124),d'         Gravity acceleration         ',b(124)
	dta b(124),d'          '
GRAVITY_LABEL_1
	dta d'      MIGHTY      '*
	dta d'          ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'           Level  rotation            ',b(124)
	dta b(124),d'          '
ROTATION_LABEL_1
	dta d'     ANIMATED     '
	dta d'          ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'               Language               ',b(124)
	dta b(124),d'          '
LANGUAGE_LABEL_1
	dta d'     ENGLISH      '
	dta d'          ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'                 Back                 ',b(124)

; TODO[RC]: Dedatatize this buffer
MAP_01_NAME
		dta d'                '
		dta d'                '
MAP_01_NAME_END
		dta d'  '
MAP_02_NAME
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
		dta d'                '
		dta d'                '
		dta d'  '
MAP_NAME_LAST
		dta b($9b)

COMPRESSED_MAPS_LUT
.rept MAPCOUNT #+1
		dta a(COMPRESSED_MAP:1)
.endr

INSTRUCTION_DATA
	dta b(124),d'Lorem ipsum dolor0sit amet, consectetu',b(124)
	dta b(124),d'Lorem ipsum dolor1sit amet, consectetu',b(124)
	dta b(124),d'Lorem ipsum dolor2sit amet, consectetu',b(124)
	dta b(124),d'Lorem ipsum dolor3sit amet, consectetu',b(124)
	dta b(124),d'Lorem ipsum dolor4sit amet, consectetu',b(124)
	dta b(124),d'Lorem ipsum dolor5sit amet, consectetu',b(124)
	dta b(124),d'Lorem ipsum dolor6sit amet, consectetu',b(124)
	dta b(124),d'Lorem ipsum dolor7sit amet, consectetu',b(124)
	dta b(124),d'Lorem ipsum dolor8sit amet, consectetu',b(124)
	dta b(124),d'Lorem ipsum dolor9sit amet, consectetu',b(124)
	dta b(124),d'Lorem ipsum dolorAsit amet, consectetu',b(124)

INSTRUCTION_DATA_EN
	dta b(124),d'Lorem ipsum dolor0for INGLISZ speaking',b(124)
	dta b(124),d'Lorem ipsum dolor1for INGLISZ speaking',b(124)
	dta b(124),d'Lorem ipsum dolor2for INGLISZ speaking',b(124)
	dta b(124),d'Lorem ipsum dolor3for INGLISZ speaking',b(124)
	dta b(124),d'Lorem ipsum dolor4for INGLISZ speaking',b(124)
	dta b(124),d'Lorem ipsum dolor5for INGLISZ speaking',b(124)
	dta b(124),d'Lorem ipsum dolor6for INGLISZ speaking',b(124)
	dta b(124),d'Lorem ipsum dolor7for INGLISZ speaking',b(124)
	dta b(124),d'Lorem ipsum dolor8for INGLISZ speaking',b(124)
	dta b(124),d'Lorem ipsum dolor9for INGLISZ speaking',b(124)
	dta b(124),d'Lorem ipsum dolorAfor INGLISZ speaking',b(124)

unZX5         lda   #$ff
              sta   offset
              sta   offset+1
              ldy   #$00
              sty   len
              sty   len+1
              lda   #$80

dzx5s_literals
              jsr   dzx5s_elias
              pha
cop0          jsr   _GET_BYTE
              ldy   #$00
              sta   (ZX5_OUTPUT),y
              inw   ZX5_OUTPUT
              lda   len
              bne   @+
              dec   len+1
@             dec   len
              bne   cop0
              lda   len+1
              bne   cop0
              pla
              asl   @
              bcs   dzx5s_other_offset

dzx5s_last_offset
              jsr   dzx5s_elias
dzx5s_copy    pha
              lda   ZX5_OUTPUT
              clc
              adc   offset
              sta   copysrc
              lda   ZX5_OUTPUT+1
              adc   offset+1
              sta   copysrc+1
              ldy   #$00
              ldx   len+1
              beq   Remainder
Page          lda   (copysrc),y
              sta   (ZX5_OUTPUT),y
              iny
              bne   Page
              inc   copysrc+1
              inc   ZX5_OUTPUT+1
              dex
              bne   Page
Remainder     ldx   len
              beq   copyDone
copyByte      lda   (copysrc),y
              sta   (ZX5_OUTPUT),y
              iny
              dex
              bne   copyByte
              tya
              clc
              adc   ZX5_OUTPUT
              sta   ZX5_OUTPUT
              bcc   copyDone
              inc   ZX5_OUTPUT+1
copyDone      stx   len+1
              stx   len
              pla
              asl   @
              bcc   dzx5s_literals

dzx5s_other_offset
              asl   @
              bne   dzx5s_other_offset_skip
              jsr   _GET_BYTE
              sec   ; można usunąć jeśli dekompresja z pamięci a nie pliku
              rol   @
dzx5s_other_offset_skip
              bcc   dzx5s_prev_offset

dzx5s_new_offset
              sta   pnb
              asl   @
              ldx   offset2
              stx   offset3
              ldx   offset2+1
              stx   offset3+1
              ldx   offset
              stx   offset2
              ldx   offset+1
              stx   offset2+1
              ldx   #$fe
              stx   len
              jsr   dzx5s_elias_loop
              pha
              ldx   len
              inx
              stx   offset+1
              bne   @+
              pla
              rts           ; koniec
@             jsr   _GET_BYTE
              sta   offset
              ldx   #$00
              stx   len+1
              inx
              stx   len
              pla
              dec   pnb
              bmi   @+
              jsr   dzx5s_elias_backtrack
@             inw   len
              jmp   dzx5s_copy

dzx5s_prev_offset
              asl   @
              bcc   dzx5s_second_offset
              ldy   offset2
              ldx   offset3
              sty   offset3
              stx   offset2
              ldy   offset2+1
              ldx   offset3+1
              sty   offset3+1
              stx   offset2+1

dzx5s_second_offset
              ldy   offset2
              ldx   offset
              sty   offset
              stx   offset2
              ldy   offset2+1
              ldx   offset+1
              sty   offset+1
              stx   offset2+1
              jmp   dzx5s_last_offset

dzx5s_elias   inc   len
dzx5s_elias_loop
              asl   @
              bne   dzx5s_elias_skip
              jsr   _GET_BYTE
              sec   ; można usunąć jeśli dekompresja z pamięci a nie pliku
              rol   @
dzx5s_elias_skip
              bcc   dzx5s_elias_backtrack
              rts
dzx5s_elias_backtrack
              asl   @
              rol   len
              rol   len+1
              jmp   dzx5s_elias_loop

HIGH_SCORE_TABLE	; Can be moved under OS
HIGH_SCORE_RECORD_BEGIN
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
HIGH_SCORE_RECORD_END
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
		   dta b($99),b($99),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
HIGH_SCORE_TABLE_END

; wr555 the value from A
wr555
			bit current_persistency_bank
			bvs _wr5c2
			sta $d502   
			sta $b555
			rts     
_wr5c2  
			sta $d542   
			sta $b555			
			rts

; wr222 the value from A
wr222
			bit current_persistency_bank
			bvs _wr2c2
			sta $d501
			sta $aaaa
			rts 
_wr2c2      
			sta $d541       
			sta $aaaa       
			rts

unlock_cart
			lda #$AA
			jsr wr555
			lda #$55
			jsr wr222
			rts
		
write_byte_to_cart
			tya
			pha

			jsr unlock_cart
			ldy #0
			lda #$a0
			jsr wr555
			sta (current_persistency_address),y
			txa
			sta (ptr0),y
			jsr cart_off
			pla
			tay
			rts

cart_off
			sta $d580
			sta wsync
			rts

burn_state
			mwa #PERSISTENCY_BANK_CTL current_persistency_address
bs_8		jsr find_persistency_slot
			cpy #$ff
			beq bs_7
			sty current_persistency_bank
bs_6		cpy #0
			beq bs_5
			inw current_persistency_address
			dey
			jmp bs_6

bs_5
			ldx #SAVE_SLOT_OCCUPIED_MARK
			jsr write_byte_to_cart

			ldy #0
bs_1		inw ptr0
			lda LEVEL_COMPLETION_BITS,y
			tax
			jsr write_byte_to_cart
			iny
			cpy #8
			bne bs_1

			mwa #HIGH_SCORE_TABLE ptr1
			ldy #0
bs_2		inw ptr0
			lda (ptr1),y
			tax
			jsr write_byte_to_cart
			inw ptr1
			#if .word ptr1 <> #HIGH_SCORE_TABLE_END
				jmp bs_2
			#end

			inw ptr0
			ldx instafall
			jsr write_byte_to_cart

			inw ptr0
			ldx rotation_speed
			jsr write_byte_to_cart

			inw ptr0
			ldx language
			jsr write_byte_to_cart

bs_X		rts
bs_7
			jsr erase_state_sector
			jmp bs_8

persistent_save
			jsr os_gone
			jsr burn_state
			jsr os_back
			rts

persistent_load
			jsr os_gone
			jsr read_state
			jsr os_back
			jsr apply_loaded_state
			rts

apply_loaded_state
			lda language
			and #%00000001
			beq als_1
			jsr enable_english		
			mwa main_menu_screen_ptr,y ANTIC_PROGRAM0.TEXT_PANEL_ADDRESS
als_1			
			rts

read_state
			jsr find_last_burned_state
			cpy #$ff
			beq bs_X ; No stored state found

			sta PERSISTENCY_BANK_CTL,y
			sta WSYNC

			ldy #0
			inw ptr0

rs_1		lda (ptr0),y
			sta LEVEL_COMPLETION_BITS,y
			iny
			cpy #8
			bne rs_1

			adw ptr0 #7
			ldy #0
			mwa #HIGH_SCORE_TABLE ptr1
rs_2		inw ptr0
			lda (ptr0),y
			sta (ptr1),y
			inw ptr1
			#if .word ptr1 <> #HIGH_SCORE_TABLE_END
				jmp rs_2
			#end

			inw ptr0
			lda (ptr0),y
			sta instafall

			iny
			lda (ptr0),y
			sta rotation_speed

			iny
			lda (ptr0),y
			sta language

			jsr cart_off

			rts

find_last_burned_state
			ldy #PERSISTENCY_BANK_END

flbs_3		sta PERSISTENCY_BANK_CTL,y
			sta wsync

			tya
			pha
			mwa #LAST_SAVE_SLOT_ADDRESS ptr0
			ldy #0
flbs_2		lda (ptr0),y
			cmp #SAVE_SLOT_OCCUPIED_MARK
			beq flbs_1

; Try previous slot
			sbw ptr0 #SAVE_SLOT_LEN
			#if .word ptr0 < #CART_RAM_START
				pla
				tay
				dey
				cpy #PERSISTENCY_BANK_START-1
				beq flbs_4
				jmp flbs_3
			#end
			jmp flbs_2

; Found last save
flbs_1		pla
			tay
flbs_5		jsr cart_off
			rts
; No save found
flbs_4
			ldy #$ff
			jmp flbs_5

erase_state_sector
			ldy #PERSISTENCY_BANK_START
			sta PERSISTENCY_BANK_CTL,y
			jsr unlock_cart
			lda #$80
			jsr wr555
			jsr unlock_cart
			sta PERSISTENCY_BANK_CTL,y
			lda #$30
			sta CART_RAM_START
			jsr wait_to_complete
			jsr cart_off
			rts

wait_to_complete
poll_write
			lda #0
			sta workpages
_poll_again		
			lda CART_RAM_START
			cmp CART_RAM_START
			bne poll_write
			cmp CART_RAM_START
			bne poll_write
			inc workpages
			bne _poll_again
			rts

find_persistency_slot

			ldy #PERSISTENCY_BANK_START

fps_5		ldx #10
			sta PERSISTENCY_BANK_CTL,y
			sta wsync

			tya
			pha
			mwa #CART_RAM_START ptr0
			ldy #0
fps_3		lda (ptr0),y
			cmp #SAVE_SLOT_OCCUPIED_MARK
			beq fps_1

; Found slot
			pla
			tay 

			; persistency bank in Y
			; slot address in ptr0
			jmp fps_6

; Try next slot within this bank
fps_1		dex
			beq fps_2

			adw ptr0 #SAVE_SLOT_LEN

			jmp fps_3


; Try next persistency bank
fps_2		pla
			tay
			iny
			cpy #PERSISTENCY_BANK_END+1
			beq fps_4
			jmp fps_5
	
; No slot found
fps_4		ldy #$ff
			jmp flbs_5

fps_6	
			jsr cart_off	
			rts

fnt
	ift USESPRITES
	.ALIGN $0800
pmg	.ds $0300
	ift FADECHR = 0
	SPRITES
	els
	.ds $500
	eif
	eif
	
	.ALIGN $0400
ant	ANTIC_PROGRAM scr,ant

main
		lda #$40
		sta os_back_nmien

	jsr disable_antic
		ldy #0
		lda #0
axa1	sta SCRMEM+40*13,y
		iny
		cpy #41
		bne axa1

	ldy #64
@	jsr synchro
	dey
	cpy #0
	bne @-

	mwa #TITLE_FONT ZX5_INPUT
	mwa #FONT_SLOT_1 ZX5_OUTPUT
	jsr decompress_data
	mwa #CREDITS_FONT ZX5_INPUT
	mwa #FONT_SLOT_2 ZX5_OUTPUT
	jsr decompress_data
	
	lda #CS_FADEIN
	sta credits_state
	ldx #0
	stx credits_timer
	inx
	stx credits_flips
	mwa #CREDITS_BASE+80 ANTIC_PROGRAM0.CREDITS_ADDRESS_DL
	ldx #CREDITCOLSTART
	stx credits_color

	lda #0
	sta mapnumber
	sta showsummary

	lda #MS_MAIN
	sta menu_state
	lda dont_touch_menu
	bne ai8
	jsr init_menu
	mwa #MENU_0_DATA ANTIC_PROGRAM0.TEXT_PANEL_ADDRESS
	jsr invert_menu_cursor
ai8 
	ift USESPRITES
	mva >pmg pmbase		;missiles and players data address
	mva #$03 pmcntl		;enable players and missiles
	eif

	lda:cmp:req $14		;wait 1 frame

////////////////////
// RASTER PROGRAM //
////////////////////

	jsr detect_ntsc
	jsr clear_pmg

	; TODO: unlock burning
	; lda PERSISTENCY_LOADED
	; bne awwq
	; jsr persistent_load
	; inc PERSISTENCY_LOADED

awwq
	lda #6
	sta ntsc_music_conductor
	lda #1
	sta rmt_player_halt

	ldx #<MODUL
	ldy #>MODUL
	jsr INIT_MUSIC
	jsr enable_antic
	
chuj
	sei			;stop interrups
	mva #$00 nmien		;stop all interrupts
	mva #$fe portb		;switch off ROM to get 16k more ram

	ZPINIT

	jmp raster_program_end

LOOP	lda vcount		;synchronization for the first screen line
	cmp #$02
	bne LOOP

	mva #@dmactl(standard|dma|lineX1|players|missiles) dmactl	;set new screen width
	mva <ant dlptr
	mva >ant dlptr+1

; Initial values

c0	lda #$00
	sta colbak
	sta hposm1
	sta color0
	sta color2
	sta color3
	sta sizep0
	sta sizep1
	sta sizep2
	sta sizep3
c1	lda LOGO_COLOR_1
	sta color1
	lda #$02
	sta chrctl
	lda #$01
	sta gtictl
s4	lda #$13
	sta sizem
x0	lda #$60
	sta hposp0
x1	lda #$68
	sta hposp1
x2	lda #$70
	sta hposp2
x3	lda #$81
	sta hposp3
x4	lda #$77
	sta hposm0
x5	lda #$69
	sta hposm2
x6	lda #$89
	sta hposm3
c4	lda LOGO_COLOR_2
	sta colpm0
	sta colpm1
	sta colpm2
	sta colpm3
	

	:2 sta wsync

; ---	wait 18 cycles
	jsr _rts
	cmp (0,x)

; ---	set global offset (27 cycles)
	jsr _rts
	jsr _rts
	cmp 0

; ---	empty line
	jsr wait54cycle
	cmp 0\ nop



line0
	jsr wait54cycle
	cmp 0\ nop

line1
	jsr wait54cycle
	cmp 0\ nop

line2
	jsr wait54cycle
	cmp 0\ nop

line3
	jsr wait54cycle
	cmp 0\ nop

line4
	jsr wait54cycle
	cmp 0\ nop

line5
	jsr wait54cycle
	cmp 0\ nop

line6
	jsr wait54cycle
	cmp 0\ nop

line7
	jsr wait54cycle
	cmp 0

line8
	jsr wait54cycle
	cmp 0\ nop

line9
	jsr wait54cycle
	cmp 0\ nop

line10
	jsr wait54cycle
	cmp 0\ nop

line11
	jsr wait54cycle
	cmp 0\ nop

line12
	jsr wait54cycle
	cmp 0\ nop

line13
	jsr wait54cycle
	cmp 0\ nop

line14
	jsr wait54cycle
	cmp 0\ nop

line15
x8	lda #$81
x9	ldx #$92
	sta hposp1
	stx hposm3
	cmp (0,x)
	jsr wait36cycle
	cmp 0

line16
x10	lda #$89
x11	ldx #$94
	sta hposp2
	stx hposp3
	cmp (0,x)
	jsr wait36cycle
	cmp 0\ nop

line17
	jsr wait54cycle
	cmp 0\ nop

line18
	jsr wait54cycle
	cmp 0\ nop

line19
	jsr wait54cycle
	cmp 0\ nop

line20
	jsr wait54cycle
	cmp 0\ nop

line21
x12	lda #$6D
	sta hposp0
	jsr _rts
	jsr wait36cycle
	cmp 0\ nop

line22
x13	lda #$90
x14	ldx #$76
x15	ldy #$91
	sta hposp3
	stx hposm2
	sty hposm3
	lda zc+0
	sta hposp3
	lda cl+0
	:2 nop
	sta hposp3
	jsr _rts
	cmp (0,x)\ cmp 0,x

line23
	jsr wait18cycle
	lda zc+0
	sta hposp3
	lda cl+0
	:2 nop
	sta hposp3
	jsr _rts
	cmp (0,x)\ nop

line24
	jsr wait18cycle
	lda zc+0
	sta hposp3
	lda cl+0
	:2 nop
	sta hposp3
	jsr _rts
	cmp (0,x)\ cmp 0,x

line25
x16	lda #$7E
	sta hposm3
	jsr _rts
	lda zc+0
	sta hposp3
	lda cl+0
	:2 nop
	sta hposp3
	jsr _rts
	cmp (0,x)\ cmp 0,x

line26
	jsr wait18cycle
	lda zc+0
	sta hposp3
	lda cl+0
	:2 nop
	sta hposp3
	jsr _rts
	cmp (0,x)\ cmp 0,x

line27
	jsr wait18cycle
	lda zc+0
	sta hposp3
	lda cl+0
	:2 nop
	sta hposp3
	jsr _rts
	cmp (0,x)\ cmp 0,x

line28
	jsr wait18cycle
	lda zc+0
	sta hposp3
	lda cl+0
	:2 nop
	sta hposp3
	jsr _rts
	cmp (0,x)\ cmp 0,x

line29
s5	lda #$53
	sta sizem
	jsr _rts
	lda zc+0
	sta hposp3
	lda cl+0
	:2 nop
	sta hposp3
	jsr _rts
	cmp (0,x)\ cmp 0,x

line30
x17	lda #$75
	sta hposp2
	jsr _rts
	lda zc+0
	sta hposp3
	lda cl+0
	:2 nop
	sta hposp3
	jsr _rts
	cmp (0,x)\ cmp 0,x

line31
x18	lda #$7D
	sta hposm3
	jsr _rts
	lda zc+0
	sta hposp3
	lda cl+0
	nop
	sta hposp3
	ldy LOGO_COLOR_3
	ldx #$00
	jsr _rts
	:2 nop

line32
	jsr wait18cycle
	lda zc+0
	stx color2 ; X=0
	sta hposp3
	lda cl+0
	sta hposp3
	cmp 0
	stx color2 ; X=0
	jsr _rts
	cmp 0

line33
	jsr wait18cycle
	lda zc+0
	stx color2 ; X=0
	sta hposp3
	lda cl+0
	sta hposp3
	cmp 0
	stx color2
	jsr _rts
	cmp 0

line34
	jsr wait18cycle
	lda zc+0
	sty color2
	sta hposp3
	lda cl+0
	sta hposp3
	cmp 0
	stx color2
	jsr _rts
	cmp 0

line35
	jsr wait18cycle
	lda zc+0
	sty color2
	sta hposp3
	lda cl+0
	sta hposp3
	cmp 0
	stx color2
	jsr _rts
	cmp 0

line36
	jsr wait18cycle
	lda zc+0
	sty color2
	sta hposp3
	lda cl+0
	sta hposp3
	cmp 0
	stx color2
	jsr _rts
	cmp 0

line37
	jsr wait18cycle
	lda zc+0
	sty color2
	sta hposp3
	lda cl+0
	sta hposp3
	cmp 0
	stx color2
	jsr _rts
	cmp 0

line38
	jsr wait18cycle
	lda zc+0
	sty color2
	sta hposp3
	lda cl+0
	sta hposp3
	cmp 0
	stx color2
	jsr _rts
	cmp 0

line39
	jsr wait18cycle
	lda zc+1
	sty color2
	sta hposp3
	lda cl+0
	sta hposp3
	cmp 0
	stx color2
	cmp (0,x)\ pha:pla

line40
x19	lda #$CB
c9	ldx #$00
	sta hposp0
	stx colpm0
	cmp (0,x)
	lda zc+1
	sty color2
	sta hposp3
	lda cl+0
	sta hposp3
	cmp 0
	stx color2
	jsr _rts
	cmp 0

line41
	jsr wait18cycle
	lda zc+1
	sty color2
	sta hposp3
	lda cl+0
	pha:pla
	stx color2
	jsr _rts
	cmp 0

line42
	jsr wait18cycle
	sty color2
	jsr _rts
	jsr _rts
	cmp (0,x)\ pha:pla

line43
	jsr wait54cycle
	cmp 0\ nop

line44
	jsr wait54cycle
	cmp 0\ nop

line45
	jsr wait54cycle
	cmp 0\ nop

line46
	jsr wait54cycle
	cmp 0\ nop

line47
	jsr wait54cycle
	cmp 0

line48
	jsr wait54cycle
	cmp 0\ nop

line49
s6	lda #$03
c10	ldx #$00
	sta sizep1
	stx colpm1
	cmp (0,x)
	jsr wait36cycle
	cmp 0\ nop

line80
x20	lda #$2D
	sta hposp1
	
	ldy #$26
@	jsr wait54cycle
	dey
	bne @-

; At this point we are at the beginning of the instruction section
	lda >FONT_SLOT_1
	sta CHBASE
	
	lda COLOR_1_INSTRUCTION_TEXT
	sta color2
	lda COLOR_2_INSTRUCTION_TEXT
	sta color1

	ldy #$69
@	jsr wait54cycle
	dey
	bne @-
:4	jsr wait18cycle
	
; At this point we are at the beginning of the credits section
	lda >FONT_SLOT_2
	sta CHBASE
	
	lda credits_state
	cmp #CS_FADEIN
	bne cred_state_0
	inc credits_color
	lda credits_color
	cmp #CREDITCOLEND
	bne cred_state_fin
	lda #CS_SHOW
	sta credits_state
	jmp cred_state_fin
cred_state_0
	cmp #CS_FADEOUT
	bne cred_state_1
	dec credits_color
	lda credits_color
	cmp #CREDITCOLSTART
	bne cred_state_fin
	lda #CS_FADEIN
	sta credits_state
	jsr flip_credits
	jmp cred_state_fin
cred_state_1
	inc credits_timer
	lda credits_timer
	cmp #$70
	bne cred_state_fin
	lda #0
	sta credits_timer
	lda #CS_FADEOUT
	sta credits_state
cred_state_fin
	lda credits_color
	sta color2
	lda #$00
	sta color1

raster_program_end

// -----------------------------------------------------------
//	EXIT
// -----------------------------------------------------------

	lda trig0		; FIRE #0
	jeq handle_menu_item

	lda porta
	cmp #253
	bne @+
	jsr menu_cursor_down
	jmp xx2
@	cmp #254
	bne xx2
	jsr menu_cursor_up
xx2	

@	jmp skp

stop
	jsr STOP_MUSIC
	mva #$00 pmcntl		;PMG disabled
	tax
	sta:rne hposp0,x+

	; TODO: Burn only if options are dirty
	; TODO: unlock burning
	; jsr persistent_save

	lda #$22	; Default SDMCTL value
	sta SDMCTL

	mva #$ff portb		;ROM switch on
	mva #$40 nmien		;only NMI interrupts, DLI disabled
	cli			;IRQ enabled

	jsr show_level_selector

	jmp run_here
skp

// -----------------------------------------------------------

	jsr CONDUCT_MUSIC
	jsr handle_delayers
	jmp LOOP

; ---

wait54cycle
	cmp (0,x)\ cmp 0,x
wait44cycle
	cmp (0,x)
	nop
wait36cycle
	cmp (0,x)
	jsr _rts
wait18cycle
	cmp (0,x)
_rts	rts

; ---

.MACRO	ANTIC_PROGRAM
	dta $4f,a(:1+$0000),$f,$f,$f,$f,$f,$f,$f
	dta $4f,a(:1+$0140),$f,$f,$f,$f,$f,$f,$f
	dta $4f,a(:1+$0280),$f,$f,$f,$f,$f,$f,$f
	dta $4f,a(:1+$03C0),$f,$f,$f,$f,$f,$f,$f
	dta $4f,a(:1+$0500),$f,$f,$f,$f,$f,$f,$f
	dta $4f,a(:1+$0640),$f,$f,$f,$f,$f,$f,$f
	dta $4f,a(:1+$0780),$f,$f,$f,$f,$f,$f,$f
	dta $4f,a(:1+$08C0),$f,$f,$f,$f,$f,$f,$f
	dta $4f,a(:1+$0A00),$f,$f,$f,$f,$f,$f,$f
	dta $4f,a(:1+$0B40),$f,$f,$f,$f,$f,$f,$f
	dta $4f,a(:1+$0C80),$f,$f,$f,$f,$f,$f,$f
	
	dta b($40)
	dta b($42)
	dta a(TITLE_TOP_BORDER)
	dta b($42)
TEXT_PANEL_ADDRESS
	dta a(SCRMEM)
	dta b($02)
	dta b($02)
	dta b($02)
	dta b($02)
	dta b($02)
	dta b($02)
	dta b($02)
	dta b($02)
	dta b($02)
	dta b($02)
	dta b($42)
	dta a(TITLE_BOTTOM_BORDER)
	dta b($30)
	dta b($42)
	dta a(SCRMEM+40*13)
	dta b($42)
CREDITS_ADDRESS_DL
	dta a(CREDITS_BASE+80)
	dta b($02)
	
	dta $41,a(:2)
.ENDM

CL
	.he 90

.MACRO	ZPINIT
	mva	#$66	zc+0
	mva	#$67	zc+1
	mva	#$00	zc+2
.ENDM

ZCOLORS	= 3

FADECHR	= 0
; ---
	run main
; ---

.MACRO	SPRITES
missiles
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 80 80 80 00 30 F2 F2 72 72 73 73 83 83
	.he B1 F0 F0 F0 F0 F0 C1 80 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
player0
	.he 00 00 00 00 00 00 00 00 00 00 00 00 08 10 30 74
	.he 62 C1 C0 C0 B8 A8 BC BC FC CC 68 78 30 11 55 3B
	.he 5F 69 E7 E0 E0 E0 E0 F0 70 71 7F 3F 3E 1E 8C 00
	.he 05 3F FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF
	.he 7F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
player1
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 80 40
	.he 20 D0 D8 7E 7F 7F 77 83 A0 D0 30 50 28 38 1C 1C
	.he 0E 0E 0E 07 07 07 07 07 67 77 F7 E7 CE 5E 7C 38
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 FF FF FF FF FF FF FF FF
	.he A2 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
player2
	.he 00 00 00 00 00 00 00 00 00 00 70 70 70 70 10 30
	.he 30 20 60 E0 C0 C0 80 00 00 1C 0E 07 13 03 23 A3
	.he 83 23 53 77 3E 3C 38 39 B8 B8 38 38 38 38 7C E0
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
player3
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 1E 3F 53 31 97 A5 00 80 C8 F9 F4 E3 EF 1C 1C
	.he 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1E 3E 7E
	.he 70 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
.ENDM

USESPRITES = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; END: TENSOR LOGO G2F ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; BEGIN: GAME ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
run_here			
		lda DL_TOP_SCROL
		sta scroll_tmp
		jsr init_game
		jsr show_level

game_loop
		ldx collectibles
		cpx #0
		bne gl_0
		#if .byte reducer = #REDUCER_START_POS
			mva #1 unlock_level_on_intermission
			adw curmap #MAP_BUFFER_END-MAP_BUFFER_START
			adw curmapname #MAP_02_NAME-MAP_01_NAME
			mva #GS_FIN gstate
		#end
gl_0	
		lda instafall
		and #%00000001
		cmp #1
		beq gl_2
		jsr synchro
		jmp gl_7
gl_2	lda moved
		cmp #PL_CHR
		bne gl_7

		jsr synchro
gl_7	lda repaint
		cmp #0
		beq @+
		jsr repaint_player_sprite
		
@		lda gstate
		cmp #GS_GRAV
		bne @+
		lda STICK0
		cmp #13
		bne gl_1
		lda #1
		sta instafall
gl_1	jsr move_element
		jsr freefall
		jmp game_loop
@		cmp #GS_FIN
		bne @+
		ldy reducer
		lda #%11000011
		sta pmg_p3,y
		lda #$ff
		iny
		sta pmg_p3,y
		iny
		sta pmg_p3,y
		lda #%11000011
		iny
		sta pmg_p3,y
		lda #$00
		iny
		sta pmg_p3,y
		dec reducer
		ldx reducer
		cpx #REDUCER_END_POS
		jeq handle_new_record
		jmp game_loop		
@		lda ignorestick
		cmp #0
		beq game_loop_movement
		lda STICK0
		sta ATRACT
		cmp #7
		jeq	stick_right
		cmp #11
		jeq stick_left
		ldx CH
		cpx #$1c	; ESC
		bne game_loop_movement
		ldx #$ff
		stx CH
		jmp main

game_loop_movement
		jsr move_element
		jmp game_loop
		
freefall
@		lda mvstate
		cmp #MV_IDLE
		bne @+
		jsr scan_geometry
		lda any_moved
		cmp #1
		beq @+
		mva #GS_PLAY gstate
		mva old_instafall instafall
		mvx #$ff CH
		mva #1 ignorestick
@		rts

repaint_player_sprite
		lda #0
		sta ludek_offset
		sta repaint
		jsr ppos2pmgoffset_x
		ldx #0
@		ldy ludek_offset
		inc ludek_offset
		lda LUDEK_DATA,y
		ldy psy
		dec psy
		dey
		sta pmg_p3,y
		dey
		inx
		cpx #8
		bne @-
		mva psx HPOSP3
		rts
		
can_move_down
		inc py
		jsr ppos2scrmem
		dec py
		ldy #0
		lda (ptr0),y
		rts

can_move_internal
		ldy #0
		sty collecting
		lda (ptr0),y
		sta target
		#if .byte target = #2+64
			tya
			mvx #1 collecting
			rts
		#end
		lda target
		rts
		
can_move_right
		inc px
		jsr ppos2scrmem
		dec px
		jsr can_move_internal
		rts
		
can_move_left
		dec px
		jsr ppos2scrmem
		inc px
		jsr can_move_internal
		rts
		
move_element
		lda mvstate
		cmp #MV_IDLE
		jeq me_00
		cmp #MV_MRGH
		bne @+
		jsr clear_player
		ldx mvcntr
		cpx #0
		jeq me_finR
		dec mvcntr
		inc psx
		ldx psx
		#if .byte VCOUNT < #SCORE_DLI_LINE
			stx HPOSP2
		#end
		#if .byte moved = #PL_CHR
			stx HPOSP3
			stx last_true_player_pos
			mva #1 ludek_face
		#end
		rts
@		cmp #MV_MLFT
		bne @+
		jsr clear_player
		ldx mvcntr
		cpx #0
		jeq me_finL
		dec mvcntr
		dec psx
		ldx psx
		#if .byte VCOUNT < #SCORE_DLI_LINE
			stx HPOSP2
		#end
		#if .byte moved = #PL_CHR
			stx HPOSP3
			stx last_true_player_pos
			mva #0 ludek_face
		#end
		rts
@		cmp #MV_MBTM
		jne @+
		jsr clear_player
		ldx mvcntr
		cpx #0
		jeq me_finD
		dec mvcntr
		ldx psx
		#if .byte VCOUNT < #SCORE_DLI_LINE
			stx HPOSP2
		#end
:2		jsr sprite_down
:2		jsr player_sprite_down
		lda #0
		sta ignorestick
		inc psy
		inc psy
me_00	rts
me_finR inc ppx
		mva ppx px
		jmp me_fin
me_finL dec ppx
		mva ppx px
		jmp me_fin
me_finD inc py
		#if .byte moved = #PL_CHR
			inc ppy
		#end
me_fin	mva #MV_IDLE mvstate
		mva #GS_GRAV gstate
		lda collecting
		cmp #0
		beq @+
		dec collectibles
		dec collecting
@		jsr display_player
		jsr clear_sprite
		rts
		
clear_player_sprite
		tya
		pha
		ldy #0
		lda #0
@		sta pmg_p3,y
		iny
		cpy #SCORE_SPRITE_START
		bne @-
		pla
		tay
		rts
		
clear_sprite
		ldx #8
		ldy psy
		lda #$0
@		sta pmg_p2,y
		dey
		dex
		cpx #0-1
		bne @-
		rts
		
player_sprite_down
		#if .byte moved = #PL_CHR
			ldx #9
			ldy psy
@			lda pmg_p3,y
			iny
			sta pmg_p3,y
			dey
			dey
			dex
			cpx #0-1
			bne @-
		#end
		rts

sprite_down
		ldx #9
		ldy psy
@		lda pmg_p2,y
		iny
		sta pmg_p2,y
		dey
		dey
		dex
		cpx #0-1
		bne @-
		rts
		
sleep_for_some_time
		ldx #90
@		jsr synchro
		dex
		cpx #0
		bne @-
		rts
		
sleep_for_short_time
		ldx #20
@		jsr synchro
		dex
		cpx #0
		bne @-
		rts
		
clear_intermission_screen
		ldy #0
		sty HPOSP3
		tya
@		sta SCRMEM,y
		iny
		cpy #11*20
		bne @-
		rts

read_record_holder_internal
		jsr calculate_map_number

		tax
		mwa #HIGH_SCORE_TABLE ptr0
rrh_2	dex
		beq rrh_1
		adw ptr0 #(HIGH_SCORE_RECORD_END-HIGH_SCORE_RECORD_BEGIN)
		jmp rrh_2
rrh_1	rts

read_record_holder
		jsr read_record_holder_internal
		iny
		lda (ptr0),y
		cmp #$ff
		beq rrh_5 ; No record set yet

		; Paint score
		lda #$db
		sta record_holder_color
		mwa #record_text_buffer ptr1
		lda #0
		ldy #4
		sta (ptr1),y
		iny
		iny
		sta (ptr1),y
		dey
		lda #"-"*
		sta (ptr1),y
		ldy #0
rrh_3	lda (ptr0),y
		pha
		and #%11110000
		lsr
		lsr
		lsr
		lsr
		add #"0"
		sta (ptr1),y
		pla
		and #%00001111
		add #"0"
		iny
		sta (ptr1),y
		inw ptr1
		cpy #1
		beq rrh_3

		; Paint record holder name
		adw ptr1 #3
rrh_4	lda (ptr0),y
		sta (ptr1),y
		iny
		cpy #12
		bne rrh_4
rrh_X	rts

		; Paint "record unset" message
rrh_5	lda ludek_offset
		cmp #0
		beq rrh_X
		lda #$04
		sta record_holder_color
		lda language
		and #%00000001
		bne rrh_7
		mwa #unset_record_text_buffer ptr0
		jmp rrh_8
rrh_7	mwa #unset_record_text_buffer_en ptr0
rrh_8	mwa #record_text_buffer ptr1
		ldy #0
rrh_6	lda (ptr0),y
		sta (ptr1),y
		iny
		cpy #(unset_record_text_buffer_END-unset_record_text_buffer)
		bne rrh_6
		rts

draw_record_holder
		mwa #record_text_buffer ptr0
		ldy #0
@		lda (ptr0),y
		sta SCRMEM+TITLEOFFSET+28,y
		iny
		cpy #(record_text_buffer_END-record_text_buffer)
		bne @-
		rts

draw_enter_pseudonim
		lda language
		and #%00000001
		bne dhxQ_1
		mwa #header_record_enter_pseudonim ptr0
		jmp dhxQ_2
dhxQ_1	mwa #header_record_enter_pseudonim_en ptr0
dhxQ_2
		ldy #0
		ldx #(header_record_enter_pseudonim_END-header_record_enter_pseudonim)
@		lda (ptr0),y
		sta SCRMEM+TITLEOFFSET+2,y
		iny
		dex
		bne @-
		rts		

draw_record_holder_header
		lda language
		and #%00000001
		bne dhx_1
		mwa #header_record_holder_text ptr0
		jmp dhx_2
dhx_1	mwa #header_record_holder_text_en ptr0
dhx_2
		ldy #0
		ldx #(header_record_holder_text_END-header_record_holder_text)
@		lda (ptr0),y
		sta SCRMEM+TITLEOFFSET+5,y
		iny
		dex
		bne @-
		rts		

draw_selector_header
		lda language
		and #%00000001
		bne dsh_7
		mwa #header_text_selector ptr0
		jmp dsh_8
dsh_7	mwa #header_text_selector_en ptr0
dsh_8	
		ldy #0
dsh_6	lda (ptr0),y
		sta SCRMEM+DIGITOFFSET-4,y
		iny
		cpy #(header_text_selector_en_END-header_text_selector_en)
		bne dsh_6
		rts
		
draw_new_record_header
		lda language
		and #%00000001
		bne dnrh_7
		mwa #header_text_new_record ptr0
		jmp dnrh_8
dnrh_7	mwa #header_text_new_record_en ptr0
dnrh_8	
		ldy #0
dnrh_6	lda (ptr0),y
		sta SCRMEM+DIGITOFFSET-6,y
		iny
		cpy #(header_text_new_record_END-header_text_new_record)
		bne dnrh_6
		rts
		
draw_header
		lda language
		and #%00000001
		bne dh_1
		mwa #header_text ptr0
		jmp dh_2
dh_1	mwa #header_text_en ptr0
dh_2
		ldy #0
		ldx #(header_text_END-header_text)
@		lda (ptr0),y
		sta SCRMEM+DIGITOFFSET-2,y
		iny
		dex
		txa
		pha
		jsr sleep_for_short_time
		
		lda STRIG0
		beq @+
		
		pla
		tax
		bne @-
		rts
@		pla
		inc stop_intermission
		rts
		
draw_cavern_number
		mwa #SCRMEM+20+DIGITOFFSET ptr1
		ldy repaint
dcn_2	beq dcn_1
		inw ptr1
		dey
		jmp dcn_2

dcn_1	mwa curmapname ptr0
		adw ptr0 #(MAP_01_NAME_END-MAP_01_NAME)
		ldy #0
		lda (ptr0),y
		sub #$10
		asl
		add #2
		sta (ptr1),y
		add #1
		inw ptr1
		sta (ptr1),y
		add #31
		pha
		adw ptr1 #19
		pla
		sta (ptr1),y
		add #1
		inw ptr1
		sta (ptr1),y
		
		iny 
		
		lda (ptr0),y
		dey
		sub #$10
		asl
		add #2
		pha
		sbw ptr1 #19
		pla 
		sta (ptr1),y
		add #1
		inw ptr1
		sta (ptr1),y
		add #31
		pha
		adw ptr1 #19
		pla
		sta (ptr1),y
		add #1
		inw ptr1
		sta (ptr1),y
		
		#if .byte movable > #0
			lda #33
			pha
			sbw ptr1 #4
			pla
			sta (ptr1),y
		#end
		
		jsr draw_cavern_number_shadow
		
		rts

handle_new_record
		lda STACK_STARTED_WITH_KUTKA_OVERRIDE
		bne hnr_2
		jsr is_better_score
		cmp #1
		bne hnr_1
		jsr show_new_record_screen
hnr_1	jmp run_here
hnr_2	jmp main
		
draw_cavern_number_shadow
		#if .byte movable > #0
			lda #65
			ldy repaint
			sta SCRMEM+SHADOWOFFSET+DIGITOFFSET-1,y
		#end

		ldy #0
		lda (ptr0),y
		dey
		sub #$10
		asl
		#if .byte @ < #5*2
			add #22+64
		#else
			add #(54-12)+2+64
		#end
		sty direction
		ldy repaint
		sta SCRMEM+SHADOWOFFSET+DIGITOFFSET,y
		add #1
		sta SCRMEM+SHADOWOFFSET+DIGITOFFSET+1,y

		ldy direction
		iny 
		iny

		lda (ptr0),y
		dey
		sub #$10
		asl
		#if .byte @ < #5*2
			add #22+64
		#else
			add #(54-12)+2+64
		#end
		ldy repaint
		sta SCRMEM+SHADOWOFFSET+DIGITOFFSET+2,y
		add #1
		sta SCRMEM+SHADOWOFFSET+DIGITOFFSET+3,y

		rts
		
do_level_name_scroll
		; How many times to scroll (16 = length, 2 bytes per scroll)
		ldx #16/2
		
dlns_1
		; Copy two bytes from pointer to the edge of the screen
		ldy #0
		lda (ptr0),y
		sta (ptr1),y
		iny
		lda (ptr0),y
		sta (ptr1),y
		
		; Animate
dlns_0
:2		jsr synchro
		inc scroll
		lda scroll
		and #%00001111
		sta hscrol
		cmp #0
		bne dlns_0
		
		; Two bytes moved in - copy entire line to the right
		ldy #22
@		lda (ptr1),y
		iny
		iny
		sta (ptr1),y
		dey
		dey
		dey
		lda (ptr1),y
		iny
		iny
		sta (ptr1),y
		dey
		dey
		dey
		
		lda STRIG0
		beq @+
		
		cpy #$fe
		bne @-
		
		; Decrase pointer and repeat
		sbw ptr0 #2
		dex
		bne dlns_1
		rts
@		inc stop_intermission
		rts
		
draw_level_name
		; Init pointers to the end of the first line of level name
		mwa #SCRMEM+TITLEOFFSET ptr1
		mwa curmapname ptr0
		adw ptr0 #14
		jsr do_level_name_scroll
		lda stop_intermission
		bne dln_X
		
		; Disable scroll on the top row
		lda #%111
		sta DL_TOP_SCROL
		
		; Copy the top row in the right place
		ldy #0
@		lda (curmapname),y
		sta SCRMEM+TITLEOFFSET,y
		iny
		cpy #16
		bne @-
		lda #0
		sta SCRMEM+TITLEOFFSET,y
		iny
		sta SCRMEM+TITLEOFFSET,y
	
		; Init pointers to the end of the second line of level name
		mwa #SCRMEM+TITLEOFFSET+20 ptr1
		mwa curmapname ptr0
		adw ptr0 #14+16
		jsr do_level_name_scroll

dln_X	rts

; TODO: Dedatatize the record text buffer
record_text_buffer
		dta d'1234 - abcdefghij'
record_text_buffer_END
unset_record_text_buffer
		dta d'na razie tu pusto'
unset_record_text_buffer_END
unset_record_text_buffer_en
		dta d'     vacant      '
unset_record_text_buffer_en_END
header_text
		dta d'pieczara'
header_text_END
header_text_en
		dta d' cavern '
header_text_en_END
header_text_new_record
		dta d'   dorodny wynik',b(61+64),d'   '
header_text_new_record_END
header_text_new_record_en
		dta d'distinguished score',b(61+64)
header_text_new_record_en_END
header_text_selector
		dta d' kt',b(5+64),d'ra pieczara| '
header_text_selector_END
header_text_selector_en
		dta d'  which cavern|  '
header_text_selector_en_END
header_record_holder_text
		dta d'wzorcowy wynik:'*
header_record_holder_text_END
header_record_holder_text_en
		dta d'  best score:  '*
header_record_holder_text_en_END
header_record_enter_pseudonim
		dta d'podaj imie bohaterze'*
header_record_enter_pseudonim_END
header_record_enter_pseudonim_en
		dta d'enter your name here'*
header_record_enter_pseudonim_en_END

draw_decoration

		ldy #0
@		lda decoration_sine_table,y
		sta HPOSP0
		add #8
		sta HPOSP1
		add #8
		sta HPOSP2
		add #8
		sta HPOSP3
:5		jsr synchro
		iny
		cpy #90
		bne @-
		rts

decoration_sine_table
		dta b(231)
		dta b(230)
		dta b(229)
		dta b(228)
		dta b(227)
		dta b(226)
		dta b(225)
		dta b(224)
		dta b(223)
		dta b(222)
		dta b(221)
		dta b(220)
		dta b(219)
		dta b(218)
		dta b(217)
		dta b(216)
		dta b(215)
		dta b(214)
		dta b(214)
		dta b(213)
		dta b(212)
		dta b(211)
		dta b(210)
		dta b(209)
		dta b(208)
		dta b(207)
		dta b(206)
		dta b(206)
		dta b(205)
		dta b(204)
		dta b(203)
		dta b(202)
		dta b(201)
		dta b(201)
		dta b(200)
		dta b(199)
		dta b(198)
		dta b(197)
		dta b(197)
		dta b(196)
		dta b(195)
		dta b(194)
		dta b(194)
		dta b(193)
		dta b(192)
		dta b(192)
		dta b(191)
		dta b(190)
		dta b(190)
		dta b(189)
		dta b(188)
		dta b(188)
		dta b(187)
		dta b(187)
		dta b(186)
		dta b(185)
		dta b(185)
		dta b(184)
		dta b(184)
		dta b(183)
		dta b(183)
		dta b(182)
		dta b(182)
		dta b(181)
		dta b(181)
		dta b(181)
		dta b(180)
		dta b(180)
		dta b(180)
		dta b(179)
		dta b(179)
		dta b(178)
		dta b(178)
		dta b(178)
		dta b(178)
		dta b(177)
		dta b(177)
		dta b(177)
		dta b(177)
		dta b(177)
		dta b(176)
		dta b(176)
		dta b(176)
		dta b(176)
		dta b(176)
		dta b(176)
		dta b(176)
		dta b(176)
		dta b(176)
		dta b(176)

setup_level_selector_colors
		lda LEVEL_SELECTOR_COLOR_0
		sta CLR0
		lda LEVEL_SELECTOR_COLOR_1
		sta CLR1
		lda LEVEL_SELECTOR_COLOR_3
		sta CLR2
		lda LEVEL_SELECTOR_COLOR_3
		sta CLR3
		rts		

setup_new_record_screen_colors		
		lda RECORD_PSEUDONIM_COLOR_0
		sta CLR0
		lda RECORD_PSEUDONIM_COLOR_1
		sta CLR1
		lda RECORD_PSEUDONIM_COLOR_2
		sta CLR2
		lda RECORD_PSEUDONIM_COLOR_3
		sta CLR3
		rts

setup_intermission_colors
		#if .word curmap = #MAP_LAST
			lda INTERMISSION_COLOR_1
			sta PCOLR0
			lda INTERMISSION_COLOR_2
			sta PCOLR1
			lda INTERMISSION_COLOR_3
			sta PCOLR2
			lda INTERMISSION_COLOR_4
			sta PCOLR3
		#else
			lda #$04
			sta PCOLR0
			lda #$0a
			sta PCOLR1
			lda #$08
			sta PCOLR2
			lda #$04
			sta PCOLR3
		#end
		
		lda INTERMISSION_COLOR_5
		sta CLR0
		lda INTERMISSION_COLOR_6
		sta CLR1
		lda INTERMISSION_COLOR_7
		sta CLR2
		lda INTERMISSION_COLOR_8
		sta CLR3
		rts
		
draw_happy_docent
		lda FINAL_SCREEN_COLOR_1
		sta CLR0
		lda #$06 ;-diament
		sta CLR1
		lda FINAL_SCREEN_COLOR_2
		sta CLR2
		lda FINAL_SCREEN_COLOR_3
		sta CLR3
		lda #0
		sta CLR4
		sta $d40e
		lda #$2e
		sta $022f
		lda <pr1
		sta $200
		lda >pr1
		sta $201
		lda #$c0
		sta $d40e
		ldy #0
@		lda scr_head,y
		sta SCRMEM,y
:5		jsr synchro
		iny
		cpy #11*20
		bne @-
		rts
		
show_intermission
		jsr disable_antic

		; Try to unlock level
		lda unlock_level_on_intermission
		beq si_01

		; But check if it is unlocked already
		jsr is_level_locked
		cmp #0
		beq si_01

		lda temp_level_completion_bits_calculation
		eor ludek_face
		ldy temp_level_completion_bits_calculation_y_reg
		sta LEVEL_COMPLETION_BITS,y

		; TODO: unlock burning
		; jsr persistent_save

si_01	; Define offset for caver number
		ldx #0
		stx repaint
		inx
		stx movable

		jsr sleep_for_short_time
		mwa #DECORATION_DATA ZX5_INPUT
		mwa #pmg_p0 ZX5_OUTPUT
		jsr decompress_data

		jsr load_intermission_fonts

		lda #0
		sta stop_intermission

		ldx #<MODUL
		ldy #>MODUL
		#if .word curmap = #MAP_LAST
			lda #$74
		#else
			lda #$36
		#end
		jsr INIT_MUSIC

		lda #0
		sta $d008 
		sta $d009
		sta $d00c
		sta HPOSM0
		
		jsr setup_intermission_colors

		#if .word curmap = #MAP_LAST
			lda >FONT_SLOT_1
			add #2
			sta CHBAS
		
			; Enable DLI
			lda <dli_routine_final
			sta VDSLST
			lda >dli_routine_final
			sta VDSLST+1
			lda #192
			sta NMIEN

			ldx <DLINTERMISSIONFINAL
			ldy >DLINTERMISSIONFINAL
			stx SDLSTL
			sty SDLSTL+1
		#else
			; Enable DLI
			lda <dli_routine
			sta VDSLST
			lda >dli_routine
			sta VDSLST+1
			lda #192
			sta NMIEN

			ldx <DLINTERMISSION
			ldy >DLINTERMISSION
			stx SDLSTL
			sty SDLSTL+1
		#end
		
		jsr clear_intermission_screen
		jsr enable_antic

		jsr draw_decoration
:4		jsr sleep_for_some_time
		#if .word curmap <> #MAP_LAST
			jsr draw_header
			lda stop_intermission
			bne di_X
:4			jsr sleep_for_some_time
			jsr draw_cavern_number
:4			jsr sleep_for_some_time
			jsr draw_level_name
		#else
			jsr draw_happy_docent
		#end

@		lda trig0		; FIRE #0
		bne @-

di_X	ldx #$ff
		stx CH
		
		jsr synchro

		; Reenable scroll on the first line of the title
		lda scroll_tmp
		sta DL_TOP_SCROL

		#if .word curmap = #MAP_LAST
			pla
			pla
			pla
			pla
			mwa #MAP_BUFFER_START curmap
			mwa #MAP_01_NAME curmapname
			jmp main
		#end
		
		rts
		
vbi_routine
		jsr CONDUCT_MUSIC
		dec rotation_warmup
		lda rotation_warmup
		cmp #$ff
		bne @+
		inc rotation_warmup
@		jmp XITVBV
		
set_amygdala
		lda amygdala_type
		cmp #0
		bne @+
		mwa #AMYGDALA_DATA_0 ptr0
		jmp sa_0
@		cmp #1
		bne @+
		mwa #AMYGDALA_DATA_1 ptr0
		jmp sa_0
@		cmp #2
		bne @+
		mwa #AMYGDALA_DATA_2 ptr0
		jmp sa_0
@		cmp #3
		bne @+
		mwa #AMYGDALA_DATA_3 ptr0
		jmp sa_0
@		cmp #4
		bne @+
		mwa #AMYGDALA_DATA_4 ptr0
		jmp sa_0
@		cmp #5
		bne @+
		mwa #AMYGDALA_DATA_5 ptr0
		jmp sa_0
@		cmp #6
		bne @+
		mwa #AMYGDALA_DATA_6 ptr0
		jmp sa_0
@		mwa #AMYGDALA_DATA_7 ptr0
sa_0		
		ldy #0
@		lda (ptr0),y
		sta FONT_SLOT_1+8+8,y
		sta FONT_SLOT_2+8+8,y
		sta FONT_SLOT_1+8+8+64*8,y
		sta FONT_SLOT_2+8+8+64*8,y
		iny
		cpy #8
		bne @-
		ldx ntsc
		cpx #1
		bne @+
		iny
@		lda (ptr0),y
		sta amygdala_color
		rts

init_game
		lda #192
		sta os_back_nmien

		jsr enable_sprites

		ldy <vbi_routine
		ldx >vbi_routine
		lda #7
		jsr SETVBV

		lda #0
		sta current_score
		sta current_score+1

		mva instafall old_instafall
;		mwa #MAP_LAST curmap		; TODO: Remove after happy docent is integrated
		jsr show_intermission

		jsr disable_antic

		mwa #GAME_FONT ZX5_INPUT
		mwa #FONT_SLOT_1 ZX5_OUTPUT
		jsr decompress_data
		mwa #GAME_FONT_2 ZX5_INPUT
		mwa #FONT_SLOT_2 ZX5_OUTPUT
		jsr decompress_data

		#if .byte first_run = #0
			mva #1 first_run
			lda #$5d
		#else
			lda RANDOM
			and #%00000111
			tay
			lda music_start_table,y
		#end
		ldx #<MODUL
		ldy #>MODUL
		jsr INIT_MUSIC

		lda <dli_routine_game
		sta VDSLST
		lda >dli_routine_game
		sta VDSLST+1
		lda #192
		sta NMIEN

		lda RANDOM
		and #%00000111
		sta amygdala_type
		jsr set_amygdala
		
		jsr init_sprites
		mva #0 sync
		ldx <DLGAME
		ldy >DLGAME
		stx SDLSTL
		sty SDLSTL+1
		mva #MV_IDLE mvstate
		mva #GS_GRAV gstate
		ldx #REDUCER_START_POS
		stx reducer
		ldx #0
		stx scroll
		stx collectibles
		stx collect
		stx collecting
		stx mvcntr
		stx direction
		jsr set_font
		stx ludek_offset
		stx ludek_face
		inx
		stx repaint
		sta ignorestick
		lda #PL_CHR
		sta moved
		jsr enable_antic
		rts

rotate_internal_1
		lda direction
		and #%00000011
		sta direction
@		jsr set_font

		jsr remember_original_map

		ldx #9
		rts

rotate_internal_2
RI_1	ldy #0
		sty credits_timer
		mwa (ptr2),y stop_intermission
		ldy #0
		mwa (ptr3),y ptr1
		txa
		pha
		jsr do_rotation_step
		pla
		tax
		dex
		beq RI_2
		adw ptr2 #2
		adw ptr3 #2
		jmp RI_1
RI_2	jsr count_score
		jsr count_score
		jsr draw_points
		rts

rotate_clockwise
		lda rotation_warmup
		cmp #0
		beq @+
		jmp SI_1
@		mva #ROT_CTR rotation_warmup

		dec direction
		jsr rotate_internal_1
		mwy #RIGHT_ROTATION_TABLE_FROM ptr2
		mwy #RIGHT_ROTATION_TABLE_TO ptr3
		jsr rotate_internal_2
		jmp SI_1
		
rotate_counter_clockwise
		lda rotation_warmup
		cmp #0
		beq @+
		jmp SI_1
@		mva #ROT_CTR rotation_warmup

		inc direction
		jsr rotate_internal_1
		mwy #LEFT_ROTATION_TABLE_FROM ptr2
		mwy #LEFT_ROTATION_TABLE_TO ptr3
		jsr rotate_internal_2
		jmp SI_1

do_rotation_step
		jsr clear_backup_buffer
RCC_2	ldy credits_timer
		lda (stop_intermission),y
		cmp #$ff
		beq RCC_1
		tay
		lda SCRMEM_BACKUP,y
		sta credits_color
		ldy credits_timer
		lda (ptr1),y
		tay
		lda credits_color
		sta SCRMEM_BUFFER,y
		inc credits_timer
		jmp RCC_2

RCC_1	jsr show_backup_buffer
		lda level_rotation
		and #%00000001
		bne RCAX_2
:9	 	jsr synchro
RCAX_2	rts

show_backup_buffer
		ldy #SCWIDTH*MAPSIZE-1
@		lda SCRMEM_BUFFER,y
		sta SCRMEM,y
		dey
		cpy #0-1
		bne @-
		rts

remember_original_map		
		ldy #SCWIDTH*MAPSIZE-1
@		lda SCRMEM,y
		sta SCRMEM_BACKUP,y
		dey
		cpy #0-1
		bne @-
		rts

clear_backup_buffer
		mwx #SCRMEM_BUFFER movable
		ldx #MAPSIZE
CBB_2	ldy #MAPSIZE+3
@		lda #0
		sta (movable),y
		dey
		cpy #3
		bne @-
		dex
		beq CBB_1
		adw movable #SCWIDTH
		jmp CBB_2
CBB_1	rts

stick_internal_return
		pla
		pla
		jmp game_loop_movement

stick_internal
		lda mvstate
		cmp #MV_IDLE
		bne stick_internal_return
		lda STRIG0
		cmp #0
		bne @+
		jsr clear_player_sprite
		pla
		pla
		tya
		pha
		txa
		pha
		rts
SI_1	jsr recalc_player_position
		mva #1 repaint
		mva #GS_GRAV gstate
		jmp game_loop
@		mva ppx px
		mva ppy py
		rts
		
stick_right
		ldx <rotate_clockwise-1
		ldy >rotate_clockwise-1
		jsr stick_internal
		jsr can_move_right
		cmp #0
		jne game_loop
		jsr init_movement
		jsr count_score
		jsr draw_points
		mva #MV_MRGH mvstate
		jmp game_loop

count_score
		sed
		clc
		lda current_score
		adc #<1
		sta current_score
		lda current_score+1
		adc #>1
		sta current_score+1
		cld
		rts
		
stick_left
		ldx <rotate_counter_clockwise-1
		ldy >rotate_counter_clockwise-1
		jsr stick_internal
		jsr can_move_left
		cmp #0
		jne game_loop
		jsr init_movement
		jsr count_score
		jsr draw_points
		mva #MV_MLFT mvstate
		jmp game_loop
		
set_falling_sprite_color
		pha
		sta ptr0+1
		#if .byte ptr0+1 = #2
			mva amygdala_color PCOLR2
			pla
			rts
		#end
		#if .byte ptr0+1 >= #3 .and .byte ptr0+1 <= #4
			mva #C_OBSTA PCOLR2
			pla
			rts
		#end
		#if .byte ptr0+1 = #PL_CHR
			mva #C_PLAYR PCOLR2
			pla
			rts
		#end
		mva amygdala_color PCOLR2
		pla
		rts
		
init_movement
		#if .byte VCOUNT < #SCORE_DLI_LINE
			lda #0
			sta HPOSP2
		#end
		lda mvstate
		cmp #MV_IDLE
		jeq @+
		pla
		pla
		pla
		pla
		jmp game_loop_movement
@		jsr ppos2pmgoffset
		jsr ppos2scrmem
		ldy #0
		lda (ptr0),y
		sta moved
		and #%01111111
		asl
		asl
		asl
		tay
		sta ptr0
		lda #0
		sta ptr0+1
		sbw ptr1 ptr0 ptr1
		mvx #0 ptr0
		mvx CHBAS ptr0+1
		ldx #0
@		lda (ptr0),y
		sta (ptr1),y
		iny
		inx		
		cpx #8
		bne @-
		mva #MV_CTR mvcntr
		rts
		
set_font
		ldy direction
		lda FONT_MAPPER,y
		sta CHBAS
		rts
		
enable_sprites
		lda #>pmg_base
		sta PMBASE
		lda #%00000001
		sta GPRIOR
		
		lda #%00000011
		sta GRACTL

		lda SDMCTL
		ora #%00001100
		sta SDMCTL
		rts

		
init_sprites
		lda #0
		ldy #0
@		sta pmg_p2,y
		sta pmg_p3,y
		iny
		cpy #pmg_p3-pmg_p2
		bne @-

		lda #0
		sta SIZEP0

		lda PLAYER_COLOR
		sta PCOLR3
		sta PCOLR2
		
		lda WALL_1_COLOR
		sta CLR0
		lda amygdala_color
		sta CLR1
		lda OBSTACLE_COLOR
		sta CLR2
		lda WALL_2_COLOR
		sta CLR3
		lda #$00
		sta CLR4
		
		rts
		
show_level
		lda curmap
		pha
		lda curmap+1
		pha
		jsr show_margin
		jsr show_geometry
		jsr draw_points
		jsr recalc_player_position
		pla
		sta curmap+1
		pla
		sta curmap
		rts

draw_points_internal_1
		and #%11110000
		lsr
		lsr
		lsr
		lsr
		rts

draw_points
		phr

		lda current_score
		pha
		jsr draw_points_internal_1
		mwy #(pmg_p0+SCORE_SPRITE_START) ptr1
		jsr draw_points_internal

		pla
		and #%00001111
		mwy #(pmg_p1+SCORE_SPRITE_START) ptr1
		jsr draw_points_internal

		lda current_score+1
		pha
		jsr draw_points_internal_1
		mwy #(pmg_p2+SCORE_SPRITE_START) ptr1
		jsr draw_points_internal

		pla
		and #%00001111
		mwy #(pmg_p3+SCORE_SPRITE_START) ptr1
		jsr draw_points_internal

		plr

		rts

draw_points_internal
		tax
		mwa #SCORE_DIGIT_DATA ptr0
dpi_1	cpx #0
		beq dpi_0
		adw ptr0 #SCORE_DIGIT_SIZE
		dex
		jmp dpi_1

dpi_0	ldy #0
dpi_2	lda (ptr0),y
		sta (ptr1),y
		iny
		cpy #SCORE_DIGIT_SIZE
		bne dpi_2

		rts
		
add_color
		sta ptr3
		#if .byte ptr3 = #2
			lda ptr3
			add #64
			inc collectibles
			rts
		#end
		lda ptr3
		rts
		
show_margin
		ldy #SCREEN_MARGIN_DATA_END-SCREEN_MARGIN_DATA
@		lda SCREEN_MARGIN_DATA,y
		sta SCRMEM,y
		sta SCRMEM_BUFFER,y
		dey
		cpy #$ff
		bne @-
		
		; Sprites for more colors
		; Vidol - begin
		lda #$00
		sta CLR4
		sta $d01b ;!!!

		lda #3
		sta $d008 
		sta $d009;-szerokosc
		sta $d00c

	lda MARGIN_COLOR
	sta PCOLR1
	sta PCOLR0

	lda #0
	sta $026f
	lda #$2e
	sta $022f
		; Vidol - end
		
		; Missile 1
		ldy #1
		lda #0
@		sta pmg_m0,y
		iny
		cpy #$ff/2
		bne @-

		ldy #16-4
		lda #%00000010
@		sta pmg_m0,y
		iny
		cpy #$ff/2-15-4
		bne @-
		
		lda #$b1
		sta hposm0
		
		; Player 0
		ldy #0
		lda #0
@		sta pmg_p0,y
		iny
		cpy #$ff/2
		bne @-

		ldy #16-4
		lda #%11111110
@		sta pmg_p0,y
		iny
		cpy #$ff/2-15-4
		bne @-
		
		lda #$b4
		sta hposp0
		
		; Player 1
		ldy #0
		lda #0
@		sta pmg_p1,y
		iny
		cpy #$ff/2
		bne @-

		ldy #16-4
		lda #$ff
@		sta pmg_p1,y
		iny
		cpy #$ff/2-15-4
		bne @-
		
		lda #$2f
		sta hposp1

		rts

decompress_data
		jsr os_gone
		jsr unZX5
		jsr os_back
		rts

load_map_from_storage
		ldy #MAP_02_NAME-MAP_01_NAME-2
		lda (curmapname),y
		sec
		sbc #$10
		asl
		sta ptr1
		asl
		asl
		clc
		adc ptr1
		sta ptr1
		iny
		lda (curmapname),y
		sec
		sbc #$10
		clc
		adc ptr1
		tay
		dey

		tya
		asl
		tay

		lda COMPRESSED_MAPS_LUT,y
		sta ZX5_INPUT
		iny
		lda COMPRESSED_MAPS_LUT,y
		sta ZX5_INPUT+1
		mwa #MAP_BUFFER_START ZX5_OUTPUT
		jsr decompress_data

		rts

show_geometry
		jsr load_map_from_storage
		mwa #(SCRMEM+MARGIN) ptr0
		mwa #MAP_BUFFER_START curmap
		ldx #0
@		ldy #0
@		lda (curmap),y
		jsr add_color
		sta (ptr0),y
		iny
		cpy #MAPSIZE
		bne @-
		adw ptr0 #SCWIDTH
		adw curmap #MAPSIZE
		inx
		cpx #MAPSIZE
		bne @-1
		rts
		
normalize
		#if .byte @ > #64
			sub #64
			jmp normalize
		#end
		rts
		
is_movable
		pha
		jsr normalize
		jsr set_falling_sprite_color
		sta compared
		lda #0
		#if .byte compared >= #1 .and .byte compared <= #4
			jsr can_move_down
			jsr logical_not
		#end
		sta movable
		pla
		rts
		
logical_not
		#if .byte @ = #0
			lda #1
		#else
			lda #0
		#end
		rts
		
recalc_player_position
		mva #10 ptr3
		lda #MAPSIZE-2
		sta ptr2
		mwa #(SCRMEM+(SCWIDTH*(MAPSIZE-2))+MAPSIZE+MARGIN/2) ptr0
		ldy #0
@		ldx #MAPSIZE-2
@		lda (ptr0),y
		#if .byte @ = #PL_CHR
			stx ppx
			mva ptr3 ppy
			rts
		#end
		dex
		dew ptr0
		cpx #0
		bne @-
		sbw ptr0 #(MARGIN+1)*2
		dec ptr2
		lda ptr2
		cmp #0
		dec ptr3
		bne @-1
		rts
		
scan_geometry
		mva #0 any_moved
		mva #9 py
		lda #MAPSIZE-3
		sta ptr2
		mwa #(SCRMEM+(SCWIDTH*(MAPSIZE-3))+MAPSIZE+MARGIN/2) ptr3
		ldy #0
@		mva #10 px
		ldx #MAPSIZE-2
@		lda (ptr3),y
		stx ptr2+1
		jsr is_movable
		ldx ptr2+1
		lda movable
		cmp #0
		beq sg_0
		inc any_moved
		jsr init_movement
		mva #MV_CTRD mvcntr
		mva #MV_MBTM mvstate
		rts
sg_0	dex
		dec px
		dew ptr3
		cpx #0
		bne @-
		sbw ptr3 #(MARGIN+1)*2
		dec py
		dec ptr2
		lda ptr2
		cmp #0
		bne @-1
		rts
		
show_player
		ldy #0
		lda (curmap),y
		sta px
		iny
		lda (curmap),y
		sta py
		jsr display_player
		rts
		
get_next_ludek_data
		sty ptr0
		stx ptr0+1
		ldy ludek_offset
		inc ludek_offset
		#if .byte ludek_offset = #32
			mva #0 ludek_offset
		#end
		lda LUDEK_DATA,y
		ldx ludek_face
		cpx #1
		bne @+
		tay
		lda bit_mirror_lut,y
@		rts

display_player
		jsr ppos2scrmem
		lda moved
		ldy #0
		sta (ptr0),y
		
		#if .byte moved = #PL_CHR
			ldy psy
			dey
			ldx #8
@			jsr get_next_ludek_data
			ldy ptr0
			ldx ptr0+1
			sta pmg_p3,y
			dey
			dex
			cpx #0
			bne @-
			lda psx
			sta HPOSP3
		#end
		rts
		
clear_player
		jsr ppos2scrmem
		lda #0
		ldy #0
		sta (ptr0),y
		rts
		
ppos2scrmem
		mwa #(SCRMEM+MARGIN) ptr0
		ldx py
ppos2scrmem_1
		cpx #0
		beq @+
		adw ptr0 #SCWIDTH
		dex 
		jmp ppos2scrmem_1
@		ldx px
ppos2scrmem_2
		cpx #0
		beq @+
		inw ptr0
		dex 
		jmp ppos2scrmem_2
@		rts

ppos2pmgoffset
		lda #LFTMARG
		ldy px
p2pmg_1	cpy #0
		beq @+
		dey
		clc
		adc #8
		jmp p2pmg_1
@		sta psx
		
		mwa #pmg_p2+TOPMARG ptr1
		
		ldy py
p2pmg_0	cpy #0
		beq @+
		dey
		adw ptr1 #8
		jmp p2pmg_0
@		sbw ptr1 #pmg_p2 ptr2
		adb ptr2 #8-4
		mva ptr2 psy
		rts

ppos2pmgoffset_x
		lda #LFTMARG
		ldy ppx
x2pmg_1	cpy #0
		beq @+
		dey
		clc
		adc #8
		jmp x2pmg_1
@		sta HPOSP3
		sta psx
		sta last_true_player_pos
		
		mwa #pmg_p3+TOPMARG ptr1
		
		ldy ppy
x2pmg_0	cpy #0
		beq @+
		dey
		adw ptr1 #8
		jmp x2pmg_0
@		sbw ptr1 #pmg_p3 ptr2
		adb ptr2 #8-4
		mva ptr2 psy
		rts

pizda_wisi jmp pizda_wisi

synchro
		lda os_gone_debug
		cmp #0
		bne pizda_wisi
		inc sync
		lda sync
		and #%00000001
		cmp #1
		beq @+
		lda PAL
		cmp #1
		bne synchr1
		lda #145	; PAL
		jmp synchr2
synchr1 lda #120	; NTSC
synchr2	cmp VCOUNT
		bne synchr2
@		rts

; thanks to mono
detect_ntsc
		sei
	  	lda #0
		sta ntsc
sync1 	ldx VCOUNT
      	bpl sync1
sync2 	txa
      	ldx VCOUNT
      	bmi sync2

      	cmp #[312+262]/2/2		
	  	bcs dn_1
		inc ntsc

		ldy #0
DNTSC_1	lda COLOR_TABLE_START_NTSC,y
		sta COLOR_TABLE_START,y
		iny 
		cpy #COLOR_COUNT
		bne DNTSC_1

dn_1  	cli
		rts

clear_pmg
		mwa #pmg_m0 ptr0
		ldy #1
		lda #0
CP_1	sta (ptr0),y
		inw ptr0
		#if .word ptr0 = #pmg_end
			rts
		#end
		jmp CP_1

os_gone
		jsr synchro
		inc os_gone_debug
		sei
		lda #0
		sta NMIEN
		lda #$fe
		sta PORTB
		rts

os_back
		lda #0
		dec os_gone_debug
		lda #$ff
		sta PORTB
		lda os_back_nmien
		sta NMIEN
		cli
		rts

init_menu
		lda #0
		sta menu_cursor_index
		sta options_cursor_index
		mwa #MENU_0_DATA main_menu_screen_ptr
		mwa #MENU_1_DATA options_screen_ptr
		rts

invert_main_menu_cursor_common
		mva #80 any_moved
		ldx menu_cursor_index
		#if .byte menu_state = #MS_MAIN .and .byte menu_cursor_index = #3
			inx
			inx
		#end
		rts

invert_menu_cursor
		mwa #MENU_0_DATA+MENU_ITEM_OFFSET+37-40 ptr1
		jsr invert_main_menu_cursor_common
		jsr invert_menu_cursor_common

		mwa #MENU_0_DATA_EN+MENU_ITEM_OFFSET+37-40 ptr1
		jsr invert_main_menu_cursor_common
		jsr invert_menu_cursor_common
		rts

invert_menu_cursor_common
imc_2	cpx #0
		beq imc_1
		adw ptr1 any_moved
		dex
		jmp imc_2
imc_1	ldy #0
imc_0	lda (ptr1),y
		eor #%10000000
		sta (ptr1),y
		iny
		cpy #MAIN_MENU_LABEL_LEN
		bne imc_0
		rts

invert_options_menu_cursor
		mva #80+40 any_moved
		mwa #MENU_1_DATA_EN+MENU_ITEM_OFFSET+37 ptr1
		ldx options_cursor_index
		jsr invert_menu_cursor_common

		mva #80+40 any_moved
		mwa #MENU_1_DATA+MENU_ITEM_OFFSET+37 ptr1
		ldx options_cursor_index
		jsr invert_menu_cursor_common
		rts

menu_cursor_down_common
		lda delayer
		bne mcc_0
		lda #MENU_CURSOR_DELAY
		sta delayer
		ldy #0
		lda #3
		rts
mcc_0	pla
		pla
		rts

menu_cursor_down
		#if .byte menu_state = #MS_MAIN
			jsr menu_cursor_down_common
			#if .byte @ > menu_cursor_index
				jsr invert_menu_cursor
				inc menu_cursor_index
				jsr invert_menu_cursor
			#end
		#end
		#if .byte menu_state = #MS_OPTIONS
			jsr menu_cursor_down_common
			#if .byte @ > options_cursor_index
				jsr invert_options_menu_cursor
				inc options_cursor_index
				jsr invert_options_menu_cursor
			#end
		#end
mcd_0	rts

menu_cursor_up_common
		lda delayer
		bne mcc_0
		lda #MENU_CURSOR_DELAY
		sta delayer
		rts

menu_cursor_up
		#if .byte menu_state = #MS_MAIN
			jsr menu_cursor_up_common
			#if menu_cursor_index > #0
				jsr invert_menu_cursor
				dec menu_cursor_index
				jsr invert_menu_cursor
			#end
		#end
		#if .byte menu_state = #MS_OPTIONS
			jsr menu_cursor_up_common
			#if options_cursor_index > #0
				jsr invert_options_menu_cursor
				dec options_cursor_index
				jsr invert_options_menu_cursor
			#end
		#end
mcu_0	rts

handle_menu_item
		#if .byte menu_state = #MS_INSTRUCTION
			jsr back_to_main_menu
			jmp skp
		#end
		#if .byte menu_state = #MS_OPTIONS
			lda options_cursor_index
			cmp #0
			bne hmi_4
			jsr flip_failing_speed
			jmp skp
hmi_4
			cmp #1
			bne hmi_5
			jsr flip_level_rotation
			jmp skp

hmi_5		cmp #2
			bne hmi_6
			jsr flip_language
			jmp skp

hmi_6		; Back to main menu
			jsr back_to_main_menu
			jmp skp
		#end

		lda menu_cursor_index
		cmp #0
		bne hmi_1
		jmp stop
hmi_1
		cmp #1
		bne hmi_2
		#if .byte menu_state = #MS_MAIN
			jsr show_options
			jmp skp
		#end
		rts
hmi_2	cmp #2
		bne hmi_3
		jsr show_instruction
		jmp skp
hmi_3
		pla
		pla
		rts

show_options
		jsr delayer_button_common
		jsr synchro ; TODO[RC]: Instead of synchro, reject call when we're in the process of drawing the logo (in all "text-redrawing" functions)
		lda #MS_OPTIONS
		sta menu_state
		ldy #0
		mwa options_screen_ptr,y ANTIC_PROGRAM0.TEXT_PANEL_ADDRESS
		jmp skp

show_instruction
		jsr delayer_button_common
		jsr synchro
		lda #MS_INSTRUCTION
		sta menu_state
		lda language
		and #%00000001
		beq sii_1
		mwa #INSTRUCTION_DATA_EN ANTIC_PROGRAM0.TEXT_PANEL_ADDRESS
		jmp sii_0
sii_1	mwa #INSTRUCTION_DATA ANTIC_PROGRAM0.TEXT_PANEL_ADDRESS
sii_0	jmp skp

back_to_main_menu
		jsr delayer_button_common
		jsr synchro
		lda #MS_MAIN
		sta menu_state
		ldy #0
		mwa main_menu_screen_ptr,y ANTIC_PROGRAM0.TEXT_PANEL_ADDRESS
		jmp skp

STOP_MUSIC
		lda #0
		sta rmt_player_halt
		jsr RASTERMUSICTRACKER+9
		rts

INIT_MUSIC
		phr
		lda #0
		sta rmt_player_halt
		jsr STOP_MUSIC
		plr
		jsr RASTERMUSICTRACKER
		inc rmt_player_halt
		rts

CONDUCT_MUSIC
		lda rmt_player_halt
		beq CM_3
		lda ntsc
		cmp #0
		beq CM_1
		dec ntsc_music_conductor
		beq CM_2
		jmp CM_1
CM_2	lda #6
		sta ntsc_music_conductor
		rts
CM_1	jsr RASTERMUSICTRACKER+3
CM_3	rts

handle_delayers
		dec delayer
		lda delayer
		cmp #$ff
		bne @+
		inc delayer
@		dec delayer_button
		lda delayer_button
		cmp #$ff
		bne @+
		ind delayer_button
@		rts

GRAVITY_1
	dta d'    STONOWANE     '*
GRAVITY_2
	dta d'     POTEZNE      '*
GRAVITY_1_EN
	dta d'      FAINT       '*
GRAVITY_2_EN
	dta d'      MIGHTY      '*
ROTATION_1
	dta d'    ANIMOWANY     '*
ROTATION_2
	dta d'  NATYCHMIASTOWY  '*
ROTATION_1_EN
	dta d'     ANIMATED     '*
ROTATION_2_EN
	dta d'  NEARLY INSTANT  '*
LANG_1
	dta d'  POLSKI '*
LANG_2
	dta d' ENGLISH '*

delayer_button_common
		lda delayer_button
		bne dbc_0
		lda #MENU_SWITCH_DELAY
		sta delayer_button
		rts
dbc_0	pla
		pla
		rts

flip_menu_option_common
		ldy #0
@		lda (ptr0),y
		sta (ptr1),y
		iny
		cpy #GRAVITY_2-GRAVITY_1
		bne @-		
		rts

instafall_common
		lda instafall
		and #%00000001
		beq ffs_1
		mwa ptr3 ptr0
		jmp ffs_2
ffs_1	mwa ppx ptr0
ffs_2	rts

flip_failing_speed
		jsr delayer_button_common
		jsr synchro

		mwa #GRAVITY_LABEL_1 ptr1
		mwa #GRAVITY_1_EN ptr3
		mwa #GRAVITY_2_EN ppx

		jsr instafall_common
		jsr flip_menu_option_common

		mwa #GRAVITY_LABEL ptr1
		mwa #GRAVITY_1 ptr3
		mwa #GRAVITY_2 ppx
		
		jsr instafall_common
		jsr flip_menu_option_common

		inc instafall
		rts

rotation_common
		lda level_rotation
		and #%00000001
		beq flr_1
		mwa ptr3 ptr0
		jmp flr_2
flr_1	mwa ppx ptr0
flr_2	rts

flip_level_rotation
		jsr delayer_button_common
		jsr synchro

		mwa #ROTATION_LABEL_1 ptr1
		mwa #ROTATION_1_EN ptr3
		mwa #ROTATION_2_EN ppx

		jsr rotation_common
		jsr flip_menu_option_common

		mwa #ROTATION_LABEL ptr1
		mwa #ROTATION_1 ptr3
		mwa #ROTATION_2 ppx

		jsr rotation_common
		jsr flip_menu_option_common

		inc level_rotation
		rts

flip_language
		jsr delayer_button_common
		jsr synchro

		mwa #LANGUAGE_LABEL ptr1
		lda language
		and #%00000001
		beq fl_1

		jsr enable_polish
		jmp fl_2
fl_1
		jsr enable_english

fl_2	
		inc language

fl_0	rts

enable_english
		jsr synchro
		mwa #MENU_0_DATA_EN main_menu_screen_ptr
		mwa #MENU_1_DATA_EN options_screen_ptr
		ldy #0
		mwa options_screen_ptr,y ANTIC_PROGRAM0.TEXT_PANEL_ADDRESS
		rts

enable_polish
		jsr synchro
		mwa #MENU_0_DATA main_menu_screen_ptr
		mwa #MENU_1_DATA options_screen_ptr
		ldy #0
		mwa options_screen_ptr,y ANTIC_PROGRAM0.TEXT_PANEL_ADDRESS
		rts

load_intermission_fonts
		mwa #DIGITS_FONT ZX5_INPUT
		mwa #FONT_SLOT_1 ZX5_OUTPUT
		jsr decompress_data
		mwa #TITLE_FONT ZX5_INPUT
		mwa #FONT_SLOT_2 ZX5_OUTPUT
		jsr decompress_data
		rts

calculate_map_number
		mwa curmapname ptr0
		adw ptr0 #(MAP_01_NAME_END-MAP_01_NAME)
		ldy #0
		lda (ptr0),y
		sub #$10
		asl
		sta ludek_face
		asl
		asl
		add ludek_face
		sta ludek_face
		iny
		lda (ptr0),y
		sub #$10
		add ludek_face
		sta ludek_face
		rts

store_new_high_score_entry
		jsr calculate_map_number
		tax
		dex
		dex
		mwa #HIGH_SCORE_TABLE ptr0
sz_1	cpx #0
		beq sz_0
		adw ptr0 #HIGH_SCORE_RECORD_END-HIGH_SCORE_RECORD_BEGIN
		dex
		jmp sz_1
sz_0
		ldy #0
		lda current_score+1
		sta (ptr0),y
		iny
		lda current_score
		sta (ptr0),y
		iny

		dew ZX5_OUTPUT
		dew ZX5_OUTPUT

sz_2	lda (ZX5_OUTPUT),y
		eor #%01000000
		sta (ptr0),y
		iny
		cpy #12
		bne sz_2

		; TODO: unlock burning
		; jsr persistent_save

		rts

find_pressed_letter
		sta target
		ldx #0
fpl_1	lda CHAR_MAP,x
		cmp target
		beq fpl_0 ; found!
		inx
		cpx #CHAR_MAP_END-CHAR_MAP
		beq fpl_2 ; not found
		jmp fpl_1

fpl_0	rts		
fpl_2	ldx #$ff
		rts

draw_level_info_common
		jsr draw_cavern_number
		mvx #1 ludek_offset
		jsr read_record_holder
		jsr draw_record_holder
		jsr is_level_locked
		cmp #0
		beq dlic_1
		jsr draw_kutka
		jmp dlic_0
dlic_1	jsr clear_kutka
dlic_0	rts

draw_kutka
		lda #32
		sta SCRMEM+14+DIGITOFFSET
		rts

clear_kutka
		lda #0
		sta SCRMEM+14+DIGITOFFSET
		rts

calculate_level_lock_bits_data
		dec ludek_face
		lda ludek_face
		lsr
		lsr
		lsr
		tay
		lda LEVEL_COMPLETION_BITS,y
		sty temp_level_completion_bits_calculation_y_reg
		sta temp_level_completion_bits_calculation
ill_1
		#if .byte ludek_face >= #8
			sbb ludek_face #8
			jmp ill_1
		#end

		lda #%00000001
		ldx ludek_face
ill_3	cpx #0
		beq ill_2
		asl
		dex
		jmp ill_3
ill_2	
		rts

show_level_selector
		jsr disable_antic
		; Define offset for cavern number
		ldx #2
		stx repaint
		inx
		stx movable

		lda language
		and #%00000001
		beq sls_1
		mwa #ENGLISH_LEVEL_NAMES ZX5_INPUT
		mwa #MAP_01_NAME ZX5_OUTPUT
		jmp sls_2
sls_1	mwa #POLISH_LEVEL_NAMES ZX5_INPUT
		mwa #MAP_01_NAME ZX5_OUTPUT
sls_2	jsr decompress_data

		jsr reset_kutka_data
		sta dont_touch_menu

		jsr load_intermission_fonts
		jsr setup_level_selector_colors

		lda #100
		sta ignorestick

		; Enable DLI
		lda <dli_routine_selector
		sta VDSLST
		lda >dli_routine_selector
		sta VDSLST+1
		lda #192
		sta NMIEN

		ldx <DLLEVELSELECTOR
		ldy >DLLEVELSELECTOR
		stx SDLSTL
		sty SDLSTL+1

		lda #0
		sta $d008 
		sta $d009
		sta $d00c
		sta HPOSM0

		jsr clear_intermission_screen
		jsr draw_selector_header
		jsr draw_record_holder_header
		jsr draw_level_info_common

		jsr enable_antic

		jmp xxxx1
xx56
		inc ignorestick
		jmp xaxx1
xxxx1	
		dec ignorestick
		lda ignorestick
		cmp #$ff
		beq xx56

xaxx1	jsr synchro
		jsr handle_delayers
		lda porta
		cmp #247	; 251
		bne @+
		jsr set_next_starting_level
		jmp xx1
		
@		cmp #251
		bne xx1
		jsr set_previous_starting_level

xx1		lda ignorestick
		bne xxxx1
		lda trig0
		beq snsl_XX
		#if .byte CONSOL = #5 .and .byte amygdala_color = #0
			lda #1
			sta STACK_STARTED_WITH_KUTKA_OVERRIDE
			mva #0 unlock_level_on_intermission
			rts
		#end
		jmp xxxx1

set_next_starting_level
		jsr delayer_button_common
		jsr reset_kutka_data
		adw curmap #MAP_BUFFER_END-MAP_BUFFER_START
		adw curmapname #MAP_02_NAME-MAP_01_NAME
		nop
		#if .word curmapname = #MAP_NAME_LAST
			sbw curmap #MAP_BUFFER_END-MAP_BUFFER_START
			sbw curmapname #MAP_02_NAME-MAP_01_NAME
		#end
		jsr draw_level_info_common
snsl_X	rts
snsl_XX	lda SCRMEM+14+DIGITOFFSET
		beq snsl_XY
		inc amygdala_type
		lda amygdala_type
		cmp #$ff
		beq allow_kutka_override
		jmp xxxx1
snsl_XY		
		lda #0
		sta STACK_STARTED_WITH_KUTKA_OVERRIDE
		rts

reset_kutka_data
		mwa #lock_override_text_empty LOCK_OVERRIDE_TEXT_ADDRESS
		lda #1
		sta amygdala_type
		sta amygdala_color
		rts

allow_kutka_override
		lda language
		and #%00000001
		bne ako_0
		mwa #lock_override_text LOCK_OVERRIDE_TEXT_ADDRESS
		jmp ako_1
ako_0	mwa #lock_override_text_en LOCK_OVERRIDE_TEXT_ADDRESS
ako_1
		lda #0
		sta amygdala_color
		jmp xxxx1
		
set_previous_starting_level
		jsr delayer_button_common
		jsr reset_kutka_data
		sbw curmap #MAP_BUFFER_END-MAP_BUFFER_START
		sbw curmapname #MAP_02_NAME-MAP_01_NAME
		nop
		#if .word curmapname = #MAP_01_NAME-(MAP_02_NAME-MAP_01_NAME)
			adw curmap #MAP_BUFFER_END-MAP_BUFFER_START
			adw curmapname #MAP_02_NAME-MAP_01_NAME
		#end
		jsr draw_level_info_common
		rts		

.align		$100
DLGAME
			dta b(%11110000)
			dta b($70)
			dta b($47)
			dta a(SCRMEM)
:MAPSIZE-2	dta	b($07)
			dta	b(%10000111)
			dta b($41),a(DLGAME)
DLINTERMISSION
:8			dta b($60)
			dta b(%10010000)	; DLI - top 			[VCOUNT=$20]
			dta b($47)
			dta a(SCRMEM)
			dta b(%11110000)	; DLI - digits			[VCOUNT=$2C]
			dta b($87)			; DLI - digits half		[VCOUNT=$34]
			dta b($87)			; DLI - digits shadow	[VCOUNT=$3C]
			dta b($06)			
:2			dta b($70)
			dta b(%11110000)	; DLI - level name		[VCOUNT=$4C]
DL_TOP_SCROL
			dta b(%10111)
			dta b($40)
DL_BOT_SCROL			
			dta b(%10111)
			dta b($41),a(DLINTERMISSION)
DLLEVELSELECTOR
:8			dta b($60)
			dta b(%10010000)	; DLI - top 			[VCOUNT=$20]
			dta b($47)
			dta a(SCRMEM)
			dta b(%11110000)	; DLI - digits			[VCOUNT=$2C]
			dta b($87)			; DLI - digits half		[VCOUNT=$34]
			dta b($87)			; DLI - digits shadow	[VCOUNT=$3C]
			dta b($06)			
:2			dta b($70)
			dta b(%11110000)	; DLI - level name		[VCOUNT=$4C]
DL_TOP_SCROL3
			dta b(%10110)
			dta b($40)
DL_BOT_SCROL3			
			dta b(%10111)
			dta b($70)
			dta b(%11110000)
			dta b($60)
			dta b(%01000010)
LOCK_OVERRIDE_TEXT_ADDRESS
			dta a(lock_override_text_empty)
			dta b($41),a(DLLEVELSELECTOR)
DLINTERMISSIONFINAL
	dta $70,$70,$70
	dta $47,a(SCRMEM), $07
     	dta $87
	:2 dta $07
	dta $87
	:2 dta $07
	dta b($07)
	dta b($07)
	dta b($07)
	dta $41,a(DLINTERMISSIONFINAL)
DLNEW_RECORD
:8			dta b($60)
			dta b(%10010000)	; DLI - top 			[VCOUNT=$20]
			dta b($47)
			dta a(SCRMEM)
			dta b(%11110000)	; DLI - digits			[VCOUNT=$2C]
			dta b($87)			; DLI - digits half		[VCOUNT=$34]
			dta b($87)			; DLI - digits shadow	[VCOUNT=$3C]
			dta b($06)			
:2			dta b($70)
			dta b(%11110000)	; DLI - level name		[VCOUNT=$4C]
DL_TOP_SCROL2
			dta b(%10110)
			dta b($40)
DL_BOT_SCROL2			
			dta b(%10111)
			dta b($41),a(DLLEVELSELECTOR)


COLOR_TABLE_START
COLOR_1_INSTRUCTION_TEXT
	dta b($ed)
COLOR_2_INSTRUCTION_TEXT
	dta b($50)
LOGO_COLOR_1
	dta b($0A)
LOGO_COLOR_2
	dta b($10)
LOGO_COLOR_3
	dta b($70)
INTERMISSION_COLOR_1
	dta b($54)
INTERMISSION_COLOR_2
	dta b($5a)
INTERMISSION_COLOR_3
	dta b($58)
INTERMISSION_COLOR_4
	dta b($54)
INTERMISSION_COLOR_5
	dta b($eb)
INTERMISSION_COLOR_6
	dta b($85)
INTERMISSION_COLOR_7
	dta b($b5)
INTERMISSION_COLOR_8
	dta b($b9)
INTERMISSION_COLOR_9
	dta b($eb-2)
INTERMISSION_COLOR_10
	dta b($eb-4)
INTERMISSION_COLOR_11
	dta b($eb-6)
MARGIN_COLOR
	dta b($90)
FINAL_SCREEN_COLOR_1
	dta b($16) ; wlosy
FINAL_SCREEN_COLOR_2
	dta b($36) ; serce
FINAL_SCREEN_COLOR_3
	dta b($fa) ; kielich
PLAYER_COLOR
	dta b(C_PLAYR)
WALL_1_COLOR
	dta b(C_WALL2)
OBSTACLE_COLOR
	dta b(C_OBSTA)
WALL_2_COLOR
	dta b(C_WALL1)
LEVEL_SELECTOR_COLOR_0
	dta b($6b)
LEVEL_SELECTOR_COLOR_1
	dta b($26)
LEVEL_SELECTOR_COLOR_2
	dta b($38)
LEVEL_SELECTOR_COLOR_3
	dta b($94)
LEVEL_SELECTOR_COLOR_4
	dta b($6b-2)
LEVEL_SELECTOR_COLOR_5
	dta b($6b-4)
LEVEL_SELECTOR_COLOR_6
	dta b($6b-6)
RECORD_PSEUDONIM_COLOR_0
	dta b($6b)
RECORD_PSEUDONIM_COLOR_1
	dta b($26)
RECORD_PSEUDONIM_COLOR_2
	dta b($ff)
RECORD_PSEUDONIM_COLOR_3
	dta b($94)
COLOR_TABLE_END
COLOR_COUNT equ 	COLOR_TABLE_END - COLOR_TABLE_START

COLOR_TABLE_START_NTSC
	dta b($fd)
COLOR_2_INSTRUCTION_TEXT_NTSC
	dta b($60)
LOGO_COLOR_1_NTSC
	dta b($1A)
LOGO_COLOR_2_NTSC
	dta b($20)
LOGO_COLOR_3_NTSC
	dta b($80)
	dta b($64)
	dta b($6a)
	dta b($68)
	dta b($64)
	dta b($fb)
	dta b($95)
	dta b($c5)
	dta b($c9)
	dta b($fb-2)
	dta b($fb-4)
	dta b($fb-6)
	dta b($a0)
	dta b($26) ; wlosy
	dta b($46) ; serce
	dta b($1a) ; kielich
	dta b(C_PLAYR+$10)
	dta b(C_WALL2+$10)
	dta b(C_OBSTA+$10)
	dta b(C_WALL1+$10)
	dta b($7b)
	dta b($36)
	dta b($38)
	dta b($a4)
	dta b($7b-2)
	dta b($7b-4)
	dta b($7b-6)
	dta b($6b)
	dta b($26)
	dta b($38)
	dta b($94)

; Sprites
.align		$1000
pmg_base
LEFT_ROTATION_TABLE_FROM
		dta a(LEFT_FRAME_0_FROM)
		dta a(LEFT_FRAME_1_FROM)
		dta a(LEFT_FRAME_2_FROM)
		dta a(LEFT_FRAME_3_FROM)
		dta a(LEFT_FRAME_4_FROM)
		dta a(LEFT_FRAME_5_FROM)
		dta a(LEFT_FRAME_6_FROM)
		dta a(LEFT_FRAME_7_FROM)
		dta a(LEFT_FRAME_8_FROM)
LEFT_ROTATION_TABLE_TO
		dta a(LEFT_FRAME_0_TO)
		dta a(LEFT_FRAME_1_TO)
		dta a(LEFT_FRAME_2_TO)
		dta a(LEFT_FRAME_3_TO)
		dta a(LEFT_FRAME_4_TO)
		dta a(LEFT_FRAME_5_TO)
		dta a(LEFT_FRAME_6_TO)
		dta a(LEFT_FRAME_7_TO)
		dta a(LEFT_FRAME_8_TO)
RIGHT_ROTATION_TABLE_FROM
		dta a(RIGHT_FRAME_0_FROM)
		dta a(RIGHT_FRAME_1_FROM)
		dta a(RIGHT_FRAME_2_FROM)
		dta a(RIGHT_FRAME_3_FROM)
		dta a(RIGHT_FRAME_4_FROM)
		dta a(RIGHT_FRAME_5_FROM)
		dta a(RIGHT_FRAME_6_FROM)
		dta a(RIGHT_FRAME_7_FROM)
		dta a(RIGHT_FRAME_8_FROM)
RIGHT_ROTATION_TABLE_TO
		dta a(RIGHT_FRAME_0_TO)
		dta a(RIGHT_FRAME_1_TO)
		dta a(RIGHT_FRAME_2_TO)
		dta a(RIGHT_FRAME_3_TO)
		dta a(RIGHT_FRAME_4_TO)
		dta a(RIGHT_FRAME_5_TO)
		dta a(RIGHT_FRAME_6_TO)
		dta a(RIGHT_FRAME_7_TO)
		dta a(RIGHT_FRAME_8_TO)
bit_mirror_lut
		dta b(0),b(128),b(64),b(192),b(32),b(160),b(96),b(224),b(16),b(144),b(80),b(208),b(48),b(176),b(112),b(240),b(8),b(136),b(72),b(200),b(40),b(168),b(104),b(232),b(24),b(152),b(88),b(216),b(56),b(184),b(120),b(248),b(4),b(132),b(68),b(196),b(36),b(164),b(100),b(228),b(20),b(148),b(84),b(212),b(52),b(180),b(116),b(244),b(12),b(140),b(76),b(204),b(44),b(172),b(108),b(236),b(28),b(156),b(92),b(220),b(60),b(188),b(124),b(252),b(2),b(130),b(66),b(194),b(34),b(162),b(98),b(226),b(18),b(146),b(82),b(210),b(50),b(178),b(114),b(242),b(10),b(138),b(74),b(202),b(42),b(170),b(106),b(234),b(26),b(154),b(90),b(218),b(58),b(186),b(122),b(250),b(6),b(134),b(70),b(198),b(38),b(166),b(102),b(230),b(22),b(150),b(86),b(214),b(54),b(182),b(118),b(246),b(14),b(142),b(78),b(206),b(46),b(174),b(110),b(238),b(30),b(158),b(94),b(222),b(62),b(190),b(126),b(254),b(1),b(129),b(65),b(193),b(33),b(161),b(97),b(225),b(17),b(145),b(81),b(209),b(49),b(177),b(113),b(241),b(9),b(137),b(73),b(201),b(41),b(169),b(105),b(233),b(25),b(153),b(89),b(217),b(57),b(185),b(121),b(249),b(5),b(133),b(69),b(197),b(37),b(165),b(101),b(229),b(21),b(149),b(85),b(213),b(53),b(181),b(117),b(245),b(13),b(141),b(77),b(205),b(45),b(173),b(109),b(237),b(29),b(157),b(93),b(221),b(61),b(189),b(125),b(253),b(3),b(131),b(67),b(195),b(35),b(163),b(99),b(227),b(19),b(147),b(83),b(211),b(51),b(179),b(115),b(243),b(11),b(139),b(75),b(203),b(43),b(171),b(107),b(235),b(27),b(155),b(91),b(219),b(59),b(187),b(123),b(251),b(7),b(135),b(71),b(199),b(39),b(167),b(103),b(231),b(23),b(151),b(87),b(215),b(55),b(183),b(119),b(247),b(15),b(143),b(79),b(207),b(47),b(175),b(111),b(239),b(31),b(159),b(95),b(223),b(63),b(191),b(127),b(255)
AMYGDALA_DATA_0	; Kielich
	dta b(0),b(124),b(116),b(116),b(116),b(40),b(16),b(116),b($fa),b($2b)

AMYGDALA_DATA_1	; Maska
	dta b(0),b(130),b(254),b(146),b(214),b(124),b(68),b(56),b($c6),b($d6)

AMYGDALA_DATA_2	; Diament
	dta b(0),b(124),b(142),b(250),b(116),b(40),b(16),b(0),b($06),b($06)

AMYGDALA_DATA_3	; Serce
	dta b(0),b(108),b(190),b(250),b(116),b(56),b(16),b(0),b($36),b($46)

AMYGDALA_DATA_4	; Swiecznik
	dta b(16),b(24),b(48),b(16),b(68),b(56),b(16),b(56),b($ea),b($fa)

enable_antic
			lda antic_tmp
			sta SDMCTL
			rts

PRE_PMG_DATA_END

; Nothing more fits here, we're overwriting the first byte of the missile, anyway
; pmg_m0 should stay fixed at $x180

pmg_m0			equ pmg_base+$180
pmg_p0			equ pmg_base+$200
pmg_p1			equ pmg_base+$280
pmg_p2			equ pmg_base+$300
pmg_p3			equ pmg_base+$380
pmg_end			equ pmg_base+$400

	org pmg_end

SCRMEM
SCRMEM_BUFFER equ SCRMEM+SCWIDTH*MAPSIZE
SCRMEM_BACKUP equ SCRMEM_BUFFER+SCWIDTH*MAPSIZE
SCRMEM_END equ SCRMEM_BACKUP+SCWIDTH*MAPSIZE

	org SCRMEM_END

SCORE_DIGIT_DATA
;0
	dta b(%00111110)
	dta b(%01100001)
	dta b(%01100011)
	dta b(%01101101)
	dta b(%01110001)
	dta b(%01100001)
	dta b(%00111110)
	dta b(%00000000)
SCORE_DIGIT_SIZE equ *-SCORE_DIGIT_DATA

;1
	dta b(%00001100)
	dta b(%00011100)
	dta b(%00111100)
	dta b(%00001100)
	dta b(%00001100)
	dta b(%00001100)
	dta b(%00001100)
	dta b(%00000000)

;2
	dta b(%00111110)
	dta b(%01000011)
	dta b(%00000011)
	dta b(%00111110)
	dta b(%01100000)
	dta b(%01100000)
	dta b(%01111111)
	dta b(%00000000)

;3
	dta b(%00111110)
	dta b(%01000011)
	dta b(%00000011)
	dta b(%00001110)
	dta b(%00000011)
	dta b(%01000011)
	dta b(%00111110)
	dta b(%00000000)

;4
	dta b(%00001110)
	dta b(%00010110)
	dta b(%00100110)
	dta b(%01000110)
	dta b(%01000110)
	dta b(%01111111)
	dta b(%00000110)
	dta b(%00000000)

;5
	dta b(%01111111)
	dta b(%01100000)
	dta b(%01100000)
	dta b(%00111110)
	dta b(%00000011)
	dta b(%01000011)
	dta b(%00111110)
	dta b(%00000000)

;6
	dta b(%00111110)
	dta b(%01000011)
	dta b(%01000000)
	dta b(%01111110)
	dta b(%01000011)
	dta b(%01000011)
	dta b(%00111110)
	dta b(%00000000)

;7
	dta b(%01111111)
	dta b(%01000011)
	dta b(%00000011)
	dta b(%00000110)
	dta b(%00001100)
	dta b(%00011000)
	dta b(%00011000)
	dta b(%00000000)

;8
	dta b(%00111110)
	dta b(%01100001)
	dta b(%01100001)
	dta b(%00111110)
	dta b(%01100001)
	dta b(%01100001)
	dta b(%00111110)
	dta b(%00000000)

;9
	dta b(%00111110)
	dta b(%01100001)
	dta b(%01100001)
	dta b(%00111111)
	dta b(%00000001)
	dta b(%01100001)
	dta b(%00111110)
	dta b(%00000000)

; First 10 levels are unlocked by default
LEVEL_COMPLETION_BITS
	dta b(%00000000)
	dta b(%11111100)
	dta b(%11111111)	
	dta b(%11111111)
	dta b(%11111111)
	dta b(%11111111)
	dta b(%11111111)
	dta b(%11111111)

CHAR_MAP
	dta b($3f)		; a
	dta b($15)		; b
	dta b($12)		; c
	dta b($3a)		; d
	dta b($2a)		; e
	dta b($38)		; f
	dta b($3d)		; g
	dta b($39)		; h
	dta b($0d)		; i
	dta b($01)		; j
	dta b($05)		; k
	dta b($00)		; l
	dta b($25)		; m
	dta b($23)		; n
	dta b($08)		; o
	dta b($0a)		; p
	dta b($2f)		; q
	dta b($28)		; r
	dta b($3e)		; s
	dta b($2d)		; t
	dta b($0b)		; u
	dta b($10)		; v
	dta b($2e)		; w
	dta b($16)		; x
	dta b($2b)		; y
	dta b($17)		; z
	dta b($21)		; space
CHAR_MAP_END
CURMAP_LOCATION_EMULATION_LOCATION
	dta b($14),b($15)
CURMAP_LOCATION_EMULATION_LOCATION_FAKE_OFFSET equ * - (MAP_01_NAME_END-MAP_01_NAME) - 2
CURMAP_LOCATION_EMULATION_LOCATION_FOR_THE_SECOND
	dta b($19),b($11)
CURMAP_LOCATION_EMULATION_LOCATION_FAKE_OFFSET_FOR_THE_SECOND equ * - (MAP_01_NAME_END-MAP_01_NAME) - 2

disable_antic
			lda SDMCTL
			sta antic_tmp
			lda #0
			sta SDMCTL
			jsr sleep_for_short_time
			rts
PERSISTENCY_LOADED
	dta b(0)
os_gone_debug dta b(0)
unlock_level_on_intermission dta b(0)
temp_level_completion_bits_calculation dta b(0)
temp_level_completion_bits_calculation_y_reg dta b(0)

is_level_locked
		jsr calculate_level_lock_bits_data
		sta ludek_face
		lda temp_level_completion_bits_calculation
		and ludek_face
		rts

lock_override_text_empty
			dta d'                                        '
lock_override_text
			dta d'        a spr',b(80),d'buj wdusi',b(86),d' '
			dta d'SELECT'*
			dta d'...      '
lock_override_text_en
			dta d'       perhaps '
			dta d'SELECT'*
			dta d' would help...     '
CONTINUE_HERE

	org (CONTINUE_HERE)
show_new_record_screen
		jsr disable_antic
		jsr STOP_MUSIC
		jsr load_intermission_fonts

		lda #0
		sta HPOSM0
		sta HPOSP0
		sta HPOSP1
		sta HPOSP2
		sta HPOSP3

		jsr clear_intermission_screen

		lda current_score
		pha
		jsr draw_points_internal_1
		eor #%00010000
		sta CURMAP_LOCATION_EMULATION_LOCATION_FOR_THE_SECOND

		pla
		and #%00001111
		eor #%00010000
		sta CURMAP_LOCATION_EMULATION_LOCATION_FOR_THE_SECOND+1

		lda current_score+1
		pha
		jsr draw_points_internal_1
		eor #%00010000
		sta CURMAP_LOCATION_EMULATION_LOCATION

		pla
		and #%00001111
		eor #%00010000
		sta CURMAP_LOCATION_EMULATION_LOCATION+1


		lda curmapname
		pha
		lda curmapname+1
		pha
		lda #0
		sta repaint
		sta movable
		lda #<CURMAP_LOCATION_EMULATION_LOCATION_FAKE_OFFSET
		sta curmapname
		lda #>CURMAP_LOCATION_EMULATION_LOCATION_FAKE_OFFSET
		sta curmapname+1
		jsr draw_cavern_number
		lda #4
		sta repaint
		lda #<CURMAP_LOCATION_EMULATION_LOCATION_FAKE_OFFSET_FOR_THE_SECOND
		sta curmapname
		lda #>CURMAP_LOCATION_EMULATION_LOCATION_FAKE_OFFSET_FOR_THE_SECOND
		sta curmapname+1
		jsr draw_cavern_number
		pla
		sta curmapname+1
		pla
		sta curmapname

		lda #1 
		sta dont_touch_menu
		jsr setup_new_record_screen_colors

		; Enable DLI
		lda <dli_routine_new_record
		sta VDSLST
		lda >dli_routine_new_record
		sta VDSLST+1
		lda #192
		sta NMIEN

		ldx <DLNEW_RECORD
		ldy >DLNEW_RECORD
		stx SDLSTL
		sty SDLSTL+1

		jsr draw_new_record_header
		jsr draw_enter_pseudonim

		jsr enable_antic

		mwa #SCRMEM+TITLEOFFSET+31 ZX5_OUTPUT
		lda #0
		sta ppx
		sta mvstate
		lda #$ff
		sta CH
snrs_0	inc ppx
		lda ppx
		and #%01000000
		cmp #%01000000
		bne snrs_1
		inc last_true_player_pos
		lda #0
		sta ppx
snrs_1	#if last_true_player_pos > #$ff/2
			lda #0
		#else
			lda #59+128
		#end
		ldy mvstate
		sta (ZX5_OUTPUT),y

		; Return	- $0c
		; Backspace - $34
		; Space     - $21

		lda CH
		cmp #$ff
		beq snrs_0

		pha
		lda #0
		sta last_true_player_pos
		ldy mvstate
		sta (ZX5_OUTPUT),y
		pla

		cmp #$0c	; Return pressed
		bne snrs_9
		cpy #0		; But we don't allow empty name
		beq snrs_9

		jsr disable_antic
		jsr store_new_high_score_entry
		jsr enable_antic
		rts

snrs_9	#if .byte @ = #$34
			lda mvstate
			beq snrs_3
			dec mvstate
snrs_3			
		#else
			jsr find_pressed_letter
			cpx #$ff
			beq snrs_2
			cpx #CHAR_MAP_END-CHAR_MAP-1
			bne snrs_5
			lda #0
			jmp snrs_8
snrs_5		txa 
			add #33
snrs_8		sta (ZX5_OUTPUT),y 
			lda mvstate
			cmp #10
			beq snrs_2
			inc mvstate
snrs_2
		#end

		lda #$ff
		sta CH
		jmp snrs_0

		rts

is_better_score
		mvx #0 ludek_offset
		jsr read_record_holder
		sbw ptr0 #HIGH_SCORE_RECORD_END-HIGH_SCORE_RECORD_BEGIN
		ldy #1
		lda (ptr0),y
		sta ppy
		dey
		lda (ptr0),y
		sta pby
		#if .word current_score < ppy
			lda #1
		#else
			lda #0
		#end
		rts
		
		org MUSICPLAYER
		icl "music\rmtplayr.a65"

MAP_BUFFER_START
	ins "maps\v1.map"

		  ; dta d'%%%%%%%%%%% '
		  ; dta d'%##"" ##""% '		
		  ; dta d'%""## ""##% '		
		  ; dta d'%%%%% %%%%% '		
		  ; dta d'    % %     '		
		  ; dta d'    % % %%%%'		
		  ; dta d'    % % % !%'		
		  ; dta d'    % % % %%'		
		  ; dta d' %%%% %%% %%'		
		  ; dta d' %         %'		
		  ; dta d' %         %'		
		  ; dta d' %%%%%%%%%%%'
MAP_BUFFER_END
MAP_LAST equ MAP_BUFFER_START+(MAP_BUFFER_END-MAP_BUFFER_START)*(MAPCOUNT)

SCREEN_MARGIN_DATA
		ins "data\ekran.dat"
SCREEN_MARGIN_DATA_END

dli_routine
		phr
		
		lda VCOUNT
		cmp #$20	; Header
		bne @+
		lda >FONT_SLOT_2
		sta CHBASE
		jmp dli_end
		
@		cmp #$2C	; Digits
		bne @+
		lda >FONT_SLOT_1
		sta CHBASE
		ldy INTERMISSION_COLOR_9
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sty COLOR0
		jmp dli_end
		
@		cmp #$34	; Digits - lower part
		bne @+
		ldy INTERMISSION_COLOR_10
		sta WSYNC
		sty COLOR0
		ldy INTERMISSION_COLOR_11
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sty COLOR0
		jmp dli_end

@		cmp #$3C	; Digits - shadow
		bne @+
		ldy #$04
		sta WSYNC
		sty COLOR1
		jmp dli_end
		
@		lda >FONT_SLOT_2
		sta CHBASE
		
dli_end		
		plr
		rti

dli_routine_new_record
		phr

		lda VCOUNT
		cmp #$20	; Header
		bne @+
		lda >FONT_SLOT_2
		sta CHBASE
		jmp dli_end
		
@		cmp #$2C	; Digits
		bne @+
		lda >FONT_SLOT_1
		sta CHBASE
		ldy LEVEL_SELECTOR_COLOR_4
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sty COLOR0
		jmp dli_end
		
@		cmp #$34	; Digits - lower part
		bne @+
		ldy LEVEL_SELECTOR_COLOR_5
		sta WSYNC
		sty COLOR0
		ldy LEVEL_SELECTOR_COLOR_6
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sty COLOR0
		jmp dli_end

@		cmp #$3C	; Digits - shadow
		bne @+
		ldy #$04
		sta WSYNC
		sty COLOR1
		jmp dli_end
		
@		lda >FONT_SLOT_2
		ldy record_holder_color
		sty COLOR1
		ldy #$35
		sty COLOR0
		sta CHBASE
		
		jmp dli_end

dli_routine_selector
		phr
		
		lda VCOUNT
		cmp #$20	; Header
		bne @+
		lda >FONT_SLOT_2
		sta CHBASE
		ldx LEVEL_SELECTOR_COLOR_3
		stx COLOR2
		jmp dli_end
		
@		cmp #$2C	; Digits
		bne @+
		lda >FONT_SLOT_1
		sta CHBASE
		ldy LEVEL_SELECTOR_COLOR_4
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sty COLOR0
		jmp dli_end
		
@		cmp #$34	; Digits - lower part
		bne @+
		ldy LEVEL_SELECTOR_COLOR_5
		sta WSYNC
		sty COLOR0
		ldy LEVEL_SELECTOR_COLOR_6
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sty COLOR0
		jmp dli_end

@		cmp #$3C	; Digits - shadow
		bne @+
		ldy #$04
		sta WSYNC
		sty COLOR1
		jmp dli_end
		
@		cmp #$4C	; Record holder name
		bne @+
		lda >FONT_SLOT_2
		ldy LEVEL_SELECTOR_COLOR_3
		sty COLOR3
		ldy record_holder_color
		sty COLOR1
		ldy #$35
		sty COLOR0
		sta CHBASE
		jmp dli_end

@		ldx #0
		ldy #$02
		sta WSYNC
		stx COLOR2
		sty COLOR1
	
		jmp dli_end

dli_routine_game
		pha
		lda VCOUNT
		cmp #SCORE_DLI_LINE
		beq daas_1
		; Drawing game board
		lda MARGIN_COLOR
		sta COLPM1
		sta COLPM0
		lda #$2f
		sta hposp1
		lda #$b4
		sta hposp0
		LDA #$03
		STA SIZEP0
		STA SIZEP1
		mva last_true_player_pos HPOSP3		
		#if .byte reducer < #REDUCER_START_POS
			lda reducer
			sta COLPM3
		#end
		pla
		rti
daas_1	; Drawing points
		sta WSYNC
		lda #0
		sta SIZEP0
		sta SIZEP1
		sta SIZEP2
		sta SIZEP3
		lda #$c8-(9*3)
		sta HPOSP2
		lda #$c8-(9*2)
		sta HPOSP3
		lda #$c8-(9*1)
		sta HPOSP0
		lda #$c8-(9*0)
		sta HPOSP1

		lda #$ff
		sta COLPM0
		sta COLPM1
		sta COLPM2
		sta COLPM3

		lda #$fa
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta WSYNC
		sta COLPM0
		sta COLPM1
		sta COLPM2
		sta COLPM3

		pla
		rti

dli_routine_final
pr1	
		sta pr1_a+1
		lda #$64 ;-miecz
		sta $d017
		lda #$c6 ;-maska
		sta $d018
		lda #$16 ;-wlosy
		sta $d019
		lda #$3a ;-twarz
		:5 sta $d40a
		sta $d016
		lda #$38 ;-twarz cien (38)
		pha
		;:2 sta $d40a
		sta $d019
		lda #$86 ;-okulary
		:12 sta $d40a
		sta $d019
		pla ;-twarz cien
		sta $d018
		lda <pr2
		sta $200
		lda >pr2
		sta $201
pr1_a	lda #$ff
		rti
	
pr2		sta pr2_a+1
		lda #$3a ;-twarz
		sta $d017
		pha
		:3 sta $d40a
		lda #$34 ;-jezyk
		sta $d017
		pla
		:10 sta $d40a
		sta $d017
		lda <pr1
		sta $200
		lda >pr1
		sta $201
pr2_a	lda #$ff
		rti
		
flip_credits
		inc credits_flips
		lda credits_flips
		cmp #3
		beq @+
		adw ANTIC_PROGRAM0.CREDITS_ADDRESS_DL #80

		; Remove dot above "inz."
		ldy #0
		sty SCRMEM+40*13+26
		sty SCRMEM+40*13+27

		rts
@		lda #0
		sta credits_flips
		mwa #CREDITS_BASE ANTIC_PROGRAM0.CREDITS_ADDRESS_DL
		
		; Paint dot above "inz."
		ldy #1
		sty SCRMEM+40*13+26
		iny
		sty SCRMEM+40*13+27
		rts

.align $100		
CREDITS_BASE
	ins "data\credits.dat"
	
ROTATE_LUT_BEGIN
.rept 9 #
	icl "include\rotate_lut\left\rotate_left_frame_:1.txt"
.endr
.rept 9 #
	icl "include\rotate_lut\right\rotate_right_frame_:1.txt"
.endr
ROTATE_LUT_END
ROTATE_LUT_SIZE	equ ROTATE_LUT_END-ROTATE_LUT_BEGIN

; TODO[RC]: Remove these `dta(0)` and just leave the buffer
credits_flips		dta(0)
credits_timer		dta(0)
credits_color		dta(0)
credits_state		dta(0)
scroll_tmp			dta(0)	
scroll				dta(0)	
old_instafall		dta(0)	
rotation_warmup		dta(0)	
instafall			dta(0)	
rotation_speed		dta(0)	
first_run			dta(0)	
amygdala_color		dta(0)	
amygdala_type		dta(0)	
reducer				dta(0)	
collecting			dta(0)	
delayer				dta(0)	
delayer_button		dta(0)	
showsummary			dta(0)	
mapnumber			dta(0)	
mvcntr				dta(0)
ignorestick			dta(0)
moved				dta(0)
gstate				dta(0)
compared			dta(0)
sync				dta(0)
collect				dta(0)
current_persistency_bank dta(0)
workpages			dta(0)
record_holder_color	dta(0)
os_back_nmien		dta(0)
current_score		dta($12),($34)
offset  dta(0),(0)
offset2 dta(0),(0)
offset3 dta(0),(0)
music_start_table
	dta b($00),b($1e),b($6c),b($45),b($5d),b($74),b($57),b($91) ; $5d
music_start_table_end
FONT_MAPPER
		dta b(>FONT_SLOT_1)			; North
		dta b(>FONT_SLOT_1+2)		; West
		dta b(>FONT_SLOT_2)			; South
		dta b(>FONT_SLOT_2+2)		; East
FONT_MAPPER_END
_GET_BYTE         lda    $ffff
ZX5_INPUT         equ    *-2
                  inw    ZX5_INPUT
                  rts			  

	org curmap
	dta a(MAP_BUFFER_START)
	org curmapname
	dta a(MAP_01_NAME)
	org first_run
	dta b(0)
	org instafall
	dta b(1)
	org level_rotation
	dta b(0)
	org language
	dta b(0)
	org dont_touch_menu
	dta b(0)

	
; Notes
;
; Character codes:
;  0		- blank
;  1		- player
;  2		- collectible
;  3- 4		- obstacles
;  5-11		- wall 1
; 12-18		- wall 2
; 19-31		- margin color 1
; 32-63		- margin color 2

; TODO:
; - DONE: 		Add detailed instruction (instafall on demand and so on)
; - DONE: 		Decreasing cavern number on the title screen is slower than increasing it
; - OBSOLETE:	Integrate next raster optimization from Vidol
; - OBSOLETE:	Check player gravity only after movement
; - OBSOLETE:	Integrate logo with OS from Vidol
; - DONE:		Remove $(ff) from _TO in rotation LUT