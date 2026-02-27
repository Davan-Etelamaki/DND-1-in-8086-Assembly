;*******************************************************************************
;	Print.asm - x86 Assembly Print Functions
;						
;
;       Copyright (c) Davan Etelamaki
;
;	Purpose:
;       To provide the functions needed to print an output to the screen
;
;*******************************************************************************
section .text
;********************************************************************************
;	print_string
;	Purpose:
;      To print a string to the screen using the print function.
;			Prototype:
;				void print_string(byte* string_address);
;			Algorithm:
;				void print_string(byte* string_address){
;					while(string_address != 0){
;						if(*string_address == 10){
;							if(yposition < 23){
;								yposition++;
;							}
;							else{
;								scroll();
;							}
;						}
;						else if(*string_address == 13){
;							xposition = 0;
;						}
;						else{
;							print(*string_address);
;						}
;						string_address++;
;					}
;				}
;				
;	Entry:
;       Byte String Address in Register BX
;	Exit:
;       None
;	Uses:
;		AX, BX
;	Exceptions:
;		None
;*******************************************************************************
print_string:
	push bx
	push ax

	test ah, ah
	jnz .loop
		mov ah, LightGrayOnBlack			;set the text color 

	.loop:
		mov al, [bx]					;Load the current byte of the string
		test al, al						;Test AL for the null terminator (0)
		jz .return             			;If it is, this is the end of the string

		inc bx							;Advance the address to the next character
		
		cmp al, 10	 					;Check for a Line Feed Character
		je .line_feed					;Perform a Line Feed if it is

		cmp al, 13						;Check for a Carriage Return Character
		je .carriage_return				;Perform a Carriage Return if it is

		call print						;Print the character
		dec cx
		jz .return
		jmp .loop
		
	.line_feed:
		cmp word [ypos], 23 			;Check if the cursor has hit the bottom
		je .scroll
			add word [ypos], 1 				;Progress the cursor down a line
			jmp .loop
		.scroll:
			call scroll
		jmp .loop
	.carriage_return:
		mov word [xpos], 0     			;Restart at the left
		jmp .loop
	.return:
		pop ax
		pop bx
ret	

;********************************************************************************
;	print
;	Purpose:
;      To print a character to the screen
;			Prototype:
;				void print(byte character);
;			Algorithm:
;				void print(byte character){
;					push_character(character);
;					xposition++;
;					if(xposition > 80){
;						xposition = 0;
;						if(yposition < 23){
;							yposition++;
;						}
;						else{
;							scroll();
;						}
;					}
;				}
;	Entry:
;       Constant Character in Register AL 
;	Exit:
;       None
;	Uses:
;		AX, BX
;	Exceptions:
;		None
;*******************************************************************************
print:
	call push_character
	inc word [xpos]		      		;Move the cursor 1 to the right
	cmp word [xpos], 80   			;check if the cursor has hit the right 

	jle .return
	mov word [xpos], 0 				;Move the cursor back to the left
	cmp word [ypos], 23 			;Check if the cursor has hit the bottom
	jge .scroll
		add word [ypos], 1 				;Progress the cursor down a line
	jmp .return
	.scroll:
		call scroll
	.return:
ret

