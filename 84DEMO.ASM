; Demonstration of Microchip 16C84 for BATC.
; Brian Kelly.   14th February 1997

; The next line tells the assembler which type of PIC is being used, the
; default radix (number base) to use unless told otherwise and how many
; columns to use in the program listing before wrapping text to the next line.

	list	p=16C84, r=HEX, c=132

; Define the values to be associated with the register names and bit names
; used later in the program. Whenever one of the names on the left of 'equ'
; is encountered, the assembler substitutes the value on the right. This is
; not essential as the values themselves could be used but using meaningful
; names makes the program far easier to read and understand. Capital letters
; have been used for pre-defined registers, the remainder are used to store
; variables used in the program.

RTCC	equ 	01		;the real time clock/counter register
STATUS	equ	03		;various status and control bits
PORT_B	equ	06		;port B, where the LEDs are connected
INTCON	equ	0B		;bits for configuring the interrupts
OPT_REG	equ	01		;processor options (in register bank 1)
TRIS_B	equ	06		;port B pin direction controls (in bank 1)
pattern		equ	0C	;the on/off pattern of the LEDS
direction	equ	0D	;only bit 0 used to decide left/right

same	equ	1		;put result back where in the source register
w	equ	0		;put result back in the working (W) register
C	equ	0		;bit number of the carry flag in STATUS


; The program counter (PCL), points to the next instruction to read and is
; set to 000H on reset so the first instruction to be executed must be there.
; As the interrupt vector is at address 004H, not leaving much space for code,
; we will start the program with a jump to an area where there is more space.

init
	org 000				;tell assembler to start at 000

	goto start			;the jump mentioned above.

; This is the interrupt routine. A jump to address 004 occurs whenever an
; interrupt is generated. In this 84DEMO program, all the interrupts are
; disabled except for the one caused by the RTCC overflowing (reaching maximum
; count of FFH and rolling over to zero).

demo
	org 004				;move assembler to the interrupt vector

	bcf INTCON,2			;clear the interrupt bit so the chip
					;doesn't immediately generate a new one
					;when interrupts are turned back on.

					;as this point is reached at fixed time
					;intervals, use it to switch LEDs

display
	movf pattern,w			;use working register to carry pattern
	movwf PORT_B			;to port B

	btfss direction,0		;check which direction to shift.
					;skip next instruction if going right
	goto left			;the left shift routine

right
	bcf STATUS,C			;ensure carry=0 before shifting
	rrf pattern,same		;shift the pattern one position right
	btfsc pattern,0			;skip next inst if not fully at right
	bcf direction,0			;fully right so reverse direction
	retfie				;return from interrupt to main program

left
	bcf STATUS,C			;ensure carry=0 before shifting
	rlf pattern,same		;shift the pattern one position left
	btfsc pattern,7			;skip next inst if not fully at left
	bsf direction,0			;fully left so reverse direction
	retfie				;return from interrupt to main program


; This is the part of the program entered when powered up or reset. It
; initialises the processor and puts starting values in some registers. After
; setting everything up it goes into a loop, waiting for interrupts to occur.

start
	movlw B'00100000'		;select register page 1
	movwf STATUS

	clrf TRIS_B			;set all port B pins to output mode

	movlw B'10000111'
	movwf OPT_REG			;sets: 	pull-up on port B OFF
					;	RTCC counts internal clock
					;	prescaler connected to RTCC
					;	prescaler divides by 256
					;	(other bits unimportant)
					; change the "111" to alter sweep speed.

	clrw				;clear the working register
	movwf STATUS			;switch back to register page 0
	movwf direction			;set direction to LEFT (bit 0 = 0)

	movlw B'00000001'		;starting pattern for LEDS
	movwf pattern

	movlw B'10100000'
	movwf INTCON			;sets:	global interrupts enabled
					;	RTIE enabled (RTCC roll over)
					;	(other bits disabled/cleared)

loop
	goto loop			;wait here for interrupts.

	end				;tell assembler there's no more
