TITLE PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures     (Proj6_kuvandim.asm)

; Author: Murat Seckin Kuvandik
; Last Modified: 6/11/2023
; OSU email address: kuvandim@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 6/11/2023
; Description: Asks user to enter ten integers. Saves these as strings. Converts strings to signed integers and saves them as an array. 
;			   Then converts these signed integers to strings again and displays them. 
;              

INCLUDE Irvine32.inc

; ********************************************************
; Macro Information
; Name: mGetString
; Description: Displays prompt to enter integer, reads and saves user integer as a string.
; Preconditions: 
; Postconditions: Uses EAX, ECX, EDX, EDI
; Receives: promptAdress, bufferAdress, bufferSize, bytesReadAdress
; Returns: Number entered is saved as a string
; ********************************************************

mGetString MACRO promptAdress, bufferAdress, bufferSize, bytesReadAdress
	
	pushad				; save registers
	mov					EDX, promptAdress
	call				WriteString
	mov					EDX, bufferAdress
	mov					ECX, bufferSize
	call				ReadString
	mov					EDI, bytesReadAdress
	mov					[EDI], EAX
	popad				; recover registers

ENDM


; ********************************************************
; Macro Information
; Name: mDisplayString
; Description: Displays a string
; Preconditions: None
; Postconditions: Uses EDX
; Receives: stringAdress
; Returns: None
; ********************************************************

mDisplayString MACRO stringAdress
	
	pushad				; save registers
	mov					EDX, stringAdress
	call				WriteString
	popad				; recover registers

ENDM

	; (insert constant definitions here)
	MAX_INTEGER =	2147483647					; 2^31-1 for SDWORD
	MIN_INTEGER =	-2147483648					; -2^31 for SDWORD
	INTEGER_COUNT = 10							; We need 10 valid integers
	
	


.data

	; (insert variable definitions here)
	intro1				BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10
						BYTE	"Written by: Murat Seckin Kuvandik",13,10,13,10
						BYTE	"Please provide 10 signed decimal integers.",13,10
						BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",13,10
						BYTE	"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",13,10,13,10,0
	prompt_1			BYTE	"Please enter a signed number: ",0
	error_1				BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10,0
	prompt_2			BYTE	"Please try again: ",0
	prompt_3			BYTE	"You entered the following numbers: ",13,10,0
	prompt_4			BYTE	"The sum of these numbers is: ",0
	prompt_5			BYTE	"The truncated average is: ",0
	prompt_6			BYTE	"Thanks for playing! ",0
	user_input_str		BYTE	101 DUP(?)
	user_int_array		SDWORD	INTEGER_COUNT DUP(?)
	bytes_read_array	DWORD	INTEGER_COUNT DUP(?)
	str_to_int_array	BYTE	101 DUP(?)
	bytesRead			DWORD	?
	integer_str_len		DWORD	101
	user_number			SDWORD	0
	num_ten				SDWORD	10
	minus_one			SDWORD	-1
	pos_or_neg			SDWORD	1
	int_to_string		BYTE	101 DUP(?)
	int_to_string_rev	BYTE	101 DUP(?)
	

	;debugging strings
	debug_1				BYTE	"This is a string, displayed with WriteString: ",0
	debug_2				BYTE	"This is the number of bytesRead, displayed with WriteDec: ",0
	debug_3				BYTE	"This is an integer, displayed with WriteInt: ",0
	debug_4				BYTE	"This is a string in reversed order, displayed with WriteString: ",0
	debug_5				BYTE	"This is a string in correct order, displayed with WriteString: ",0
	debug_6				BYTE	"This is a string with corrected first char, displayed with WriteString: ",0
	;debugging strings

	; main loop strings
	main_1				BYTE	"You entered the following numbers: ",13,10,0
	main_2				BYTE	"The sum of these numbers is: ",0
	main_3				BYTE	"The truncated average is: ",0
	goodbye				BYTE	13,10,"Thanks for playing!",13,10,0
	sum_message			BYTE	"The sum of these numbers is: ",0		
	average_message		BYTE    "The truncated average is: ",0
	sum					SDWORD	?
	average				SDWORD	?


.code
main PROC

; (insert executable instructions here)

	; display intro
	push				OFFSET intro1
	call				introduction

	mov					ECX, 10
	mov					EBX, 4
	mov					EDI, OFFSET user_int_array
	mov					ESI, OFFSET bytes_read_array
	
