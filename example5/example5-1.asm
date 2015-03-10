;==============================================================
; Example 5-1
; Horizontal scrolling text. Also, testing self modifying code
;==============================================================

		!cpu 6502
		!to "build/example5-1.prg",cbm

		* = $1000

		sei		; disable interrupts

		lda #$35
		sta $01		; swap out KERNAL



;--------------------------------------------------------------
; CLEAR SCREEN AND PRINT TEXT
;--------------------------------------------------------------
		
		;lda #$18
		;sta $d018	; screen at $0400, chars at $2000

		lda #$20
		ldx #$fa
clrscreen	sta $0400,x
		sta $04fa,x
		sta $05f4,x
		sta $06ee,x
		dex
		bne clrscreen	; screen data is $03e8 bytes long



		ldx #messagelength
prnttext	lda message-1,x
		sta firstposition-1,x
		dex
		bne prnttext



;--------------------------------------------------------------
; CONFIGURE RASTER IRQ
;--------------------------------------------------------------

		lda #%01111111
		sta $dc0d	; turn off CIA1 interrupts
		sta $dd0d	; turn off CIA2 interrupts
		lda #%00000001
		sta $d01a	; turn on raster interrupts

		lda #<scrollirq
		sta $fffe	; high byte of IRQ address
		lda #>scrollirq
		sta $ffff	; low byte of IRQ address

		lda #$1b
		sta $d011	; low bit (lines 0 - 255)
		lda #$92
		sta $d012	; trigger irq on line 146

		cli		; reenable interrupts


;--------------------------------------------------------------
; MAIN LOOP
;--------------------------------------------------------------

mainloop	jmp mainloop	; wait for IRQ



;--------------------------------------------------------------
; RASTER IRQ
;--------------------------------------------------------------

scrollirq	stx endirq+1
irqdelay	ldx #$08
		dex
		stx irqdelay+1
		bne endirq
		ldx #$08
		stx irqdelay+1

		sta pushregs+1
		sty pushregs+3

scrolloffset	ldx #$00	; scroll offset, self modified
		ldy #horzscrolldir
		bne scrollleft



scrollright	inx
		bne setscroll

		lda #$00
		jmp setscroll2



scrollleft	dex
		bne setscroll

		lda #$00
		jmp setscroll2



setscroll	txa
		and #$07	; mask offset, max value is $07
setscroll2	sta scrolloffset+1

		lda $d016
		and #%11111000	; last 3 bits are offset
		adc scrolloffset+1
		sta $d016

pushregs	lda #$00
		ldy #$00
endirq		ldx #$00
		asl $d019
		rti


;--------------------------------------------------------------
; DATA AND VARIABLES
;--------------------------------------------------------------
message		!scr "horizontal scrolling text"

		messagelength =	$19
		firstposition = $05e5
		lastposition  = $05ef
		horzscrolldir = $00