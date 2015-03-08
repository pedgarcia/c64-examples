;============================================================
; Example 1-3
; Cycling screen colors
;============================================================

		!cpu 6502
		!to "build/example1-3.prg",cbm

		* = $1000

loop:
		lda $d012	; load $d012 value into A register
				; $d012 is the current raster line
		cmp #$00	; compare it to #$00
		bne loop	; if not equal, keep checking
		inc $d021	; change screen color
		jmp loop	; repeat