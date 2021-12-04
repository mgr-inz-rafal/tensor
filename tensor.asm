; "Tensor Trzaskowskiego" for Atari 8-bit by mgr_inz_rafal

; This project is licensed under "THE BEER-WARE LICENSE" (Revision 42).
; rchabowski@gmail.com wrote this project. As long as you retain this
; notice you can do whatever you want with this stuff.
; If we meet some day, and you think this stuff is worth it,
; you can buy me a beer in return.

	; Selected ATARI registes
	icl "include\atari.inc"

CREDITCOLSTART	equ $00
CREDITCOLEND	equ	CREDITCOLSTART+$0f
LEVELFLIPDELAY	equ %00000011
AMYGDALFLIPDEL	equ %00000111
SOURCEDECO 		equ $ff-8*3
TARGETDECO 		equ $b0
PMGDECOOFFSET 	equ 12
DIGITOFFSET		equ 6
SHADOWOFFSET 	equ 60
TITLEOFFSET 	equ 60+20
MAPCOUNT 		equ 51
MUSICPLAYER		equ $9000
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
LAST_FONT_STORAGE equ $FFFA-1-1024 ; 5th font

.zpvar	.byte	antic_tmp
.zpvar	.byte	stop_intermission
.zpvar	.byte	scroll_tmp
.zpvar	.byte	credits_flips
.zpvar	.byte	credits_timer
.zpvar	.byte	credits_color
.zpvar	.byte	credits_state
.zpvar	.byte	scroll
.zpvar	.byte	old_instafall
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
.zpvar  .byte   ntsc
.zpvar  .byte   ntsc_music_conductor
.zpvar  .byte	rmt_player_halt

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

; ---	Load map data and move under OS
	org $2000
.rept MAPCOUNT #+1
	ins "maps\v:1.map"
.endr
MAPS_END equ *
MAPS_END_IN_STORAGE equ MAPS_END + MAP_STORAGE - $2000

COPY_UNDER_OS
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

; ---	Load first 4 fonts and move under OS
	org $2000
CREDITS_FONT equ *-$2000 + FONTS_STORAGE		
		ins "fonts\credits3.fnt"
TITLE_FONT equ *-$2000 + FONTS_STORAGE
		ins "fonts\BZZZ1.FNT"
GAME_FONT equ *-$2000 + FONTS_STORAGE		
		ins "fonts\fontek.fnt"
DIGITS_FONT equ *-$2000 + FONTS_STORAGE		
		ins "fonts\digits.fnt"
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

; ---	Load last font and move under OS
	org $2000
GAME_FONT_2 equ *-$2000 + LAST_FONT_STORAGE
		ins "fonts\fontek2.fnt"
LAST_FONT_END equ *
LAST_FONT_END_IN_STORAGE equ LAST_FONT_END + LAST_FONT_STORAGE - $2000

COPY_UNDER_OS_LAST_FONT
	sei
	lda #0
	sta NMIEN
	lda #$fe
	sta PORTB

; Copy target
	lda <LAST_FONT_STORAGE
	sta $80
	lda >LAST_FONT_STORAGE
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
	cmp <LAST_FONT_END
	bne @-
	lda $83
	cmp >LAST_FONT_END
	bne @-

COPY_LAST_FONT_DONE
	lda #$ff
	sta PORTB
	lda #$40
	sta NMIEN
	cli

	rts
	ini COPY_UNDER_OS_LAST_FONT

; ---	MAIN PROGRAM
	org $2000
scr	ins "data\tensor5.raw" +0,+0,3520
MODUL
		opt h-
		ins "music\TENSOR.rmt"
		opt h+
		
	org $3900-3+1087
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

AMYGDALA_DATA_5	; Miecz
	dta b(0),b(192),b(160),b(84),b(44),b(24),b(52),b(2),b($64),b($74)

AMYGDALA_DATA_6	; Pierscionek
	dta b(0),b(60),b(24),b(52),b(82),b(64),b(66),b(52),b($a6),b($b6)

AMYGDALA_DATA_7	; Robak
	dta b(0),b(146),b(130),b(84),b(16),b(88),b(16),b(56),b($34),b($44)
	
TITLE_PART_1
	dta b(62)
:38	dta b(125)
	dta b(93)
	dta b(124),d' Docent Ireneusz Trzaskowski poszukuje',b(124)
	dta b(124),d'na  Jowiszu  mistycznych ',b(31),d'MIGDA',b(11),b(5),d'W X4',b(30),b(124)
	
	dta b(124),d'Nie skacze, nie strzela, ale za pomoc',b(81),b(124)
	dta b(124),b(31),d'Tensora Miotu  Grawitacyjnego',b(30),d' miesza',b(124)
	dta b(124),d'przestrzeni',b(81),d' i powoduje  opad  rzeczy.',b(124)
