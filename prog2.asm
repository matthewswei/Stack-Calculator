; Postfix Expression Stack Calculator
;
; This program calculates final result given in a postfix expression and outputs the final result as
; a hexadecimal. Taken inputs are the single digits 0-9 and the operands +-*/^ and =. After typing in
; the expression, type equal to calulate the expression. If at any point there is an invalid expression
; being typed, the program will end and print "Invalid Expression", same as if the final expression
; is invalid. Program was coded using the stack data strucuture by pushing and popping values when
; needed during the program. Reused code was used from MP1 for printing a value in hexadecimal by
; left-shifting the bit. JSR subroutines were coded as well to help and simplify operand math.
;
; Algorithm:
;	- Look at input and determine its value
;	- If number, add to stack and if operand, pop values from stack and call corrosponding subroutine
;	  to calulate final value
;	- Repeat until invalid expression is detected or an equal sign is inputed
;	- Print "Invalid Epression" or the final value in hexadecimal
;
; Register Table
;
;	R0 - character input from keyboard
;	R1 - temporary register
;	R2 - counter for checking numbers
;	R3 - holds older inputed value
;	R4 - holds newer inputed value
;	R5 - holds final value and holds overflow/underflow checker
;	R6 - current numerical output
;
;	Matthew Shuyu Wei
;	mswei2
;	Febuary 10, 2022

.ORIG x3000	

EVALUATE			;Start of getting input charater
	GETC
	ST R0,REG0_SAVE
SPACE_LOOP			;Checks if input was a space
	LD R1, SPACE
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz ECHO_SPACE
	BRnp NUM_LOOP		;Goes to check number if not a space
NUM_LOOP			;Initializes registers for NUMIN_LOOP
	AND R2,R2,#0
	AND R3,R3,#0
	AND R4,R4,#0
	ADD R2,R2,#9
	LEA R3,NUM
NUMIN_LOOP			;Checks if input was a number
	LDR R1,R3,#0
	ADD R1,R1,R4
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R0,R1
	BRz ECHO
	ADD R4,R4,#1
	ADD R2,R2,#-1
	BRzp NUMIN_LOOP		;Loops back to check all numbers 0-9
	BRnzp OP_LOOP		;If not number, goes to check if operator
OP_LOOP				;Checks if input was an operand
	LD R1, ADDITION
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz ECHO1
	LD R1, SUBTRACTION
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz ECHO1
	LD R1, MULTIPLY
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz ECHO1
	LD R1, DIVIDE
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz ECHO1
	LD R1, POWER
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz ECHO1
	LD R1, EQUAL
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz ECHO2
	BRnzp EVALUATE			;Goes back to get next input
DO_OPS					;Determines which operand to use for math
	LD R1, ADDITION
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz ADD_NUM
	LD R1, SUBTRACTION
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz SUB_NUM
	LD R1, MULTIPLY
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz MUL_NUM
	LD R1, DIVIDE
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz DIV_NUM
	LD R1, POWER
	NOT R1,R1
	ADD R1,R1,#1
	ADD R1,R1,R0
	BRz POW_NUM
	BRnp EVALUATE			;Goes back to get next input
ADD_NUM					;Adds values, updates stack, and stores in R5 
	JSR PLUS
	JSR PUSH
	AND R5,R5,#0
	ADD R5,R0,#0
	ST R5,REG5_SAVE
	BRnzp EVALUATE			;Goes back to get next input
SUB_NUM					;Subtracts values, updates stack, and stores in R5
	JSR MIN
	JSR PUSH
	AND R5,R5,#0
	ADD R5,R0,#0
	ST R5,REG5_SAVE
	BRnzp EVALUATE			;Goes back to get next input
MUL_NUM					;Multiplies values, updates stack, and stores in R5
	JSR MUL
	JSR PUSH
	AND R5,R5,#0
	ADD R5,R0,#0
	ST R5,REG5_SAVE
	BRnzp EVALUATE			;Goes back to get next input
DIV_NUM					;Divides values, updates stack, and stores in R5
	JSR DIV
	JSR PUSH
	AND R5,R5,#0
	ADD R5,R0,#0
	ST R5,REG5_SAVE
	BRnzp EVALUATE			;Goes back to get next input
POW_NUM					;Powers values, updates stack, and stores in R5
	JSR EXP
	JSR PUSH
	AND R5,R5,#0
	ADD R5,R0,#0
	ST R5,REG5_SAVE
	BRnzp EVALUATE			;Goes back to get next input
