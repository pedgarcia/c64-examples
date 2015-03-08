;============================================================
; Example 3-4
; Printing characters and modifying character set
;============================================================

		!cpu 6502
		!to "build/example3-4.prg",cbm

		* = $1000

;--------------------------------------------------------------
; SETUP SCREEN
;--------------------------------------------------------------

		lda #$20	; black
		sta $d020	; set border background color
		sta $d021	; set screen background color

		lda #$20	; space character in PETSCII
		ldx #$fa

clrscreen:			; screen data is $03e8 bytes long
		sta $0400,x
		sta $04fa,x
		sta $05f4,x
		sta $06ee,x
		dex
		bne clrscreen

		lda #$18
		sta $d018	; screen at $0400, chars at $2000



; -----------------------------------------------------------
; SETUP CHARACTERS
; -----------------------------------------------------------

		lda #$ff
		ldx #$08
clrchar:			; empty character $01 data
		sta $2007,x
		dex
		bne clrchar



		lda #$01
		ldx #$28
drwchar:			; fill first line with char $01
		sta $03ff,x
		dex
		bne drwchar



; -----------------------------------------------------------
; MAIN LOOP
; -----------------------------------------------------------

loop:
		lda $d012
		cmp #$ff
		bne loop	; wait until raster line $ff

		ldx counter
		inx
		cpx #$08
		bmi incchar	; change one char line
		cpx #$20
		bne endincchar	; don't change chars for some cycles
		ldx #$00

incchar:			
		stx counter
		lda $2008,x
		eor #$ff	; invert line values (A OR $ff)
		sta $2008,x
endincchar:
		stx counter
		jmp loop

counter:
		!byte $ff