TITLE_PART_2
	dta b(124),d'Pom',b(80),b(88),d' mu  wypr',b(80),b(88),d'ni',b(86),d' wszelkie pieczary.',b(124)
	dta b(124),d'                                      ',b(124)
	dta b(124),d'Kierunek ',b(28),d' FIRE zmienia grawitacj',b(68),d'.   ',b(124)
	dta b(124),d'D',b(88),d'oj w d',b(80),b(123),d' przyspiesza ospa',b(123),d'e spadki. ',b(124)
	dta b(63)
:38	dta b(74)
	dta b(29)
	dta b(124)
	dta b(128)
	dta b(94+128)
	dta b(95+128)
	dta d' - PIECZARA:'*
TITLE_LEVEL_NUMBER
	dta d'           '*
	dta b(32+128),b(64+128)
	dta d' - '*
TITLE_AMYGDALA_SPEED
	dta d'       '*,b(124)
TITLE_PART_3
	dta b(91)
:1	dta b(125)
	dta b(126)

	; http://github.com/mgr-inz-rafal/tensor
	dta b(66)
	dta b(83)
	dta b(79)
	dta b(90)
	dta b(76)
	dta b(65)
	dta b(84)
	dta b(67)
	dta b(69)
	dta b(96)
	dta b(27)
	dta b(59)
	dta b(60)
	dta b(61)
	dta b(120)
	dta b(89)
	dta b(8)
	dta b(7)

	dta b(127)
:12	dta b(125)

	dta b(126)
	dta b(72)
	dta b(73)
	dta b(127)
	dta b(125)
	dta b(92)
MAP_01_NAME
		dta d'kr'*,b(1+64*3),d'pcewo w prawo'*
		dta d'    I W LEWO    '*
MAP_01_NAME_END
		dta d'01'
