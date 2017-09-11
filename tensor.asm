; "Tensor Trzaskowskiego" for Atari 8-bit by mgr_inz_rafal

; This project is licensed under "THE BEER-WARE LICENSE" (Revision 42).
; rchabowski@gmail.com wrote this project. As long as you retain this
; notice you can do whatever you want with this stuff.
; If we meet some day, and you think this stuff is worth it,
; you can buy me a beer in return.

	; Selected ATARI registes
	icl "include\atari.inc"

MAPCOUNT equ 28
MUSICPLAYER	equ $9000
;MODUL	equ $2dc0
MAPSIZE	equ	12
SCWIDTH equ 20
MARGIN 	equ	(SCWIDTH-MAPSIZE)/2
TOPMARG	equ 16
LFTMARG	equ 80
MV_IDLE	equ 0	; Element not moving
MV_MRGH	equ	1	; Element is moving right
MV_MLFT	equ	2	; Element is moving left
MV_MUP	equ	3	; Element is moving up
MV_MBTM	equ	4	; Element is moving bottom
MV_CTRD	equ 4	; Single move distance when falling down
MV_CTR	equ 8	; Single move distance when moving left or right
C_PLAYR	equ	$5d	; Player color
C_OBSTA	equ	$76	; Obstacles
C_WALL1	equ	$54	; Wall #1
C_WALL2	equ	$14	; Wall #2
GS_GRAV	equ	0	; Making sure everything is on the ground
GS_PLAY	equ	1	; Player movement
GS_FIN	equ	2	; Level completed
ROT_CTR	equ	20	; Delay between rotations
PL_CHR	equ 1	; Player character

.zpvar	.byte	old_instafall
.zpvar	.byte	instruction_page
.zpvar	.byte	rotation_warmup
.zpvar	.byte	instafall
.zpvar	.byte	first_run
.zpvar	.byte	amygdala_color
.zpvar	.byte	amygdala_type
.zpvar	.byte	reducer
.zpvar	.byte	collecting
.zpvar	.byte	delayer
.zpvar	.byte	showsummary
.zpvar	.byte	mapnumber
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
.zpvar	.byte	mvcntr
.zpvar	.byte	ignorestick
.zpvar	.byte	moved
.zpvar	.byte	gstate
.zpvar	.byte	movable
.zpvar	.byte	compared
.zpvar	.byte	sync
.zpvar	.byte	any_moved
.zpvar	.byte	collect
.zpvar	.byte	target
.zpvar	.byte	collectibles
.zpvar	.byte	repaint
.zpvar	.byte	direction	; 0 - N, 1 - W, 2 - S, 3 - E
.zpvar	.byte	ludek_offset
.zpvar	.byte	ludek_face	; 0 - L, 1 - R

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

; ---	MAIN PROGRAM
	org $2000
scr	ins "data\tensor5.raw" +0,+0,3520
;scr	ins "rmtplayr.a65" +0,+0,3520
MODUL
		opt h-
		ins "music\TENSOR.rmt"
		opt h+
		
	org $3900-3
bit_mirror_lut
		dta b(0),b(128),b(64),b(192),b(32),b(160),b(96),b(224),b(16),b(144),b(80),b(208),b(48),b(176),b(112),b(240),b(8),b(136),b(72),b(200),b(40),b(168),b(104),b(232),b(24),b(152),b(88),b(216),b(56),b(184),b(120),b(248),b(4),b(132),b(68),b(196),b(36),b(164),b(100),b(228),b(20),b(148),b(84),b(212),b(52),b(180),b(116),b(244),b(12),b(140),b(76),b(204),b(44),b(172),b(108),b(236),b(28),b(156),b(92),b(220),b(60),b(188),b(124),b(252),b(2),b(130),b(66),b(194),b(34),b(162),b(98),b(226),b(18),b(146),b(82),b(210),b(50),b(178),b(114),b(242),b(10),b(138),b(74),b(202),b(42),b(170),b(106),b(234),b(26),b(154),b(90),b(218),b(58),b(186),b(122),b(250),b(6),b(134),b(70),b(198),b(38),b(166),b(102),b(230),b(22),b(150),b(86),b(214),b(54),b(182),b(118),b(246),b(14),b(142),b(78),b(206),b(46),b(174),b(110),b(238),b(30),b(158),b(94),b(222),b(62),b(190),b(126),b(254),b(1),b(129),b(65),b(193),b(33),b(161),b(97),b(225),b(17),b(145),b(81),b(209),b(49),b(177),b(113),b(241),b(9),b(137),b(73),b(201),b(41),b(169),b(105),b(233),b(25),b(153),b(89),b(217),b(57),b(185),b(121),b(249),b(5),b(133),b(69),b(197),b(37),b(165),b(101),b(229),b(21),b(149),b(85),b(213),b(53),b(181),b(117),b(245),b(13),b(141),b(77),b(205),b(45),b(173),b(109),b(237),b(29),b(157),b(93),b(221),b(61),b(189),b(125),b(253),b(3),b(131),b(67),b(195),b(35),b(163),b(99),b(227),b(19),b(147),b(83),b(211),b(51),b(179),b(115),b(243),b(11),b(139),b(75),b(203),b(43),b(171),b(107),b(235),b(27),b(155),b(91),b(219),b(59),b(187),b(123),b(251),b(7),b(135),b(71),b(199),b(39),b(167),b(103),b(231),b(23),b(151),b(87),b(215),b(55),b(183),b(119),b(247),b(15),b(143),b(79),b(207),b(47),b(175),b(111),b(239),b(31),b(159),b(95),b(223),b(63),b(191),b(127),b(255)
