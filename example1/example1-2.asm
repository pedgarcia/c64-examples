;============================================================
; Example 1-2
; Flashing the border and the screen
;============================================================

		!cpu 6502
		!to "build/example1-2.prg",cbm

		* = $1000

loop:
		inc $d020	; increment value stored at $d020
		inc $d021	; increment value stored at $d021
				; $d021 is the screen color
		jmp loop	; unconditional jump to loop label