;============================================================
; Example 3-3
; Clearing screen and moving two sprites
;============================================================

		!cpu 6502
		!to "build/example3-3.prg",cbm

		* = $1000



; -----------------------------------------------------------
; CONFIGURE IRQs
; -----------------------------------------------------------

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
		sta $d012	; interrupt on raster line $ff



; -----------------------------------------------------------
; CLEAR SCREEN
; -----------------------------------------------------------

		lda #$20
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
; SPRITE SETUP
; -----------------------------------------------------------

		lda #%00000011
		sta $d015	; turn sprites 0 & 1 on
		lda #$0e
		sta $d027
		sta $d028	; make them blue
		lda #$40
		sta $d000
		sta $d001	; sprite 0 coordinates: $40/$40
		sta $d002
		lda #$e0
		sta $d003	; sprite 1 coordinates: $40/$e0


		cli		; re-enable interrupts

; -----------------------------------------------------------
; MAIN LOOP
; -----------------------------------------------------------

loop:
		jmp loop	; infinite loop

dir:
		!byte $00	; current direction

; -----------------------------------------------------------
; RASTER IRQ
; -----------------------------------------------------------

rasterirq:
		ldx $d001
		lda dir		; check direction
		beq zero

one:
		dex
		inc $d003
		cpx #$40
		bne endraster
		lda #$00
		sta dir
		jmp endraster

zero:
		inx
		dec $d003
		cpx #$e0
		bne endraster
		lda #$01
		sta dir
		jmp endraster

endraster:
		stx $d000
		stx $d001
		stx $d002

		asl $d019	; re-enable raster interrupt
		pla		; restore registers from the stack
		tay
		pla
		tax
		pla
		rti		; return from interrupt