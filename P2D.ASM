; Starting from PICDREAM.ASM this is P2D.ASM for a 6MHz Xtal
; and a third push button on pin 11 (RB5).    625/50
; by Andy STURT G8SIK 14/05/1998

; CQ-TV Editors note:
; The original PIC processor has to be repaced with the "-10" version.
; Increasing the clock from 4 to 6 MHz means the normal 4 MHz version is
; pushed beyond its limit. The 10MHz version works OK.

; PICDREAM
; (Programmable Intelligent Circuit Dedicated to Radio
; and Electronic Amateurs, Mainly.)
; Origional program by Alain FORT F1CJN  22/08/1997
; Alain thanks Peter KNIGHT for his origional 4MHz Sync routines
; Free for public domain
; Assembled with MPASM
; Tristan@Club-Internet.fr or F1CJN @ F6KBF.FRPA
; 5*7 character routines
; 9 characters visible as scrolling text at the top of the screen
; A grey scale of 8 steps, in the middle
; and a 4 digit clock at the bottom 
; The clock is set up with two push buttons
; There are 4 text messages selected by a 3rd push button
; The 625 line TV screen looks like this:-
;
;			  *************
;			  *  T E X T  * this line is scrolling to the left
;			  * grey bars *
;			  *   12:00   *
;			  *************
;
; 

	TITLE	"PICDREAM"

	LIST	P=16C84


#Define	W	0
#Define	F	1

	cblock	0x00
		INDF,RTCC,PCL,Status,FSR,PortA,PortB
	endc
	cblock	0x08
		EEData,EEAdr,PClath,IntCon
	endc

	cblock	0x00
		C,DC,Z,PD,TO,RP0,RP1,IRP
	endc

; Page 1 registers
Roption	EQU	01
TrisA	EQU	05
TrisB	EQU	06
RAMbase	EQU	0C


#define	Sync	PortA,0  ; Synchro out at RA0  (PIN 17)
#define	GREY	PortA,2  ; Synchro out at RA1  (PIN 18)


; DNOP - Double NOP. Delay of 2 cycles, takes only one instruction

DNOP	MACRO
	LOCAL	Label
Label	GOTO	Label+1
	ENDM

; Delay3W - Delay 3 * W cycles, three instructions

Delay3W	MACRO
	LOCAL	Label
	MOVWF	Delay		
Label	DECFSZ	Delay,F
	GOTO	Label
	ENDM

SKIPCC	MACRO
	BTFSC	Status,C
	ENDM

SKIPNZ	MACRO
	BTFSC	Status,Z
	ENDM

	LIST

	CBLOCK	RAMbase
		Delay,Count,Count2,Count3             ; 4 various registers
		Hrs,MiT,MiU,SeU,SubSec  	      ; 6 clock registers 
                Ptrtxt,TNB,RTPT,TStrt,TLen
		CA0,CA1,CA2,CA3,CA4,CA5               ; 6 caracters pointers
                CA6,CA7,CA8,CA9,CA10
		Ta0,Ta1,Ta2,Ta3,Ta4,Ta5               ; 7 caracter lines ptrs
                Ta6,Ta7,Ta8,Ta9,Ta10
	ENDC

	ORG	0
	GOTO	Main

	ORG	4
	RETURN

; Table of caracters

Table	ADDWF	PCL,F
Tbase	equ	$
Car0	equ	$-Tbase
CarO	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	; ....***.
        RETLW   B'00000000'
Car1	equ	$-Tbase
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001100'	; ....**..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001110'	; ....***.
        RETLW   B'00000000'
Car2	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001000'	; ....*...
	RETLW	B'00011111'	; ...*****
        RETLW   B'00000000'
Car3	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001' 	;....*...*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000110'	; .....**.
	RETLW	B'00000001'	; .......*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	; ....***.
        RETLW   B'00000000'
Car4	equ	$-Tbase
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000110'	; .....**.
	RETLW	B'00001010'	; ....*.*.
	RETLW	B'00010010'	; ...*..*.
	RETLW	B'00011111'	; ...*****
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000010'	; ......*.
        RETLW   B'00000000'
Car5	equ	$-Tbase
	RETLW	B'00011111'	; ...*****
	RETLW	B'00010000'	; ...*....
	RETLW	B'00011110'	; ...****.
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	; ....***.
        RETLW   B'00000000'
Car6	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010000'	; ...*....
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	; ....***.
        RETLW   B'00000000'
Car7	equ	$-Tbase
	RETLW	B'00011111'	; ...*****
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
        RETLW   B'00000000'