AMYGDALA_DATA_0	; Kielich
	dta b(0),b(124),b(116),b(116),b(116),b(40),b(16),b(116),b($fa)

AMYGDALA_DATA_1	; Maska
	dta b(0),b(130),b(254),b(146),b(214),b(124),b(68),b(56),b($c6)

AMYGDALA_DATA_2	; Diament
	dta b(0),b(124),b(142),b(250),b(116),b(40),b(16),b(0),b($06)

AMYGDALA_DATA_3	; Serce
	dta b(0),b(108),b(190),b(250),b(116),b(56),b(16),b(0),b($36)

AMYGDALA_DATA_4	; Swiecznik
	dta b(16),b(24),b(48),b(16),b(68),b(56),b(16),b(56),b($ea)

AMYGDALA_DATA_5	; Miecz
	dta b(0),b(192),b(160),b(84),b(44),b(24),b(52),b(2),b($64)

AMYGDALA_DATA_6	; Pierscionek
	dta b(0),b(60),b(24),b(52),b(82),b(64),b(66),b(52),b($a6)

AMYGDALA_DATA_7	; Robak
	dta b(0),b(146),b(130),b(84),b(16),b(88),b(16),b(56),b($34)
	
TITLE_PART_1_X
	dta b(62)
:38	dta b(125)
	dta b(93)
	dta b(124)
	dta d' to jest miejsce na druga strone      ',b(124)
	dta b(124)
	dta d' instrukcji oraz chyba jakies opcje   ',b(124)
	dta b(124)
	dta d' .................................... ',b(124)
	dta b(124)
	dta d' .................................... ',b(124)
	dta b(124)
	dta d' .................................... ',b(124)
TITLE_PART_2_X
	dta b(124)
	dta d' .................................... ',b(124)
	dta b(124)
	dta d' .................................... ',b(124)
	dta b(124)
	dta d' ',b(72),d'SELECT'*,b(72+128)
	dta d' - migdaly ',b(7)
TITLE_AMYGDALA_SPEED
	dta d'       e',b(7),d' ...... ',b(124)
	dta b(124)
	dta d' ..................................!D ',b(124)
	dta b(63)
:38	dta b(125)
	dta b(29)
	dta b(124)
	dta b(128)
	dta b(94+128)
	dta b(95+128)
	dta d' - pieczara:'*
	dta d'           '*
	dta b(32+128),b(64+128)
	dta d' - strona '*,b(124)
TITLE_PART_1
	dta b(62)
:38	dta b(125)
	dta b(93)
	dta b(124)
	dta d' Docent Ireneusz Trzaskowski lubi     ',b(124)
	dta b(124)
	dta d' kosmos. Bywa tam cz',b(68),d'sto i robi r',b(80),b(88),d'ne ',b(124)
	dta b(124)
	dta d' rzeczy. Obecnie realizuje proces     ',b(124)
	dta b(124)
	dta d' zbierania mistycznych '
	dta d'MIGDA'*
	dta b(76+128),b(79+128)
	dta d'W X4'*
	dta d' z  ',b(124)
	dta b(124)
	dta d' pieczar na Jowiszu. Pomaga mu w tym  ',b(124)
TITLE_PART_2
	dta b(124)
	dta d' '
	dta d'Tensor Miotu Grawitacyjnego'*
	dta d' oraz Ty, ',b(124)
	dta b(124)
	dta d' zacny Atarowcu. Penetruj rygorys-    ',b(124)
	dta b(124)
	dta d' tycznie, z ka',b(88),d'dego kierunku, aby     ',b(124)
	dta b(124)
	dta d' ',b(88),d'aden '
	dta d'MIGDA'*
	dta b(76+128)
	dta d' X4'*
	dta d' nie zostal sam...    ',b(124)
	dta b(63)
:38	dta b(125)
	dta b(29)
	dta b(124)
	dta b(128)
	dta b(94+128)
	dta b(95+128)
	dta d' - pieczara:'*
TITLE_LEVEL_NUMBER
	dta d'           '*
	dta b(32+128),b(64+128)
	dta d' - strona '*,b(124)
TITLE_PART_3
	dta b(91)
:31	dta b(125)
	dta b(126)
	dta d'v1.'
	dta b(31)
	dta b(127)
	dta b(125)
	dta b(92)
	dta d'CODE: '
	dta d'mgr in'*
	dta b(10+64+64+64)
	dta b(14+64+64+64)
	dta d' rafa'*
	dta b(11+64+64+64)
	dta d'GFX & LEVELS:  '
	dta d'vidol'*
	dta d'MSX:  '
	dta d'makary brauner'*