MAP_02_NAME
		dta d'   staro'*,b(10+64*3),d'ytne   '*
		dta d'  KO'*,b(2+64*2),d'CIEPIECHO  '*
		dta d'02'
		dta d'sple'*,b(2+64*3),d'nia'*,b(11+64*3),d'a grota'*
		dta d'  OTY'*,b(11+64*2),d'EGO KOTA  '*
		dta d'03'
		dta d' sawa woda alfa '*
		dta d' SANTIAGO BELLA '*
		dta d'04'
		dta d' wydrapany loft '*
		dta d'FERMENTACJI SERA'*
		dta d'05'
		dta d' dystopia sze'*,b(2+64*3),b(3+64*3),d' '*
		dta d'DLA UMYTYCH LW'*,b(5+64*2),d'W'*
		dta d'06'
		dta d'komora kompresji'*
		dta d'STAWONOG'*,b(5+64*2),d'W I KUR'*
		dta d'07'
		dta d'  miejsce bytu  '*
		dta d'DWUMOLIBDENOWEGO'*
		dta d'08'
		dta d'swie'*,b(10+64*3),d'o wydr'*,b(4+64*3),b(10+64*3),d'ona'*
		dta d'JAMA '*,b(10+64*2),d'UKA ZENONA'*
		dta d'09'
		dta d' przesi'*,b(4+64*3),d'kni'*,b(1+64*3),d'cie '*
		dta d'  PONUREGO Z'*,b(11+64*2),d'A  '*
		dta d'10'
		dta d'tryskaj'*,b(4+64*3),d'ca jadem'*
		dta d'KLITA CHRZCIELNA'*
		dta d'11'
		dta d' grzyby widelec '*
		dta b(10+64*2),d'AR'*,b(5+64*2),d'WKA ROBOT V4'*
		dta d'12'
		dta d'podwodna piwnica'*
		dta d'Z MI'*,b(1+64*2),d'SEM I PSAMI'*
		dta d'13'
		dta d'  krater z'*,b(11+64*3),d'a i  '*
		dta d'SPIENIONEJ PIANY'*
		dta d'14'
		dta d'nisza schorza'*,b(11+64*3),d'ej'*
		dta d' KOLONISTKI OLI '*
		dta d'15'
		dta d'izba sn'*,b(5+64*3),d'w du'*,b(10+64*3),d'ego'*
		dta d'P'*,b(1+64*2),d'KATEGO SZATANA'*
		dta d'16'
		dta d'sprz'*,b(1+64*3),d'g kolimacji'*
		dta d'NIKLOWO-KADMOWEJ'*
		dta d'17'
		dta d'   ponury k'*,b(4+64*3),d't   '*
		dta d'ZAKICHANYCH CIA'*,b(11+64*2)
		dta d'18'
		dta d' jama przebicia '*
		dta d'SYFU Z ZA'*,b(2+64*2),d'WIAT'*,b(5+64*2),d'W'*
		dta d'19'
		dta d' zw'*,b(1+64*3),d'glona budka '*
		dta d'  PE'*,b(11+64*2),d'NA MITOZY  '*
		dta d'20'
		dta d' gibony strachu '*
		dta d' TU JADA'*,b(11+64*2),d'Y '*,b(2+64*2),d'LUZ '*
		dta d'21'
		dta d' dom '*,b(10+64*3),d'ony brata '*
		dta d' SIOSTRY TE'*,b(2+64*2),d'CIA '*
		dta d'22'
		dta d'podwodny bezkres'*
		dta d'POLA '*,b(2+64*2),d'LEDZIOWEGO'*
		dta d'23'
		dta d' dwie zaropia'*,b(11+64*3),d'e '*
		dta d'WN'*,b(1+64*2),d'TRZNO'*,b(2+64*2),d'CI DYNI'*
		dta d'24'
		dta b(2+64*3),d'luza numer trzy'*
		dta d'ONGI'*,b(2+64*2),d' DZIA'*,b(11+64*2),d'AJ'*,b(4+64*2),d'CA'*
		dta d'25'
		dta d'   przedpok'*,b(5+64*3),d'j   '*
		dta d'SNYCERSKICH PS'*,b(5+64*2),d'W'*
		dta d'26'
		dta d'zbiornik balsamu'*
		dta d' Z DERMATOFIT'*,b(5+64*2),d'W '*
		dta d'27'
		dta d'miejsce poch'*,b(5+64*3),d'wku'*
		dta d'OGORZA'*,b(11+64*2),d'EJ ESTERY'*
		dta d'28'
		dta d'  upiorny loft  '*
		dta d'Z KRWAW'*,b(4+64*2),d' KAPLIC'*,b(4+64*2)
		dta d'29'
		dta d'  biblioteka z  '*
		dta d'  UMAR'*,b(11+64*2),b(4+64*2),d' PRAS'*,b(4+64*2),d'  '*
		dta d'30'
		dta d' pop'*,b(1+64*3),d'kany strop '*
		dta d' GROZI KOLAPSJ'*,b(4+64*2),d' '*
		dta d'31'
		dta d'  wiktoria'*,b(15+64*3),d'ski  '*
		dta d'     RYGIEL     '*
		dta d'32'
		dta d'   tunele pod   '*
		dta d' MIASTEM UWI'*,b(4+64*2),d'DU '*
		dta d'33'
		dta d'  przeci'*,b(4+64*3),d'g jak  '*
		dta d'   Z KOSZMARU   '*
		dta d'34'
		dta d' bezkresne pola '*
		dta d'    OGLEJONU    '*
		dta d'35'
		dta d'    jaskinia    '*
		dta d'PONUREGO KINTARO'*
		dta d'36'
		dta d'     w'*,b(5+64*3),d'lka      '*
		dta d'  DOBROWOLSKA   '*
		dta d'37'
		dta d'    prze'*,b(11+64*3),b(1+64*3),d'cz    '*
		dta d'  MASZTALERSKA  '*
		dta d'38'
		dta d'    anomalia    '*
		dta d'    RZYGULIN    '*
		dta d'39'
		dta d'      ch'*,b(5+64*3),d'r      '*
		dta d'   BEMBNIST'*,b(5+64*2),d'W   '*
		dta d'40'
		dta d'     zau'*,b(11+64*3),d'ek     '*
		dta d' Z'*,b(11+64*2),d'EJ TEKTONIKI '*
		dta d'41'
		dta d'  termy '*,b(10+64*3),d'ywego  '*
		dta d'      BOGA      '*
		dta d'42'
		dta d' buda sanacyjna '*
		dta d' NAD PRZEPA'*,b(2+64*2),d'CI'*,b(4+64*2),d' '*
		dta d'43'
		dta d'     podkop     '*
		dta d' DR. KAMI'*,b(15+64*2),d'SKIEJ '*
		dta d'44'
		dta d'   paul morty   '*
		dta d'KOHORTY GERIATRY'*
		dta d'45'
		dta d'ponure podziemne'*
		dta d'OPACTWO PRZEMOCY'*
		dta d'46'
		dta d'   przepastne   '*
		dta d'    BEZDRO'*,b(10+64*2),d'A    '*
		dta d'47'
		dta d' podziemny targ '*
		dta d'Z RYBAMI I SEREM'*
		dta d'48'
		dta d'    kryj'*,b(5+64*3),d'wka    '*
		dta d' KORUPCJONIST'*,b(5+64*2),d'W '*
		dta d'49'
		dta d'  zalany tunel  '*
		dta d'   SZMUGLER'*,b(5+64*2),d'W   '*
		dta d'50'
		dta d' dwa anihilanty '*
		dta d'ZNAMION KALECTWA'*
		dta d'51'