Car8	equ	$-Tbase
 	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
 	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
 	RETLW	B'00001110'	; ....***.
        RETLW   B'00000000'
Car9	equ	$-Tbase
 	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
 	RETLW	B'00001111'	; ....****
	RETLW	B'00000001'	; .......*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	; ....***.	
;B0  	D'80'
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00001000'	; ....*...
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000010'	; ......*.
;B3  	D'85'
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000010'	; ......*.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001000'	; ....*...
CarSP	equ	$-Tbase
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
	RETLW	B'00000000'	; ........
CarA	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011111'	; ...*****
CarH	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011111'	; ...*****
CarU	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001110'	;.....***.
CarD	equ	$-Tbase
	RETLW	B'00011110'	; ...****.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
CarB	equ	$-Tbase
	RETLW	B'00011110'	; ...****.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
CarP	equ	$-Tbase
	RETLW	B'00011110'	; ...****.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011110'	; ...****.
CarL	equ	$-Tbase
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
CarE	equ	$-Tbase
	RETLW	B'00011111'	; ...***** 
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00011100'	; ...***..
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
CarF	equ	$-Tbase
	RETLW	B'00011111'	; ...***** 
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00011100'	; ...***..
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
CarJ	equ	$-Tbase
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00000001'	; .......*
	RETLW	B'00010001'	; ...*...*
CarG	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010011'	; ...*..**
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
CarQ	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010101'	; ...*.*.*
	RETLW	B'00010011'	; ...*..**
CarS	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010000'	; ...*....
	RETLW	B'00001110'	; ....***.
	RETLW	B'00000001'	; .......*
	RETLW	B'00010001'	; ...*...*
CarC	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010000'	; ...*....
	RETLW	B'00010001'	; ...*...*
CarI	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001110'	; ....***.
CarK	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010010'	; ...*..*.
	RETLW	B'00010100'	; ...*.*..
	RETLW	B'00011000'	; ...**...
	RETLW	B'00010100'	; ...*.*..
	RETLW	B'00010010'	; ...*..*.
CarM	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011011'	; ...**.**
	RETLW	B'00010101'	; ...*.*.*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
CarN	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011001'	; ...**..*
	RETLW	B'00010101'	; ...*.*.*
	RETLW	B'00010011'	; ...*..**
CarY	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001010'	; ....*.*.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
CarR	equ	$-Tbase
	RETLW	B'00011110'	; ...****.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00011110'	; ...****.
CarV	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
CarX	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00001010'	; ....*.*.
	RETLW	B'00000100'	; .....*..
	RETLW	B'00001010'	; ....*.*.
CarW	equ	$-Tbase
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010101'	; ...*.*.*
	RETLW	B'00011011'	; ...**.**
	RETLW	B'00010001'	; ...*...*
CarZ	equ	$-Tbase
	RETLW	B'00011111'	; ...***** 
	RETLW	B'00000001'	; ...... *
	RETLW	B'00000010'	; ..... *.
	RETLW	B'00000100'	; .... *..
	RETLW	B'00001000'	; ....*...
	RETLW	B'00010000'	; ...*....
CarT	equ	$-Tbase
	RETLW	B'00011111'	; ...*****
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
	RETLW	B'00000100'	; .....*..
Car@	equ	$-Tbase
	RETLW	B'00001110'	; ....***.
	RETLW	B'00010001'	; ...*...*
	RETLW	B'00010111'	; ...*.***
	RETLW	B'00010101'	; ...*.*.*
	RETLW	B'00010111'	; ...*.***
	RETLW	B'00010000'	; ...*....
	RETLW	B'00001111'	; ....****

Main
	BSF	Status,RP0	; addressing bank 1
	MOVLW	B'10000'        ; Set up RA0 to RA3 as O/Ps
	MOVWF	TrisA
	MOVLW	B'11100000'
	MOVWF	TrisB		; port B as outputs except  RB5, RB6 and RB7
	BCF	Roption,7	; we need the integrated pull-up resistors
	BCF	Status,RP0	; addressing bank 0 from now on

        MOVLW   5
        MOVWF   RTPT
        CLRF    TNB
	CLRF	Count3

; Frame starts here.
;
; Frame must be exactly 312.5 Lines long, each Line is 96 cycles long.
; That ensures frame rate is exactly 50Hz to crystal accuracy.

; 5 Broard pulses

Frame				;Main Loop
	BCF	Sync		; 1	30us Sync
	DNOP			; 3
	MOVLW	4		; 4
	MOVWF	Count		; 5