MAP_01_NAME
;             #........;.........##........;.........#
		dta d'      kr'
		dta b(1+64)
		dta d'pcewo        w prawo i w lewo  01'
MAP_02_NAME
		dta d'     staro'
		dta b(10+64)
		dta d'ytne         ko'
		dta b(2+64)
		dta d'ciepiecho    02'
		dta d'  wieloraka grota    poszanowania kota  03'
		dta d'     sawa woda         santiago bela    04'
		dta d' wydrapane miejsce    eliminacji sera   05'
		dta d'  dystopia siedem    dla ciemnych lw',b(5+64),d'w  06'
		dta d'komora do kompresji  trzech stawonog',b(5+64),d'w  07'
		dta d'    miejsce snu        molibdenowego    08'
		dta d' wydr',b(4+64),b(10+64),d'ona w skale   jama ',b(10+64),d'uka tomasza  09'
		dta d'   przepompownia       okrutnego z',b(11+64),d'a    10'
		dta d'   ziej',b(4+64),d'ca jadem       przed obiadem    11'
		dta d'   grzyb widelec       ',b(10+64),d'arowka robot    12'
		dta d' podwodny grobowiec   kwiatk',b(5+64),d'w i mi',b(1+64),d'sa  13'
		dta d'  krater z',b(11+64),d'a pe',b(11+64),d'en    spienionej piany  14'
		dta d'nisza kolonistki olikt',b(5+64),d'ra drwi',b(11+64),d'a z gruzu15'
		dta d' izba sn',b(5+64),d'w obsikana  przez koty szatana 16'
		dta d' odwrotna kolimacja    biedoty z boru   17'
		dta d'     ponury k',b(4+64),d't      przeciwnik',b(5+64),d'w dobra 18'
		dta d'   grota  przebi',b(3+64),d'    z onych  za',b(2+64),d'wiat',b(5+64),d'w 19'
		dta d'       budka          mitochondrialna   20'
		dta d'cztery p',b(11+64),d'ozy strachu ponad osiem mi',b(1+64),b(2+64),d'ni 21'
		dta d'  dom lisa siostry  brata drwala staszka22'
		dta d'  podwodne  piek',b(11+64),d'o   beztypowych ',b(2+64),d'ledzi 23'
		dta d'  wype',b(11+64),d'nione  rop',b(4+64),d'   koszmarne  po',b(11+64),d'acie 24'
		dta d' ',b(2+64),d'luza numer siedem wcze',b(2+64),d'niej spopielona25'
		dta d'przedpok',b(5+64),d'j  kulawych lis',b(5+64),d'w  snycerskich 26'
		dta d'  miejsce',b(12+64),d' kt',b(5+64),d'rego   nigdy nie za wiele 27'
;             #........;.........##........;.........#
		dta d'  xena xenia xella       przewiewna     28'
;		dta d'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa19'
;		dta d'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa20'
MAP_NAME_LAST
		dta b($9b)
		
FONT_MAPPER
		dta b(>GAME_FONT)			; North
		dta b(>GAME_FONT+2)			; West
		dta b(>GAME_FONT_2)			; South
		dta b(>GAME_FONT_2+2)		; East
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
; ---	init PMG
	ldy #64
@	jsr synchro
	dey
	cpy #0
	bne @-
	
	ldx #0
	stx instruction_page
	mwa #TITLE_PART_1 ptr0
	mwa #TITLE_PART_2 ptr1

	lda #0
	sta mapnumber
	sta showsummary
	lda >TITLE_FONT
	sta CHBAS
	jsr paint_title_text
	jsr paint_level_number

	ift USESPRITES
	mva >pmg pmbase		;missiles and players data address
	mva #$03 pmcntl		;enable players and missiles
	eif

	lda:cmp:req $14		;wait 1 frame

	sei			;stop interrups
	mva #$00 nmien		;stop all interrupts
	mva #$fe portb		;switch off ROM to get 16k more ram

	ZPINIT

////////////////////
// RASTER PROGRAM //
////////////////////

	lda #00
	ldx #<MODUL
	ldy #>MODUL
	jsr RASTERMUSICTRACKER	;Init
	
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
c1	lda #$0A
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
c4	lda #$10
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
	:2 nop
	sta hposp3
	ldy #$70
	ldx #$00
	jsr _rts
	:2 nop

line32
	jsr wait18cycle
	lda zc+0
	stx color2
	sta hposp3
	lda cl+0
	sta hposp3
	cmp 0
	stx color2
	jsr _rts
	cmp 0

line33
	jsr wait18cycle
	lda zc+0
	stx color2
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

	lda #$da
	sta color2
	lda #$63
	sta color1
	lda #$98
	sta color0
	lda #$ff
	sta color3
	
	

raster_program_end

;	lda #$00
;	sta colpm0
;	sta colpm1
;	sta colpm2
;	sta colpm3
;	sta color0
;	sta color1
;	sta color2
;	sta color3
;	sta colbak

