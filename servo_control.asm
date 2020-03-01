#include p18f87k22.inc

    extern	button
    global	servo_setup, pwm_loop	

acs0    udata_acs	
Delay	    res 1
Delay1	    res 1
Delay2	    res 1
offset	    res 1

servo_control    code
	    
servo_setup
	banksel	    ADCON1
	movlw	    0x06 		; all pins digital I/O			
	movwf	    ADCON1	
	CLRF	    PORTC

	CLRF	    TRISC		; All pins on portc are output
	movlw	    d'37'
	movwf	    offset
	return
	
    
pwm_loop	
	BSF	    PORTC,1		;
	call	    Delay_10ms
	BCF	    PORTC,1		; Turn them off, no more pulse
	MOVLW	    d'200'		; set delay of approx 18ms
	CALL	    Delay_10x	; 
	return

;Setup up the delay routines that may be used
;delay of 0.1ms for 64MHz clock
;

Delay_0_1ms
	Movlw	    d'250'	
Delay_1x                                 ;call here with W set allows diiferent delays
	Movwf	    Delay
delay_loop			; 6 cycles
	Nop
	Nop
	Nop
	Decfsz	    Delay,f		; 1 cycle
	bra	    delay_loop	; 2 cycles
	return

;delay of variable length 
Delay_10ms
	movf	    button, 0
	subfwb	    offset, 0

Delay_10x                               ;call here with W set allows diiferent delays
	movwf	    Delay2
Delay_Loop_10ms	
	Call	    Delay_0_1ms		; Call 1ms delay	
	Decfsz	    Delay2,f
	bra	    Delay_Loop_10ms
	return	

	end