Loop1	MOVLW	D'13'		; 6  6
	Delay3W			;45 45
	BSF	Sync		;46 46	2us Black
	DNOP			;48 48
	BCF	Sync		; 1  1	30us Sync
	NOP			; 2  2
	DECFSZ Count,F		; 3  4
	GOTO	Loop1		; 5
	MOVLW	D'13'		;    5
	Delay3W			;   44
	NOP			;   45
	BSF	Sync		;   46	2us Black
	DNOP			;   48

; Now 5 short equalising pulses

	BCF	Sync		; 1	2us Sync
	DNOP			; 3
	BSF	Sync		; 4	30us Black
	MOVLW	4		; 5
	MOVWF	Count		; 6
        DNOP                    ; 8
Loop2	MOVLW	D'13'		; 9  9  9  9
	Delay3W			;48 48 48 48
	BCF	Sync		; 1  1  1  1	2us Sync
	DNOP			; 3  3  3  3
	BSF	Sync		; 4  4  4  4	30us Black
        NOP                     ; 5  5  5  5
	DECFSZ Count,F		; 6  6  6  7
	GOTO	Loop2		; 8  8  8
        DNOP                    ;          9    9
        MOVLW   D'28'           ;         10   10
        BTFSS   SubSec,0        ;         11   12   on interlace (SubSec odd)
	MOVLW	D'12'		;         12    -
	Delay3W			;         48   96   so extra half line of black

;Increment time. 3 or 4 Lines depending on field   Line 8

        BCF     Sync            ; 1
        CALL    IncTim          ; 96

;*****  KEYS TEST 1 line  Line 9

	BCF	Sync		; 1
	CALL	TOUCHE		; 96

; 14 black Lines   Line 23

	BCF	Sync		; 1
	MOVLW	D'14'		; 2
        BCF     Hrs,7           ; 3
	CALL	GryLns		; 96

; 36 Grey Lines     Line 59

        BCF     Sync            ; 1
        MOVLW   D'36'           ; 2
        BSF     Hrs,7           ; 3
        CALL    GryLns          ; 96

; ****     INIT TEXTE ******   line  60

	BCF 	Sync            ; 1
	Call 	Preptxt3        ; 96

; ****    INIT TEXTE CONTINUED ****** line 61

	BCF 	Sync            ; 1
	Call 	Preptxt4        ; 96

;********** DISPLAY TEXTE ********* ( + 57 lines) = 118

	BCF	Sync		; 1
	CALL	DisTxt		; 96

; 18 Grey lines = 136

	BCF	Sync		; 1
	MOVLW	D'18'		; 2
        BSF     Hrs,7           ; 3
	CALL	GryLns		; 96

; ***** GREY BARS ***** 60 lines = 196

        BCF     Sync            ; 1
        MOVLW   D'59'           ; 2
        MOVWF   Count           ; 3
        NOP                     ; 4
LP      CALL    BARRE           ; 96
        BCF     Sync            ; 1
        DECFSZ  Count,F         ; 2
        GOTO    LP              ; 4
        NOP                     ; 4
        CALL    BARRE           ; 96

;*****  16  Grey LINES = 212

	BCF	Sync		; 1
	MOVLW	D'16'		; 2
        BSF     Hrs,7           ; 3
	CALL	GryLns		; 96

;***** PREPARE CLOCK    =  213

	BCF	Sync		; 1
	CALL	PREPH		; 96

;***** DISPLAY CLOCK 	= 270  ***** (this takes 57 Lines)

	BCF	Sync            ; 1
	CALL	DisTxt          ; 96


; *****  40 Grey LINES = 310

	BCF	Sync		; 1	5us Sync
	MOVLW	D'40'		; 2
        BSF     Hrs,7           ; 3
	CALL	GryLns		; 96

; insert half Line here on interlace

; Now 5 short equalising pulses
; prefixed by half video Line on interlace

	BCF	Sync		; 1	   2us Sync
        NOP                     ; 2
        BTFSC   SubSec,0        ; 3
	BSF	Sync		; 4	   30us Black
        DNOP                    ; 6
        BTFSS   SubSec,0        ; 7
        BSF     Sync            ; 8        Black starts here if it was a
	MOVLW	4		; 9        full sync pulse
	BTFSS	SubSec,0	;10
	MOVLW	5		;11
	MOVWF	Count		;12
        NOP                     ;13
	MOVLW	D'11'		;14
