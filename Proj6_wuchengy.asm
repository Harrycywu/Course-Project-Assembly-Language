TITLE Program 6 Designing low-level I/O procedures     (Proj6_wuchengy.asm)

; Last Modified: 03/13/2021
; OSU email address: wuchengy@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 03/14/2021
; Description: Write and test a MASM program to perform the following tasks, including implementing and testing two macros (mGetSring: display a prompt and get user's input & mDisplayString:  
;              print the string) for string processing, implementing and testing two procedures (ReadVal: invoke the mGetSring macro, convert string to value, and store the value & WriteVal: 
;              convert value to string and invoke the mDisplayString macro to print the ascii representation of the SDWORD value) for signed integers which use string primitive instructions,  
;              and writing a test program (in main) which uses the ReadVal and WriteVal procedures to get 10 valid integers from the user, store these numeric values in an array, 
;              and display the integers, their sum, and their average. 
;              Note: Also, including extra credit option #1.

INCLUDE Irvine32.inc

; -------------
; Define Macros
; -------------

; ----------mGetString MACRO-------------------------------------------------------------
; Description: Display a prompt and get the user's keyboard input into a memory location.
; Preconditions: promptAddr and stringAddr are passed by reference.
; Postconditions: EAX, ECX, and EDX changed (But restored)
; Receives: promptAddr = prompt message address
;           inputAddr  = The address that stores the user's input
;           countSize  = The length of input string 
;           byteCount  = The address that stores the number of bytes read
; Returns: inputAddr   = inputted string address
;          byteCount   = number of bytes read address
; ---------------------------------------------------------------------------------------
mGetString MACRO promptAddr:REQ, inputAddr:REQ, countSize: REQ, byteCount:REQ
  ; Preserve EDX, ECX, and EAX
  PUSH   EDX
  PUSH   ECX
  PUSH   EAX

  ; Display the prompt
  mDisplayString promptAddr                 ; promptAddr is passed by reference

  ; Read the string inputted by the user
  MOV    EDX, inputAddr                     ; Precondition of ReadString: EDX = address of buffer
  MOV    ECX, countSize                     ; Precondition of ReadString: ECX = buffer size
  CALL   ReadString
  MOV    byteCount, EAX                     ; Postcondition of ReadString: EAX = number of characters entered

  ; Restore EDX, ECX, and EAX
  POP    EAX
  POP    ECX
  POP    EDX

ENDM


; ----------mDisplayString MACRO------------------------------------------------
; Description: Print the string which is stored in a specified memory location.
; Preconditions: stringAddr is passed by reference.
; Postconditions: EDX changed (But restored)
; Receives: stringAddr = The address that stores the string to be printed
; Returns: None
; ------------------------------------------------------------------------------
mDisplayString MACRO stringAddr:REQ
  ; Preserve EDX
  PUSH   EDX

  ; Display the string
  MOV    EDX, stringAddr
  CALL   WriteString

  ; Restore EDX
  POP    EDX

ENDM


; ------------------------------------------------------
; Define the ARRAYSIZE, MAXSIZE, and DIVISOR as constant
; ------------------------------------------------------
ARRAYSIZE   =   10
MAXSIZE     =   101                          ; The max characters of inputted string
DIVISOR     =   10                           ; The divisor that will be implemented by the algorithm to convert a numeric SDWORD value to a string of ascii digits

.data

; --------------------------------
; variables that will be print out
; --------------------------------
titleName    BYTE   "---------Welcome to PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures---------", 0
authorName   BYTE   "Written by: Cheng Ying Wu", 0
intro_1      BYTE   "Please provide 10 signed decimal integers.", 0
intro_2      BYTE   "Each number needs to be small enough to fit inside a 32 bit register. (Range: [-2147483648, 2147483647])", 0
intro_3      BYTE   "After you have finished inputting the raw numbers,", 13, 10, "I will display a list of the integers, their sum, and their average value.", 0
prompt_1     BYTE   "Please enter a signed number: ", 0
prompt_2     BYTE   "Please try again: ", 0
errorMess    BYTE   "ERROR: You did not enter a signed number or your number was too big.", 0
enteredMess  BYTE   "You entered the following numbers:", 0
sumMess      BYTE   "The sum of these numbers is: ", 0
avgMess      BYTE   "The rounded average (round down (floor) to the nearest integer) is: ", 0 
farewellMess BYTE   "Goodbye, and thanks for playing! Results certified by Cheng Ying Wu.", 0
commaSpace   BYTE   ", ", 0
 

