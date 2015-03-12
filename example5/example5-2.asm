;==============================================================
; Example 5-2
; Opening top and bottom borders
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
		lda #<raster25
		sta $0314
		lda #>raster25
		sta $0315
		lda #$13
		sta $d011	; 24 row mode, trick the VIC into
				; thinking that it has already started
				; drawing the border, so it never
				; starts drawing it.
		lda #$fc
		sta $d012	; irq on line 252 
		asl $d019	; ack interrupt, re-enables it
		pla
		tay
		pla
		tax
		pla
		rti

raster25
		lda #<rasterirq
		sta $0314
		lda #>rasterirq
		sta $0315
		lda #$1a
		sta $d011	; lines 1-255, 25 row mode
		lda #$fa
		sta $d012	; irq on line 250
		asl $d019	; ack interrupt, re-enables it
		pla
		tay
		pla
		tax
		pla
		rti