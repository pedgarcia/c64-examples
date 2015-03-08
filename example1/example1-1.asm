;============================================================
; Example 1-1
; Flashing the border
;============================================================

		!cpu 6502
		!to "build/example1-1.prg",cbm

		* = $1000

loop:
		inc $d020	; increment value stored at $d020
				; $d020 is the border color
		jmp loop	; unconditional jump to loop label