ECHO	LD R0,REG0_SAVE			;Prints number value and updates stack and registers
	LD R1,NEG_NUM			;Converts ASCII over to actual value in hexadecimal
	ADD R0,R0,R1
	JSR PUSH
	AND R5,R5,#0
	ADD R5,R5,R0
	ST R5,REG5_SAVE
	LD R0,REG0_SAVE
	OUT
	LD R1,INPUT_CK			;Updates counter to inform at least one valid input has been seen
	ADD R1,R1,#1
	ST R1,INPUT_CK
	BRnzp EVALUATE			;Goes back to get next input
ECHO1	LD R0,REG0_SAVE			;Prints operand and updates registers for math through stack
	OUT
	ST R0,REG0_SAVE
	AND R3,R3,#0
	AND R4,R4,#0
	JSR POP
	ADD R5,R5,#0
	BRnp INVALID			;Checks if underflow occured
	ADD R4,R0,#0
	JSR POP
	ADD R5,R5,#0
	BRnp INVALID			;Checks if underflow occured
	ADD R3,R0,#0
	LD R0,REG0_SAVE
	BRnzp DO_OPS			;Goes to determine which operand to use for math
ECHO2	LD R0,EQUAL			;Prints equal sign
	OUT
	BRnzp CHECK_STACK
ECHO_SPACE				;Prints space
	LD R0,SPACE
	OUT
	BRnzp EVALUATE			;Goes back to get next input
CHECK_STACK				;Checks if there is underflow or invalid input was inputed
	LD R4,INPUT_CK
	ADD R4,R4,#0
	BRz INVALID			;Checks if expression was invalid
	LD R4,STACK_BEG
	LD R5,REG5_SAVE
	NOT R4,R4
	ADD R4,R4,#1
	ADD R4,R4,R6
	BRz DONE
	BRnp INVALID			;Checks if expression was invalid
INVALID					;Prints invalid expression
	AND R5,R5,#0
	ST R5,REG5_SAVE
	LEA R3,INVALID_EX
PRINTI	LDR R0,R3,#0
	BRz COMP
	OUT
	ADD R3,R3,#1
	BRnp PRINTI
DONE	LD R1,CHECK			;Start of printing hexadecimal, initalizes values
	JSR POP
	AND R2,R2,#0
	ADD R2,R0,R2

; Reused code from MP1. Algorithm for this code is checking left-most bit for its value four times
; in four groups representing each digit in hexadecimal. Then it determines if the value is 0-9 or 10-15
; and prints out either 0-9 or A-F depending on its value. This will result in a hexidecimal value being
; printed.
;
; Register Table
;	R0 - printing regiser
;	R1 - holds x8000 to check left-most bit
;	R2 - holds value to be left-shifted
;	R3 - holds left-shifted value
;	R4 - digit counter for each digit in one part of hexidecimal value
;	R6 - ASCII counter for each hexadecimal value

START				;Initializes everything for the line being printed
	AND R4,R4,#0		;Reset counter to 0
	ADD R4,R4,#4		;Set counter to 4
	LD  R6,COUNT		;Load counter to temporary register
	AND R6,R6,#0		;Resets counter for future loops
	ADD R6,R6,#4		;Sets counter to 4
	ST  R6,COUNT		;Stores coutner back to memory
VALUE_CHECKER			;Determines if value is 0 or 1
	AND R3,R1,R2		;ANDs value and x8000 to determine if value if 1 or 0
	BRz ZERO		;Branch to ZERO if 0
	BRnp ONE		;Branch to ONE if 1
ONE				;Adds one to temporary 4-bit container
	LD  R6,ASCII_COUNT	;Loads 4-bit container to temporary register
	ADD R6,R6,R6		;Left-Shifts 4-bit container
	ADD R2,R2,R2		;Left-Shifts histogram value
	ADD R6,R6,#1		;Adds one to 4-bit container
	ST  R6,ASCII_COUNT	;Stores 4-bit container back to memory
	ADD R4,R4,#-1		;Decrement counter
	BRz DET_VAL		;Branch to DET_VAL if 4 bits have been checked
	BRnp VALUE_CHECKER	;Branch to VALUE_CHECKER for next bit
ZERO				;Adds zero to temporary 4-bit container
	LD  R6,ASCII_COUNT	;Loads 4-bit container to temporary register
	ADD R6,R6,R6		;Left-Shifts 4-bit container
	ADD R2,R2,R2		;Left-Shifts histogram value
	ST  R6,ASCII_COUNT	;Stores 4-bit container back to memory
	ADD R4,R4,#-1		;Decrement counter
	BRz DET_VAL		;Branch to DET_VAL if 4 bits have been checked
	BRnp VALUE_CHECKER	;Branch to VALUE_CHECKER for next bit