Loop6   NOP                     ;15  9  9
	Delay3W			;48 48 48
	BCF	Sync		; 1  1  1  2us Sync
	DNOP			; 3  3  3
	BSF	Sync		; 4  4  4  30us Black
        MOVLW   D'13'           ; 5  5  5
	DECFSZ	Count,F		; 6  6  7
	GOTO	Loop6		; 8  8
        
	Delay3W			;      46
	GOTO	Frame		;      48

; Delay routines

Delay9  NOP
Delay8  NOP
Delay7  NOP
Delay6	NOP
Delay5	NOP
Delay4	RETURN

; Some Grey Lines
GryLns	ADDLW	-1              ; 6            1
        NOP                     ; 7            2
	BSF	Sync		; 8            1        59us black
	MOVWF	Count           ; 9            1
	DNOP			; 11           2
GryLp5	CALL    Delay4          ; 15 15 15     4  4  4
        BTFSC   Hrs,7           ; 16 16 16     1  1  1
        BSF     GREY            ; 17 17 17     1  1  1
        MOVLW   D'25'           ; 18 18 18
        Delay3W                 ; 93 93 93
        BCF     GREY            ; 94 94 94
        DNOP                    ; 96 96 96 
	BCF	Sync		; 1  1  1      1  1  1  5us Sync
	CALL	Delay6		; 7  7  7      6  6  6
	BSF	Sync		; 8  8  8      1  1  1  59us Grey
	DECFSZ	Count,F		; 9  9  10     1  1  2
	GOTO	GryLp5		; 11 11        2  2
	CALL    Delay5          ;       15           1
        BTFSC   Hrs,7           ;       16           1
        BSF     GREY            ;       17
	MOVLW	D'25'		;       18           1
	Delay3W			;       93
        BCF     GREY            ;       94
	RETURN			;       96           2

; Increment Time
IncTim	INCF	SubSec,F        ;4	Increment 1/50th sec
	MOVLW	-D'50'		;5
	ADDWF	SubSec,W	;6	Carry now set if second has expired
        NOP                     ;7
        BSF     Sync            ;8
	SKIPCC			;9	Zero SubSec if =50
	CLRF	SubSec   	;10
	SKIPCC			;
	INCF	SeU,F		;	And increment Second Units
	SKIPCC			;
	NOP			; 	seconds counter modulo 256
	MOVLW	-D'60'		;15
	ADDWF	SeU,W		;	Carry if needed Second Units->Tens
	SKIPCC			;
	CLRF	SeU		;
	SKIPCC			;
	INCF	MiU,F		;20	Minutes Units
	MOVLW	-D'10'		;
	ADDWF	MiU,W		;
	SKIPCC			;
	CLRF	MiU		;
	SKIPCC			;25
	INCF	MiT,F		;	Minutes tens
        SKIPCC                  ;27
        GOTO    IT3             ;29
        DNOP                    ;30
        GOTO    IT4             ;32
IT3     DECF    RTPT,F          ;30
        MOVLW   FTexte4-DTexte  ;31
        MOVWF   Ptrtxt          ;32
IT4	MOVLW	-6		;33
	ADDWF	MiT,W		;
	SKIPCC			;
	CLRF	MiT		;36
	SKIPCC			;
	INCF	Hrs,F		;
        MOVLW   B'1111'
        ANDWF   Hrs,W
        MOVWF   TNB             ;41
	MOVLW	-D'10'		;
	ADDWF	TNB,W		; 
	SKIPCC			;44
        GOTO    IT1             ;46
        CALL    Delay4          ;49
        GOTO    IT2             ;51
IT1     MOVLW   B'110000'       ;47
        ANDWF   Hrs,F
        MOVLW   D'16'
        ADDWF   Hrs,F           ;50
        CLRF    TNB             ;51
IT2	MOVF	TNB,W		;52   Now check for Hours=24
	BTFSC	Hrs,5		;53
	ADDLW	-4		;54
	SKIPCC			;55
	CLRF	Hrs		;56   clear hours
	MOVLW	D'12'		;57
	Delay3W			;93
        MOVLW   2               ;94
        BTFSC   SubSec,0        ;95
        MOVLW   3               ;96
        BCF     Sync            ;1
        NOP                     ;2
        BCF     Hrs,7           ;3
        GOTO    GryLns          ;96

;Display