; -------------------------
; variables that store data 
; -------------------------
inputArray   SDWORD ARRAYSIZE  DUP(?)         ; An array that stores the 10 valid integers
userString   BYTE   MAXSIZE    DUP(?)         ; An array that stores the user's input string
printString  BYTE   MAXSIZE    DUP(?)         ; An array that stores the string to be printed
sumString    BYTE   MAXSIZE    DUP(?)         ; An array that stores the string representing the sum value to be printed
avgString    BYTE   MAXSIZE    DUP(?)         ; An array that stores the string representing the average value to be printed
byteNum      DWORD  ?                         ; The length of the inputted string
validInt     SDWORD ?                         ; The value converted from the inputted string


; --------------------------
; variables for Extra Credit
; --------------------------
; Extra Credit Options #1
EC1Mess      BYTE   "**EC #1: Number each line of user input and display a running subtotal of the user's valid numbers.", 0
subMess      BYTE   "**EC #1-The running subtotal value is: ", 0
dotSpace     BYTE   ". ", 0
lineCount    DWORD  1                         ; Initialize the lineCount value to 1
lineString   BYTE   MAXSIZE    DUP(?)         ; An array that stores the string representing the line value to be printed
subTotal     BYTE   MAXSIZE    DUP(?)         ; An array that stores the string representing the subtotal value to be printed


.code
main PROC

  ; Call introduction procedure
  PUSH  OFFSET EC1Mess                         ; [EBP + 28]  4 Bytes
  PUSH  OFFSET intro_1                         ; [EBP + 24]  4 Bytes
  PUSH  OFFSET intro_2                         ; [EBP + 20]  4 Bytes
  PUSH  OFFSET intro_3                         ; [EBP + 16]  4 Bytes
  PUSH  OFFSET titleName                       ; [EBP + 12]  4 Bytes
  PUSH  OFFSET authorName                      ; [EBP + 8]   4 Bytes
  CALL  introduction                           ; Total parameter space = 4 * 6 = 24 bytes 


  ; Get 10 valid integers from the user and fill them in the inputArray
  ; Modifies the code in Exploration 2 of Module 7 to generate an Array that stores every read validated integer 
  MOV   ESI, OFFSET inputArray                 ; inputArray: Address of first element of inputArray into ESI
  MOV   ECX, ARRAYSIZE                         ; ARRAYSIZE 
  MOV   EBX, 0                                 ; Used to store the subtotal values

  ; Use LOOP instruction to count the number of integers
