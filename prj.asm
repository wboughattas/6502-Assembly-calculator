; Wasim Boughattas
    .org $0801

    .byte $0B, $08, $E4, $00, $9E, $32, $30, $36, $31, $00, $00, $00

welcome:
    JSR reset ;reset all variables to 0

    ;print hello_instruction
    LDA #00 ;load 0 to accumulator
    STA index ;initialize index to increment over the number of characters of the hello_instruction
    JMP print_hello_instruction ;jump to this address to print the instruction

main:
    JSR get_char ;goto get_char to store any input in variable char then print it ...
                 ;...if input is valid(within 0-9, "=", and "+" and if number is a 1-to-4-digits number), ... 
                 ;...otherise it is a loop until input is valid

    LDA char ;load variable char

    ;checks if input is =
    CMP #$3D
    BEQ end ;end the program

    ;checks if input is integer
    CMP #$30
    BMI here ;if input < 0, goto here (line 33)
    JMP save_digit ;save the digit

here:    
    ;input is +
    ;the past number is added to sum 
    JSR addPastNumber ;goto addPastNumber then return here
    JMP main ;loop

end:
    JSR addPastNumber ;goto addPastNumber to add the number preceding "=" to sum then return here

    ;print "overflow" if the carry digit equals 1
    LDA #00 ;load 0 to accmulator
    STA index ;store it in index
    LDA carry4 ;load carry4
    CMP #01 ;compare it to 1
    BEQ print_overflow ;if it equals 1, goto print_overflow

stop:
    ;print the sum and halts the program
    JSR print_sum ;goto to print_sum then return here
    RTS ;end subroutine
        ;halts the program

halt:
    ;halts the program without printing 
    ;used when there is overflow
    RTS


;public static void main() ends here
;below are methods that are called by main()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;printing methods start here


print_hello_instruction:
  ; load hello_instruction[index] into A using X as the indexing register
  LDX index
  LDA hello_instruction, X

  ; if the value loaded into A, go to main
  BEQ main

  ; call the KERNAL to print the character with the code in A
  JSR $FFD2

  ; increment the variable index
  INC index

  ; restart the loop
  JMP print_hello_instruction

print_overflow:
  ; load overflow[index] into A using X as the indexing register
  LDX index
  LDA overflow, X

  ; if the value loaded into A, go to stop
  BEQ halt

  ; call the KERNAL to print the character with the code in A
  JSR $FFD2

  ; increment the variable index
  INC index

  ; restart the loop
  JMP print_overflow

get_char:
    ;read input
    CLC
	JSR $FFE4 ;input scanner subroutine
    BEQ get_char

    STA char ;store A in char
    CLC ;clear carry

    ;proceed to print_char upon verifying the validity of char

print_char:
    ;print char iff char is within 0-9, "=", and "+" and if number is a 1-to-4-digits number
    ;otherwise return to main (which re-triggers get_char)
    
    CLC ;clear carry
    
    ;if input is allowed, goto go_here, otherwise return to main 
    CMP #$2B ;compare to + 
    BEQ operator
    CMP #$3D ;compare to = 
    BEQ operator
    CMP #$30 ;compare to 0 
    BEQ integer 
    CMP #$31 ;compare to 1 
    BEQ integer
    CMP #$32 ;compare to 2 
    BEQ integer
    CMP #$33 ;compare to 3 
    BEQ integer 
    CMP #$34 ;compare to 4 
    BEQ integer
    CMP #$35 ;compare to 5 
    BEQ integer
    CMP #$36 ;compare to 6 
    BEQ integer 
    CMP #$37 ;compare to 7 
    BEQ integer
    CMP #$38 ;compare to 8 
    BEQ integer
    CMP #$39 ;compare to 9 
    BEQ integer 

    ;input is invalid, return to get a new input
    JMP get_char ;jump to get_char

integer:
    LDA n_digits ;load # of digits
    CMP #$04 ;if the number of digits reached 4, do not accept any more digits
    BEQ get_char

operator:
    ;prints the input istantenously for visual reference
    LDA char
	JSR $FFD2 ;print subroutine
    RTS

print_sum:
    ;print sum digits
    CLC
    LDA sum4
    ADC #$30 ;added 30 to follow petscii addressing
	JSR $FFD2 ;print subroutine

    CLC
    LDA sum3
    ADC #$30 ;
	JSR $FFD2 ;

    CLC
    LDA sum2
    ADC #$30 ;
	JSR $FFD2 ;

    CLC
    LDA sum1
    ADC #$30 ;
	JSR $FFD2 ;

    RTS


