# Course-Project-Assembly-Language
Course Project - Assembly Language (MASM)

Course: CS 271 - Computer Architecture & Assembly Language

Term: Winter 2021

**Course Description:**

Introduction to functional organization and operation of digital computers. Coverage of assembly language; addressing, stacks, argument passing, arithmetic operations, decisions, macros, modularization, linkers and debuggers.

My Grade: A (97.67%)

# Project Name: String Primitives and Macros
**Project Description**

The purpose of this assignment:
* Designing, implementing, and calling low-level I/O procedures
* Implementing and using macros

Write and test a MASM program to perform the following tasks (check the Requirements section for specifics on program modularization):

1. Implement and test two macros for string processing. These macros may use Irvine’s `ReadString` to get input from the user, and `WriteString` procedures to display output.
* `mGetString`:  Display a prompt (input parameter, by reference), then get the user’s keyboard input into a memory location (output parameter, by reference). You may also need to provide a count (input parameter, by value) for the length of input string you can accommodate and a provide a number of bytes read (output parameter, by reference) by the macro.
* `mDisplayString`:  Print the string which is stored in a specified memory location (input parameter, by reference).

2. Implement and test two procedures for signed integers which use string primitive instructions
* `ReadVal`: 
  * Invoke the `mGetString` macro (see parameter requirements above) to get user input in the form of a string of digits.
  * Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc).
  * Store this value in a memory variable (output parameter, by reference). 
* `WriteVal`: 
  * Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits
  * Invoke the `mDisplayString` macro to print the ascii representation of the SDWORD value to the output.

3. Write a test program (in `main`) which uses the `ReadVal` and `WriteVal` procedures above to:
* Get 10 valid integers from the user.
* Stores these numeric values in an array.
* Display the integers, their sum, and their average.

**Project Requirements**

* User’s numeric input must be validated the hard way:
  * Read the user's input as a string and convert the string to numeric form.
  * If the user enters non-digits other than something which will indicate sign (e.g. ‘+’ or ‘-‘), or the number is too large for 32-bit registers, an error message should be displayed and the number should be discarded.
  * If the user enters nothing (empty input), display an error and re-prompt.
* `ReadInt`, `ReadDec`, `WriteInt`, and `WriteDec` are not allowed in this program.
* Conversion routines must appropriately use the `LODSB` and/or `STOSB` operators for dealing with strings.
* All procedure parameters must be passed on the runtime stack. Strings must be passed by reference
* Prompts, identifying strings, and other memory locations must be passed by address to the macros.
* Used registers must be saved and restored by the called procedures and macros.
* The stack frame must be cleaned up by the called procedure.
* Procedures (except `main`) must not reference data segment variables by name. There is a significant penalty attached to violations of this rule.  Some global constants (properly defined using EQU, =, or TEXTEQU and not redefined) are allowed. These must fit the proper role of a constant in a program (master values used throughout a program which, similar to `HI` and `LO` in Project 5)
* The program must use Register Indirect addressing for integer (SDWORD) array elements, and Base+Offset addressing for accessing parameters on the runtime stack.
* Procedures may use local variables when appropriate.

**Extra Credit Options**

Number each line of user input and display a running subtotal of the user’s valid numbers. These displays must use `WriteVal`. 

**Example Execution**

User input in this example is shown after ": " in the Please sentence.

```
PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures 
Written by: Sheperd Cooper 
 
Please provide 10 signed decimal integers.  
Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value. 
 
Please enter an signed number: 156 
Please enter an signed number: 51d6fd 
ERROR: You did not enter a signed number or your number was too big. 
Please try again: 34 
Please enter a signed number: -186 
Please enter a signed number: 115616148561615630 
ERROR: You did not enter an signed number or your number was too big. 
Please try again: -145
Please enter a signed number: 5 
Please enter a signed number: +23 
Please enter a signed number: 51 
Please enter a signed number: 0 
Please enter a signed number: 56 
Please enter a signed number: 11 
 
You entered the following numbers: 
156, 34, -186, -145, 5, 23, 51, 0, 56, 11 
The sum of these numbers is: 5 
The rounded average is: 1 
 
Thanks for playing! 
```