// -----------------------------------------------------------
//	EXIT
// -----------------------------------------------------------

	lda trig0		; FIRE #0
	beq stop

	lda consol		; START
	and #1
	beq stop

	lda porta
	cmp #247	; 251
	bne @+
	jsr set_next_starting_level
	jmp xx1
	
@	cmp #251
	bne @+
	jsr set_previous_starting_level
xx1	
@	cmp #253
	bne @+
	jsr flip_instruction_page
	jmp xx2
@	cmp #254
	bne xx2
	jsr flip_instruction_page
xx2	
	lda consol
	cmp #5
	bne @+
	jsr flip_amygdala_speed

@	jmp skp

stop
	jsr RASTERMUSICTRACKER+9 ; Stop music
	mva #$00 pmcntl		;PMG disabled
	tax
	sta:rne hposp0,x+

	mva #$ff portb		;ROM switch on
	mva #$40 nmien		;only NMI interrupts, DLI disabled
	cli			;IRQ enabled

	jmp run_here
skp

// -----------------------------------------------------------

	jsr RASTERMUSICTRACKER+3
	inc delayer
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
	
	dta b($70)
	dta b($42)
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
	dta b($02)
	dta b($02)
	dta b($70)
	dta b($06)
	dta b($06)
	dta b($06)
	
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
		jsr init_game
		jsr show_level

game_loop
		ldx collectibles
		cpx #0
		bne gl_0
		#if .byte reducer = #$ff/2-4
			adw curmap #MAP_02-MAP_01
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
		jeq run_here
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
		
can_move_right
		inc px
		jsr ppos2scrmem
		dec px
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
		
can_move_left
		dec px
		jsr ppos2scrmem
		inc px
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
		stx HPOSP2
		#if .byte moved = #PL_CHR
			stx HPOSP3
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
		stx HPOSP2
		#if .byte moved = #PL_CHR
			stx HPOSP3
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
		stx HPOSP2
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
		mva #0 HPOSP2
		rts
		
clear_player_sprite
		ldy #0
		lda #0
@		sta pmg_p3,y
		iny
		cpy #128
		bne @-
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
		cpy #100
		bne @-
		rts
		
show_intermission
		lda #$da
		sta CLR1

		lda #$0F
		sta CLR0

		lda #$77
		sta CLR2

		ldx #<MODUL
		ldy #>MODUL
		lda #$36
		jsr RASTERMUSICTRACKER

		ldx #0
		sta HPOSM0
		sta HPOSP0
		sta HPOSP1

		ldx <DLINTERMISSION
		ldy >DLINTERMISSION
		stx SDLSTL
		sty SDLSTL+1
		lda >TITLE_FONT
		sta CHBAS
		
		; TODO: Optimize these moves
		#if .byte showsummary = #1
			jsr clear_intermission_screen
			mva #39 SCRMEM+5	; G
			mva #50 SCRMEM+6	; R
			mva #33 SCRMEM+7	; A
			mva #52 SCRMEM+8	; T
			mva #53 SCRMEM+9	; U
			mva #44 SCRMEM+10	; L
			mva #33 SCRMEM+11	; A
			mva #35 SCRMEM+12	; C
			mva #42 SCRMEM+13	; J
			mva #37 SCRMEM+14	; E
			jsr sleep_for_some_time

			mva #128+36 SCRMEM+20	; D
			mva #128+47 SCRMEM+21	; O
			mva #128+35 SCRMEM+22	; C
			mva #128+37 SCRMEM+23	; E
			mva #128+46 SCRMEM+24	; N
			mva #128+35 SCRMEM+25	; C
			mva #128+41 SCRMEM+26	; I
			mva #128+37 SCRMEM+27	; E
			jsr sleep_for_some_time
			mva #64+52 SCRMEM+29	; T
			mva #64+50 SCRMEM+30	; R
			mva #64+58 SCRMEM+31	; Z
			mva #64+33 SCRMEM+32	; A
			mva #64+51 SCRMEM+33	; S
			mva #64+43 SCRMEM+34	; K
			mva #64+47 SCRMEM+35	; O
			mva #64+55 SCRMEM+36	; W
			mva #64+51 SCRMEM+37	; S
			mva #64+43 SCRMEM+38	; K
			mva #64+41 SCRMEM+39	; I
			jsr sleep_for_some_time
			
			mva #34 SCRMEM+60
			jsr sleep_for_short_time
			mva #47 SCRMEM+61
			jsr sleep_for_short_time
			mva #58 SCRMEM+63
			jsr sleep_for_short_time
			mva #55 SCRMEM+64
			jsr sleep_for_short_time
			mva #57 SCRMEM+65
			jsr sleep_for_short_time
			mva #35 SCRMEM+66
			jsr sleep_for_short_time
			mva #41 SCRMEM+67
			jsr sleep_for_short_time
			mva #1 SCRMEM+68
			jsr sleep_for_short_time
			mva #10 SCRMEM+69
			jsr sleep_for_short_time
			mva #57 SCRMEM+70
			jsr sleep_for_short_time
			mva #3 SCRMEM+71
			jsr sleep_for_short_time
			mva #45 SCRMEM+73
			jsr sleep_for_short_time
			mva #47 SCRMEM+74
			jsr sleep_for_short_time
			mva #39 SCRMEM+75
			jsr sleep_for_short_time
			mva #4 SCRMEM+76
			jsr sleep_for_short_time
			mva #35 SCRMEM+78
			jsr sleep_for_short_time
			mva #41 SCRMEM+79
			jsr sleep_for_short_time
			
			mva #128+35 SCRMEM+80
			jsr sleep_for_short_time
			mva #128+47 SCRMEM+81
			jsr sleep_for_short_time
			mva #128+52 SCRMEM+83
			jsr sleep_for_short_time
			mva #128+37 SCRMEM+84
			jsr sleep_for_short_time
			mva #128+46 SCRMEM+85
			jsr sleep_for_short_time
			mva #128+51 SCRMEM+86
			jsr sleep_for_short_time
			mva #128+47 SCRMEM+87
			jsr sleep_for_short_time
			mva #128+50 SCRMEM+88
			jsr sleep_for_short_time
			mva #128+37 SCRMEM+89
			jsr sleep_for_short_time
			mva #128+45 SCRMEM+90
			jsr sleep_for_short_time
			mva #128+55 SCRMEM+92
			jsr sleep_for_short_time
			mva #128+11 SCRMEM+93
			jsr sleep_for_short_time
			mva #128+47 SCRMEM+94
			jsr sleep_for_short_time
			mva #128+36 SCRMEM+95
			jsr sleep_for_short_time
			mva #128+33 SCRMEM+96
			jsr sleep_for_short_time
			mva #128+50 SCRMEM+97
			jsr sleep_for_short_time
			mva #128+58 SCRMEM+98
			jsr sleep_for_short_time
			mva #128+4 SCRMEM+99