DET_VAL				;Determines if the group of 4 bits is 0-9 or A-F
	LD  R6,ASCII_COUNT	;Loads 4-bit container to temporary register
	ADD R6,R6,#-9		;Subtracts 9 from register to determine if value should be 0-9 or A-F
	BRp PRINT_ALPHA		;Branch to PRINT_ALPHA if value is greater than 9
	BRnz PRINT_NUM		;Branch to PRINT_NUM if value is less than or equal to 9
PRINT_NUM			;Prints number 0-9
	LD R0,ASCII_COUNT	;Loads number into printing register
	LD R6,NUM		;Loads ASCII value for 0 to temporary register
	ADD R0,R0,R6		;Sets printing register equal to number for printing
	OUT			;Prints from printing register
	LD  R6,ASCII_COUNT	;Loads ASCII_COUNT to temporary register
	AND R6,R6,#0		;Resets ASCII_COUNT to 0
	ST  R6,ASCII_COUNT	;Stores ASCII_COUNT back to memory
	LD  R6,COUNT		;Loads counter to temporary register
	ADD R6,R6,#-1		;Decrements from coutner
	BRz COMP		;Goes to FINISH if counter reaches 0
	ST  R6,COUNT		;Stores counter back to memory
	ADD R4,R4,#4		;Resets bit counter back to 4
	BRnzp VALUE_CHECKER	;Branches to VALUE_CHECKER
PRINT_ALPHA			;Prints letter A-F
	LD R0,HEX		;Loads @ into register
	ADD R0,R0,R6		;Adds offest to get R0 equal to A-F
	OUT			;Prints from printing register
	LD  R6,ASCII_COUNT	;Loads ASCII_COUNT to temporary register
	AND R6,R6,#0		;Resets ASCII_COUNT to 0
	ST  R6,ASCII_COUNT	;Stores ASCII_COUNT back to memory
	LD  R6,COUNT		;Loads coutner to temporary register
	ADD R6,R6,#-1		;Subtracts 1 from coutner
	BRz COMP		;Goes to FINISH if counter reaches 0
	ST  R6,COUNT		;Stores counter back to memory
	ADD R4,R4,#4		;Resets bit counter back to 4
	BRnzp VALUE_CHECKER	;Branches to VALUE_CHECKER
COMP	HALT

; the data needed by the program
REG0_SAVE	.FILL x0000
REG5_SAVE	.FILL x0000
HEX		.FILL x0040	;Holds @
LETTER_COUNT	.FILL x0010	;Holds count for letters
COUNT		.FILL x0000	;Acts as a counter to make sure only 4 digits are printed
ASCII_COUNT	.FILL x0000	;Acts as a container to hold the 4 digits being printed
INVALID_EX	.STRINGZ "Invalid Expression"
SPACE		.FILL x0020	;Holds space
ADDITION	.FILL x002B	;Holds +
SUBTRACTION	.FILL x002D	;Holds -
MULTIPLY	.FILL x002A	;Holds *
DIVIDE		.FILL x002F	;Holds /
POWER		.FILL x005E	;Holds ^
EQUAL		.FILL x003D	;Holds =
CHECK		.FILL x8000	;Holds 1000000000000000
INPUT_CK	.FILL x0000	;Checks if at least one input is inputed
NUM		.FILL x0030	;Holds 0
NEG_NUM		.FILL xFFD0	;Holds negative value of x0030
STACK_BEG	.FILL x3FFF	;Holds beginning of stack

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subroutine for calculating addition (R3+R4)
;input R3, R4
;out R0
PLUS
	AND R0,R0,#0	
	ADD R0,R3,R4
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subroutine for calculating subtraction (R3-R4)
;input R3, R4
;out R0
MIN	
	AND R0,R0,#0
	NOT R4,R4
	ADD R4,R4,#1
	ADD R0,R3,R4
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subroutine for calculating multiplication (R3*R4)
;input R3, R4
;out R0
MUL	
	LD R0,CHECK
	AND R0,R3,R0
	BRn MULN
	BRzp MULN2
MULN	NOT R3,R3		;R3 is negative
	ADD R3,R3,#1
	BRnzp MULN1
MULN1	LD R0,CHECK		;Checks if R4 is negative if R3 is negative
	AND R0,R4,R0
	BRn MULC4
	AND R0,R0,#0
	BRzp MUL2
MULC4	NOT R4,R4		;R4 is negative and R3 is negative
	ADD R4,R4,#1
	AND R0,R0,#0
	BRnzp MUL1
