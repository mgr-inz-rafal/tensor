WSYNC   equ $D40A
CH      equ $02FC
PAL     equ $D014
VCOUNT  equ	$D40B

        org $2000

.zpvar  ptr0            .word
.zpvar  ptr1            .word
.zpvar  ptr2            .word

LOOP
        lda #$ff
        sta CH
        jsr synchro

        jsr SHOW_BUF

        lda CH
        cmp #33 ; Space

        bne LOOP

        jsr SUM_RECORDS

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

FIND_START_VALUE
        ldx #0
        mwa #HIGH_SCORE_TABLE ptr0
        mwa #MUL9999_LUT ptr1
        ldy #2
FSV_AGAIN        
        lda (ptr0),y
        cmp #$ff
        bne PROCESS_NEXT_ROW
        inx 
PROCESS_NEXT_ROW
        adw ptr0 #(HIGH_SCORE_RECORD_END-HIGH_SCORE_RECORD_BEGIN)
        nop
        #if .word ptr0 = #HIGH_SCORE_TABLE_TRUE_END
                rts
        #end
        jmp FSV_AGAIN

APPLY_START_VALUE
        mwa #MUL9999_LUT ptr0
ASV_LOOP        
        cpx #0
        beq ASV_GOT_BASE
        adw ptr0 #(MUL9999_LUT_ROW_END-MUL9999_LUT)
        dex
        jmp ASV_LOOP
ASV_GOT_BASE
        ldy #0
ASV_LOOP2        
        lda (ptr0),y
        sta NUMBUF,y
        iny
        cpy #6
        bne ASV_LOOP2
        rts

SUM_RECORDS
        jsr FIND_START_VALUE
        jsr APPLY_START_VALUE

        mwa #HIGH_SCORE_TABLE ptr0
SUM_RECORDS_CONTINUE_WITH_NEXT_ROW
        ldy #2
        lda (ptr0),y
        cmp #$ff
        beq SUM_RECORDS_FINISHED_ADDING_ROW
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
                jmp SUM_RECORDS_FINISHED_ADDING_ROW
        #end
        jmp SUM_RECORDS_LOOP

SUM_RECORDS_FINISHED_ADDING_ROW
        adw ptr0 #(HIGH_SCORE_RECORD_END-HIGH_SCORE_RECORD_BEGIN)
        nop
        #if .word ptr0 = #HIGH_SCORE_TABLE_TRUE_END
                rts
        #end
        jmp SUM_RECORDS_CONTINUE_WITH_NEXT_ROW

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

MUL9999_LUT
        dta b(0),b(0),b(0),b(0),b(0),b(0)  ; *0
MUL9999_LUT_ROW_END        
        dta b(0),b(0),b(9),b(9),b(9),b(9)  ; *1
        dta b(0),b(1),b(9),b(9),b(9),b(8)  ; *2
        dta b(0),b(2),b(9),b(9),b(9),b(7)  ; *3
        dta b(0),b(3),b(9),b(9),b(9),b(6)  ; *4
        dta b(0),b(4),b(9),b(9),b(9),b(5)  ; *5
        dta b(0),b(5),b(9),b(9),b(9),b(4)  ; *6
        dta b(0),b(6),b(9),b(9),b(9),b(3)  ; *7
        dta b(0),b(7),b(9),b(9),b(9),b(2)  ; *8
        dta b(0),b(8),b(9),b(9),b(9),b(1)  ; *9
        dta b(0),b(9),b(9),b(9),b(9),b(0)  ; *10
        dta b(1),b(0),b(9),b(9),b(8),b(9)  ; *11
        dta b(1),b(1),b(9),b(9),b(8),b(8)  ; *12
        dta b(1),b(2),b(9),b(9),b(8),b(7)  ; *13
        dta b(1),b(3),b(9),b(9),b(8),b(6)  ; *14
        dta b(1),b(4),b(9),b(9),b(8),b(5)  ; *15
        dta b(1),b(5),b(9),b(9),b(8),b(4)  ; *16
        dta b(1),b(6),b(9),b(9),b(8),b(3)  ; *17
        dta b(1),b(7),b(9),b(9),b(8),b(2)  ; *18
        dta b(1),b(8),b(9),b(9),b(8),b(1)  ; *19
        dta b(1),b(9),b(9),b(9),b(8),b(0)  ; *20
        dta b(2),b(0),b(9),b(9),b(7),b(9)  ; *21
        dta b(2),b(1),b(9),b(9),b(7),b(8)  ; *22
        dta b(2),b(2),b(9),b(9),b(7),b(7)  ; *23
        dta b(2),b(3),b(9),b(9),b(7),b(6)  ; *24
        dta b(2),b(4),b(9),b(9),b(7),b(5)  ; *25
        dta b(2),b(5),b(9),b(9),b(7),b(4)  ; *26
        dta b(2),b(6),b(9),b(9),b(7),b(3)  ; *27
        dta b(2),b(7),b(9),b(9),b(7),b(2)  ; *28
        dta b(2),b(8),b(9),b(9),b(7),b(1)  ; *29
        dta b(2),b(9),b(9),b(9),b(7),b(0)  ; *30
        dta b(3),b(0),b(9),b(9),b(6),b(9)  ; *31
        dta b(3),b(1),b(9),b(9),b(6),b(8)  ; *32
        dta b(3),b(2),b(9),b(9),b(6),b(7)  ; *33
        dta b(3),b(3),b(9),b(9),b(6),b(6)  ; *34
        dta b(3),b(4),b(9),b(9),b(6),b(5)  ; *35
        dta b(3),b(5),b(9),b(9),b(6),b(4)  ; *36
        dta b(3),b(6),b(9),b(9),b(6),b(3)  ; *37
        dta b(3),b(7),b(9),b(9),b(6),b(2)  ; *38
        dta b(3),b(8),b(9),b(9),b(6),b(1)  ; *39
        dta b(3),b(9),b(9),b(9),b(6),b(0)  ; *40
        dta b(4),b(0),b(9),b(9),b(5),b(9)  ; *41
        dta b(4),b(1),b(9),b(9),b(5),b(8)  ; *42
        dta b(4),b(2),b(9),b(9),b(5),b(7)  ; *43
        dta b(4),b(3),b(9),b(9),b(5),b(6)  ; *44
        dta b(4),b(4),b(9),b(9),b(5),b(5)  ; *45
        dta b(4),b(5),b(9),b(9),b(5),b(4)  ; *46
        dta b(4),b(6),b(9),b(9),b(5),b(3)  ; *47
        dta b(4),b(7),b(9),b(9),b(5),b(2)  ; *48
        dta b(4),b(8),b(9),b(9),b(5),b(1)  ; *49
        dta b(4),b(9),b(9),b(9),b(5),b(0)  ; *50
        dta b(5),b(0),b(9),b(9),b(4),b(9)  ; *51
        dta b(5),b(1),b(9),b(9),b(4),b(8)  ; *52
        dta b(5),b(2),b(9),b(9),b(4),b(7)  ; *53
        dta b(5),b(3),b(9),b(9),b(4),b(6)  ; *54


HIGH_SCORE_TABLE	; Can be moved under OS
HIGH_SCORE_RECORD_BEGIN
                   dta b($00),b($01),b($aa),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
HIGH_SCORE_RECORD_END
                   dta b($00),b($02),b($aa),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
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
                   dta b($12),b($34),b($aa),b('j'),b('e'),b('b'),b('a'),b('c'),b(' '),b('p'),b('i'),b('s')
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
