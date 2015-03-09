;==============================================================
; Example 4-1
; Playing sounds
; SID File: Elle - Leigh White (RazerX)
; Included in HVSC Collection #62
;==============================================================

		!cpu 6502
		!to "build/example4-1.prg",cbm


		* = $1000

		lda #$00
		tax
		tay
		jsr $1800 	; initialize music

loop
		lda $d012
		cmp #$80
		bne loop

		inc $d020
		jsr $1806	; jump to music play routine
		dec $d020	; view cycles wasted by the routine
		jmp loop

		* = $1800 - $7e
		!bin "Elle.sid"