_fillLoop:
  ; Call ReadVal procedure to get the input values
  PUSH  lineCount                              ; [EBP + 48]  4 Bytes
  PUSH  DIVISOR                                ; [EBP + 44]  4 Bytes
  PUSH  OFFSET lineString                      ; [EBP + 40]  4 Bytes
  PUSH  OFFSET dotSpace                        ; [EBP + 36]  4 Bytes
  PUSH  OFFSET errorMess                       ; [EBP + 32]  4 Bytes
  PUSH  OFFSET validInt                        ; [EBP + 28]  4 Bytes
  PUSH  byteNum                                ; [EBP + 24]  4 Bytes
  PUSH  MAXSIZE                                ; [EBP + 20]  4 Bytes
  PUSH  OFFSET userString                      ; [EBP + 16]  4 Bytes
  PUSH  OFFSET prompt_2                        ; [EBP + 12]  4 Bytes
  PUSH  OFFSET prompt_1                        ; [EBP + 8]   4 Bytes
  CALL  ReadVal                                ; Total parameter space = 4 * 11 = 44 bytes

  ; Move the values store in validInt to EAX
  MOV   EAX, validInt

  ; Storing them in consecutive elements of an array inputArray
  MOV   [ESI], EAX                             ; Move the value to the inputArray

  ; ---------**Extra Credit Option #1----------------------------------
  ; Increment lineCount by 1, calculate and display the subtotal values
  INC   lineCount

  ; Calculate the subtotal value and store the value in EBX
  ADD   EBX, EAX

  ; Display the subtotal message (passed by reference) and its value
  mDisplayString OFFSET subMess

  ; Call WriteVal procedure to display the value (EBX stores the value)
  PUSH  DIVISOR                                ; [EBP + 16]  4 Bytes
  PUSH  EBX                                    ; [EBP + 12]  4 Bytes
  PUSH  OFFSET subTotal                        ; [EBP + 8]   4 Bytes
  CALL  WriteVal                               ; Total parameter space = 4 * 3 = 12 bytes
  CALL  CrLf
  ; -------------------------------------------------------------------

  ADD   ESI, 4                                 ; Type inputArray = 4 Bytes: Increment ESI by 4 to point to the next element address of inputArray
  LOOP  _fillLoop

  ; Call displayArray procedure to read the inputArray and display the values
  PUSH  DIVISOR                                ; [EBP + 28]  4 Bytes
  PUSH  OFFSET enteredMess                     ; [EBP + 24]  4 Bytes
  PUSH  OFFSET inputArray                      ; [EBP + 20]  4 Bytes
  PUSH  ARRAYSIZE                              ; [EBP + 16]  4 Bytes
  PUSH  OFFSET printString                     ; [EBP + 12]  4 Bytes
  PUSH  OFFSET commaSpace                      ; [EBP + 8]   4 Bytes
  CALL  displayArray                           ; Total parameter space = 4 * 6 = 24 bytes

  ; Call sumAverage procedure to calculate and display Array's sum and average
  PUSH  OFFSET sumString                       ; [EBP + 32]  4 Bytes
  PUSH  OFFSET avgString                       ; [EBP + 28]  4 Bytes
  PUSH  OFFSET sumMess                         ; [EBP + 24]  4 Bytes
  PUSH  OFFSET avgMess                         ; [EBP + 20]  4 Bytes
  PUSH  DIVISOR                                ; [EBP + 16]  4 Bytes
  PUSH  ARRAYSIZE                              ; [EBP + 12]  4 Bytes
  PUSH  OFFSET inputArray                      ; [EBP + 8]   4 Bytes
  CALL  sumAverage                             ; Total parameter space = 4 * 7 = 28 bytes
 
  ; Call farewell procedure
  CALL  CrLf
  PUSH  OFFSET farewellMess                    ; [EBP + 8]   4 Bytes
  CALL  farewell                               ; Total parameter space = 4 bytes

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

; ----------introduction procedure---------------------------------------------------------------------------
; Description: Procedure to introduce the program.
; Preconditions: titleName, authorName, and intro_1 to 3 are strings that describe and introduce the program.
; Postconditions: None
; Receives: [EBP + 28]   = reference to EC1Mess
;           [EBP + 24]   = reference to intro_1
;           [EBP + 20]   = reference to intro_2
;           [EBP + 16]   = reference to intro_3
;           [EBP + 12]   = reference to titleName
;           [EBP + 8]    = reference to authorName
; Returns: None
; -----------------------------------------------------------------------------------------------------------
introduction PROC
  ; Preserve EBP and assign static stack-frame pointer
  PUSH  EBP
  MOV   EBP, ESP

  ; Display the program title 
  mDisplayString [EBP + 12]                    ; [EBP + 12]   = reference to titleName
  CALL  CrLf

  ; Display the programmer's name
  mDisplayString [EBP + 8]                     ; [EBP + 8]   = reference to authorName
  CALL  CrLf
  CALL  CrLf
  
  ; Display the introductions
  ; intro_1
  mDisplayString [EBP + 24]                    ; [EBP + 24]   = reference to intro_1
  CALL  CrLf
  
  ; intro_2
  mDisplayString [EBP + 20]                    ; [EBP + 20]   = reference to intro_2
  CALL  CrLf

  ; intro_3
  mDisplayString [EBP + 16]                    ; [EBP + 16]   = reference to intro_3
  CALL  CrLf
  CALL  CrLf

  ; ---------**Extra Credit Option-----------------------------------------
  ; Print the statement that describes the extra credit I chose to work on.
  ; **Extra Credit Option #1
  mDisplayString [EBP + 28]                    ; [EBP + 28]   = reference to EC1Mess
  CALL  CrLf
  CALL  CrLf
  ; -----------------------------------------------------------------------

  ; Restore EBP and clean up the stack
  POP   EBP
  RET   24                       ; De-reference 24 bytes

introduction ENDP


