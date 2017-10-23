/***************************************/
/*  Use MADS http://mads.atari8.info/  */
/*  Mode: DLI (char mode)              */
/***************************************/

	icl "title_1.h"
	
MODUL 		equ 6000
MUSICPLAYER	equ 8000

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
ant	dta $70,$70
	dta $44,a(scr)
	dta $04,$84,$04,$84,$84,$04,$84,$04,$04,$84,$84,$04,$84,$04
	dta $04,$84,$04,$04,$84,$04,$84,$84,$04,$04
	dta $41,a(ant)

scr	ins "title_1.src"+0,+80,+25*40

	.ds 0*40

	.ALIGN $0400
fnt	ins "title_1.fnt"

	ift USESPRITES
	.ALIGN $0800
pmg	.ds $0300
	ift FADECHR = 0
	SPRITES
	els
	.ds $500
	eif
	eif

synchro
		lda PAL
		cmp #1
		bne synchr1
		lda #145	; PAL
		jmp synchr2
synchr1 lda #120	; NTSC
synchr2	cmp VCOUNT
		bne synchr2
		rts

main
; ---	init PMG

	lda #00
	ldx #$00
	ldy #$60
	jsr RASTERMUSICTRACKER	;Init
	
	ift USESPRITES
	mva >pmg pmbase		;missiles and players data address
	mva #$03 pmcntl		;enable players and missiles
	eif

	lda:cmp:req $14		;wait 1 frame

	sei			;stop IRQ interrupts
	mva #$00 nmien		;stop NMI interrupts
	sta dmactl
	mva #$fe portb		;switch off ROM to get 16k more ram

	mwa #NMI $fffa		;new NMI handler

	mva #$c0 nmien		;switch on NMI+DLI again

	ift CHANGES		;if label CHANGES defined

_lp	lda trig0		; FIRE #0
	beq stop

	lda trig1		; FIRE #1
	beq stop

	lda consol		; START
	and #1
	beq stop

	lda skctl
	and #$04
	bne _lp			;wait to press any key; here you can put any own routine

	els

null	jmp DLI.dli1		;CPU is busy here, so no more routines allowed

	eif


stop
	jsr RASTERMUSICTRACKER+9 ; Stop music
	mva #$00 pmcntl		;PMG disabled
	tax
	sta:rne hposp0,x+

	mva #$ff portb		;ROM switch on
	mva #$40 nmien		;only NMI interrupts, DLI disabled
	cli			;IRQ enabled

	rts			;return to ... DOS

; ---	DLI PROGRAM

.local	DLI

	?old_dli = *

	ift !CHANGES

dli1	lda trig0		; FIRE #0
	beq stop

	lda trig1		; FIRE #1
	beq stop

	lda consol		; START
	and #1
	beq stop

	lda skctl
	and #$04
	beq stop

	lda vcount
	cmp #$02
	bne dli1

	:3 sta wsync

	DLINEW dli12

	eif

dli_start

dli12
	sta regA

c9	lda #$16
	sta wsync		;line=40
	sta color3
	DLINEW DLI.dli2 1 0 0

dli2
	sta regA
	lda >fnt+$400*$01
	sta wsync		;line=56
	sta chbase
	DLINEW dli13 1 0 0

dli13
	sta regA

c10	lda #$38
	sta wsync		;line=64
	sta color3
c11	lda #$34
	sta wsync		;line=65
	sta colpm2
	sta wsync		;line=66
	sta wsync		;line=67
	sta wsync		;line=68
	sta wsync		;line=69
	sta wsync		;line=70
x8	lda #$8D
	sta wsync		;line=71
	sta hposp3
	sta wsync		;line=72
	sta wsync		;line=73
	sta wsync		;line=74
	sta wsync		;line=75
x9	lda #$7B
	sta wsync		;line=76
	sta hposp1
	DLINEW dli3 1 0 0

dli3
	sta regA
	stx regX
	sty regY
	lda >fnt+$400*$02
	sta wsync		;line=80
	sta chbase
	sta wsync		;line=81
