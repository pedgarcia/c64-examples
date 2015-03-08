;============================================================
; Example 2-2
; Playing with raster bars
;============================================================

		!cpu 6502
		!to "build/example2-2.prg",cbm

		* = $1000

		sei		; turn off interrupts
		lda #$7f
		sta $dc0d	; turn off CIA1 interrupts
		sta $dd0d	; turn off CIA2 interrupts
		lda #$01
		sta $d01a	; turn on raster interrupts

		ldx #<rasterirq
		ldy #>rasterirq
		stx $0314	; store interrupt handler address
		sty $0315

		lda #$1b
		sta $d011
		lda #$9b
		sta $d012	; interrupt on raster line 155

		lda $dc0d	; ACK CIA1 interrupts
		lda $dd0d	; ACK CIA2 interrupts
		asl $d019	; ACK VIC interrupts
		cli		; re-enable interrupts



loop:
		jmp loop	;infinite loop



rasterirq:
		lda $d020	; save border color
		ldx $d021	; save screen color

		ldy #$07
rasterwait:
		dey
		bne rasterwait	; manually "stabilize" raster

		stx $d020
		sta $d021

		ldy #$80
 
rasterwait2:
		dey
		bne rasterwait2	; waste cycles

		sta $d020	; restore border color
		stx $d021	; restore screen color

		asl $d019	; reenable raster interrupt

		pla		; restore registers from the stack
		tay
		pla
		tax
		pla
		rti		; return from interrupt