DisTxt	CALL    Delay4		; 7	First Line is black
	BSF	Sync		; 8
        CALL    Delay8          ; 16
        BSF     GREY            ; 17
	MOVLW	D'25'		; 18
	Delay3W			; 93
        BCF     GREY            ; 94
        DECF    CA1,F           ; 95
        DECF    CA2,F           ; 96
	BCF	Sync		; 1	Line 2 is black, +1 for characters line
	CALL	INCLIN		; 96
	BCF	Sync		; 1	Line 10 is black, +1 for caracters line
	CALL	INCLIN		; 96
	BCF	Sync		; 1	Line 18 is black, +1 for caracters line
	CALL	INCLIN		; 96
	BCF	Sync		; 1	Line 26 is black,+1 for caracters line
	CALL	INCLIN		; 96
	BCF	Sync		; 1	Line 34 is black, +1 for caracters line
	CALL	INCLIN		; 96
	BCF	Sync		; 1	Line 42 is black, +1 for caracters line
	CALL	INCLIN		; 96
	BCF	Sync		; 1	Line 50 is black, +1 for caracters line
	GOTO	INCLIN		; 96


Showline MOVF	Ta0,W		;16 Carac 1
        BSF     GREY            ;17
        MOVWF   PortB           ;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	CLRF	PortB		;
	MOVF	Ta1,W		;24 Carac 2
	MOVWF	PortB		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	CLRF	PortB		;
	MOVF	Ta2,W		;31 Carac 3
	MOVWF	PortB		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	CLRF	PortB		;
	MOVF	Ta3,W		;38 Carac 4
	MOVWF	PortB		;  
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	CLRF	PortB		;
	MOVF	Ta4,W		;45 Carac 5
	MOVWF	PortB		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	CLRF	PortB		;
	MOVF	Ta5,W		;52 Carac 6
	MOVWF	PortB		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	CLRF	PortB		;
	MOVF	Ta6,W		;59 Carac 7
	MOVWF	PortB		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	CLRF	PortB		;
	MOVF	Ta7,W		;66 Carac 8
	MOVWF	PortB		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	CLRF	PortB		;
	MOVF	Ta8,W		;73 Carac 9
	MOVWF	PortB		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	CLRF	PortB		;
	MOVF	Ta9,W		;80 Carac 10
	MOVWF	PortB		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	RLF	PortB,F		;
	CLRF	PortB		;   Put 0 ( black video between 2 characters)
	MOVF	Ta10,W		;87 Carac 11
	MOVWF	PortB		;88
	RLF	PortB,F		;89
	RLF	PortB,F		;90
	RLF	PortB,F		;91
	RLF	PortB,F		;92
	CLRF	PortB		;93
        BCF     GREY            ;94
	RETURN			;96

Preptxt3  MOVF	SubSec,w	; 4
	ANDLW	B'00000001'	; 5
        DNOP                    ; 7
        BSF     Sync            ; 8
	SKIPNZ			; 9
	GOTO	GT4		; 11
	MOVLW	D'16'		; 11
	ADDWF	Count3,F	; 12
	SKIPNZ			; 13
	INCF	Ptrtxt,F	; 14
        DNOP                    ; 16
        BSF     GREY            ; 17
	GOTO 	GT5		; 19
GT4	CALL	Delay5		; 16
        BSF     GREY            ; 17
        DNOP                    ; 19
GT5 	MOVLW   HIGH Texte	; 20  prepare to read the text page above 300h
	MOVWF	PClath		; 21
	MOVF	Ptrtxt,W	; 22	first caracter
	CALL	Texte		; 28
	MOVWF	CA0		; 
	INCF	Ptrtxt,F	; 
	MOVF	Ptrtxt,W	; 31	Second caracter
	CALL	Texte		; 
	MOVWF	CA1		; 
	INCF	Ptrtxt,F	; 
	MOVF	Ptrtxt,W	; 40	Third caracter
	CALL	Texte		; 
	MOVWF	CA2		; 
	INCF	Ptrtxt,F	; 	
	MOVF	Ptrtxt,W	; 49	Fourth caracter
	CALL	Texte		; 55
	MOVWF	CA3		; 56
	INCF	Ptrtxt,F	; 57
	MOVF	Ptrtxt,W	; 58	Fifth caracter
	CALL	Texte		; 64
	MOVWF	CA4		; 65
	INCF	Ptrtxt,F	; 66
	MOVF	Ptrtxt,W	; 67    Sixth caracter
	CALL	Texte		; 73
	MOVWF	CA5		; 74
	INCF	Ptrtxt,F	; 75
	MOVF	Ptrtxt,W	; 76	Seventh caracter
	CALL	Texte		; 82
	MOVWF	CA6		; 83
	INCF	Ptrtxt,F	; 84
	MOVF	Ptrtxt,W	; 85	Eighth caracter
	CALL	Texte		; 91
	MOVWF	CA7		; 92
	INCF	Ptrtxt,F	; 93
        BCF     GREY            ; 94
	RETURN			; 96