MULN2	LD R0,CHECK		;Checks if R4 is negative if R3 is positive
	AND R0,R4,R0
	BRn MULC41
	AND R0,R0,#0
	BRzp MUL1
MULC41	NOT R4,R4		;R4 is negative and R3 is positive
	ADD R4,R4,#1
	AND R0,R0,#0
	BRnzp MUL2
MUL1	ADD R0,R3,R0		;Both are positive or negative
	ADD R4,R4,#-1
	BRp MUL1
	BRz MULE
	BRn MULZ
MUL2	ADD R0,R3,R0		;Just one is regative
	ADD R4,R4,#-1
	BRp MUL2
	BRz MULRN
	BRn MULZ
MULRN	NOT R0,R0		;Negate value
	ADD R0,R0,#1
	BRnzp MULE
MULZ	AND R0,R0,#0		;If one of the inputs was 0
MULE	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subroutine for calculating division (R3/R4)
;input R3, R4
;out R0
DIV	
	LD R0,CHECK
	AND R0,R3,R0
	BRn DIVN
	AND R0,R0,#0
	BRzp DIVS1	
DIVS1	AND R0,R0,#0		;Negates R4 for division
	NOT R4,R4
	ADD R4,R4,#1
DIV1	ADD R3,R3,R4		;Loop for doing division
	BRn DIVE
	ADD R0,R0,#1
	BRzp DIV1
DIVN	NOT R3,R3		;If R3 is negative
	ADD R3,R3,#1
	BRnzp DIVS2
DIVS2	AND R0,R0,#0		;Division for R3 negative
	NOT R4,R4
	ADD R4,R4,#1
DIV2	ADD R3,R3,R4		;Loop for division if R3 was negative
	BRn DIVRN
	ADD R0,R0,#1
	BRzp DIV2
DIVRN	NOT R0,R0		;Negates value
	ADD R0,R0,#1
DIVE	RET
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subroutine for calculating power (R3^R4)
;input R3, R4
;out R0
EXP
	AND R0,R0,#0
	AND R1,R1,#0
	ADD R0,R3,#0
	ADD R1,R4,#0
	ADD R1,R1,#-1
	BRn EXPZ		;Checks if R4 was 0
	BRz EXPE		;Checks if R4 was 1
	AND R4,R4,#0
	AND R2,R2,#0
	ADD R4,R3,#0
	ADD R2,R2,R4
EXP1	ST R7,REG7_SAVE		;Goes through loop to calcualte power
	JSR MUL
	LD R7,REG7_SAVE
	AND R3,R3,#0
	ADD R3,R0,#0
	AND R4,R4,#0
	ADD R4,R2,#0
	ADD R1,R1,#-1
	BRnz EXPR
	BRp EXP1
EXPZ	AND R0,R0,#0		;If exponent is 0
	ADD R0,R0,#1
	BRnzp EXPE
EXPR	AND R0,R0,#0		;Gets final value after powering
	ADD R0,R3,#0
EXPE	RET 

REG7_SAVE 	.FILL x0000
	
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH	
	ST R3, PUSH_SaveR3	;save R3
	ST R4, PUSH_SaveR4	;save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACk_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz OVERFLOW		;stack is full
	STR R0, R4, #0		;no overflow, store value in the stack
	ADD R4, R4, #-1		;move top of the stack
	ST R4, STACK_TOP	;store top of stack pointer
	LD R6, STACK_TOP
	BRnzp DONE_PUSH		;
OVERFLOW
	ADD R5, R5, #1		;
DONE_PUSH
	LD R3, PUSH_SaveR3	;
	LD R4, PUSH_SaveR4	;
	RET


PUSH_SaveR3	.BLKW #1	;
PUSH_SaveR4	.BLKW #1	;


;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP	
	ST R3, POP_SaveR3	;save R3
	ST R4, POP_SaveR4	;save R3
	AND R5, R5, #0		;clear R5
	LD R3, STACK_START	;
	LD R4, STACK_TOP	;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz UNDERFLOW		;
	ADD R4, R4, #1		;
	LDR R0, R4, #0		;
	ST R4, STACK_TOP	;
	LD R6, STACK_TOP
	BRnzp DONE_POP		;
UNDERFLOW
	ADD R5, R5, #1		;
DONE_POP
	LD R3, POP_SaveR3	;
	LD R4, POP_SaveR4	;
	RET

POP_SaveR3	.BLKW #1	;
POP_SaveR4	.BLKW #1	;
STACK_END	.FILL x3FF0	;
STACK_START	.FILL x4000	;
STACK_TOP	.FILL x4000	;

.END
