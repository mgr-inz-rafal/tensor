WSYNC   equ $D40A
CH      equ $02FC
PAL     equ $D014
VCOUNT  equ	$D40B

        org $2000

.zpvar  ptr0            .word
.zpvar  ptr1            .word

LOOP
        lda #$ff
        sta CH
        jsr synchro

        jsr SHOW_BUF

        lda CH
        cmp #33 ; Space

        bne LOOP

        jsr SUM_RECORDS
        ;jsr SUM_RECORDS_ADD_9999
        jsr SHOW_BUF

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

SUM_RECORDS
        mwa #HIGH_SCORE_TABLE ptr0
SUM_RECORDS_CONTINUE_WITH_NEXT_ROW
;        ldy #2
;        lda (ptr0),y
;        cmp #$ff
;        beq SUM_RECORDS_ADD_9999
        ldy #0
        lda (ptr0),y
        sta ptr1+1
        iny
        lda (ptr0),y
        sta ptr1

        ; ptr1 now contains the number of times we need to call INCREMENT
SUM_RECORDS_LOOP
        jsr INCREMENT
        sed
        sec
        lda ptr1
        sbc #<1
        sta ptr1
        lda ptr1+1
        sbc #>1
        sta ptr1+1
        cld
        #if .word ptr1 == #0
                jmp SUM_RECORDS_NEXT_ROW
        #end
        jmp SUM_RECORDS_LOOP
SUM_RECORDS_NEXT_ROW
        adw ptr0 #(HIGH_SCORE_RECORD_END-HIGH_SCORE_RECORD_BEGIN)
        nop        
        #if .word ptr0 = #HIGH_SCORE_TABLE_TRUE_END
SUM_RECORDS_EXIT
                rts
        #end
        jmp SUM_RECORDS_CONTINUE_WITH_NEXT_ROW
SUM_RECORDS_ADD_9999
        ldy #1
        lda NUMBUF,y
        add #1
        sta NUMBUF,y
        cmp #26-16
        bne SUM_RECORDS_EXIT
        lda #0
        sta NUMBUF,y
        dey
        lda NUMBUF,y
        add #1
        sta NUMBUF,y
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
        rts
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
        dta b(0)
        dta b(0)
        dta b(0)
        dta b(0)
        dta b(0)
        dta b(0)

HIGH_SCORE_TABLE	; Can be moved under OS
HIGH_SCORE_RECORD_BEGIN
                   dta b($00),b($01),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
HIGH_SCORE_RECORD_END
                   dta b($00),b($02),b($ff),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
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
HIGH_SCORE_TABLE_TRUE_END
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
        