;printing methods end here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;arithmetic methods start here


;SUMMARY
;the addition algorithm is the same as adding 2 numbers by hand
;step1: add the first 2 digits of each number.
;step2: If sum of the 2 digits >= 10, (1) is carried and sum is subtracted by 10. It is guaranteed that the carry is either 0 or 1
;step3: repeat step1, but also add the carry
;step4: repeat step2
; ....
;final step: if there is overflow (final carry equals 1), print "overflow", otherwise print all sum digits
addPastNumber:
    ;add the first saved digit to the sum's first digit
    CLC ;clear carry
    LDA digit1 ;load digit1 to accumulator
    ADC sum1 ;add sum1 to A
    STA sum1 ;store A im sum1
    CMP #$0A ;compare to 10
    BPL carryDigit1 ;if digit1 + sum's 1 digit >= 10, then goto carryDigit1 to produce a carry digit

checkpoint1:
    ;add the second saved digit to the sum's second digit
    CLC ;
    LDA digit2 ;
    ADC sum2 ;
    ADC carry1 ;
    STA sum2 ;
    CMP #$0A ;compare to 10
    BPL carryDigit2 ;

checkpoint2:    
    ;add the third saved digit to the sum's third digit
    CLC ;
    LDA digit3 ;
    ADC sum3 ;
    ADC carry2 ;
    STA sum3 ;
    CMP #$0A ;compare to 10
    BPL carryDigit3

checkpoint3:
    ;add the fouth saved digit to the sum's fourth digit
    CLC ;
    LDA digit4 ;
    ADC sum4 ;
    ADC carry3 ;
    STA sum4 ;
    CMP #$0A ;compare to 10
    BPL carryDigit4 ;

checkpoint4:
    ;reset all variables to prepare to store the next number's digits except of carry4
    ;carry4 content will detect if there is overflow 
    ;carry4 is reset once the program is restarted
    LDA #00
    STA n_digits
    STA digit1
    STA digit2
    STA digit3
    STA digit4
    STA carry1
    STA carry2
    STA carry3

    RTS ;end subroutine

carryDigit1:
    INC carry1 ;carry1 is incremented by 1
    LDA sum1
    SEC
    SBC #10 ;subtract sum's 1st digit by 10
    STA sum1 ;store A in sum's 1st digit
    JMP checkpoint1 ;jump to checkpoint1 (line 103)

carryDigit2:
    INC carry2 ;
    LDA sum2
    SEC
    SBC #10 ;
    STA sum2 ;
    JMP checkpoint2 ;

carryDigit3:
    INC carry3 ;
    LDA sum3
    SEC
    SBC #10 ;
    STA sum3 ;
    JMP checkpoint3 ;

carryDigit4:
    INC carry4 ;
    LDA sum4
    SEC
    SBC #10 ;
    STA sum4 ;
    JMP checkpoint4 ;

