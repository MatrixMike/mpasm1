; swrite.asm
; PIC programming, part 2, CQ-TV 191, August 2000
; (c) 2000 by Brian Kelly
;
		list	p=16c84,w=0,r=hex
w		EQU     H'0000'
same		EQU     H'0001'
;----- Register Files------------------------------------------------------
RTCC		EQU     H'0001'
PCL		EQU     H'0002'
STATUS		EQU     H'0003'
PORT_A		EQU     H'0005'
PORT_B		EQU     H'0006'
timeout		EQU     H'000C'
scan_pos		EQU     H'000D'
scan_len		EQU     H'000E'
OPT_REG		EQU     H'0001'			;following registers are in bank 1
TRIS_A		EQU     H'0005'
TRIS_B		EQU     H'0006'
;----- STATUS Register Bits -----------------------------------------------
RP0		EQU     H’0005’
Z		EQU     H'0002'
C		EQU     H'0000'

page_0	macro					;macro to reset the page bit (page 0)
	bcf STATUS,RP0
	endm

page_1	macro					;macro to set the page bit (page 1)
	bsf STATUS,RP0
	endm

	org	0				;start at address zero (reset vector)
	goto setup				;jump to the real start of the program

	org	4				;address 4 is called by interrupts
interrupt
	retfie					;just return if an interrupt occurs

setup
	movlw H'FF'				;set all RB high (LEDs off)
	movwf PORT_B
	page_1					;RB pins to output mode
	clrf TRIS_B
	movlw H'01'				;RA0 to input, others to output
	movwf TRIS_A
	page_0
	clrf timeout				;count before shutting off
	movlw (table_end - table) - 1		;calculate table length
	movwf scan_len				;count of character raster lines

wait_for_go
	btfsc PORT_A,0				;skip next if start pin has gone low
	goto wait_for_go				;hop on the spot!
	clrf timeout

spacewrite
	decfsz timeout,same			;skip next if finished
	goto sw2	
	movlw H'FF'				;switch off all LEDs
	movwf PORT_B
	goto wait_for_go
sw2
	movf scan_len,w
	movwf scan_pos
sw3
	decf scan_pos,same			;
	movf scan_pos,w
	call table
	movwf PORT_B				;set the LEDs
	movlw H'FF'				;turn of again
	movwf PORT_B
	movf scan_pos,same			;set flags
	btfss STATUS,Z				;skip next if scan_pos = 0
	goto sw3
	goto spacewrite


; led pattern data. 0 = led ON,  1 = led OFF
table
 	addwf PCL,same		;jump to table offset by value in w
	retlw B'10000000'		; *******
	retlw B'01101111'		;*  *
	retlw B'01101111'		;*  *
	retlw B'01101111'		;*  *
	retlw B'10000000'		; *******
	retlw B'11111111'		;
	retlw B'11111111'		;
	retlw B'00000000'		;********
	retlw B'01101110'		;*  *   *
	retlw B'01101110'		;*  *   *
	retlw B'01101110'		;*  *   * 
	retlw B'10010001'		; ** ***
	retlw B'11111111'		;
	retlw B'11111111'		;
	retlw B'10000001'		; ******
	retlw B'01111110'		;*      *
	retlw B'01111110'		;*      *
	retlw B'01111110'		;*      *
	retlw B'10111101'		; *    *
	retlw B'11111111'		;
	retlw B'11111111'		;
table_end
	end