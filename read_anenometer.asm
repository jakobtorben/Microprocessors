	#include p18f87k22.inc

	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern	UART_Setup, UART_Transmit_Message, UART_Transmit_Byte ; external UART subroutines
	global	measure_loop
	global	read_anenometer_setup
	
	acs0	udata_acs   ; reserve data space in access ram
	counter	    res 1   ; reserve one byte for a counter variable
	asdf	    res 1

	; reserve a byte for each of the counter bytes
	less_than_count1  res 1 
	less_than_count2  res 1 
	less_than_count3  res 1 

	greater_than_count1 res 1
	greater_than_count2 res 1
	greater_than_count3 res 1

	; reserve three bytes each for the saved values of the greater_than and 
	; less_than counts
	less_final_count1     res 1
	less_final_count2     res 1
	less_final_count3     res 1

	greater_final_count1  res 1
	greater_final_count2  res 1
	greater_final_count3  res 1

	should_reset          res 1 ; used to check if counts need resetting

	read_anenometer	code

	
read_anenometer_setup	;bcf	EECON1, CFGS	; point to Flash program memory  

	call	ADC_Setup	; setup ADC
	
	;set ports D and E to tri-state and output (used for debugging)
	movlw	0x00
	movwf   TRISD
	movlw	0x00
	movwf   TRISE
	
	;setting all counter bytes to zero
	movlw   0x00
	movwf   less_than_count1
	movwf   less_than_count2
	movwf   less_than_count3
	movwf   greater_than_count1
	movwf   greater_than_count2
	movwf   greater_than_count3
	
	movlw	0xff
	movwf	asdf
	return
	
measure_loop
	
	call	ADC_Read ; reads voltage V_out
	
	bsf	PORTD, 0 ; sets PORTD to high
	
	;if voltage not 1024mV or higher, then call less_than subroutine
	movlw	0x03
	cpfsgt  ADRESH
	call    less_than
	
	;if voltage not less than 1024mV, then call greater_than subroutine
	movlw	0x04
	cpfslt  ADRESH
	call    greater_than
	
	; output ADRESH value to PORTE LEDs to check ADC working
	movff   ADRESH, PORTE
	
	bcf	PORTD, 0 ; sets PORTD to low
	
	
	return
	
less_than
	call    check_gt ; checks if greater than count non-zero
	
	; if lowest byte of counter greater than 0xFF, increment second counter
	movlw   0xFF
	cpfslt  less_than_count1
	call    inc_lt_byte2
	
	; increment lowest byte of counter, if 0xFF, gores to 0x00
	incf    less_than_count1, W, ACCESS
	movwf   less_than_count1
	
	return
	
inc_lt_byte2
	; if second byte of counter greater than 0xFF, increment third counter
	movlw	0xFF
	cpfslt	less_than_count2
	call	inc_lt_byte3
	
	; increment second byte of counter, if 0xFF, gores to 0x00
	incf    less_than_count2, W, ACCESS
	movwf   less_than_count2
	
	return

inc_lt_byte3
	; increment third byte of counter
	incf	less_than_count3, W, ACCESS
	movwf	less_than_count3
	
	return
	
check_gt
	; increment value stored in should_reset if any byte of the counter 
	; holds a non-zero value
	movlw   0x00
	cpfseq   greater_than_count1
	call    increment_should_reset
	
	movlw	0x00
	cpfseq	greater_than_count2
	call	increment_should_reset
	
	movlw	0x00
	cpfseq	greater_than_count3
	call	increment_should_reset
	
	; save and reset counter bytes if should_reset holds a non-zero value
	movlw	0x00
	cpfseq	should_reset
	call	reset_gt
	
	; reset should_reset to zero
	movlw	0x00
	movwf	should_reset
	
	return
	
increment_should_reset
	; increments the value stored at should_reset
	incf	should_reset, W, ACCESS
	movwf	should_reset
	
	return
	
reset_gt
	; save count values for each byte
	movff   greater_than_count1, greater_final_count1
	movff   greater_than_count2, greater_final_count2
	movff   greater_than_count3, greater_final_count3
	
	; reset each byte of the counter to zero
	movlw   0x00
	movwf   greater_than_count1
	movwf	greater_than_count2
	movwf	greater_than_count3
	
	return
	
greater_than	
	call	check_lt ; checks if greater than count non-zero
	
	; if lowest byte of counter greater than 0xFF, increment second counter
	movlw   0xFF
	cpfslt  greater_than_count1
	call    inc_gt_byte2
	
	; increment lowest byte of counter, if 0xFF, gores to 0x00
	incf    greater_than_count1, W, ACCESS
	movwf   greater_than_count1
	
	return
	
inc_gt_byte2	
	; if second byte of counter greater than 0xFF, increment third counter
	movlw	0xFF
	cpfslt	greater_than_count2
	call	inc_gt_byte3
	
	; increment second byte of counter, if 0xFF, gores to 0x00
	incf    greater_than_count2, W, ACCESS
	movwf   greater_than_count2
	
	return

inc_gt_byte3
	; increment third byte of counter
	incf	greater_than_count3, W, ACCESS
	movwf	greater_than_count3
	
	return
	
check_lt
	; increment value stored in should_reset if any byte of the counter 
	; holds a non-zero value
	movlw   0x00
	cpfseq   less_than_count1
	call    increment_should_reset
	
	movlw	0x00
	cpfseq	less_than_count2
	call	increment_should_reset
	
	movlw	0x00
	cpfseq	less_than_count3
	call	increment_should_reset
	
	; save and reset counter bytes if should_reset holds a non-zero value
	movlw	0x00
	cpfseq	should_reset
	call	reset_lt
	
	; reset should_reset to zero
	movlw	0x00
	movwf	should_reset
	
	return
	
reset_lt
	; save count values for each byte
	movff   less_than_count1, less_final_count1
	movff   less_than_count2, less_final_count2
	movff   less_than_count3, less_final_count3
	
	call	send_data ; subroutine sends saved greater_than and less_than 
	; final counts to the UART
	
	; reset each byte of the counter to zero
	movlw   0x00
	movwf   less_than_count1
	movwf	less_than_count2
	movwf	less_than_count3
	
	return

send_data	
	; three byte sequence signifying the start of the data transmission
	movlw	0x0d
	call	UART_Transmit_Byte
	
	movlw	0xff
	call	UART_Transmit_Byte
	
	movlw	0x0d
	call	UART_Transmit_Byte
	
	; transmit highest bytes first, first for the less_than count, then for 
	; the greater_than count
	movf	less_final_count3, W
	call	UART_Transmit_Byte
	
	movf	less_final_count2, W
	call	UART_Transmit_Byte
	
	movf	less_final_count1, W
	call	UART_Transmit_Byte
	
	movf	greater_final_count3, W
	call	UART_Transmit_Byte
	
	movf	greater_final_count2, W
	call	UART_Transmit_Byte
	
	movf	greater_final_count1, W
	call	UART_Transmit_Byte
	
	return
	
	    

	end