; ----------ReadVal procedure------------------------------------------------------------------------------------------
; Description: First, invoke the mGetSring macro to get user input in the form of a string of digits.
;              Second, convert (using string primitives) the string of ascii digits to its numeric value representation 
;              and validate this value to be valid.
;              Finally, store this value in a memory variable.
; Preconditions: lineString, dotSpace, errorMess, validInt, userString, prompt_2 and prompt_1 are passed by reference.
; Postconditions: EDI, ECX, ESI, EAX, EBX, and EDX changed. (But restored)
; Receives: [EBP + 48]   = lineCount 
;           [EBP + 44]   = DIVISOR
;           [EBP + 40]   = reference to lineString
;           [EBP + 36]   = reference to dotSpace
;           [EBP + 32]   = reference to errorMess
;           [EBP + 28]   = reference to validInt
;           [EBP + 24]   = byteNum
;           [EBP + 20]   = MAXSIZE
;           [EBP + 16]   = reference to userString
;           [EBP + 12]   = reference to prompt_2
;           [EBP + 8]    = reference to prompt_1
; Returns: validInt ([EBP + 28]) = The address that stores the value converted from the input string
; ---------------------------------------------------------------------------------------------------------------------
ReadVal PROC
  ; Preserve EBP and assign static stack-frame pointer
  PUSH  EBP
  MOV   EBP, ESP

  ; Preserve used registers (Used registers must be saved and restored by the called procedures and macros)
  PUSH  EDI
  PUSH  ECX
  PUSH  ESI
  PUSH  EAX
  PUSH  EBX
  PUSH  EDX

  ; [EBP + 28] is the address that is expected to store the valid converted value
  MOV   EDI, [EBP + 28]

  ; ---------**Extra Credit Option #1-----------------------------------------------------
  ; Number each line of user input.
  ; Call WriteVal procedure to display the lineCount value
  PUSH  [EBP + 44]               ; [EBP + 44] = DIVISOR;                 [EBP + 16]
  PUSH  [EBP + 48]               ; [EBP + 48] = lineCount value;         [EBP + 12]
  PUSH  [EBP + 40]               ; [EBP + 40] = reference to lineString; [EBP + 8]
  CALL  WriteVal                 ; Total parameter space = 4 * 3 = 12 bytes

  ; Display dot and space after the lineCount value
  mDisplayString [EBP + 36]      ; [EBP + 36] = reference to dotSpace
  ; --------------------------------------------------------------------------------------

  ; Invoke the mGetString macro to get the user input
  mGetString [EBP + 8], [EBP + 16], [EBP + 20], [EBP + 24]

_convertInt:
  MOV   SDWORD PTR [EDI], 0      ; Cast immediate 0 as SDWORD, then write to memory (Since numInt = 0)

  ; Set up loop counter and indexes
  CLD                            ; clear direction flag
  MOV   ECX, [EBP + 24]

  ; If the user enters nothing (empty input), display an error and re-prompt
  CMP   ECX, 0
  JE    _invalid

  MOV   ESI, [EBP + 16]          ; Address of first element of userString into ESI
  
  ; Convert (using string primitives) the string of ascii digits to its numeric value representation
_checkSign:
  LODSB                          ; MOV AL, [ESI] & ADD ESI, 1
 
  ; Check the first string to determine its sign
  MOV   BL, 1                    ; Assume it is positive

  CMP   AL, 43                   ; ASCII 43: +
  JE    _nextChar

  CMP   AL, 45                   ; ASCII 45: -
  JNE   _convertDigits
  MOV   BL, -1                   ; If it is negative, then need to add the negative sign

_nextChar:
  ; Move to the next character
  DEC   ECX
  LODSB

_convertDigits:
  ; Implement the algorithm in the Lower Level Programming Exploration
  SUB   AL, 48                   ; numChar - 48

  CMP   AL, 0                    ; ASCII 48: 0
  JB    _invalid
  
  CMP   AL, 9                    ; ASCII 57: 9
  JA    _invalid

  ; Multiply numInt by 10 (Since numInt = 10 * numInt + (numChar - 48))
  MOV   EDX, [EDI]
  IMUL  EDX, 10

  ; Check whether this value is out of range (Overflow)
  JO    _invalid                 ; JO detects overflow after arithmetic operations

  IMUL  BL                       ; Convert AL (numChar - 48) to negative values, if the user enter "-" 
  MOVSX EAX, AL                  ; Copy the signed value from a smaller-sized source operand into a larger-sized destination operand

  ; Add (numChar - 48) to 10 * numInt and store in numInt
  ADD   EDX, EAX
  JO    _invalid                 ; JO detects overflow after arithmetic operations

  ; Store this value in a memory variable
  MOV   [EDI], EDX

  LODSB
  LOOP  _convertDigits           ; Repeat the process (for loop)
  JMP   _endConvert

  ; If the user enters an invalid value, display an error and re-prompt
