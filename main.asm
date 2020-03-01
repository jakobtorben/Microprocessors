	#include p18f87k22.inc

	extern  LCD_Setup, LCD_Write_Message, LCD_Send_Byte_I, LCD_delay_x4us, LCD_Clear_Display	    ; external LCD subroutines
	extern	servo_setup, pwm_loop
	extern  button_read, keypad_setup

	
	
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
      
      
tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	
	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup LCD
	call	servo_setup	; setup servo_control
	call	keypad_setup	; setup keypad
	
	goto	start
	
	; ******* Main programme ****************************************
start 	
	call	button_read
	call	pwm_loop
	
	goto start


	end