@			lda trig0		; FIRE #0
			bne @-

			jsr clear_intermission_screen
			jsr sleep_for_short_time
			ldy #0
			lda (curmapname),y
			cmp #$9b
			bne @+
			pla
			pla
			pla
			pla
:4			jsr sleep_for_some_time

			mwa #MAP_01 curmap
			mwa #MAP_01_NAME curmapname
		
			jmp main
@
		#end
		
		mva #1 showsummary
		
		jsr clear_intermission_screen
		
		mva #48 SCRMEM+1	; P
		mva #37 SCRMEM+2	; E
		mva #46 SCRMEM+3	; N
		mva #37 SCRMEM+4	; E
		mva #52 SCRMEM+5	; T
		mva #50 SCRMEM+6	; R
		mva #33 SCRMEM+7	; A
		mva #35 SCRMEM+8	; C
		mva #42 SCRMEM+9	; J
		mva #33 SCRMEM+10	; A
		mva #42 SCRMEM+12	; J
		mva #33 SCRMEM+13	; A
		mva #51 SCRMEM+14	; S
		mva #43 SCRMEM+15	; K
		mva #41 SCRMEM+16	; I
		mva #46 SCRMEM+17	; N
		mva #41 SCRMEM+18	; I
		jsr sleep_for_some_time
	
		mva #46+128 SCRMEM+26	;  
		mva #53+128 SCRMEM+27	;  
		mva #45+128 SCRMEM+28	;  
		mva #37+128 SCRMEM+29	;  
		mva #50+128 SCRMEM+30	;  
		jsr sleep_for_some_time
		
		ldy #40
		lda (curmapname),y
		add #64
		sta SCRMEM+32
		iny
		lda (curmapname),y
		add #64
		sta SCRMEM+33
		jsr sleep_for_some_time
		
		mva #58 SCRMEM+40	;  
		mva #55 SCRMEM+41	;  
		mva #33 SCRMEM+42	;  
		mva #46 SCRMEM+43	;  
		mva #37 SCRMEM+44	;  
		mva #42 SCRMEM+45	;  
		mva #37 SCRMEM+47	;  
		mva #46 SCRMEM+48	;  
		mva #41 SCRMEM+49	;  
		mva #39 SCRMEM+50	;  G
		mva #45 SCRMEM+51	;  M
		mva #33 SCRMEM+52	;  A
		mva #52 SCRMEM+53	;  T
		#if .byte RANDOM > #128
			mva #57 SCRMEM+54	;  Y
			mva #35 SCRMEM+55	;  C
			mva #58 SCRMEM+56	;  Z
		#else
			mva #35 SCRMEM+54	;  C
			mva #58 SCRMEM+55	;  Z
			mva #57 SCRMEM+56	;  Y
		#end
		mva #46 SCRMEM+57	;  
		mva #41 SCRMEM+58	;  
		mva #37 SCRMEM+59	;  
		jsr sleep_for_some_time
	
		ldy #0
@		lda (curmapname),y
		sta SCRMEM+60,y
		cmp #0
		beq @+
		jsr sleep_for_short_time
@		iny
		cpy #40
		bne @-1

