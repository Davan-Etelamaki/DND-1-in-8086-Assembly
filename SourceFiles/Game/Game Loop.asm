section .text
game_loop:
	call save_game
	call game_loop_welcome
	call get_command
	.loop:
		call get_command_from_user
	jmp .loop
ret

;********************************************************************************
;   game_loop_welcome
;   Purpose:
;      To welcome the player to the dungeon
;           Prototype:
;               void game_loop_welcome();
;           Algorithm:
;               void game_loop_welcome(){
;					Console.WriteLine(WelcomeStrings[0] + DungeonNumber);
;
;					Console.WriteLine(WelcomeStrings[1] + Character.x + WelcomeStrings[2] + Character.y + WelcomeStrings[3]);
;					Console.Read();
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
game_loop_welcome:

	Write WelcomeStrings, 0
	mov bl, [DungeonNumber]
	xor bh, bh
	call print_dec
	call new_line

	Write WelcomeStrings, 1
	mov bh, 0
	mov bl, [Character.x]
	call print_dec
	Write WelcomeStrings, 2 
	mov bl, [Character.y]
	call print_dec
	WriteLine WelcomeStrings, 3 
ret


;********************************************************************************
;   quit
;   Purpose:
;      To go to the beginning of the program when a player quits the game
;           Prototype:
;               void quit();
;           Algorithm:
;               void quit(){
;					goto(boot);
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
quit:
	jmp boot
ret