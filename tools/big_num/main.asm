WSYNC   equ $D40A
CH      equ $02FC
PAL     equ $D014
VCOUNT  equ	$D40B

        org $2000

LOOP
        lda #$ff
        sta CH
        jsr synchro

        jsr SHOW_BUF

        lda CH
        cmp #33 ; Space

        bne LOOP

        jsr INCREMENT
        jmp LOOP

SHOW_BUF
        ldy #0
SHB_0   lda NUMBUF,y
        add #16
        sta $BC40,y
        iny
        cpy #6
        bne SHB_0
        rts

INCREMENT
        ldy #5
INCREMENT_LOOP
        jsr INCREMENT_NUM
        cpx #1
        bne INCREMENT_EXIT
        dey
        jmp INCREMENT_LOOP
INCREMENT_EXIT        
        rts

INCREMENT_NUM
        lda NUMBUF,y
        add #1
        sta NUMBUF,y
        cmp #26-16
        beq INCREMENT_NUM_OVERFLOW
        ldx #0
        rts
INCREMENT_NUM_OVERFLOW        
        lda #0
        sta NUMBUF,y
        ldx #1
        rts

synchro
		lda PAL
		cmp #1
		beq syn_pal
saas112
		#if .byte VCOUNT >= #117
			rts
		#end
		jmp saas112
		rts
syn_pal
		#if .byte VCOUNT >= #150
			rts
		#end
		jmp syn_pal
		rts


NUMBUF
        dta b(1)
        dta b(2)
        dta b(3)
        dta b(4)
        dta b(5)
        dta b(6)