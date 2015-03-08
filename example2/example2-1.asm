;============================================================
; Example 2-1
; Enabling raster interrupts
;============================================================

		!cpu 6502
		!to "build/example2-1.prg",cbm

		* = $1000

		sei		; turn off interrupts
		lda #$7f
		sta $dc0d	; turn off CIA1 interrupts
		sta $dd0d	; turn off CIA2 interrupts
		lda #$01
		sta $d01a	; turn on raster interrupts

		ldx #<rasterirq	; low nibble of interrupt handler address
		ldy #>rasterirq	; high nibble of interrupt handler address
		stx $0314	; store in interrupt vector
		sty $0315

		lda #$1b
		sta $d011	; clear high bit of $d012
		lda #$00	
		sta $d012	; raster line where interrupt will be triggered

		lda $dc0d	; ACK CIA1 interrupts
		lda $dd0d	; ACK CIA2 interrupts
		asl $d019	; ACK VIC interrupts
		cli		; re-enable interrupts

loop:
		jmp loop	; infinite loop

rasterirq:
		inc $d020	; flash border
		asl $d019	; ACK interrupt to reenable it
		pla		; restore registers from the stack. could
		tay		; be done with jmp $ea81, wasting three cycles
		pla		; for the JMP, but saving 3 bytes of memory
		tax
		pla
		rti		; return from interrupt