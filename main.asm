	#include p18f87k22.inc

	
	extern	UART_Setup, UART_Transmit_Message  ; external UART subroutines
	extern  UART_Setup2, UART_receive_Message
	extern  LCD_Setup, LCD_Write_Message, LCD_Send_Byte_I, LCD_delay_x4us, LCD_Clear_Display	    ; external LCD subroutines
	extern	servo_setup, pwm_loop
	extern  button_read, keypad_setup
	global	myTable;, myTable_l
	
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
keyread1    res 1   ; reserve one byte for the keypad value maybe
rowval	    res 1   ; reserves one byte for row value
colval	    res 1   ; reserves one byte for column value
button      res 1   ; reserves one byte for key value
Delay	    res 1
Delay1	    res 1
Delay2	    res 1
offset	    res 1
      
;CBLOCK	0x20
;	Delay
;	Delay1
;	Delay2
;ENDC
      
tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Hello world!\n"	; message, plus carriage return
	constant    myTable_l=.13	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	
	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UAR
	call	LCD_Setup	; setup LCD
	call	servo_setup	; setup servo_control
	call	keypad_setup	; setup keypad
	
	goto	start
	
	; ******* Main programme ****************************************
start 	
	call	button_read
	;call	delay
	call	pwm_loop
	;call	button_read
	
	goto start


	
;start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
;	movlw	upper(myTable)	; address of data in PM
;	movwf	TBLPTRU		; load upper bits to TBLPTRU
;	movlw	high(myTable)	; address of data in PM
;	movwf	TBLPTRH		; load high byte to TBLPTRH
;	movlw	low(myTable)	; address of data in PM
;	movwf	TBLPTRL		; load low byte to TBLPTRL
;	movlw	myTable_l	; bytes to read
;	movwf 	counter		; our counter register
;loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
;	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
;	decfsz	counter		; count down to zero
;	bra	loop		; keep going until finished
		
;	movlw	.15  ;myTable_l	; output message to UART
	;lfsr	FSR2, myArray
	;call	UART_Transmit_Message
;	call	UART_Setup2
;	call	UART_receive_Message
;	lfsr	FSR2, RCREG1
;	call	UART_Setup
;	call	UART_Transmit_Message
	
;	goto	start;$		; goto current line in code

	end