_invalid:
  ; Display an error Message
  mDisplayString [EBP + 32]      ; [EBP + 32]   = reference to errorMess
  CALL  CrLf

   ; ---------**Extra Credit Option #1-----------------------------------------------------
  ; Number each line of user input.
  ; Call WriteVal procedure to display the lineCount value
  PUSH  [EBP + 44]               ; [EBP + 44] = DIVISOR;                 [EBP + 16]
  PUSH  [EBP + 48]               ; [EBP + 48] = lineCount value;         [EBP + 12]
  PUSH  [EBP + 40]               ; [EBP + 40] = reference to lineString; [EBP + 8]
  CALL  WriteVal                 ; Total parameter space = 4 * 3 = 12 bytes

  ; Display dot and space after the lineCount value
  mDisplayString [EBP + 36]      ; [EBP + 36] = reference to dotSpace
  ; ---------------------------------------------------------------------------------------

  ; Get the user input values
  mGetString [EBP + 12], [EBP + 16], [EBP + 20], [EBP + 24]
  JMP   _convertInt

_endConvert: 
  ; Restore used registers
  POP   EDX
  POP   EBX
  POP   EAX
  POP   ESI
  POP   ECX
  POP   EDI

  ; Restore EBP and clean up the stack
  POP   EBP
  RET   44                       ; De-reference 44 bytes

ReadVal ENDP


; ----------WriteVal procedure-------------------------------------------------------------------------------------------
; Description: First, convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits.
;              Next, invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output.
; Preconditions: printString is passed by reference.
; Postconditions: EDI, EAX, EDX and EBX changed. (But restored)
; Receives: [EBP + 16]   = DIVISOR
;           [EBP + 12]   = numeric SDWORD value
;           [EBP + 8]    = reference to printString
; Returns: printString = The address that stores the converted string
; -----------------------------------------------------------------------------------------------------------------------
WriteVal PROC
  ; Preserve EBP and assign static stack-frame pointer
  PUSH  EBP
  MOV   EBP, ESP

  ; Preserve used registers (Used registers must be saved and restored by the called procedures and macros)
  PUSH  EDI
  PUSH  EAX
  PUSH  EDX
  PUSH  EBX

  STD                            ; Set direction flag
  ; [EBP + 8] is the address that is expected to store the converted string of ascii digits
  MOV   EDI, [EBP + 8]

   ; [EBP + 12] is the numeric SDWORD value that needs to be converted to a string of ascii digits
  MOV   EAX, [EBP + 12]
  CMP   EAX, 0                   ; If the value is less than zero, convert it to positive, and then add the negative sign
  JL    _negative

_convertString:
  ; Divide it by 10 to get each digit from the backward
  CDQ  
  IDIV  DWORD PTR [EBP + 16]     ; [EBP + 16] = DIVISOR = 10

  ; Keep dividing until the quotient is zero
  CMP   EAX, 0                   ; Compare the quotient to 0
  JE    _addLast
  PUSH  EAX

  ; Move the remainder to AL, convert to a string of ascii digits, and store it
  MOV   AL, DL
  ADD   AL, 48                   ; ASCII 48: 0

  STOSB                          ; MOV [EDI], AL & SUB EDI, 1
  POP   EAX
  JMP   _convertString           ; Repeat the process (while loop)

_negative:
  ; Check whether it is the edge case
  CMP   EAX, -2147483648
  JE    _edgeCase

  ; If the value is less than zero, convert it to positive, and then add the negative sign
  ; Convert to positive
  MOV   EBX, -1
  IMUL  EBX                      ; Turn EAX to positive

  ; Repeat the process same as the positive value
_convertNeg:
  ; Divide it by 10 to get each digit from the backward
  CDQ  
  IDIV  DWORD PTR [EBP + 16]     ; [EBP + 16] = DIVISOR = 10

  ; Keep dividing until the quotient is zero
  CMP   EAX, 0                   ; Compare the quotient to 0
  JE    _addSign
  PUSH  EAX

  ; Move the remainder to AL, convert to a string of ascii digits, and store it
  MOV   AL, DL
  ADD   AL, 48                   ; ASCII 48: 0

  STOSB                          ; MOV [EDI], AL & SUB EDI, 1
  POP   EAX
  JMP   _convertNeg              ; Repeat the process (while loop)