@		lda trig0		; FIRE #0
		bne @-

		ldx #$ff
		stx CH
		rts
		
vbi_routine
		jsr RASTERMUSICTRACKER+3
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
		sta GAME_FONT+8+8,y
		sta GAME_FONT_2+8+8,y
		sta GAME_FONT+8+8+64*8,y
		sta GAME_FONT_2+8+8+64*8,y
		iny
		cpy #8
		bne @-
		lda (ptr0),y
		sta amygdala_color
		rts

init_game
		ldy <vbi_routine
		ldx >vbi_routine
		lda #7
		jsr SETVBV
		
		mva instafall old_instafall
		jsr show_intermission

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
		jsr RASTERMUSICTRACKER

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
		ldx #$ff/2-4
		stx reducer
		ldx #0
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
		rts

rotate_clockwise
		lda rotation_warmup
		cmp #0
		beq @+
		rts
@		mva #ROT_CTR rotation_warmup

		dec direction
		lda direction
		and #%00000011
		sta direction
@		jsr set_font
.rept MAPSIZE, #, SCWIDTH-MARGIN-1-#
		lda SCRMEM+SCWIDTH*:1+4
		sta SCRMEM_BUFFER+SCWIDTH*0+:2
		lda SCRMEM+SCWIDTH*:1+5
		sta SCRMEM_BUFFER+SCWIDTH*1+:2
		lda SCRMEM+SCWIDTH*:1+6
		sta SCRMEM_BUFFER+SCWIDTH*2+:2
		lda SCRMEM+SCWIDTH*:1+7
		sta SCRMEM_BUFFER+SCWIDTH*3+:2
		lda SCRMEM+SCWIDTH*:1+8
		sta SCRMEM_BUFFER+SCWIDTH*4+:2
		lda SCRMEM+SCWIDTH*:1+9
		sta SCRMEM_BUFFER+SCWIDTH*5+:2
		lda SCRMEM+SCWIDTH*:1+10
		sta SCRMEM_BUFFER+SCWIDTH*6+:2
		lda SCRMEM+SCWIDTH*:1+11
		sta SCRMEM_BUFFER+SCWIDTH*7+:2
		lda SCRMEM+SCWIDTH*:1+12
		sta SCRMEM_BUFFER+SCWIDTH*8+:2
		lda SCRMEM+SCWIDTH*:1+13
		sta SCRMEM_BUFFER+SCWIDTH*9+:2
		lda SCRMEM+SCWIDTH*:1+14
		sta SCRMEM_BUFFER+SCWIDTH*10+:2
		lda SCRMEM+SCWIDTH*:1+15
		sta SCRMEM_BUFFER+SCWIDTH*11+:2
.endr
		jsr show_backup_buffer
		rts
		
rotate_counter_clockwise
		lda rotation_warmup
		cmp #0
		beq @+
		rts
@		mva #ROT_CTR rotation_warmup
		
		inc direction
		lda direction
		and #%00000011
		sta direction
@		jsr set_font
.rept MAPSIZE, #, MARGIN+#
		lda SCRMEM+SCWIDTH*:1+4
		sta SCRMEM_BUFFER+SCWIDTH*11+:2
		lda SCRMEM+SCWIDTH*:1+5
		sta SCRMEM_BUFFER+SCWIDTH*10+:2
		lda SCRMEM+SCWIDTH*:1+6
		sta SCRMEM_BUFFER+SCWIDTH*9+:2
		lda SCRMEM+SCWIDTH*:1+7
		sta SCRMEM_BUFFER+SCWIDTH*8+:2
		lda SCRMEM+SCWIDTH*:1+8
		sta SCRMEM_BUFFER+SCWIDTH*7+:2
		lda SCRMEM+SCWIDTH*:1+9
		sta SCRMEM_BUFFER+SCWIDTH*6+:2
		lda SCRMEM+SCWIDTH*:1+10
		sta SCRMEM_BUFFER+SCWIDTH*5+:2
		lda SCRMEM+SCWIDTH*:1+11
		sta SCRMEM_BUFFER+SCWIDTH*4+:2
		lda SCRMEM+SCWIDTH*:1+12
		sta SCRMEM_BUFFER+SCWIDTH*3+:2
		lda SCRMEM+SCWIDTH*:1+13
		sta SCRMEM_BUFFER+SCWIDTH*2+:2
		lda SCRMEM+SCWIDTH*:1+14
		sta SCRMEM_BUFFER+SCWIDTH*1+:2
		lda SCRMEM+SCWIDTH*:1+15
		sta SCRMEM_BUFFER+SCWIDTH*0+:2
.endr
		jsr show_backup_buffer
		rts
		
show_backup_buffer
		ldy #SCWIDTH*MAPSIZE-1
@		lda SCRMEM_BUFFER,y
		sta SCRMEM,y
		dey
		cpy #0-1
		bne @-
		rts
		
stick_right
		lda mvstate
		cmp #MV_IDLE
		jne game_loop_movement
		lda STRIG0
		cmp #0
		bne @+
		jsr clear_player_sprite
		jsr rotate_clockwise
		jsr recalc_player_position
		mva #1 repaint
		mva #GS_GRAV gstate
		jmp game_loop
