#include p18f87k22.inc

    extern  LCD_Setup, LCD_Write_Message, LCD_Send_Byte_I, LCD_delay_x4us, LCD_Clear_Display	    ; external LCD subroutines
    global  button_read, keypad_setup
    global  button

acs0    udata_acs	    ; named variables in access ram
keyread1    res 1   ; reserve one byte for the keypad value maybe
rowval	    res 1   ; reserves one byte for row value
colval	    res 1   ; reserves one byte for column value
button      res 1   ; reserves one byte for key value
delay_count res 1   ; reserve one byte for counter in the delay routine

keypad    code
    
keypad_setup	
    	clrf	LATE
	setf	TRISE ; Tri-state PortE
	banksel PADCFG1 ; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, REPU, BANKED ; PortE pull-ups on
	movlw	0x00	
	movwf	TRISD	; Set port D to output
    
    
button_read
	movlw	0x0f	; Set port E 0 to 3 to input and 4 to 7 to output
	movwf	TRISE
	call	delay
	movff	PORTE, keyread1
	movff	PORTE, PORTD	; Display input, only for verification
	
row1	
	movlw	b'00000111' 
	cpfseq	keyread1    ; Checks if row 1 has been pressed
	bra     row2	    ; If not pressed, move to next row
	movwf	rowval	    ; Saves value to be used for determining value
	bra     colcheck    ; If pressed continue to check column value
	
row2	movlw	b'00001011' ; Check row 2
	cpfseq	keyread1
	bra     row3
	movwf	rowval
	bra     colcheck
	
row3	movlw	b'00001101' ; Check row 3
	cpfseq	keyread1
	bra     row4
	movwf	rowval
	bra     colcheck
	
row4	movlw	b'00001110' ; Check row 4
	cpfseq	keyread1
	return
	movwf	rowval
	bra     colcheck
	
	
colcheck
	movlw	0xf0
	movwf	TRISE	; Set port E 0 to 3 to output and 4 to 7 to input
	call	delay
	movff	PORTE, keyread1
	
col1
	movlw	b'01110000' 
	cpfseq	keyread1    ; Checks if a button on column 1 is pressed
	bra     col2	    ; If not go to next column
	movwf	colval	    ; If pressed, saves value
	bra     determine   ; Continues to determine value of button
	
col2	movlw	b'10110000' ; Checks column 2
	cpfseq	keyread1
	bra     col3
	movwf	colval
	bra     determine
	
col3	movlw	b'11010000' ; Checks column 3
	cpfseq	keyread1
	bra     col4
	movwf	colval
	bra     determine
	
col4	movlw	b'11100000' ; Checks column 4
	cpfseq	keyread1
	return
	movwf	colval
	bra     determine
	
determine		    
; Determines value of button pressed by adding row and column and checking
; against 16 unique combinations
	movf	rowval, 0, 0
	addwf	colval
	bra	check0
	
check0	movlw   0xBE	; Value of row + column if button 0 pressed
	cpfseq  colval
	bra     check1	; Continues to check next value if not equal
	movlw   '0'	; If equal, saves ASCII value of '0' to button value
	movwf   button
	bra     output	; Continues to output the value
	
check1	movlw   0x77	; Checks button value is 1
	cpfseq  colval
	bra     check2
	movlw	'1'
	movwf   button
	bra     output
	
check2	movlw   0xB7	; Checks button value is 2
	cpfseq  colval
	bra     check3
	movlw   '2'
	movwf   button
	bra     output
	
check3	movlw   0xD7	; Checks button value is 3
	cpfseq  colval
	bra     check4
	movlw   '3'
	movwf   button
	bra     output
	
check4	movlw   0x7B	; Checks button value is 4
	cpfseq  colval
	bra     check5
	movlw   '4'
	movwf   button
	bra     output
	
check5	movlw   0xBB	; Checks button value is 5
	cpfseq  colval
	bra     check6
	movlw   '5'
	movwf   button
	bra     output
	
check6	movlw   0xDB	; Checks button value is 6
	cpfseq  colval
	bra     check7
	movlw   '6'
	movwf   button
	bra     output
	
check7	movlw   0x7D	; Checks button value is 7
	cpfseq  colval
	bra     check8
	movlw   '7'
	movwf   button
	bra     output
	
check8	movlw   0xBD	; Checks button value is 8
	cpfseq  colval
	bra     check9
	movlw   '8'
	movwf   button
	bra     output
	
check9	movlw   0xDD	; Checks button value is 9
	cpfseq  colval
	bra     checkA
	movlw   '9'
	movwf   button
	bra     output
	
checkA	movlw   0x7E	; Checks button value is A
	cpfseq  colval
	bra     checkB
	movlw   'A'
	movwf   button
	bra     output
	
checkB	movlw   0xDE	; Checks button value is B
	cpfseq  colval
	bra     checkC
	movlw   'B'
	movwf   button
	bra     output
	
checkC	movlw   0xEE	; Checks button value is C
	cpfseq  colval
	bra     checkD
	movlw   'C'
	movwf   button
	bra     output
	
checkD	movlw   0xED	; Checks button value is D
	cpfseq  colval
	bra     checkE
	movlw   'D'
	movwf   button
	bra     output
	
checkE	movlw   0xEB	; Checks button value is E
	cpfseq  colval
	bra     checkF
	movlw   'E'
	movwf   button
	bra     output
	
checkF	movlw   0xE7	; Checks button value is F
	cpfseq  colval
	return
	movlw   'F'
	movwf   button
	bra     output

output		
	call	LCD_Clear_Display
	
	movlw	1		    ; Length of message
	lfsr	FSR2, button	    ; Moves value of button into FSR2
	call    LCD_Write_Message   ; Writes button value to the LCD
	return
	
	
	; a delay subroutine, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return
	
	end