MAP_NAME_LAST
		dta b($9b)
		
FONT_MAPPER
		dta b(>FONT_SLOT_1)			; North
		dta b(>FONT_SLOT_1+2)		; West
		dta b(>FONT_SLOT_2)			; South
		dta b(>FONT_SLOT_2+2)		; East
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
	disable_antic
	ldy #64
@	jsr synchro
	dey
	cpy #0
	bne @-

	ldx <TITLE_FONT
	ldy >TITLE_FONT
	jsr load_font_from_storage_slot_1
	ldx <CREDITS_FONT
	ldy >CREDITS_FONT
	jsr load_font_from_storage_slot_2
	
	mwa #TITLE_PART_1 ptr0
	mwa #TITLE_PART_2 ptr1
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
	jsr paint_title_text
	jsr paint_level_number
	jsr paint_amygdala_speed
	enable_antic

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

	jsr detect_ntsc
	lda #6
	sta ntsc_music_conductor
	lda #1
	sta rmt_player_halt

	ldx #<MODUL
	ldy #>MODUL
	jsr INIT_MUSIC
	
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
c1	ldy ntsc
	lda LOGO_COLOR_1,y
	lda #$0A
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
c4	ldy ntsc
	lda LOGO_COLOR_2,y
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
	sta hposp3
	ldy ntsc
	lda LOGO_COLOR_3,y
	tay
;	ldy #$70
	ldx #$00
	jsr _rts

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
	
	ldy ntsc
	lda COLOR_1_INSTRUCTION_TEXT,y
	sta color2
	lda COLOR_2_INSTRUCTION_TEXT,y
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
	jsr flip_amygdala_speed
	jmp xx2
@	cmp #254
	bne xx2
	jsr flip_amygdala_speed
xx2	

@	jmp skp

stop
	jsr STOP_MUSIC
	mva #$00 pmcntl		;PMG disabled
	tax
	sta:rne hposp0,x+

	mva #$ff portb		;ROM switch on
	mva #$40 nmien		;only NMI interrupts, DLI disabled
	cli			;IRQ enabled

	jmp run_here
skp

// -----------------------------------------------------------

	jsr CONDUCT_MUSIC
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
	
	dta b($40)
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
	dta b($30)
	dta b($02)
	dta b($42)
CREDITS_ADDRESS_DL
	dta a(CREDITS_BASE+80)
	dta b($02)
	dta b($42)
	dta a(FOURTY_EMPTY_CHARS)
	
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
		#if .byte reducer = #$ff/2-4
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
		cpy #11*20
		bne @-
		rts
		
draw_header
		ldy #0
		ldx #(header_text_END-header_text)
@		lda header_text,y
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
		mwa curmapname ptr0
		adw ptr0 #(MAP_01_NAME_END-MAP_01_NAME)
		ldy #0
		lda (ptr0),y
		sub #$10
		asl
		add #2
		sta SCRMEM+20+DIGITOFFSET,y
		add #1
		sta SCRMEM+21+DIGITOFFSET,y
		add #31
		sta SCRMEM+20+20+DIGITOFFSET,y
		add #1
		sta SCRMEM+21+20+DIGITOFFSET,y
		
		iny 
		
		lda (ptr0),y
		dey
		sub #$10
		asl
		add #2
		sta SCRMEM+22+DIGITOFFSET,y
		add #1
		sta SCRMEM+23+DIGITOFFSET,y
		add #31
		sta SCRMEM+22+20+DIGITOFFSET,y
		add #1
		sta SCRMEM+23+20+DIGITOFFSET,y
		
		lda #33
		sta SCRMEM+20+20+DIGITOFFSET-1,y
		
		jsr draw_cavern_number_shadow
		
		rts
		
draw_cavern_number_shadow
		lda #65
		sta SCRMEM+SHADOWOFFSET+DIGITOFFSET-1

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
		sta SCRMEM+SHADOWOFFSET+DIGITOFFSET
		add #1
		sta SCRMEM+SHADOWOFFSET+DIGITOFFSET+1

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
		sta SCRMEM+SHADOWOFFSET+DIGITOFFSET+2
		add #1
		sta SCRMEM+SHADOWOFFSET+DIGITOFFSET+3

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
		
header_text
		dta d'pieczara'
header_text_END

draw_decoration
		ldy #0
		tya
@		sta pmg_p0,y
		iny
		bne @-
