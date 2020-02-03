	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message  ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message, LCD_Send_Byte_I, LCD_delay_x4us, LCD_Clear_Display	    ; external LCD subroutines
	global	myTable;, myTable_l
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
keyread1    res 1   ; reserve one byte for the keypad value maybe
rowval	    res 1   ; reserves one byte for row value
colval	    res 1   ; reserves one byte for column value
button      res 1   ; reserves one byte for key value
      

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Hello world!\n"	; message, plus carriage return
	constant    myTable_l=.3	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	clrf	LATE
	setf	TRISE ; Tri-state PortE
	banksel PADCFG1 ; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, REPU, BANKED ; PortE pull-ups on
	movlw	0x00
	movwf	TRISD
	
	goto	start
	
	; ******* Main programme ****************************************
start 	
	movlw	0x0f
	movwf	TRISE
	call	delay
	movff	PORTE, keyread1
	movff	PORTE, PORTD
	
	
row1	
	movlw	b'00000111'
	cpfseq	keyread1
	bra     row2
	movwf	rowval
	bra     colcheck
	
row2	movlw	b'00001011'
	cpfseq	keyread1
	bra     row3
	movwf	rowval
	bra     colcheck
	
row3	movlw	b'00001101'
	cpfseq	keyread1
	bra     row4
	movwf	rowval
	bra     colcheck
	
row4	movlw	b'00001110'
	cpfseq	keyread1
	bra     start
	movwf	rowval
	bra     colcheck
	
	
colcheck
	movlw	0xf0
	movwf	TRISE
	call	delay
	movff	PORTE, keyread1
	
col1
	movlw	b'01110000'
	cpfseq	keyread1
	bra     col2
	movwf	colval
	bra     determine
	
col2	movlw	b'10110000'
	cpfseq	keyread1
	bra     col3
	movwf	colval
	bra     determine
	
col3	movlw	b'11010000'
	cpfseq	keyread1
	bra     col4
	movwf	colval
	bra     determine
	
col4	movlw	b'11100000'
	cpfseq	keyread1
	bra     start
	movwf	colval
	bra     determine
	
determine
	movf	rowval, 0, 0
	addwf	colval
	bra	check0
	
check0	movlw   0xBE
	cpfseq  colval
	bra     check1
	movlw   '0'
	movwf   button
	bra     output
	
check1	movlw   0x77
	cpfseq  colval
	bra     check2
	movlw	'1'
	movwf   button
	bra     output
	
check2	movlw   0xB7
	cpfseq  colval
	bra     check3
	movlw   '2'
	movwf   button
	bra     output
	
check3	movlw   0xD7
	cpfseq  colval
	bra     check4
	movlw   '3'
	movwf   button
	bra     output
	
check4	movlw   0x7B
	cpfseq  colval
	bra     check5
	movlw   '4'
	movwf   button
	bra     output
	
check5	movlw   0xBB
	cpfseq  colval
	bra     check6
	movlw   '5'
	movwf   button
	bra     output
	
check6	movlw   0xDB
	cpfseq  colval
	bra     check7
	movlw   '6'
	movwf   button
	bra     output
	
check7	movlw   0x7D
	cpfseq  colval
	bra     check8
	movlw   '7'
	movwf   button
	bra     output
	
check8	movlw   0xBD
	cpfseq  colval
	bra     check9
	movlw   '8'
	movwf   button
	bra     output
	
check9	movlw   0xDD
	cpfseq  colval
	bra     checkA
	movlw   '9'
	movwf   button
	bra     output
	
checkA	movlw   0x7E
	cpfseq  colval
	bra     checkB
	movlw   'A'
	movwf   button
	bra     output
	
checkB	movlw   0xDE
	cpfseq  colval
	bra     checkC
	movlw   'B'
	movwf   button
	bra     output
	
checkC	movlw   0xEE
	cpfseq  colval
	bra     checkD
	movlw   'C'
	movwf   button
	bra     output
	
checkD	movlw   0xED
	cpfseq  colval
	bra     checkE
	movlw   'D'
	movwf   button
	bra     output
	
checkE	movlw   0xEB
	cpfseq  colval
	bra     checkF
	movlw   'E'
	movwf   button
	bra     output
	
checkF	movlw   0xE7
	cpfseq  colval
	bra     errmsg
	movlw   'F'
	movwf   button
	bra     output

	
output
	call	LCD_Clear_Display
	
	
	movlw	1
	lfsr	FSR2, button
	call    LCD_Write_Message
	call	delay
	
	;movlw	myTable_l
	;lfsr	FSR2, myArray
	;call	UART_Transmit_Message

	goto	start
errmsg	
		
	goto	start

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return
	
	


	end