_tenIntegers:
	push				ECX
	mov					user_number, 0

	; readVal
	call				CrLf
	push				OFFSET prompt_1
	push				OFFSET prompt_2
	push				OFFSET user_input_str
	push				integer_str_len
	push				OFFSET bytesRead
	push				OFFSET user_number
	push				num_ten
	push				OFFSET pos_or_neg
	push				OFFSET error_1
	call				readVal

	mov					EDX, user_number
	mov					[EDI], EDX							; store 10 integers in user_int_array
	add					EDI, 4
	
	mov					EDX, bytesRead						; store 10 bytesRead in bytes_read_array
	mov					[ESI], EDX
	add					ESI, 4
	
	pop					ECX
	loop				_tenIntegers

	; show bytes read
	;call				CrLf
	;mov					EAX, 0
	;mov					ECX, 10
	;mov					ESI, OFFSET bytes_read_array				
	;_showIntegers:
	;push				ECX
	;mov					EAX, [ESI]
	;call				CrLf
	;call				WriteInt
	;call				CrLf
	;add					ESI, 4
	;pop					ECX
	;loop				_showIntegers


	; print the user_int_array looping writeVal 10 times
	call				CrLf
	mov					EDX, OFFSET main_1
	mDisplayString		EDX
	mov					ECX, 10
	mov					ESI, OFFSET user_int_array
	mov					EDI, OFFSET bytes_read_array
	_loopPrint:
	push				ECX
	push				ESI
	push				EDI
	push				OFFSET int_to_string
	push				OFFSET int_to_string_rev
	push				pos_or_neg
	call				writeVal
	add					ESI, 4
	add					EDI, 4
	pop					ECX
	loop				_loopPrint

	; calculate and display the sum of numbers
	call				CrLf
	mov					EDX, OFFSET sum_message
	mDisplayString		EDX
	mov					EAX, 0
	mov					ECX, 10
	mov					ESI, OFFSET user_int_array				
_sumIntegers:
	push				ECX
	add					EAX, [ESI]
	add					ESI, 4
	pop					ECX
	loop				_sumIntegers
	mov					sum ,EAX
	mov					EAX, sum
	call				WriteInt

	; calculate and display the truncated average
	call				CrLf
	mov					EDX, OFFSET average_message
	mDisplayString		EDX
	mov					EBX, 10
	mov					EDX, 0
	div					EBX
	mov					average, EAX
	mov					EAX, average
	call				WriteInt

	; say thanks
	call				CrLf
	mov					EDX, OFFSET goodbye
	mDisplayString		EDX
	


	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ********************************************************
; Procedure Information
; Name: introduction
; Description: Displays title, author and user instructions.
; Preconditions: intro1 adress pushed to stack, mDisplayString is a procedure
; Postconditions: uses EDX
; Receives: intro1 adress from stack
; Returns: None
; ********************************************************

introduction PROC

	; Display introduction
	push				EBP
	mov					EBP, ESP
	mov					EDX, [EBP+8]			; intro1 adress in EDX
	mDisplayString		EDX						; mDisplayString must be used to display all strings
	pop					EBP
	ret					4

introduction ENDP

; ********************************************************
; Procedure Information
; Name: readVal
; Description: Converts a string to a signed integer
; Preconditions: Stack as follows
	;OFFSET error_1			[EBP+8]
	;OFFSET pos_or_neg		[EBP+12]
	;num_ten				[EBP+16]
	;OFFSET user_number		[EBP+20]
	;OFFSET bytesRead		[EBP+24]
	;integer_str_len		[EBP+28]
	;OFFSET user_input_str	[EBP+32]
	;OFFSET prompt_2		[EBP+36]
	;OFFSET prompt_1		[EBP+40]
; Postconditions: Uses EAX, EBX, ECX, EDX, EDI, ESI
; Receives: Values listed in preconditions
; Returns: Saves integer to user_number adress
; ********************************************************

readVal PROC

	; readVal
	push				EBP
	mov					EBP, ESP
	pushad

	;invoke mGetString
	; mGetString OFFSET prompt_1, OFFSET user_input_str, integer_str_len, OFFSET bytesRead
	mGetString			[EBP+40], [EBP+32], [EBP+28], [EBP+24]	
	
	jmp					_skipTryAgain
_tryAgain:
	mGetString			[EBP+36], [EBP+32], [EBP+28], [EBP+24]
_skipTryAgain:
	

	mov					ESI, [EBP+32]			; OFFSET user_input_str
	mov					EDI, [EBP+24]			; bytesRead
	mov					ECX, [EDI]				; bytesRead in ECX
	cld

