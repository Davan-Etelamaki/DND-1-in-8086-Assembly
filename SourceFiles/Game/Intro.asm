section .text
intro:
	WriteLine TitleString, 0 	
	WriteLine TitleString, 1 	
	WriteLine TitleString, 2 	
	call new_line	

	call instructions

	call new_or_old
ret

;********************************************************************************
;   instructions
;   Purpose:
;      To see if the user needs instructions to play
;           Prototype:
;               void instructions();
;           Algorithm:
;               void instructions(){
;					while(true){
;                	    Console.Write(NeedInstructionString);
;						string input = Console.Read().ToUpper();
;						if(input[0] == 'Y' || input == 'YES'){
;						Console.Write(WhoSaidString);
;							return;
;						}
;						else if(input[0] == 'N' || input == 'NO'){
;							return;
;						}
;						invalid_input();
;					}
;               }
;               
;   Entry:
;       None
;   Exit:
;       None
;   Uses:
;       BX
;   Exceptions:
;       
;*******************************************************************************
instructions:
	Write NeedInstructionsString	
	ReadLine
	StringToUpper InputStringBuffer
	StringCompareInsensitive InputStringBuffer, YesString
	je .yes_instructions

	cmp byte [InputStringBuffer + 2], 'Y'
	je .yes_instructions

	StringCompareInsensitive InputStringBuffer, NoString
	je .no_instructions
	
	cmp byte [InputStringBuffer + 2], 'N'
	je .no_instructions

	call invalid_input
	jmp instructions

	.yes_instructions:
		WriteLine WhoSaidString
		call wait_key
		ret
	.no_instructions:  
ret

;********************************************************************************
;   new_or_old
;   Purpose:
;      To see if the user wants to continue a previous game
;           Prototype:
;               void new_or_old();
;           Algorithm:
;               void new_or_old(){
;                	Console.Write(NoInstructionsString);
;					string input = Console.Read().ToUpper();
;					if(input == 'OLD'){
;						load_game();
;					}
;					else
;						get_dungeon_num();
;						get_continues();
;						roll_character();
;						item_shop();
;						print_characteristics_and_eq();
;						read_dungeon();
;					}
;               }
;               
;   Entry:
;       None
;   Exit:
;       None
;   Uses:
;       BX
;   Exceptions:
;       
;*******************************************************************************
new_or_old:
	WriteLine NoInstructionsString
	ReadLine
	StringCompareInsensitive InputStringBuffer, OldGameString
	je .old
		call get_dungeon_num

		call get_continues

		call roll_character

		call item_shop

		call print_characteristics_and_eq

		call read_dungeon
	ret
	.old:
		call load_game
ret

;********************************************************************************
;   get_dungeon_num
;   Purpose:
;      To get the dungeon the user wants to play
;           Prototype:
;               void get_dungeon_num();
;           Algorithm:
;               void get_dungeon_num(){
;					while(true){
;                		Console.Write(DungeonNumberString);
;						int input = int.Parse(Console.Read());
;						if(input > 0){
;							DungeonNumber = input;
;							return;
;						}
;					}
;               }
;               
;   Entry:
;       None
;   Exit:
;       None
;   Uses:
;       BX
;   Exceptions:
;       
;*******************************************************************************
get_dungeon_num:
	Write DungeonNumberString
	ReadLine
	call parse_int
	test bx, bx
	jnz .return
	.fail:
		call invalid_input
		jmp get_dungeon_num
	.return:
	mov [DungeonNumber], bl
ret

;********************************************************************************
;   get_continues
;   Purpose:
;      To see if the user wants to reset their continues
;           Prototype:
;               void get_continues();
;           Algorithm:
;               void get_continues(){
;					while(true){
;                		Console.Write(ResetContinuesString);
;						int input = int.Parse(Console.Read());
;						if(input = 1 || input == 2){
;							Character.continues = input;
;							return;
;						}
;						invalid_input();
;					}
;               }
;               
;   Entry:
;       None
;   Exit:
;       None
;   Uses:
;       BX
;   Exceptions:
;       
;*******************************************************************************
get_continues:
	Write ResetContinuesString
	ReadLine
	call parse_int
	cmp bx, 1
	jl .fail

	cmp bx, 2
	jg .fail

	mov [Character.continues], bl
	jmp .return
	.fail:
		call invalid_input
		jmp get_continues
	.return:
ret