@		sta pmg_p2,y
		iny
		bne @-

.rept 4 #
		ldy #0
@		lda sprite_decoration_data_:1,y
		sta pmg_p:1+PMGDECOOFFSET,y
		iny
		cpy #sprite_decoration_data_0_LEN-sprite_decoration_data_0
		bne @-
.endr

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
		
sprite_decoration_data_0
		dta b(0),b(64),b(0),b(80),b(5),b(82),b(81),b(70)
		dta b(86),b(64),b(84),b(80),b(80),b(88),b(80),b(72)
		dta b(90),b(72),b(88),b(75),b(83),b(72),b(74),b(104)
		dta b(68),b(108),b(68),b(110),b(36),b(46),b(38),b(18)
		dta b(23),b(27),b(13),b(15),b(5),b(6),b(7),b(2)
		dta b(3),b(2),b(3),b(2),b(3),b(3),b(3),b(3)
		dta b(7),b(3),b(7),b(14),b(7),b(14),b(31),b(15)
		dta b(25),b(59),b(30),b(60),b(28),b(56),b(80),b(57)
		dta b(112),b(32),b(112),b(38),b(118),b(32),b(80),b(32)
		dta b(113),b(98),b(80),b(32),b(114),b(32),b(112),b(32)
		dta b(49),b(57),b(16),b(8),b(4),b(4),b(2),b(1)
		dta b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)
		dta b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)
sprite_decoration_data_0_LEN
sprite_decoration_data_1
		dta b(3),b(67),b(16),b(1),b(12),b(14),b(0),b(0)
		dta b(5),b(56),b(25),b(34),b(1),b(42),b(129),b(11)
		dta b(2),b(59),b(53),b(35),b(87),b(43),b(23),b(135)
		dta b(87),b(137),b(89),b(47),b(95),b(46),b(31),b(46)
		dta b(29),b(44),b(28),b(174),b(29),b(174),b(159),b(188)
		dta b(223),b(157),b(219),b(189),b(218),b(154),b(220),b(191)
		dta b(103),b(171),b(118),b(252),b(153),b(185),b(240),b(248)
		dta b(240),b(99),b(112),b(100),b(114),b(32),b(114),b(32)
		dta b(116),b(32),b(114),b(56),b(82),b(24),b(89),b(44)
		dta b(124),b(174),b(119),b(59),b(17),b(25),b(29),b(14)
		dta b(135),b(139),b(23),b(18),b(9),b(1),b(1),b(8)
		dta b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)
		dta b(24),b(161),b(65),b(73),b(99),b(35),b(22),b(44)
sprite_decoration_data_2
		dta b(10),b(119),b(122),b(84),b(10),b(239),b(203),b(143)
		dta b(83),b(179),b(127),b(190),b(101),b(227),b(247),b(254)
		dta b(149),b(106),b(128),b(48),b(40),b(152),b(64),b(232)
		dta b(208),b(200),b(221),b(250),b(214),b(162),b(84),b(138)
		dta b(64),b(162),b(81),b(27),b(65),b(232),b(212),b(228)
		dta b(117),b(171),b(183),b(222),b(220),b(240),b(193),b(160)
		dta b(140),b(26),b(12),b(64),b(161),b(35),b(198),b(12)
		dta b(57),b(18),b(178),b(36),b(53),b(111),b(39),b(110)
		dta b(47),b(110),b(109),b(109),b(110),b(44),b(108),b(38)
		dta b(180),b(54),b(18),b(24),b(140),b(164),b(130),b(193)
		dta b(200),b(192),b(96),b(34),b(49),b(185),b(246),b(160)
		dta b(240),b(160),b(240),b(164),b(240),b(224),b(224),b(160)
		dta b(210),b(204),b(64),b(128),b(0),b(128),b(0),b(0)
sprite_decoration_data_3
		dta b(171),b(127),b(47),b(127),b(165),b(231),b(255),b(187)
		dta b(255),b(211),b(249),b(171),b(119),b(251),b(95),b(235)
		dta b(15),b(5),b(195),b(193),b(27),b(153),b(1),b(131)
		dta b(65),b(169),b(69),b(239),b(165),b(73),b(5),b(161)
		dta b(19),b(131),b(69),b(45),b(201),b(147),b(49),b(227)
		dta b(201),b(131),b(53),b(35),b(7),b(138),b(165),b(14)
		dta b(157),b(40),b(117),b(162),b(29),b(52),b(66),b(134)
		dta b(0),b(8),b(80),b(160),b(208),b(128),b(65),b(130)
		dta b(21),b(202),b(149),b(46),b(85),b(46),b(87),b(11)
		dta b(5),b(3),b(1),b(2),b(1),b(0),b(1),b(2)
		dta b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)
		dta b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)
		dta b(0),b(0),b(0),b(0),b(0),b(0),b(0),b(0)

