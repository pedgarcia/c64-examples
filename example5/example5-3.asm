;==============================================================
; Example 5-3
; Opening top and bottom borders with self modifying interrupt
;==============================================================

		!cpu 6502
		!to "border.prg",cbm

		* = $1000



;--------------------------------------------------------------
; CONFIGURE RASTER IRQ
;--------------------------------------------------------------

		sei	 	; disable interrupts

		lda #%01111111
		sta $dc0d	; turn off CIA1 interrupts
		sta $dd0d	; turn off CIA2 interrupts
		lda #%00000001
		sta $d01a	; turn on raster interrupts
		lda #<rasterirq
		sta $0314
		lda #>rasterirq
		sta $0315
		lda #$1a
		sta $d011	; lines 1-255, 25 row mode
		lda #$fa
		sta $d012	; irq on line 250

		cli		; re-enable interrupts



;--------------------------------------------------------------
; MAIN LOOP
;--------------------------------------------------------------

loop
		jmp loop


;--------------------------------------------------------------
; RASTER IRQ
;--------------------------------------------------------------

rasterirq
		lda $d011
		and #$f7	; and #$f7 opcodes: 29 f7
				; ora #$08 opcodes: 09 08
		sta $d011

		lda #$fc
		sta $d012	; irq on line 252 ($fc)
				; then again on line 250 ($fa)

		lda #$20
		eor rasterirq+3
		sta rasterirq+3	; switch and & ora opcodes

		lda #$ff
		eor rasterirq+4
		sta rasterirq+4 ; switch and & ora values

		lda #$06
		eor rasterirq+9
		sta rasterirq+9	; switch raster irq line

		asl $d019	; ack interrupt, re-enables it
		pla
		tay
		pla
		tax
		pla
		rti