_loopx:
	mov					EDI, [EBP+20]
	mov					EAX, [EDI]						; user_number value in EAX
	mov					EBX, [EBP+16]					; num_ten in EBX
	mul					EBX
				
	mov					EDI, [EBP+20]
	mov					[EDI], EAX						; value in EAX to user_number value

	mov					EAX, 0							; clear register, we weed it to load string bytes
	lodsb
	cmp					ECX, 0
	je					_invalid						; user hits enter without entering digits
	cmp					AL, "+"
	je					_plusSign						; user enters + at the beginning
	cmp					AL, "-"
	je					_negativeSign					; user enters - at the beginning
	cmp					AL, 48
	jb					_invalid						; char below zero
	cmp					AL, 57
	ja					_invalid						; char greater than nine
	sub					AL, 48							
	mov					EDI, [EBP+20]
	add					[EDI], EAX						; add EAX to user_number value
	jmp					_plusSign
_negativeSign:			
	mov					EDI, [EBP+12]					
	mov					EBX, -1							; -1 is a constant, I use it to get the negative value.
	mov					[EDI], EBX						; pos_or_neg is -1 now
_plusSign:
	loop				_loopx
	
	; Max and min check for SDWORD, does not handle -2147483648. Handles 2147483648.
	mov					EDI, [EBP+20]
	jo					_invalid
	mov					EAX, [EDI]						;mov EAX, user_number

	mov					EDI, [EBP+12]
	mov					EBX, [EDI]
	Imul				EBX								;Imul pos_or_neg; the sum of digits gets multiplied by 1 if positive, -1 if negative, did not know NEG existed when I did this

	mov					EDI, [EBP+20]
	mov					[EDI], EAX						;mov user_number, EAX

	jmp					_end

_invalid:
	mov					EDX, [EBP+8]					;mov	EDX, OFFSET error_1
	mDisplayString		EDX								;call	WriteString
	jmp					_tryAgain

_end:
	popad
	pop					EBP
	ret					36

readVal ENDP


; ********************************************************
; Procedure Information
; Name: writeVal
; Description: Reads an integer and converts it to a string.
; Preconditions: Stack as follows
	;OFFSET user_number			[EBP+24]
	;OFFSET bytesRead			[EBP+20]
	;OFFSET int_to_string		[EBP+16]
	;OFFSET int_to_string_rev	[EBP+12]
	;pos_or_neg					[EBP+8]
; Postconditions: Uses EAX, EBX, ECX, EDX, ESI, EDI
; Receives: Values listed in preconditions
; Returns: Saves string to OFFSET int_to_string_rev
; ********************************************************

writeVal PROC

	; writeVal
	push				EBP
	mov					EBP, ESP
	pushad
	
	; divide the integer to 10, number of digit times

	;mov				EAX, user_number
	mov					ESI, [EBP+24]
	mov					EAX, [ESI]

	;if the number is negative, make it positive
	cmp					EAX, 0
	jge					_positive
	neg					EAX

_positive:
	mov					EBX, 10
	;mov				ECX, bytesRead
	mov					ESI, [EBP+20]
	mov					ECX, [ESI]
	mov					EDX, 0
	;mov				EDI, OFFSET int_to_string
	mov					EDI, [EBP+16]


	cld
	
	_divisionLoop:
	div					EBX
	push				EAX
	mov					EAX, EDX
	add					DWORD PTR EAX, 48
	stosb				
	pop					EAX
	mov					EDX, 0
	loop				_divisionLoop

	;mov				ECX, bytesRead
	mov					ESI, [EBP+20]
	mov					ECX, [ESI]

	; reverse the string
	mov					ESI, [EBP+16]
	add					ESI, ECX
	dec					ESI
	mov					EDI, [EBP+12]

	_reverseStringLoop:
	std
	lodsb
	cld	
	stosb
	loop				_reverseStringLoop


	mov					ESI, [EBP+12]						;compare first char to zero
	mov					AL, [ESI]
	cmp					AL, "0"
	je					_Zero								;if user entered + or - at the beginning, it appears as a zero here. Let's replace it with the sign.
	jmp					_procEnd2							;if no zero, skip the whole sign adding process.

_Zero:
	mov					EAX, [EBP+8]						;pos_or_neg in EAX
	cmp					EAX, 0
	jge					_positiveSign
	jl					_negativeSign

	
	_positiveSign:
	mov					AL, 43								;plus sign
	mov					[ESI], AL							;at the beginning of the string
	
	; for display purpose
	call				CrLf
	mov					EDX, OFFSET int_to_string_rev
	mDisplayString		EDX
	; for display purpose


	jmp					_procEND2

	_negativeSign:
	mov					AL, 45								;negative sign
	mov					[ESI], AL							;at the beginning of the string
	
	
	; for display purpose
	call				CrLf
	mov					EDX, OFFSET int_to_string_rev
	mDisplayString		EDX
	; for display purpose



_procEND:

	; for display purpose
	call				CrLf
	mov					EDX, OFFSET int_to_string_rev
	mDisplayString		EDX
	; for display purpose

_procEND2:

	popad
	pop					EBP
	ret					20

	
writeVal ENDP


END main