Preptxt4  CALL  Delay4		; 7
	BSF	Sync		; 8
        CALL    Delay8          ;16
        BSF     GREY            ;17
	MOVF	Ptrtxt,W	; 18	Ninth caracter
	CALL	Texte		; 24
	MOVWF	CA8		; 25
        INCF    Ptrtxt,F        ; 26
	MOVF	Ptrtxt,W	; 27	Tenth caracter
	CALL	Texte		; 33
	MOVWF	CA9		; 34
	INCF	Ptrtxt,F	; 35
	MOVF	Ptrtxt,W	; 36	Eleventh caracter
	CALL	Texte		; 42
	MOVWF	CA10		; 43
        NOP                     ; 44
	MOVLW	D'10'		; 45
	Delay3W			; 75
        MOVLW   HIGH ClrPtr     ; 76
        MOVWF   PClath          ; 77
	MOVLW	-D'10'		; 78   plus 10 for a one caracter shift
	ADDWF	Ptrtxt,F	; 79   voila 
        MOVF    TLen,W          ; 80
        MOVWF   TNB             ; 81
	MOVF	Ptrtxt,W	; 82
	ADDWF   TNB,F           ; 83   compare to text length
	SKIPCC			; 84/85
	GOTO    ClrPtr          ; 86
        CALL    Delay5          ; 90
CPC     CLRF 	PClath		; 91 reset PClath for reading character
                                ;    table at page 0
        DNOP                    ; 93
        BCF     GREY            ; 94
	RETURN			; 96

ClrPtr  MOVF    TStrt,W         ; 87 reset text pointer if end of scroll
	MOVWF   Ptrtxt          ; 88
        GOTO    CPC             ; 90

INCLIN	MOVF	CA0,W		; 4  Computing the table input address 
	INCF    CA0,F  		; 5
        INCF    CA1,F           ; 6
        INCF    CA2,F           ; 7
	BSF	Sync		; 8  and store in  Ta0 to Ta5 registers
	CALL 	Table		; 14  Call line number NB
	MOVWF	Ta0		; 15  Table in TA0
        MOVF    CA1,W           ; 16
        BSF     GREY            ; 17
	CALL 	Table		; 23
	MOVWF	Ta1		;
	MOVF 	CA2,W		;	
	CALL 	Table		; 31
	MOVWF	Ta2		;
	MOVF 	CA3,W		;	
	CALL 	Table		; 39
	MOVWF	Ta3		;
	MOVF 	CA4,W		;	
	CALL 	Table		; 47
	MOVWF	Ta4		; 
	MOVF 	CA5,W		; 
	CALL 	Table		; 55 
	MOVWF	Ta5		; 
        MOVF    CA6,W           ;
        CALL    Table           ; 63
        MOVWF   Ta6             ;
	MOVF	CA7,W		;
	CALL 	Table		; 71
	MOVWF	Ta7		;
        MOVF    CA8,W           ;
        CALL    Table           ; 79
        MOVWF   Ta8             ;
        MOVF    CA9,W           ;
        CALL    Table           ; 87
        MOVWF   Ta9             ;
        MOVLW   6
        MOVWF   Count           ; 90
        INCF    CA3,F           ;
        INCF    CA4,F           ; 92
        INCF    CA5,F           ; 93
        BCF     GREY            ; 94
        INCF    CA6,F           ; 95
        MOVF    CA10,W          ; 96
        BCF     Sync            ; 1
        CALL    Table           ; 7
        BSF     Sync            ; 8
        MOVWF   Ta10            ; 9
        INCF    CA7,F           ; 10
        INCF    CA8,F           ; 11
        INCF    CA9,F           ; 12
LPSH    NOP                     ; 13
        CALL    Showline        ; 96
        BCF     Sync            ; 1
        CALL    Delay6          ; 7
        BSF     Sync            ; 8
        NOP                     ; 9
        DECFSZ  Count,F         ; 10
        GOTO    LPSH            ; 12
        INCF    CA10,F          ; 12
        NOP                     ; 13
        GOTO    Showline        ; 96