setup_intermission_colors
		ldy ntsc
		#if .word curmap = #MAP_LAST
			lda INTERMISSION_COLOR_1,y
			sta PCOLR0
			lda INTERMISSION_COLOR_2,y
			sta PCOLR1
			lda INTERMISSION_COLOR_3,y
			sta PCOLR2
			lda INTERMISSION_COLOR_4,y
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
		
		lda INTERMISSION_COLOR_5,y
		sta CLR0
		lda INTERMISSION_COLOR_6,y
		sta CLR1
		lda INTERMISSION_COLOR_7,y
		sta CLR2
		lda INTERMISSION_COLOR_8,y
		sta CLR3
		rts
		
draw_happy_docent
		ldy ntsc
		lda FINAL_SCREEN_COLOR_1,y
		sta CLR0
		lda #$06 ;-diament
		sta CLR1
		lda FINAL_SCREEN_COLOR_2,y
		sta CLR2
		lda FINAL_SCREEN_COLOR_3,y
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
		jsr sleep_for_short_time
		ldx <DIGITS_FONT
		ldy >DIGITS_FONT
		jsr load_font_from_storage_slot_1
		ldx <TITLE_FONT
		ldy >TITLE_FONT
		jsr load_font_from_storage_slot_2
		enable_antic

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
		
		disable_antic
		jsr synchro

		; Reenable scroll on the first line of the title
		lda scroll_tmp
		sta DL_TOP_SCROL

		#if .word curmap = #MAP_LAST
			pla
			pla
			pla
			pla
			enable_antic
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
		jsr enable_sprites
		disable_antic

		ldy <vbi_routine
		ldx >vbi_routine
		lda #7
		jsr SETVBV
		
		mva instafall old_instafall
;		mwa #MAP_LAST curmap		; TODO: Remove after happy docent is integrated
		jsr show_intermission

		ldx <GAME_FONT
		ldy >GAME_FONT
		jsr load_font_from_storage_slot_1
		ldx <GAME_FONT_2
		ldy >GAME_FONT_2
		jsr load_font_from_storage_slot_2

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
		enable_antic
		rts

rotate_clockwise
		jsr os_gone
		jsr os_back
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

		jsr remember_original_map

		lda #0
		sta credits_timer
		mwy #RIGHT_FRAME_0_FROM ptr0
		mwy #RIGHT_FRAME_0_TO ptr1
		jsr do_rotation_step

		lda #0
		sta credits_timer
		mwy #RIGHT_FRAME_1_FROM ptr0
		mwy #RIGHT_FRAME_1_TO ptr1
		jsr do_rotation_step

		lda #0
		sta credits_timer
		mwy #RIGHT_FRAME_2_FROM ptr0
		mwy #RIGHT_FRAME_2_TO ptr1
		jsr do_rotation_step

		lda #0
		sta credits_timer
		mwy #RIGHT_FRAME_3_FROM ptr0
		mwy #RIGHT_FRAME_3_TO ptr1
		jsr do_rotation_step

		lda #0
		sta credits_timer
		mwy #RIGHT_FRAME_4_FROM ptr0
		mwy #RIGHT_FRAME_4_TO ptr1
		jsr do_rotation_step

		lda #0
		sta credits_timer
		mwy #RIGHT_FRAME_5_FROM ptr0
		mwy #RIGHT_FRAME_5_TO ptr1
		jsr do_rotation_step

		lda #0
		sta credits_timer
		mwy #RIGHT_FRAME_6_FROM ptr0
		mwy #RIGHT_FRAME_6_TO ptr1
		jsr do_rotation_step

		lda #0
		sta credits_timer
		mwy #RIGHT_FRAME_7_FROM ptr0
		mwy #RIGHT_FRAME_7_TO ptr1
		jsr do_rotation_step

		lda #0
		sta credits_timer
		mwy #RIGHT_FRAME_8_FROM ptr0
		mwy #RIGHT_FRAME_8_TO ptr1
		jsr do_rotation_step

		rts

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

		jsr remember_original_map

		ldx #9
		mwy #LEFT_ROTATION_TABLE_FROM ptr2
		mwy #LEFT_ROTATION_TABLE_TO ptr3
RCC_6	ldy #0
		sty credits_timer
		mwa (ptr2),y ptr0
		ldy #0
		mwa (ptr3),y ptr1
		txa
		pha
		jsr do_rotation_step
		pla
		tax
		dex
		beq RCC_5
		adw ptr2 #2
		adw ptr3 #2
		jmp RCC_6