_addSign:
  ; Add the last digit
  MOV   AL, DL
  ADD   AL, 48 
  STOSB

  ; Add the negative sign
  MOV   AL, 45                   ; ASCII 45: -
  STOSB
  JMP   _endPrint
  
_addLast: 
  ; Add the last digit
  MOV   AL, DL
  ADD   AL, 48 
  STOSB                          ; MOV [EDI], AL & SUB EDI, 1
  JMP   _endPrint

_edgeCase:
  ; Deal with the edge case: input = -2147483648
  _convertEdge:
    ; Divide it by 10 to get each digit from the backward
    CDQ  
    IDIV  DWORD PTR [EBP + 16]   ; [EBP + 16] = DIVISOR = 10

    ; Convert the quotient to positive
    IMUL  DX, -1

    ; Keep dividing until the quotient is zero
    CMP   EAX, 0                 ; Compare the quotient to 0
    JE    _addSign
    PUSH  EAX

    ; Move the remainder to AL, convert to a string of ascii digits, and store it
    MOV   AL, DL
    ADD   AL, 48                 ; ASCII 48: 0

    STOSB                        ; MOV [EDI], AL & SUB EDI, 1
    POP   EAX
    JMP   _convertEdge           ; Repeat the process (while loop)

_endPrint:
  ; Add back 1 to return to the first address of the string
  ADD   EDI, 1

  ; Invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output
  mDisplayString EDI             ; Pass by reference

  ; Restore used registers
  POP   EBX
  POP   EDX
  POP   EAX
  POP   EDI

  ; Restore EBP and clean up the stack
  POP   EBP
  RET   12                       ; De-reference 12 bytes

WriteVal ENDP


; ----------displayArray procedure------------------------------------------------------------
; Description: Procedure to display the values stored in the input array. 
; Preconditions: enteredMess, inputArray, printString, and commaSpace are passed by reference.
; Postconditions: ESI, ECX, and EAX changed. (But restored)
; Receives: [EBP + 28]   = DIVISOR
;           [EBP + 24]   = reference to enteredMess
;           [EBP + 20]   = reference to inputArray
;           [EBP + 16]   = ARRAYSIZE
;           [EBP + 12]   = reference to printString
;           [EBP + 8]    = reference to commaSpace
; Returns: printString = The address that stores the converted string
; --------------------------------------------------------------------------------------------
displayArray PROC
  ; Preserve EBP and assign static stack-frame pointer
  PUSH  EBP
  MOV   EBP, ESP

  ; Preserve used registers (Used registers must be saved and restored by the called procedures and macros)
  PUSH  ESI
  PUSH  ECX
  PUSH  EAX
 
  ; Display the message to indicate the following are entered values
  CALL  CrLf
  mDisplayString [EBP + 24]                    ; [EBP + 24]   = reference to enteredMess
  CALL  CrLf

  ; Modifies the code in Exploration 2 of Module 7 to display inputArray 
  MOV   ESI, [EBP + 20]                        ; [EBP + 20]   = reference to inputArray: Address of first element of inputArray into ESI
  MOV   ECX, [EBP + 16]                        ; ARRAYSIZE 

  ; Use LOOP instruction to display the values
_printLoop:
  MOV   EAX, [ESI]                             ; WriteVal parameter: numeric SDWORD value (input parameter, by value)                      

  PUSH  [EBP + 28]                             ; DIVISOR
  PUSH  EAX                                    ; numeric SDWORD value
  PUSH  [EBP + 12]                             ; [EBP + 12]   = reference to printString

  ; Call WriteVal procedure to display this value
  CALL  WriteVal                               ; Total parameter space = 4 * 3 = 12 bytes

  ; Display one comma and one space after each value (except the last value)
  CMP   ECX, 1
  JE    _endPrint

  mDisplayString [EBP + 8]                     ; [EBP + 8]    = reference to commaSpace

_endPrint:
  ADD   ESI, 4                                 ; Increment ESI by 4 to point to the next element of randArray
  LOOP  _printLoop

  ; Restore used registers
  POP   EAX
  POP   ECX
  POP   ESI

  ; Restore EBP and clean up the stack
  POP   EBP
  RET   24                       ; De-reference 24 bytes