s3	lda #$01
x10	ldx #$74
	sta wsync		;line=82
	sta sizep1
	stx hposp1
	sta wsync		;line=83
	sta wsync		;line=84
	sta wsync		;line=85
	sta wsync		;line=86
x11	lda #$6E
x12	ldx #$A6
c12	ldy #$16
	sta wsync		;line=87
	sta hposp1
	stx hposm0
	sty colpm0
	sta wsync		;line=88
x13	lda #$46
	sta wsync		;line=89
	sta hposm1
	sta wsync		;line=90
	sta wsync		;line=91
	sta wsync		;line=92
s4	lda #$00
x14	ldx #$40
c13	ldy #$0A
	sta wsync		;line=93
	sta sizep3
	stx hposp3
	sty colpm3
	sta wsync		;line=94
x15	lda #$6D
	sta wsync		;line=95
	sta hposp1
c14	lda #$86
	sta wsync		;line=96
	sta color3
c15	lda #$9A
x16	ldx #$A2
c16	ldy #$F4
	sta wsync		;line=97
	sta color1
	stx hposp2
	sty colpm2
s5	lda #$00
x17	ldx #$3E
c17	ldy #$38
	sta wsync		;line=98
	sta sizep1
	stx hposp1
	sty colpm1
	DLINEW dli4 1 1 1

dli4
	sta regA
	stx regX
	sty regY
	lda >fnt+$400*$03
	sta wsync		;line=104
	sta chbase
	sta wsync		;line=105
	sta wsync		;line=106
	sta wsync		;line=107
	sta wsync		;line=108
s6	lda #$03
x18	ldx #$88
c18	ldy #$8A
	sta wsync		;line=109
	sta sizep1
	stx hposp1
	sty colpm1
	DLINEW dli14 1 1 1

dli14
	sta regA

x19	lda #$86
	sta wsync		;line=112
	sta hposp1
x20	lda #$A7
	sta wsync		;line=113
	sta hposm0
x21	lda #$83
	sta wsync		;line=114
	sta hposp1
	sta wsync		;line=115
	sta wsync		;line=116
x22	lda #$81
	sta wsync		;line=117
	sta hposp1
	DLINEW dli5 1 0 0

dli5
	sta regA
	lda >fnt+$400*$04
	sta wsync		;line=128
	sta chbase
	sta wsync		;line=129
	sta wsync		;line=130
	sta wsync		;line=131
	sta wsync		;line=132
	sta wsync		;line=133
c19	lda #$8A
	sta wsync		;line=134
	sta color1
	DLINEW dli6 1 0 0

dli6
	sta regA
	lda >fnt+$400*$05
	sta wsync		;line=152
	sta chbase
	sta wsync		;line=153
	sta wsync		;line=154
	sta wsync		;line=155
x23	lda #$91
	sta wsync		;line=156
	sta hposp0
	DLINEW dli7 1 0 0

dli7
	sta regA
	lda >fnt+$400*$06
	sta wsync		;line=176
	sta chbase
	DLINEW dli15 1 0 0

dli15
	sta regA

	sta wsync		;line=192
x24	lda #$8E
	sta wsync		;line=193
	sta hposp2
	sta wsync		;line=194
	sta wsync		;line=195
c20	lda #$A6
	sta wsync		;line=196
	sta color3
x25	lda #$8F
	sta wsync		;line=197
	sta hposp2
	DLINEW dli8 1 0 0

dli8
	sta regA
	stx regX
	lda >fnt+$400*$07
x26	ldx #$99
	sta wsync		;line=200
	sta chbase
	stx hposm0
x27	lda #$99
	sta wsync		;line=201
	sta hposm2
x28	lda #$91
	sta wsync		;line=202
	sta hposp2
	lda regA
	rti


.endl

; ---

CHANGES = 1
FADECHR	= 0

SCHR	= 127

; ---

.proc	NMI

	bit nmist
	bpl VBL

	jmp DLI.dli_start