;********************************************************************************
;	push_character
;	Purpose:
;      To push a character into video memory
;			Prototype:
;				void push_character(byte character);
;			Algorithm:
;				void push_character(byte character){
;					location = VideoMemory + (yposition * 160) + (xposition * 2)
;					*location = character;
;				}
;				
;	Entry:
;       Byte Character in Register AX
;	Exit:
;       None
;	Uses:
;		AX, BX, CX, DX, ES, DI
;	Exceptions:
;		None
;*******************************************************************************
push_character:						;Character Print
	push ax
	%ifdef DEBUG
		push bx
		push dx
		mov bx, sp
		mov al, [ss:bx+4]		; character was in AX (pushed first), so at sp+4
		mov dx, 0				; COM1
		mov ah, 1				; write character to serial (BIOS int 14h)
		int 0x14
		pop dx
		pop bx
	%endif
	push bx
	push cx
	push dx
	push es
	push di
	mov cx, [VideoMemory]  			;text video memory
	mov es, cx 						;move es to the video memory
									;setting the cursor position
	mov bx, ax   					;store the character in ax in the register BX

									;get the row
	mov ax, word [ypos] 			;get the current yposition
									;we want to multiply the position by 160 
									;(2 bytes per character 80 characters per row)
									;a bitshift is faster than multiplication 
									;(ax * 128 + bx * 32 = ax * 160)
	mov dx, ax 						;we copy ax to dx
	mov cl, 7
	shl ax, cl 						;then shift ax by 7 (ax * 128) 
	mov cl, 5
	shl dx, cl 						;we shift bx by 5 (dx * 32)
	add ax, dx 						;then add ax and dx 

									;get the column
	mov di, word [xpos]				;get the current xposition
	shl di, 1

	add di, ax						;Set the offset location to di

	mov [es:di], bx					;push our character to memory
	pop di
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
ret

;********************************************************************************
;	clear_screen
;	Purpose:
;      To clear the screen
;			Prototype:
;				void clear_screen();
;			Algorithm:
;				void clear_screen(){
;					int* memory = VideoMemory
;					for(int x = 0; x < 4000; x++){
;						memory = 0;
;						*memory++;
;					}
;					xposition = 0;
;					yposition = 0;
;				}
;				
;	Entry:
;       None
;	Exit:
;       None
;	Uses:
;		ES, DI
;	Exceptions:
;		None
;*******************************************************************************
clear_screen:						;Clear Screen
	push es
	push di
	mov di, 4000 					;Set the offset to the size of text video memory
    mov es, [VideoMemory] 			;Move our segment into video memory

    .loop:
        mov word[es:di], 0 			;Set the data at our segment and offset to 0
        sub di, 2 					;advance to the next word
        jge .loop 					;Repeat until we hit the start of bideo memory
	mov word [xpos], 0 				;Move the cursor back to the left
	mov word [ypos], 0 				;Move the cursor back to the top
	pop di
	pop es
ret

;********************************************************************************
;	new_line
;	Purpose:
;      To advance the cursor to a new line
;			Prototype:
;				void new_line();
;			Algorithm:
;				void new_line(){
;					xposition = 0;
;					if(yposition < 23)
;						yposition++;
;					}
;					else{
;						scroll();
;					}
;				}
;				
;	Entry:
;       None
;	Exit:
;       None
;	Uses:
;		None
;	Exceptions:
;		None
;*******************************************************************************
new_line:
	mov word [xpos], 0 					;Move the cursor back to the left
	cmp word [ypos], 23 				;Check if the cursor has hit the bottom
	jge .scroll 						;If we are the second to last row scroll the screen
		add word [ypos], 1 				;Progress the cursor down a line
	jmp .return
	.scroll:
		call scroll
	.return:
ret

;********************************************************************************
;	scroll
;	Purpose:
;      Scroll the screen
;			Prototype:
;				void scroll();
;			Algorithm:
;				void scroll(){
;					extended_mem_copy(VideoMemory + 10, VideoMemory, 3840);
;				}
;				
;	Entry:
;       None
;	Exit:
;       None
;	Uses:
;		AX, BX, CX
;	Exceptions:
;		None
;*******************************************************************************
scroll:
	push ax
	push bx
	push cx
		mov cx, 3840 				;Set our length to all but one row of the screen
		mov ax, [VideoMemory]  		;Set address a to the video memory
		add ax, 10 					;Advance address a by 160 (It is offset by 16bits)
		mov bx, [VideoMemory] 		;Set address b to the video memory
		call extended_mem_copy 		;Copy from address a into address b moving the screen up one row
	pop cx
	pop bx
	pop ax
ret

