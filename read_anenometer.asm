	#include p18f87k22.inc

	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern	UART_Setup, UART_Transmit_Message  ; external UART subroutines
	global	measure_loop
	global	read_anenometer_setup
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
new_line    res 1

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

read_anenometer	code

	
read_anenometer_setup	;bcf	EECON1, CFGS	; point to Flash program memory  

	call	ADC_Setup	; setup ADC
	movlw	0x00
	movwf   TRISD
	movlw	0x00
	movwf   TRISE
	
	movlw   0x00
	movwf   less_than_count1
	movwf   greater_than_count1
	
	movlw	0x0d
	movwf	new_line
	return

	
measure_loop
	
	call	ADC_Read
	
	movlw	d'1'
	lfsr	FSR2, ADRESH
	call	UART_Transmit_Message
	
	movlw	d'1'
	lfsr	FSR2, ADRESL
	call	UART_Transmit_Message
	
	movlw	0x04
	cpfslt  ADRESH
	;movff   ADRESH, PORTD
	movff	should_reset, PORTD ;think of better check
	cpfsgt  ADRESH
	call    less_than
	cpfslt  ADRESH
	call    greater_than
	movff   ADRESH, PORTE
	call	send_data
	return
	;goto	measure_loop
	;bra     measure_loop
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
	
	;movlw	d'1'
	;lfsr	FSR2, less_than_count1
	;call	UART_Transmit_Message
	
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
	
;calculate_time
;	return

send_data	
	;movlw	d'1'
	;lfsr	FSR2, less_final_count1
	;call	UART_Transmit_Message
	
	;movlw	d'1'
	;lfsr	FSR2, less_final_count2
	;call	UART_Transmit_Message
	
	;movlw	d'1'
	;lfsr	FSR2, less_final_count3
	;call	UART_Transmit_Message
	
	;movlw	d'1'
	;lfsr	FSR2, greater_final_count1
	;call	UART_Transmit_Message
	
	;movlw	d'1'
	;lfsr	FSR2, greater_final_count2
	;call	UART_Transmit_Message
	
	;movlw	d'1'
	;lfsr	FSR2, greater_final_count3
	;call	UART_Transmit_Message
	
	; split data packages with new line
	movlw	d'1'
	lfsr	FSR2, new_line
	call	UART_Transmit_Message
	
	return
	
	; a delay subroutine if you need one, times around loop in delay_count
;delay	decfsz	delay_count	; decrement until zero
;	bra delay
;	return

	end