PREPH	CALL    Delay4		; 7	Clock 
	BSF	Sync		; 8
	BCF 	Status,C	; 9
	MOVLW	D'89'		; 10  First 2 characters are spaces (black)
	MOVWF	CA0		; 11
        MOVWF   CA1             ; 12
        MOVWF   CA2
        NOP
        DNOP                    ; 16
        BSF     GREY            ; 17
        MOVLW   B'110000'       ; 18
	ANDWF   Hrs,W		; 19  Hours Tens 
	MOVWF	CA3		; 20
        RRF     CA3,F
        MOVLW   B'1111'
	ANDWF   Hrs,W		; 23  Hours Units
	MOVWF	CA4		; 
	RLF	CA4,F		; 25  multiply by 7 for table access
	RLF	CA4,F		; 
        RLF     CA4,F
	MOVLW 	D'79'		; 
	BTFSC	SeU,0		; 29  parity test for seconds
	ADDLW	5		; 
	MOVWF	CA5		; 31  result = 70 or 75
	MOVF	MiT,W		; 32  Minutes Tens
	MOVWF	CA6		; 
	RLF	CA6,F		; 34  multiply by 7 for table access
	RLF	CA6,F		; 
        RLF     CA6,F
	MOVF	MiU,W		; 37  Minutes Units
	MOVWF	CA7		; 
	RLF	CA7,F		; 39  multiply by 7 for table access
	RLF	CA7,F		; 
        RLF     CA7,F
	MOVLW	D'89'		;
	MOVWF	CA8		; 43  Last 2 characters are spaces
        MOVWF   CA9
        MOVWF   CA10            ; 45
        DNOP
	MOVLW	D'15'		; 48
	Delay3W			; 93
        BCF     GREY            ; 94
	RETURN			; 96

BARRE	NOP     		; 7   Grey for outputs RA1 RA2 RA3
        BSF     Sync           	; 8
        DNOP                    ; 10
        MOVLW   D'4'            ; 11
        Delay3W                 ; 23
        MOVLW   3               ; 24
	MOVWF   PortA           ; 25  Only even numbers (for sync='1')
	CALL 	Delay8		; 33
        MOVLW   5               ; 34
	MOVWF   PortA 		; 35
	CALL	Delay8  	; 43
	MOVLW	7		;
	MOVWF	PortA		; 
	CALL 	Delay8		; 53
	MOVLW	9		; 54
	MOVWF	PortA		; 55
	CALL	Delay8		; 63
	MOVLW	D'11'		;
	MOVWF	PortA		; 
	CALL	Delay8		; 73 
	MOVLW	D'13'		;
	MOVWF	PortA		; 
	CALL	Delay8		; 83
	MOVLW	D'15'		; 84
	MOVWF	PortA		; 85
	CALL	Delay7		; 92
        MOVLW   1               ; 93
        MOVWF   PortA           ; 94
	RETURN			; 96

TOUCHE
	CALL    Delay4		;7
	BSF     Sync		;8
	MOVF	PortB,w		;9	reading PortB
	XORLW	B'11111111'	;10	compare with before which was '1'
                                ;       due to the pull-up loads
	ANDLW	B'11100000'	;11     mask for RB7, RB6 and RB5
	BTFSC	Status,Z	;12	zero set=no buttons
	GOTO	RT2		;14	out if no key press	
	INCFSZ 	Count2,F	;14	delay (with frame counter) if a key at 1
	GOTO 	RT1		;16
	BTFSS	PortB,7		;16	minutes button test
	INCF	MiU,F		;17
	BTFSS	PortB,6		;18	hours button test
	INCF	Hrs,F		;19
        BTFSS   PortB,5         ;20
        GOTO    RT4             ;22
	MOVLW	D'236'		;22	Wait a while
	MOVWF 	Count2		;23
	GOTO	RT3		;25
RT4     DECF    RTPT,F          ;23
        MOVLW   FTexte4-DTexte  ;24
        MOVWF   Ptrtxt          ;25
        MOVLW   D'236'          ;26
        MOVWF   Count2          ;27
        GOTO    RT5             ;29
RT2	MOVLW	D'236'		;15	
	MOVWF	Count2		;16
RT1	CALL Delay9		;25
RT3     CALL    Delay4          ;29
RT5	MOVLW   4               ;30
        DECF    RTPT,F          ;31
        SKIPNZ                  ;32
        MOVWF   RTPT            ;33
        INCF    RTPT,F          ;34
        MOVF    RTPT,W          ;35
        SUBLW   5               ;36
        SKIPNZ                  ;37
        GOTO    ONE             ;39
        MOVF    RTPT,W          ;39
        SUBLW   4               ;40
        SKIPNZ                  ;41
        GOTO    TWO             ;43
        MOVF    RTPT,W          ;43
        SUBLW   3               ;44
        SKIPNZ                  ;45
        GOTO    THREE           ;47
        MOVF    RTPT,W          ;47
        SUBLW   2               ;48
        SKIPNZ                  ;49
        GOTO    FOUR            ;51
        NOP                     ;51
        DNOP                    ;53
        GOTO    FIN             ;55