displayArray ENDP


; ----------sumAverage procedure------------------------------------------------------------------
; Description: Procedure to calculate and display Array's sum and average.
; Preconditions: sumString, avgString, sumMess, avgMess, and inputArray are passed by reference.
; Postconditions: ESI, ECX, EAX, EBX, and EDX changed. (But restored)
; Receives: [EBP + 32]   = reference to sumString
;           [EBP + 28]   = reference to avgString
;           [EBP + 24]   = reference to sumMess
;           [EBP + 20]   = reference to avgMess
;           [EBP + 16]   = DIVISOR
;           [EBP + 12]   = ARRAYSIZE
;           [EBP + 8]    = reference to inputArray
; Returns: sumString = The address that stores the converted string representing the sum value
;          avgString = The address that stores the converted string representing the average value
; ------------------------------------------------------------------------------------------------
sumAverage PROC
  ; Preserve EBP and assign static stack-frame pointer
  PUSH  EBP
  MOV   EBP, ESP

  ; Preserve used registers (Used registers must be saved and restored by the called procedures and macros)
  PUSH  ESI
  PUSH  ECX
  PUSH  EAX
  PUSH  EBX
  PUSH  EDX

  ; Iterate through inputArray and sum up all the elements
  MOV   ESI, [EBP + 8]                         ; [EBP + 8]   = reference to inputArray: Address of first element of inputArray into ESI
  MOV   ECX, [EBP + 12]                        ; ARRAYSIZE 
  MOV   EAX, 0                                 ; sum   
  
  ; Use LOOP instruction to iterate inputArray and calculate the sum
_sumLoop:
  MOV   EBX, [ESI]  
  ADD   EAX, EBX                               ; Add each element to EAX and store the sum in EAX
  
  ADD   ESI, 4                                 ; Increment ESI by 4 to point to the next element of inputArray
  LOOP  _sumLoop

  ; Display the sum message
  CALL  CrLf
  mDisplayString [EBP + 24]                    ; [EBP + 24]   = reference to sumMess

  PUSH  [EBP + 16]                             ; DIVISOR
  PUSH  EAX                                    ; numeric SDWORD value (sum)
  PUSH  [EBP + 32]                             ; [EBP + 32]   = reference to sumString

  ; Call WriteVal procedure to display sum value
  CALL  WriteVal                               ; Total parameter space = 4 * 3 = 12 bytes
  CALL  CrLf

  ; Display the average message 
  mDisplayString [EBP + 20]                    ; [EBP + 20]   = reference to avgMess

  ; Calculate average (round down (floor) to the nearest integer)
  CDQ  
  IDIV  DWORD PTR [EBP + 16]                   ; [EBP + 16] = DIVISOR = 10

  ; Check its remainder
  CMP   EDX, 0
  JGE   _displayAvg                            ; If the remainder is positive or zero, by the round down rule, then just display the quotient

  ; If the remainder is negative (Less than zero), then subtract the quotient by 1
  SUB   EAX, 1

_displayAvg:
  PUSH  [EBP + 16]                             ; DIVISOR
  PUSH  EAX                                    ; numeric SDWORD value (avg)
  PUSH  [EBP + 28]                             ; [EBP + 28]   = reference to avgString

  ; Call WriteVal procedure to display average value
  CALL  WriteVal                               ; Total parameter space = 4 * 3 = 12 bytes
  CALL  CrLf

  ; Restore used registers
  POP   EDX
  POP   EBX
  POP   EAX
  POP   ECX
  POP   ESI

  ; Restore EBP and clean up the stack
  POP   EBP
  RET   28                       ; De-reference 28 bytes

sumAverage ENDP


; ----------farewell procedure-------------------------------------------
; Description: Procedure to display the farewell message.
; Preconditions: farewellMess is the string that say goodbye to the user.
; Postconditions: EDX changed
; Receives: [EBP + 8]    = reference to farewellMess
; Returns: None
; -----------------------------------------------------------------------
farewell PROC
  ; Preserve EBP and assign static stack-frame pointer
  PUSH  EBP
  MOV   EBP, ESP

  ; Display the closing message
  mDisplayString [EBP + 8]                     ; [EBP + 8]   = reference to farewellMess
  CALL  CrLf
  
  ; Restore EBP and clean up the stack
  POP   EBP
  RET   4                        ; De-reference 4 bytes

farewell ENDP


END main
