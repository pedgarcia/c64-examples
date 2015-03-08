;============================================================
; Example 3-2
; Moving a sprite with an interrupt
;============================================================

		!cpu 6502
		!to "build/example3-2.prg",cbm

		* = $1000

		sei		; turn off interrupts
		lda #%01111111
		ldx #%00000001
		sta $dc0d	; turn off CIA1 interrupts
		sta $dd0d	; turn off CIA2 interrupts
		stx $d01a	; turn on raster interrupts

		lda #<rasterirq
		ldx #>rasterirq
		sta $0314
		stx $0315	; store interrupt handler address

		lda #$1b
		sta $d011
		lda #$ff
		sta $d012	; interrupt on raster line ff

		lda #$01
		sta $d015	; turn sprite 0 on
		sta $d027	; make it white
		lda #$40
		sta $d000
		sta $d001	; set x and y coordinates to 40

		cli		; re-enable interrupts

loop:
		jmp loop	; infinite loop

coord:
		!byte $40	; current x and y coordinates

dir:
		!byte $00	; current direction
				; 0 = down-right
				; 1 = up-left

rasterirq:
		ldx coord
		lda dir		; check direction
		beq down	; if 0, down

up:
		dex
		cpx #$40	; change dir when coordinate is $40
		bne setxysprite
		lda #$00
		sta dir
		jmp setxysprite 


down:
		inx
		cpx #$e0	; change dir when coordinate is $e0
		bne setxysprite
		lda #$01
		sta dir
		jmp setxysprite

setxysprite:
		stx coord
		stx $d000
		stx $d001

		asl $d019	; re-enable raster interrupt
		pla		; restore registers from the stack
		tay
		pla
		tax
		pla
		rti		; return from interrupt