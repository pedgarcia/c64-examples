;==============================================================
; Example 6-1
; Opening left and right borders
;==============================================================

		!cpu 6502
		!to "build/example6-1.prg",cbm

		* = $1000

		sei		; disable interrupts

		lda #$35
		sta $01		; page out kernal and basic

;--------------------------------------------------------------
; CONFIGURE IRQs
;--------------------------------------------------------------

		lda #%01111111
		sta $dc0d	; turn off CIA1 interrupts
		sta $dd0d	; turn off CIA2 interrupts
		lda #%00000001
		sta $d01a	; turn on raster interrupts

		lda #<irqfirst
		sta $fffe
		lda #>irqfirst
		sta $ffff	; install raster IRQ address

		;lda #$1b
		;sta $d011	; high bit (lines 256-311)
		;lda #$34
		;sta $d012	; line 308

		lda #$1a
		sta $d011
		lda #$00
		sta $d012

		asl $d019	; ack previous IRQs

		cli		; re-enable interrupts



;--------------------------------------------------------------
; MAIN LOOP
;--------------------------------------------------------------

loop
		jmp loop	; endless loop



;--------------------------------------------------------------
; RASTER IRQ
;--------------------------------------------------------------

irqfirst	; syncronization IRQ
		; cycles: 7 for the IRQ handler + 2-7 jittering
		sta pushregs+1	; 4 cycles
		stx pushregs+3	; 4 cycles
		sty pushregs+5	; 4 cycles
		
		tsx		; 2 cycles
		ldy $d012	; 4 cycles

		; cycles: 27 - 32
		lda #<irqsecond	; 2 cycles
		sta $fffe	; 4 cycles
		lda #>irqsecond	; 2 cycles
		sta $ffff	; 4 cycles
		inc $d012	; 6 cycles

		asl $d019	; 6 cycles
		cli		; 2 cycles

		; cycles: 53 - 58
		nop		; nop's (2 cycles), until next
		nop		; IRQ is triggered, it will
		nop		; have 0-1 cycles of jitter
		nop
		nop
		nop		; cycles: 65 - 69


irqsecond	; almost 100% stable IRQ
		; cycles: 7 for the IRQ handler + 0-1 jittering
		txs		; recover the stack (2 cycles)
		cpy $d012	; 4 cycles
		beq irqstable	; 2 cycles, 3 if branch taken
				; add one cycle if $d012 wasn't
				; incremented (jitter = 0)
irqstable	

		inc $d021
		dec $d021

		lda #<irqfirst
		sta $fffe
		lda #>irqfirst
		sta $ffff
		inc $d012

pushregs	lda #$00
		ldx #$00
		ldy #$00

		;asl $d019	; ack IRQs
		rti		; return from IRQ