RCC_5	rts

do_rotation_step
		jsr clear_backup_buffer
RCC_2	ldy credits_timer
		lda (ptr0),y
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
:6	 	jsr synchro
		rts

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

		ldy ntsc
		lda PLAYER_COLOR,y
		sta PCOLR3
		sta PCOLR2
		
		lda WALL_1_COLOR,y
		sta CLR0
		lda amygdala_color
		sta CLR1
		lda OBSTACLE_COLOR,y
		sta CLR2
		lda WALL_2_COLOR,y
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

	ldy ntsc
	lda MARGIN_COLOR,y
	sta PCOLR1
	sta PCOLR0

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

load_font_from_storage_slot_1
		stx ptr0
		sty ptr0+1
		mwa #FONT_SLOT_1 ptr1
		ldy #0
		jsr os_gone
lffss_1	lda (ptr0),y
		sta (ptr1),y
		#if .word ptr1 = #FONT_SLOT_2
			jsr os_back
			rts
		#end
		inw ptr0
		inw ptr1
		jmp lffss_1

load_font_from_storage_slot_2
		stx ptr0
		sty ptr0+1
		mwa #FONT_SLOT_2 ptr1
		ldy #0
		jsr os_gone
lffss_2	lda (ptr0),y
		sta (ptr1),y
		#if .word ptr1 = #FONT_SLOT_END
			jsr os_back
			rts
		#end
		inw ptr0
		inw ptr1
		jmp lffss_2

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

		mwa #MAP_STORAGE ptr0
lmfs_1	cpy #0
		beq lmfs_0
		adw ptr0 #MAP_BUFFER_END-MAP_BUFFER_START
		dey
		jmp lmfs_1

lmfs_0
		jsr os_gone

 		ldy #MAPSIZE*MAPSIZE-1
@		lda (ptr0),y
 		sta MAP_BUFFER_START,y
 		dey
 		cpy #0-1
 		bne @-

		jsr os_back
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
dn_1  	cli
		rts

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
		cpy #40
		bne @-
		ldy #0
		lda #0
@		sta SCRMEM+40*13,y
		iny
		cpy #40
		bne @-
		
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
		and #LEVELFLIPDELAY
		cmp #LEVELFLIPDELAY
		bne @+
		adw curmap #MAP_BUFFER_END-MAP_BUFFER_START
		adw curmapname #MAP_02_NAME-MAP_01_NAME
		nop
		#if .word curmapname = #MAP_NAME_LAST
			sbw curmap #MAP_BUFFER_END-MAP_BUFFER_START
			sbw curmapname #MAP_02_NAME-MAP_01_NAME
		#end
		jsr paint_level_number
@		rts
		
set_previous_starting_level
		lda delayer
		and #LEVELFLIPDELAY
		cmp #LEVELFLIPDELAY
		bne @-
		sbw curmap #MAP_BUFFER_END-MAP_BUFFER_START
		sbw curmapname #MAP_02_NAME-MAP_01_NAME
		nop
		#if .word curmapname = #MAP_01_NAME-(MAP_02_NAME-MAP_01_NAME)
			adw curmap #MAP_BUFFER_END-MAP_BUFFER_START
			adw curmapname #MAP_02_NAME-MAP_01_NAME
		#end
		jsr paint_level_number
		rts
		
flip_amygdala_speed
		lda delayer
		and #AMYGDALFLIPDEL
		cmp #AMYGDALFLIPDEL
		bne @+
		inc instafall
		jsr paint_amygdala_speed
@		rts

paint_amygdala_speed
		lda instafall
		and #%00000001
		beq @+
		mwa #amygdala_speed_text_01 ptr3
		jmp pas_0
@		mwa #amygdala_speed_text_02 ptr3
pas_0
		ldy #0
@		lda (ptr3),y
		sta SCRMEM+(TITLE_AMYGDALA_SPEED-TITLE_PART_1),y
		iny
		cpy #AMYGDALA_SPEED_TEXT_01_END-AMYGDALA_SPEED_TEXT_01
		bne @-
		rts

os_gone
		jsr synchro
		sei
		lda #0
		sta NMIEN
		lda #$fe
		sta PORTB
		rts

os_back
		jsr synchro
		lda #$ff
		sta PORTB
		lda #$40
		sta NMIEN
		cli
		rts

STOP_MUSIC
		jsr RASTERMUSICTRACKER+9
		rts

INIT_MUSIC
		phr
		dec rmt_player_halt
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

AMYGDALA_SPEED_TEXT_01
		dta d'WARTKO'*
AMYGDALA_SPEED_TEXT_01_END
AMYGDALA_SPEED_TEXT_02
		dta d'OSPALE'*


