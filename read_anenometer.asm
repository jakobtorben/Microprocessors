	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex			    ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine

less_than_count1  res 1 
less_than_count2  res 1 
less_than_count3  res 1 
  
greater_than_count1 res 1
greater_than_count2 res 1
greater_than_count3 res 1

less_final_count1     res 1
less_final_count2     res 1
less_final_count3     res 1
     
greater_final_count1  res 1
greater_final_count2  res 1
greater_final_count3  res 1

should_reset          res 1
 
current_reading res 2  ; reserve 2 bytes for the current voltage value

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Hello World!\n"	; message, plus carriage return
	constant    myTable_l=.13	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	movlw	0x00
	movwf   TRISD
	movlw	0x00
	movwf   TRISE
	
	movlw   0x00
	movwf   less_than_count1
	movwf   greater_than_count1
;	banksel PADCFG1 ; PADCFG1 is not in Access Bank!!
;	bcf     PADCFG1, RDPU, BANKED ; PortD pull-ups on
	goto	start
	
	; ******* Main programme ****************************************
start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message

	movlw	myTable_l	; output message to UART
	lfsr	FSR2, myArray
	call	UART_Transmit_Message
	
measure_loop
	
	call	ADC_Read
	movlw	0x04
	cpfslt  ADRESH
	;movff   ADRESH, PORTD
	movff	should_reset, PORTD ;think of better check
	cpfsgt  ADRESH
	call    less_than
	cpfslt  ADRESH
	call    greater_than
	movff   ADRESH, PORTE
	
	
	bra     measure_loop
;	call	LCD_Write_Hex
;	movf	ADRESL,W
;	call	LCD_Write_Hex
;	goto	measure_loop
	
less_than
;	movlw   0x00
;	movff   W, PORTD
	call    check_gt
	
	movlw   0xFF
	cpfslt  less_than_count1
	call    inc_lt_byte2
	
	incf    less_than_count1, W, ACCESS
	movwf   less_than_count1
	
	return
	
inc_lt_byte2	
	movlw	0xFF
	cpfslt	less_than_count2
	call	inc_lt_byte3
	
	incf    less_than_count2, W, ACCESS
	movwf   less_than_count2
	
	return

inc_lt_byte3
	incf	less_than_count3, W, ACCESS
	movwf	less_than_count3
	
	return
	
check_gt
	movlw   0x00
	cpfseq   greater_than_count1
	call    increment_should_reset
	
	movlw	0x00
	cpfseq	greater_than_count2
	call	increment_should_reset
	
	movlw	0x00
	cpfseq	greater_than_count3
	call	increment_should_reset
	
	movlw	0x00
	cpfseq	should_reset ;if zero then no need to call reset
	call	reset_gt
	
	movlw	0x00
	movwf	should_reset
	
	return
	
increment_should_reset
	incf	should_reset, W, ACCESS
	movwf	should_reset
	
	return
	
reset_gt
	movff   greater_than_count1, greater_final_count1
	movff   greater_than_count2, greater_final_count2
	movff   greater_than_count3, greater_final_count3
	
	movlw   0x00
	movwf   greater_than_count1
	movwf	greater_than_count2
	movwf	greater_than_count3
	
	return
	
greater_than
;	movlw   0x00
;	movff   W, PORTD
	
	call	check_lt
	
	movlw   0xFF
	cpfslt  greater_than_count1
	call    inc_gt_byte2
	
	incf    greater_than_count1, W, ACCESS
	movwf   greater_than_count1
	
	return 
	
inc_gt_byte2	
	movlw	0xFF
	cpfslt	greater_than_count2
	call	inc_gt_byte3
	
	incf    greater_than_count2, W, ACCESS
	movwf   greater_than_count2
	
	return

inc_gt_byte3
	incf	greater_than_count3, W, ACCESS
	movwf	greater_than_count3
	
	return
	
check_lt
	movlw   0x00
	cpfseq   less_than_count1
	call    increment_should_reset
	
	movlw	0x00
	cpfseq	less_than_count2
	call	increment_should_reset
	
	movlw	0x00
	cpfseq	less_than_count3
	call	increment_should_reset
	
	movlw	0x00
	cpfseq	should_reset
	call	reset_lt
	
	movlw	0x00
	movwf	should_reset
	
	return
	
reset_lt
	movff   less_than_count1, less_final_count1
	movff   less_than_count2, less_final_count2
	movff   less_than_count3, less_final_count3
	
	movlw   0x00
	movwf   less_than_count1
	movwf	less_than_count2
	movwf	less_than_count3
	
	return
	
calculate_time
	return

	; a delay subroutine if you need one, times around loop in delay_count
;delay	decfsz	delay_count	; decrement until zero
;	bra delay
;	return

	end