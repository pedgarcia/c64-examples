;============================================================
; Example 3-1
; Moving a sprite
;============================================================

		!cpu 6502
		!to "build/example3-1.prg",cbm

		* = $1000

		lda #$01
		sta $d015	; turn sprite 0 on
		sta $d027	; make it white
		lda #$40
		sta $d000
		sta $d001	; set x and y coordinates to 40

loop:
		lda $d012
		cmp #$ff
		bne loop	; wait until raster line $ff

		lda dir		; check moving direction
		beq down	; if 0, down

up:
		ldx coord
		dex
		stx coord	; decrement coordinates
		stx $d000
		stx $d001
		cpx #$40	; change dir when coordinate is 40
		bne loop
		lda #$00
		sta dir
		jmp loop

down:
		ldx coord
		inx
		stx coord
		stx $d000
		stx $d001
		cpx #$e0
		bne loop
		lda #$01
		sta dir
		jmp loop

coord:
		!byte $40	; current x and y coordinates

dir:
		!byte $00	; current direction
				; 0 = down-right
				; 1 = up-left