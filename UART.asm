#include p18f87k22.inc

    global  UART_Setup, UART_Setup2, UART_Transmit_Message, UART_receive_Message, UART_Transmit_Byte

acs0    udata_acs	    ; named variables in access ram
UART_counter res 1	    ; reserve 1 byte for variable UART_counter
UART_counter2 res 1	    ; reserve 1 byte for variable UART_counter
TMP_TX EQU 0x20
;value

UART    code
    
UART_Setup
    bsf	    RCSTA1, SPEN    ; enable
    bcf	    TXSTA1, SYNC    ; synchronous
    bcf	    TXSTA1, BRGH    ; slow speed
    bsf	    TXSTA1, TXEN    ; enable transmit
    bcf	    BAUDCON1, BRG16 ; 8-bit generator only
    movlw   .103	    ; gives 9600 Baud rate (actually 9615)
    movwf   SPBRG1
    bsf	    TRISC, TX1	    ; TX1 pin as output
    return

UART_Transmit_Message	    ; Message stored at FSR2, length stored in W
    movwf   UART_counter
UART_Loop_message
    movf    POSTINC2, W
    call    UART_Transmit_Byte
    decfsz  UART_counter
    bra	    UART_Loop_message
    return

UART_Transmit_Byte	    ; Transmits byte stored in W
    btfss   PIR1,TX1IF	    ; TX1IF is set when TXREG1 is empty
    bra	    UART_Transmit_Byte
    movwf   TXREG1
    return
    
    
UART_Setup2
    bsf	    RCSTA1, SPEN    ; enable
    bcf	    RCSTA1, SYNC    ; synchronous
    bcf	    RCSTA1, BRGH    ; slow speed
    bsf	    RCSTA1, SREN    ; enable input
    bcf	    BAUDCON1, BRG16 ; 8-bit generator only
    movlw   .103	    ; gives 9600 Baud rate (actually 9615)
    movwf   SPBRG1
    bcf	    TRISG, RX1	    ; RX1 pin as input
    
    MOVLW b'10010000' ; enable receive and serial port
    MOVWF RCSTA
    BSF TRISC, RX1 ; make RX pin an input
    CLRF TRISB
    

    return

UART_receive_Message	    ; Message stored at FSR2, length stored in W
    movwf   UART_counter2
UART_Loop_message2
    movf    POSTINC2, W
    call    UART_receive_Byte
    decfsz  UART_counter2
    bra	    UART_Loop_message2
    return
    
    
    
UART_receive_Byte	    ; Transmits byte stored in W
    ;BCF INTCON,7 ;DISABLE ALL INTERRUPTS
    ;BTFSS PIR1,5
    ;btfss   PIR1,RC1IF	    ; TX1IF is set when TXREG1 is empty
    BTFSS PIR1, RCIF ; check for ready
    bra	    UART_receive_Byte
    MOVFF RCREG, PORTB
    ;movf   RCREG1, W
    return

    end