@		mva ppx px
		mva ppy py
		jsr can_move_right
		cmp #0
		jne game_loop
		jsr init_movement
		mva #MV_MRGH mvstate
		jmp game_loop
		
stick_left
		lda mvstate
		cmp #MV_IDLE
		jne game_loop_movement
		lda STRIG0
		cmp #0
		bne @+
		jsr clear_player_sprite
		jsr rotate_counter_clockwise
		jsr recalc_player_position
		mva #1 repaint
		mva #GS_GRAV gstate
		jmp game_loop
@		mva ppx px
		mva ppy py
		jsr can_move_left
		cmp #0
		jne game_loop
		jsr init_movement
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
		lda #0
		sta HPOSP2
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
		
init_sprites
		lda #0
		ldy #0
@		sta pmg_p2,y
		sta pmg_p3,y
		iny
		cpy #pmg_p3-pmg_p2
		bne @-

		lda #>pmg_base
		sta PMBASE
		lda #%00000001
		sta GPRIOR
		
		lda #%00000011
		sta GRACTL

		lda SDMCTL
		ora #%00001100
		sta SDMCTL
		
		lda #0
		sta SIZEP0

		lda #C_PLAYR
		sta PCOLR3
		sta PCOLR2
		
		lda #C_WALL2
		sta CLR0
		lda amygdala_color
		sta CLR1
		lda #C_OBSTA
		sta CLR2
		lda #C_WALL1
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
		jsr recalc_player_position
		pla
		sta curmap+1
		pla
		sta curmap
		rts
		
add_color
		sta ptr3
		#if .byte ptr3 = #2
			lda ptr3
			add #64
			inc collectibles
			rts
		#end
		/*
		#if .byte ptr3 >= #3 .and .byte ptr3 <= #4
			lda ptr3
			add #128
			rts
		#end
		#if .byte ptr3 >= #5 .and .byte ptr3 <= #11
			lda ptr3
			add #128+64
			rts
		#end
		*/
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
		sta $2c8
		sta $d01b ;!!!

		lda #3
		sta $d008 
		sta $d009;-szerokosc
		sta $d00c

	lda #$90
	sta $02c1
	sta $02c0

	lda #0
	sta $026f
	lda #$2e
	sta $022f
		; Vidol - end
		
		; Missile 1
		ldy #0
		lda #0
@		sta pmg_m0,y
		iny
		cpy #$ff/2
		bne @-

		ldy #16
		lda #%00000010
@		sta pmg_m0,y
		iny
		cpy #$ff/2-15
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

		ldy #16
		lda #%11111110
@		sta pmg_p0,y
		iny
		cpy #$ff/2-15
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

		ldy #16
		lda #$ff
@		sta pmg_p1,y
		iny
		cpy #$ff/2-15
		bne @-
		
		lda #$2f
		sta hposp1

		rts
		
show_geometry
		mwa #(SCRMEM+MARGIN) ptr0
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
		adb ptr2 #8
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
		
		mwa #pmg_p3+TOPMARG ptr1
		
		ldy ppy
x2pmg_0	cpy #0
		beq @+
		dey
		adw ptr1 #8
		jmp x2pmg_0
@		sbw ptr1 #pmg_p3 ptr2
		adb ptr2 #8
		mva ptr2 psy
		rts

synchro
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

paint_title_text
		ldy #0
@		lda (ptr0),y
		sta SCRMEM,y
		iny
		cpy #240
		bne @-
		ldy #0
@		lda (ptr1),y
		sta SCRMEM+40*6,y
		iny
		cpy #240
		bne @-
		ldy #0
@		lda TITLE_PART_3,y
		sta SCRMEM+40*6*2,y
		iny
		cpy #40+3*20
		bne @-
		jsr paint_amygdala_speed
		rts

paint_level_number
		ldy #MAP_02_NAME-MAP_01_NAME-2
		lda (curmapname),y
		eor #%10000000
		sta SCRMEM+(TITLE_LEVEL_NUMBER-TITLE_PART_1)+1
		iny
		lda (curmapname),y
		eor #%10000000
		sta SCRMEM+(TITLE_LEVEL_NUMBER-TITLE_PART_1)+2
		rts
		
set_next_starting_level
		lda delayer
		and #%00000011
		cmp #%00000011
		bne @+
		adw curmap #MAP_02-MAP_01
		adw curmapname #MAP_02_NAME-MAP_01_NAME
		nop
		#if .word curmapname = #MAP_NAME_LAST
			sbw curmap #MAP_02-MAP_01
			sbw curmapname #MAP_02_NAME-MAP_01_NAME
		#end
		jsr paint_level_number
@		rts
		
set_previous_starting_level
		lda delayer
		and #%00000111
		cmp #%00000111
		bne @-
		sbw curmap #MAP_02-MAP_01
		sbw curmapname #MAP_02_NAME-MAP_01_NAME
		nop
		#if .word curmapname = #MAP_01_NAME-(MAP_02_NAME-MAP_01_NAME)
			adw curmap #MAP_02-MAP_01
			adw curmapname #MAP_02_NAME-MAP_01_NAME
		#end
		jsr paint_level_number
		rts
		