;********************************************************************************
;	print_hex
;	Purpose:
;      Print a number in hex to the screen
;			Prototype:
;				void print_hex(byte number);
;			Algorithm:
;				void print_hex(byte number){
;					string output = "";
;					for(int x = 0; x < 4; x++){
;						number = ROL(number,4);		Roll to the last half byte
;						temp = number and 0x0F;		Mask the previous half byte
;						output += hexStr[temp];		Add the character for the half byte value
;					}
;					print_string(output);
;				}
;				
;	Entry:
;       None
;	Exit:
;       None
;	Uses:
;		AX, BX, CX, DI
;	Exceptions:
;		None
;*******************************************************************************
print_hex:
	push bx
	push dx
	push ax
	mov di, hexOutput			;Store address of our output in the DI register
	mov ax, bx					;Push our Value to the AX register
	mov ch, 0x04   				;Set CH to 4 since we have 2 bytes in our register
	.hexloop: 		
		mov cl, 0x04			;We want to shift our register by 4
		rol ax, cl 				;Shift the BX register by the Value in CL to reverse the order
		mov bx, ax       		;Push the value back to BX
		and bx, 0x0f     		;Logical AND the value of BX with 0x0F to filter to one Value
		mov bl, [hexStr + bx]	;Push the character at the offset of the value of BX in the Hex String
		mov [di], bl			;Store this character in our output string buffer
		inc di					;Increment the address of the string buffer
		dec ch					;Decrement the value in CH
		jnz .hexloop			;As long as CX is greater than 0, repeat

	mov bx, hexOutput
	mov ah, 0x07
	call print_string
	pop ax
	pop dx
	pop bx
ret

;********************************************************************************
;	print_hex
;	Purpose:
;      Print a number in hex to the screen
;			Prototype:
;				void print_hex(byte number);
;			Algorithm:
;				void print_hex(byte number){
;					string output = "";
;					string reversed = "";
;					if(number < 0){
;						number *= -1;
;						output += "-";
;					}
;					while(number > 0){
;						reversed = number % 10 + ' ';
;						number = number / 10;
;					}
;					for(int x = 0; x < number.length; x++){
;						output += reversed[x];
;					}
;					print_string(output);
;				}
;				
;	Entry:
;       None
;	Exit:
;       None
;	Uses:
;		AX, BX, CX, DX, DI
;	Exceptions:
;		None
;*******************************************************************************
print_dec:
	push dx
	push cx
	push bx
	push ax
	push di
	mov di, decOutput			;Store address of our output in the DI register
	mov ax, bx					;Push our Value to the AX register

	mov bx, 10 					;Push 10 into our BX register for division later
	mov cx, 0 					;Set CX to 0 we are going to store our length in it for flipping the string

	cmp ax, 0 					;Check if our number is positive
	jge .decloop
		xor dx, dx  			;Clear DX
		mov word[di], '-'	 	;Prepend our string with a -
		inc di 					;Increment our string
		xor ax, 0xFFFF 			;Make our number positive
		inc ax 					;Adjust for the twos compliment switch
	.decloop: 	
		xor dx, dx 				;Clear DX
		div bx 					;Divide our value by 10

		add dx, '0' 			;Adjust the remainder to be the character representation of our number
		push dx					;Push the character to the stack
		inc cx 					;Increment our counter
		
		cmp ax, 0 				
		jnz .decloop			;As long as AX is greater than 0, repeat

	.flipLoop:					;Our number is backwards lets flip it
		pop dx 					;Pull the first number from the stack
		mov [di], dx 			;Push it into the current position in our string
		inc di 					;Increment our string pointer 
		dec cx 					;Decrement the number of remaining characters
		jnz .flipLoop     		;If there are remaining characters repeat
		mov word[di], 0 		;Append a 0 as the null terminator of the string
	pop di
	mov bx, decOutput			;Move BX to point to our string
	call print_string			;Print our string
	pop ax
	pop bx
	pop cx
	pop dx
ret

section .bss
	ypos        resw  1 			;The current cursor y position
	xpos        resw  1				;The current cursor x position
	decOutput 	resb 10 			;Our buffer for decimal output
	hexOutput   resb 6	 			;Our buffer for hexidecimal output

section .data
	hexStr      db '0123456789ABCDEF'  	;The characters for the values in Hex
	VideoMemory dw  0xb800 				;The location of text video memory offset by 16bits (0xb8000)