dliv	equ *-2

VBL
	sta regA
	stx regX
	sty regY

	sta nmist		;reset NMI flag

	mwa #ant dlptr		;ANTIC address program

	mva #@dmactl(standard|dma|lineX1|players|missiles) dmactl	;set new screen width

	inc cloc		;little timer

; Initial values

	lda >fnt+$400*$00
	sta chbase
c0	lda #$00
	sta colbak
	sta sizem
	sta sizep0
	sta sizep1
	sta sizep2

c1	lda #$04
	sta color0
c2	lda #$0A
	sta color1
c3	lda #$96
	sta color2
c4	lda #$A6
	sta color3
	lda #$02
	sta chrctl
	lda #$04
	sta gtictl
x0	lda #$97
	sta hposm2
c5	lda #$38
	sta colpm2
s1	lda #$01
	sta sizep3
x1	lda #$88
	sta hposp0
x2	lda #$7F
	sta hposp1
x3	lda #$65
	sta hposp2
x4	lda #$91
	sta hposp3
x5	lda #$86
	sta hposm0
x6	lda #$83
	sta hposm1
x7	lda #$3F
	sta hposm3
c6	lda #$38
	sta colpm0
c7	lda #$9A
	sta colpm1
c8	lda #$A6
	sta colpm3

	
	mwa #DLI.dli_start dliv	;set the first address of DLI interrupt

;this area is for yours routines
	jsr RASTERMUSICTRACKER+3

quit
	lda regA
	ldx regX
	ldy regY
	rti

.endp

; ---
	run main
; ---

	opt l-

.MACRO	SPRITES
missiles
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 01 00 00 02 00 00 00 02 01 00 00
	.he 00 00 00 00 08 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 4A 03 83 45 02
	.he 41 01 04 09 01 00 01 00 00 00 00 01 01 00 01 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 20 20
	.he 10 20 20 00 10 30 02 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
player0
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 12 10 45 08 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 20 70 E0 D0 A8 54
	.he 2A 1F 0F 06 00 00 01 03 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
player1
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 01
	.he 04 0C 1C 38 03 07 1F 1E 3E 3C 3E 3C 7C FC F8 BE
	.he 3E FC FC D8 F8 F0 E0 F0 F0 00 48 08 A2 10 40 A0
	.he 41 22 11 09 03 C0 E0 F0 F8 FE FF FF DF EF E2 C0
	.he C0 C0 C0 80 80 80 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
player2
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 01 02 1F 00 03 06 04 80 48 28 08
	.he 10 04 0B 04 20 43 02 29 41 81 01 1C CE EE 7D 72
	.he 8C 60 00 00 80 41 36 00 00 00 08 14 10 10 18 14
	.he 18 18 1C 18 08 0C 08 0C 0C 0C 0C 0C 0C 0E 0C 0E
	.he 0E 0C 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 04 0A 70 A3 CB 55 EA
	.he 35 58 B0 59 2E 00 0A 04 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
player3
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	.he 00 00 00 01 02 00 00 00 00 00 00 00 00 10 10 30
	.he 30 28 2C 3C 3E 66 6F 1C 4D 7F 6C DC DE F8 F8 3C
	.he 7C 4C 4E 8C 3C 24 7C 78 28 38 14 18 08 08 06 00
	.he 00 00 00 00 00 00 00 00 00 20 00 10 52 3A 3E 7F
	.he 7B 77 3A 18 00 00 00 00 00 00 00 00 00 00 00 00
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

.MACRO	DLINEW
	mva <:1 NMI.dliv
	ift [>?old_dli]<>[>:1]
	mva >:1 NMI.dliv+1
	eif

	ift :2
	lda regA
	eif

	ift :3
	ldx regX
	eif

	ift :4
	ldy regY
	eif

	rti

	.def ?old_dli = *
.ENDM

		org MODUL
		opt h-
		ins "title_music.rmt"
		opt h+
		
		org MUSICPLAYER
		icl "rmtplayr.a65"