flip_instruction_page
		lda delayer
		and #%00000111
		cmp #%00000111
		bne fip_XX
		dec instruction_page
		lda instruction_page
		and #%00000001
		cmp #0
		beq @+
		mwa #TITLE_PART_1_X ptr0
		mwa #TITLE_PART_2_X ptr1
		jmp fip_X
@		mwa #TITLE_PART_1 ptr0
		mwa #TITLE_PART_2 ptr1
fip_X	jsr paint_title_text
		jsr paint_level_number
fip_XX	rts

flip_amygdala_speed
		lda delayer
		and #%00000111
		cmp #%00000111
		bne @+
		inc instafall
		jsr paint_amygdala_speed
@		rts

paint_amygdala_speed
		lda instruction_page
		and #%00000001
		cmp #0
		beq pas_X
		
		lda instafall
		and #%00000001
		cmp #0
		bne pas_0

		lda #46
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)
		lda #105
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+1
		lda #101
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+2
		lda #109
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+3
		lda #114
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+4
		lda #97
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+5
		lda #119
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+6
		jmp pas_X

pas_0
		lda #2
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)
		lda #112
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+1
		lda #105
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+2
		lda #101
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+3
		lda #115
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+4
		lda #122
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+5
		lda #110
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1_X)+6
		
pas_X	rts

.align		$100
DLGAME
:3			dta b($70)
			dta b($47)
			dta a(SCRMEM)
:MAPSIZE-1	dta	b($07)
			dta b($41),a(DLGAME)
DLINTERMISSION
:8			dta b($70)
			dta b($46)
			dta a(SCRMEM)
			dta b($70)
			dta b($06)
			dta b($70)
			dta b($06)
:4			dta b($70)
			dta b($07)
			dta b($40)
			dta b($07)
			dta b($41),a(DLINTERMISSION)

		; dta d'%&''()*+%%%%%'
		; dta d'%          %'		
		; dta d'%    %%%   %'		
		; dta d'%    %"$$  %'		
		; dta d'%   ,-./012,'		
		; dta d'%          %'		
		; dta d'%"##    %  %'		
		; dta d'%%%%%%% %  %'		
		; dta d'%   "   %  %'		
		; dta d'%  %%%  %  %'		
		; dta d'%!  "   %  %'		
		; dta d'%%%%%%&''()*+'

; Sprites
.align		$1000
pmg_base
:1024 dta b(0)
pmg_m0			equ pmg_base+$180
pmg_p0			equ pmg_base+$200
pmg_p1			equ pmg_base+$280
pmg_p2			equ pmg_base+$300
pmg_p3			equ pmg_base+$380

SCRMEM
:SCWIDTH*MAPSIZE	dta b(0)
SCRMEM_BUFFER
:SCWIDTH*MAPSIZE	dta b(0)

.align	$400
TITLE_FONT
		ins "fonts\BZZZ1.FNT"
.align	$400
GAME_FONT
		ins "fonts\fontek.fnt"
.align	$400
GAME_FONT_2
		ins "fonts\fontek2.fnt"
		
		org MUSICPLAYER
		icl "music\rmtplayr.a65"

MAP_01
;	ins "maps\v1.map"

		   dta d'   %%%%%%   '
		   dta d'   %   "%   '		
		   dta d'   %%% %%   '		
		   dta d'%%%%    %%%%'		
		   dta d'% %        %'		
		   dta d'%        % %'		
		   dta d'% %     %% %'		
		   dta d'%"%    %%  %'		
		   dta d'%%%   %% ##%'		
		   dta d'%    %% ##%%'		
		   dta d'%!  %% ##%% '		
		   dta d'%%%%%%%%%%  '

		  ; dta d'%%%%%%%%%%%%'
		  ; dta d'%          %'		
		  ; dta d'%          %'		
		  ; dta d'%          %'		
		  ; dta d'%          %'		
		  ; dta d'%          %'		
		  ; dta d'%          %'		
		  ; dta d'%          %'		
		  ; dta d'%          %'		
		  ; dta d'%          %'		
		  ; dta d'%!         %'		
		  ; dta d'%%%%%%%%%%%%'
	
MAP_02
.rept MAPCOUNT-1 #+2
	ins "maps\v:1.map"
.endr
MAP_LAST
SCREEN_MARGIN_DATA
		ins "data\ekran.dat"
SCREEN_MARGIN_DATA_END
music_start_table
	dta b($00),b($1e),b($45),b($45),b($5d),b($57),b($57),b($57) ; $5d

	org curmap
	dta a(MAP_01)
	org curmapname
	dta a(MAP_01_NAME)
	org first_run
	dta b(0)
	org instruction_page
	dta b(0)
	org instafall
	dta b(1)


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
; - Check player gravity only after movement
; - Integrate next raster optimization from Vidol
; - Add detailed instruction (instafall on demand and so on)