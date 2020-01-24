	#include p18f87k22.inc
	
	code
	org 0x0
	goto	main
	
	org 0x100		    ; Main code starts here at address 0x100
	
main    
	call	SPI_MasterInit
	bra	SPI_MasterTransmit

	; ******* Programme FLASH read Setup Code ****  
;setup	bcf	EECON1, CFGS	; point to Flash program memory  
;	bsf	EECON1, EEPGD 	; access Flash program memory
;	movlw	0xf0
;	movwf	TRISD, A
;	setf	TRISE ; Tri-state PortE
;	banksel	PADCFG1 ; PADCFG1 is not in Access Bank!!
;	bsf	PADCFG1, REPU, BANKED ; PortE pull-ups on
;	movlb	0x00 ; set BSR back to Bank 0
;
;	;movlw	0xff
;	;movwf	PORTD, A
;	goto	start
	
	; ******* My data and where to put it in RAM *
;myTable data	 "This is just some data"
;	constant myArray=0x400	; Address in RAM for data
;	constant counter=0x10	; Address of counter variable
	; ******* Main programme *********************

;start 	;lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
;	movlw	0x06	; address of data in PM
;	call	writemem1
;	movlw   0x05
;	call	writemem2
;	call    read
;	goto	start
;
;	constant OE1=0
;	constant OE2=1
;	constant CP1=2
;	constant CP2=3
;writemem1		    ; writes content of W to memory 1
;	bsf	LATD, OE1   ;set PORTD RF0 to high (output enable*)
;	bsf	LATD, OE2   ;set PORTD RF1 to high
;	bsf	LATD, CP1   ;set PORTD RF2 to high
;	bsf	LATD, CP2   ;set PORTD RF3 to high
;	clrf	TRISE	    ;sets PORTE to output
;	movwf	LATE	    ;moves w onto PORTE (onto the databus)
;	bcf	LATD, CP1   ;sets PORTD RF2 to low
;	nop
;	nop
;	nop
;	nop
;	bsf	LATD, CP1   ;sets PORTD RF2 back to high
;	setf	TRISE	    ;sets PORTE to input
;	return
;	
;writemem2
;	clrf	TRISE	    ;sets PORTE to output
;	movwf	LATE	    ;moves w onto PORTE (onto the databus)
;	bcf	LATD, CP2   ;sets PORTD RF3 to low
;	nop
;	nop
;	nop
;	nop
;	bsf	LATD, CP2   ;sets PORTD RF3 back to high
;	setf	TRISE	    ;sets PORTE to input
;	return
;	
;read			    ; read content of memory 1 to PORTC
;	bcf	LATD, OE1   ;set PORTD RF0 to low (output enable)
;	clrf	TRISC	    ;sets PORTC to output
;	movff	PORTE, PORTC
;	bsf	LATD, OE1   ;set PORTD RF0 to low (output enable*)
;			    ; read content of memory 2 to PORTH
;	bcf	LATD, OE2   ;set PORTD RF1 to low
;	clrf	TRISH	    ;sets PORTH to output
;	movff	PORTE, PORTH
;	bsf	LATD, OE2   ;set PORTD RF0 to low (output enable*)
;	
;	goto	0
	

SPI_MasterInit ; Set Clock edge to negative
	bcf	SSP2STAT, CKE
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw	(1<<SSPEN)|(1<<CKP)|(0x02) ;probably change this to movff
	movwf	SSP2CON1
	; SDO2 output; SCK2 output
	bcf	TRISD, SDO2
	bcf	TRISD, SCK2
	call	SPI_MasterTransmit
	
	
SPI_MasterTransmit ; Start transmission of data (held in W)
	movlw	0x111
	movwf	SSP2BUF
	; movff	SSP2BUF, SDO2
	
	;call    Wait_Transmit
Wait_Transmit ; Wait for transmission to complete
	btfss	PIR2, SSP2IF
	bra	Wait_Transmit
	bcf	PIR2, SSP2IF ; clear interrupt flag
	
	return


	end