storeDigit1:
    LDA char ;load input in A
    SEC
    SBC #$30 ;subtract A by 30 so that the address of the ...
             ;... digit is equivalent to the the value that it is storing (in 2's complement)
             ;explained in detail in the report
    STA digit1 ;char is stored in digit1
    JMP main ;jump to main

storeDigit2:
    LDA digit1 ;
    STA digit2 ;digit1 has been promoted to digit2
               ;e.g. user wants to input the number 18, user ...
               ;...starts by inputting 1 then digit1 = char = 1 ...
               ;then inputs 8, digit2 = digit1 = 1 and digit2 = char = 8 
    LDA char
    SEC
    SBC #$30
    STA digit1 ;char is stored in digit1
    JMP main ;

storeDigit3:
    LDA digit2
    STA digit3 ;digit2 has been promoted to digit3
    LDA digit1
    STA digit2 ;digit1 has been promoted to digit2
    LDA char
    SEC
    SBC #$30
    STA digit1 ;char is stored in digit1
    JMP main ;

storeDigit4:
    LDA digit3
    STA digit4 ;digit3 has been promoted to digit4
    LDA digit2
    STA digit3 ;digit2 has been promoted to digit3
    LDA digit1
    STA digit2 ;digit1 has been promoted to digit2
    LDA char
    SEC
    SBC #$30
    STA digit1 ;char is stored in digit1
    JMP main ;

save_digit:
    ;once the input is verified as an integer, this function saves that integer
    INC n_digits ;increment the number of digits
    
    CLC
    LDA n_digits

    CMP #$01
    BEQ storeDigit1 ;store the first digit encountered

    CMP #$02
    BEQ storeDigit2 ;store the 2nd digit

    CMP #$03
    BEQ storeDigit3 ;store the 3rd digit

    ;storeDigit4 address was out of range so CMP-BEQ was replaced by a CMP-BNE-JMP-JMP which serves the same purpose
    ;explained in detail in the report
    CMP #$04
    BNE fix
    JMP storeDigit4 ;store the 4th digit
fix:
    JMP main ;this is never reached

reset:
    ;reset all variables when the the program is restarted
    LDA #00
    STA char
    STA n_digits
    STA digit1
    STA digit2
    STA digit3
    STA digit4
    STA sum1
    STA sum2
    STA sum3
    STA sum4
    STA carry1
    STA carry2
    STA carry3
    STA carry4

    RTS

;arithmetic methods end here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;variables are stated below


char: ;store the input
    .byte $00

;the numbers below are subtracted by $30
;they will not follow the petscii ordering
;e.g. $00<-0, $01<-1, ..., $09<-9
n_digits: ;the number of digits of the number
    .byte $00

digit1: ;first digit of input number
    .byte $00

digit2: ;second digit of input number
    .byte $00

digit3: ;third digit of input number
    .byte $00

digit4: ;fourth digit of input number
    .byte $00

sum1: ;first digit of sum result
    .byte $00

sum2: ;second digit of sum result
    .byte $00

sum3: ;third digit of sum result
    .byte $00

sum4: ;fourth digit of sum result
    .byte $00

carry1: ;carry from sum's first digit to second
    .byte $00

carry2: ;carry from sum's second digit to third
    .byte $00

carry3: ;carry from sum's third digit to fourth
    .byte $00

carry4: ;carry from sum's fourth digit to fifth
        ;triggers overflow if it equals 0
    .byte $00

;to print
index:
    .byte 0
hello_instruction:
    ;this is an array of bytes representing character codes
    .byte $0D, $50, $52, $4f, $4a, $45, $43, $54, $20, $4d, $41, $44, $45, $20, $42, $59, $3a, $20, $57, $41, $53, $49, $4d, $20, $42, $4f, $55, $47, $48, $41, $54, $54, $41, $53, $20, $28, $34, $30, $31, $32, $36, $30, $32, $38, $29, $0D, $0D, $45, $58, $41, $4d, $50, $4c, $45, $53, $20, $4f, $46, $20, $49, $4e, $50, $55, $54, $3a, $0D, $31, $2b, $31, $31, $2b, $31, $31, $31, $2b, $31, $31, $31, $31, $3d, $0D, $39, $2b, $39, $39, $2b, $39, $39, $39, $3d, $0D, $30, $3d, $0D, $0D, $4e, $2e, $42, $2e, $3a, $20, $54, $48, $45, $20, $49, $4e, $50, $55, $54, $20, $53, $43, $41, $4e, $4e, $45, $52, $20, $52, $41, $52, $45, $4c, $59, $20, $44, $4f, $45, $53, $4e, $27, $54, $20, $52, $45, $47, $49, $53, $54, $20, $57, $48, $49, $43, $48, $20, $4d, $45, $53, $53, $45, $53, $20, $57, $49, $54, $48, $20, $54, $48, $45, $20, $4f, $55, $54, $50, $55, $54, $2e, $0D, $54, $4f, $20, $52, $45, $53, $54, $41, $52, $54, $20, $54, $48, $45, $20, $50, $52, $4f, $47, $52, $41, $4d, $2c, $20, $53, $49, $4d, $50, $4c, $59, $20, $50, $52, $45, $53, $53, $20, $22, $3d, $22, $20, $41, $4e, $44, $20, $54, $59, $50, $45, $20, $22, $52, $55, $4e, $22, $20, $28, $43, $41, $50, $53, $20, $4b, $45, $59, $20, $4d, $55, $53, $54, $20, $42, $45, $20, $4f, $46, $46, $29, $2e, $0D, $0D, $00

overflow:
    ;this is an array of bytes representing character codes
    .byte $4f, $56, $45, $52, $46, $4c, $4f, $57, $21, $4f, $56, $45, $52, $46, $4c, $4f, $57, $21, $00