ONE     MOVLW   DTexte-FTexte1  ;40
        MOVWF   TLen            ;41
        CLRF    TStrt           ;42
        DNOP                    ;44
        CALL    Delay9          ;53
        GOTO    FIN             ;55
TWO     MOVLW   FTexte1-DTexte  ;44
        MOVWF   TStrt           ;45
        MOVLW   DTexte-FTexte2  ;46
        MOVWF   TLen            ;47
        CALL    Delay6          ;53
        GOTO    FIN             ;55
THREE   MOVLW   FTexte2-DTexte  ;48
        MOVWF   TStrt           ;49
        MOVLW   DTexte-FTexte3  ;50
        MOVWF   TLen            ;51
        DNOP                    ;53
        GOTO    FIN             ;55
FOUR    MOVLW   FTexte3-DTexte  ;52
        MOVWF   TStrt           ;53
        MOVLW   DTexte-FTexte4  ;54
        MOVWF   TLen            ;55
FIN     DNOP                    ;57
        MOVLW	D'12'		;58
	Delay3W			;94
	RETURN			;96

Texte	ADDWF	PCL,F
DTexte	RETLW	CarSP	; 1  LENGTH = 95 MAXIMUM (characters plus space)
	RETLW	CarSP	; 2
	RETLW	CarSP	; 3
	RETLW	CarSP	; 4
	RETLW	CarSP	; 5  
	RETLW	CarSP	; 6  *** do not modify the first 10 SP characters **
        RETLW   CarSP   ; 7
        RETLW   CarSP   ; 8
        RETLW   CarSP   ; 9
        RETLW   CarSP   ; 10
        RETLW   CarSP   ; 11
;	RETLW	CarB
;	RETLW	CarA
;	RETLW	CarT
;	RETLW	CarC
;	RETLW	CarSP
;	RETLW	CarP 
;	RETLW	CarI  
;	RETLW	CarC
;	RETLW	CarD
;	RETLW	CarR
;	RETLW	CarE
;	RETLW	CarA
;	RETLW	CarM
	RETLW	CarJ
	RETLW	CarO
	RETLW	CarI
	RETLW	CarN
	RETLW	CarSP
	RETLW	CarS 
	RETLW	CarO  
	RETLW	CarU
	RETLW	CarT
	RETLW	CarH
	RETLW	CarG
	RETLW	CarA
	RETLW	CarT
	RETLW	CarE
	RETLW	CarSP
	RETLW	CarA
	RETLW	CarR
	RETLW	CarC
	RETLW	CarSP 
	RETLW	CarH
	RETLW	CarE
	RETLW	CarR
        RETLW   CarE
FTexte1	RETLW   CarSP
	RETLW   CarSP
	RETLW   CarSP
	RETLW   CarSP
	RETLW	CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarG
        RETLW   Car8
        RETLW   CarS
        RETLW   CarI
        RETLW   CarK
        RETLW   CarSP
        RETLW   Car@
        RETLW   CarSP
        RETLW   CarG
        RETLW   CarB
        RETLW   Car7
        RETLW   CarT
        RETLW   CarU
	RETLW	CarT
FTexte2	RETLW   CarSP
	RETLW   CarSP
	RETLW   CarSP
	RETLW   CarSP
	RETLW	CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarN
        RETLW   CarO
        RETLW   CarR
        RETLW   CarT
        RETLW   CarH
        RETLW   CarSP
        RETLW   CarL
        RETLW   CarO
        RETLW   CarN
        RETLW   CarD
        RETLW   CarO
	RETLW	CarN
	RETLW	CarSP
	RETLW	CarT
	RETLW	CarV
	RETLW	CarSP
	RETLW	CarG
	RETLW   CarR
	RETLW   CarO
	RETLW   CarU
	RETLW	CarP
	RETLW	CarSP
	RETLW	CarSP
	RETLW	CarSP
	RETLW	CarN
	RETLW	CarL
	RETLW	CarT
	RETLW	CarG
FTexte3	RETLW   CarSP
	RETLW	CarSP
	RETLW	CarSP
	RETLW	CarSP
	RETLW   CarSP
	RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarG
        RETLW   CarB
        RETLW   Car3
        RETLW   CarE
        RETLW   CarN
FTexte4	RETLW   CarSP	; necessary for scrolling 9 characters on the screen
	RETLW   CarSP
	RETLW   CarSP
	RETLW   CarSP
	RETLW	CarSP
        RETLW   CarSP
	RETLW	CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP
        RETLW   CarSP

	END