.align		$100
DLGAME
:3			dta b($70)
			dta b($47)
			dta a(SCRMEM)
:MAPSIZE-1	dta	b($07)
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

COLOR_1_INSTRUCTION_TEXT
	dta b($bd), b($dd)
COLOR_2_INSTRUCTION_TEXT
	dta b($50), b($60)
LOGO_COLOR_1
	dta b($0A), b($1A)
LOGO_COLOR_2
	dta b($10), b($20)
LOGO_COLOR_3
	dta b($70), b($80)
INTERMISSION_COLOR_1
	dta b($54), b($64)
INTERMISSION_COLOR_2
	dta b($5a), b($6a)
INTERMISSION_COLOR_3
	dta b($58), b($68)
INTERMISSION_COLOR_4
	dta b($54), b($64)
INTERMISSION_COLOR_5
	dta b($eb), b($fb)
INTERMISSION_COLOR_6
	dta b($85), b($95)
INTERMISSION_COLOR_7
	dta b($b5), b($c5)
INTERMISSION_COLOR_8
	dta b($b9), b($c9)
INTERMISSION_COLOR_9
	dta b($eb-2), b($fb-2)
INTERMISSION_COLOR_10
	dta b($eb-4), b($fb-4)
INTERMISSION_COLOR_11
	dta b($eb-6), b($fb-6)
MARGIN_COLOR
	dta b($90), b($90)
FINAL_SCREEN_COLOR_1
	dta b($16), b($26) ; wlosy
FINAL_SCREEN_COLOR_2
	dta b($36), b($46) ; serce
FINAL_SCREEN_COLOR_3
	dta b($fa), b($2b) ; kielich
PLAYER_COLOR
	dta b(C_PLAYR), b(C_PLAYR+$10)
WALL_1_COLOR
	dta b(C_WALL2), b(C_WALL2+$10) ; Margin color depends on this guy :-/
OBSTACLE_COLOR
	dta b(C_OBSTA), b(C_OBSTA+$10)
WALL_2_COLOR
	dta b(C_WALL1), b(C_WALL1+$10)

; Sprites
.align		$1000
pmg_base
:1024 dta b(0)
pmg_m0			equ pmg_base+$180
pmg_p0			equ pmg_base+$200
pmg_p1			equ pmg_base+$280
pmg_p2			equ pmg_base+$300
pmg_p3			equ pmg_base+$380

; TODO[RC]: Do this w/o dta b(0)
SCRMEM
:SCWIDTH*MAPSIZE	dta b(0)
SCRMEM_BUFFER
:SCWIDTH*MAPSIZE	dta b(0)
SCRMEM_BACKUP
:SCWIDTH*MAPSIZE	dta b(0)

.align	$400
FONT_SLOT_1
FONT_SLOT_2 equ FONT_SLOT_1+1024
FONT_SLOT_END equ FONT_SLOT_2+1024

; CODE HERE UNTIL ($8CE0-1)
		
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
MAP_LAST

SCREEN_MARGIN_DATA
		ins "data\ekran.dat"
SCREEN_MARGIN_DATA_END
music_start_table
	dta b($00),b($1e),b($6c),b($45),b($5d),b($74),b($57),b($91) ; $5d

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
		ldy ntsc
		lda INTERMISSION_COLOR_9,y
		tay
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
		ldy ntsc
		lda INTERMISSION_COLOR_10,y
		tay
		sta WSYNC
		sty COLOR0
		ldy ntsc
		lda INTERMISSION_COLOR_11,y
		tay
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
FOURTY_EMPTY_CHARS
:40	dta b(0)
	
.proc disable_antic
				lda SDMCTL
				sta antic_tmp
				lda #$00
				sta SDMCTL
				lda 20
@				cmp 20
				beq @-
				lda #%01000000
				sta NMIEN
				rts
.endp

; Enables ANTIC and DLI
.proc enable_antic
				lda antic_tmp
				sta SDMCTL
				lda #%11000000
				sta NMIEN
				rts
.endp

ROTATE_LUT_BEGIN
.rept 9 #
	icl "include\rotate_lut\left\rotate_left_frame_:1.txt"
.endr
.rept 9 #
	icl "include\rotate_lut\right\rotate_right_frame_:1.txt"
.endr
ROTATE_LUT_END
ROTATE_LUT_SIZE	equ ROTATE_LUT_END-ROTATE_LUT_BEGIN

	org curmap
	dta a(MAP_BUFFER_START)
	org curmapname
	dta a(MAP_01_NAME)
	org first_run
	dta b(0)
	org instafall
	dta b(1)
	org $4777
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
; - 			Remove $(ff) from _TO in rotation LUT