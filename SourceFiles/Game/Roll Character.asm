section .text
roll_character:
	call get_character_name
	call roll_character_starting_point
	call roll_attributes
	call print_attributes
	call set_character_class
ret

;********************************************************************************
;   get_character_name
;   Purpose:
;      To get the character's name (must be SHAVS)
;           Prototype:
;               void get_character_name();
;           Algorithm:
;               void get_character_name(){
;					while(true){
;                	    Console.Write(PlayerNameInputString);
;						string input = Console.Read().ToUpper();
;						if(input.length > 0){
;							if(input == "SHAVS"){
;								Character.name = input;
;								return
;							}
;							else
;							{
;								Console.Write(WhoSaidString);
;							}
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
get_character_name:
	Write PlayerNameInputString 
	ReadLine
	call string_length
	test cx, cx
	je get_character_name 
	call to_upper

	StringCompareInsensitive bx, PlayerNameShavs
	je .return 		
		WriteLine WhoSaidString
		call get_key
		jmp get_character_name
	.return:
		mov bx, InputStringBuffer
		call string_length
		StringCopy bx, Character.name
ret

;********************************************************************************
;   roll_attribute
;   Purpose:
;      To get the sum of rolling 3 D6 dice for a character attribute
;           Prototype:
;               int roll_attribute();
;           Algorithm:
;               int roll_attribute(){
;					int value = roll_d6();
;					value += roll_d6();
;					return value + roll_d6();
;               }
;               
;   Entry:
;       None
;   Exit:
;       AX
;   Uses:
;       AX, BX
;   Exceptions:
;       
;*******************************************************************************
roll_attribute:
		call roll_d6
		mov ax, bx

		call roll_d6
		add ax, bx

		call roll_d6
		add ax, bx

ret

;********************************************************************************
;   roll_character_starting_point
;   Purpose:
;      To get the starting point of the player
;           Prototype:
;               void roll_character_starting_point();
;           Algorithm:
;               void roll_character_starting_point(){
;					Character.x = roll_d12() + roll_d12();
;					Character.y = roll_d12() + roll_d12();
;               }
;               
;   Entry:
;       None
;   Exit:
;       None
;   Uses:
;       AX, BX
;   Exceptions:
;       
;*******************************************************************************
roll_character_starting_point:
	call roll_d12
	mov ax, bx

	call roll_d12
	mov ax, bx
	mov byte[Character.x], al

	call roll_d12
	mov ax, bx

	call roll_d12
	mov ax, bx
	mov byte[Character.y], al
ret


;********************************************************************************
;   roll_attributes
;   Purpose:
;      To populate the player's attributes
;           Prototype:
;               void roll_attributes();
;           Algorithm:
;               void roll_attributes(){
;					for(int x = 0; x < 8; x++){
;						var value = roll_attribute();
;						if(x == 7){
;							value *= 15;
;						}
;						Character.attributes[x] = value;
;					}
;               }
;               
;   Entry:
;       None
;   Exit:
;       None
;   Uses:
;       AX, BX, CX
;   Exceptions:
;       
;*******************************************************************************
roll_attributes:
	mov cx, 7
	.loop:
		call roll_attribute

		mov bx, ax
		cmp cx, 7
		jne .not_gold
			mov bx, 15
			mul bx
		.not_gold:

		mov bx, cx
		sub bx, 1
		shl bx, 1
		mov [Character.str + bx], word ax
		dec cx
		cmp cx, 0
		jne .loop
ret

;********************************************************************************
;   set_character_class
;   Purpose:
;      To get the character's class
;           Prototype:
;               void set_character_class();
;           Algorithm:
;               void set_character_class(){
;					while(true){
;						Console.WriteLine(ClassStrings[0]);
;						Console.WriteLine(ClassStrings[1]);
;						Console.WriteLine(ClassStrings[2]);
;						var input = Console.Read().ToUpper();
;						if(input == "none"){
;							roll_attributes();
;							print_attributes();
;						}
;						else if(input == "Fighter"){
;							Character.hp = roll_d8();
;							Character.class = "Fighter";
;							return;
;						}
;						else if(input == "Cleric"){
;							Character.hp = roll_d4();
;							Character.class = "Cleric";
;							return;
;						}
;						else if(input == "Wizard"){
;							Character.hp = roll_d6();
;							Character.class = "Wizard";
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
;       AX, BX
;   Exceptions:
;       
;*******************************************************************************
set_character_class:
	WriteLine ClassStrings, 0 
	WriteLine ClassStrings, 1
	WriteLine ClassStrings, 2
	call get_user_input
	StringToUpper InputStringBuffer
	
	StringCompareInsensitive InputStringBuffer, Classes, 0 
	je .reroll
	StringCompareInsensitive InputStringBuffer, Classes, 2
	je .cleric
	StringCompareInsensitive InputStringBuffer, Classes, 1 
	je .fighter
	StringCompareInsensitive InputStringBuffer, Classes, 3
	je .wizard
	jmp set_character_class
	.cleric:
		StringCopy InputStringBuffer, Character.class
		call roll_d4
		mov ax, bx
		mov [Character.hp], word ax
	jmp .return

	.fighter:
		StringCopy InputStringBuffer, Character.class
		call roll_d8
		mov ax, bx
		mov [Character.hp], word ax
	jmp .return

	.wizard:
		StringCopy InputStringBuffer, Character.class
		call roll_d6
		mov ax, bx
		mov [Character.hp], word ax
	jmp .return

	.reroll:
		call roll_attributes
		call print_attributes
		jmp set_character_class
	.return:
ret

;********************************************************************************
;   print_characteristics_and_eq
;   Purpose:
;      To display the player's characteristics and equipment
;           Prototype:
;               void print_characteristics_and_eq();
;           Algorithm:
;               void print_characteristics_and_eq(){
;					list_equipment();
;					print_characteristics();
;               }
;               
;   Entry:
;       None
;   Exit:
;       None
;   Uses:
;       None
;   Exceptions:
;       
;*******************************************************************************
print_characteristics_and_eq:
	call list_equipment
	call print_characteristics
ret

;********************************************************************************
;   list_equipment
;   Purpose:
;      To display the player's equipment
;           Prototype:
;               void list_equipment();
;           Algorithm:
;               void list_equipment(){
;					Console.Write(EqListString);
;					string input = Console.Read().ToUpper();
;					if(input != "NO"){
;						for(int x = 0; x < Character.itemCount; x++){
;							Console.WriteLine(Character.inventory[x].name);
;						}
;					}
;               }
;               
;   Entry:
;       None
;   Exit:
;       None
;   Uses:
;       AX, BX, CX
;   Exceptions:
;       
;*******************************************************************************
list_equipment:
	Write EQListString
	ReadLine
	StringCompareInsensitive InputStringBuffer, NoString
	je .return
		mov cl, byte[Character.itemCount]
		mov ch, 0
		cmp cx, 0
		je .return
		.loop:
			mov bx, cx 
			mov al, byte[Character.inventory + bx]
			mov ah, 0

			mov bx, item_size
			mul bx
			add ax, Items + item.name
			WriteLine ax
			dec cx
		jnz .loop
	.return:
	call wait_key
ret


;********************************************************************************
;   print_characteristics
;   Purpose:
;      To display the player's characteristics
;           Prototype:
;               void print_characteristics();
;           Algorithm:
;               void print_characteristics(){
;					Console.WriteLine(YourCharacteristicsString + Character.name);
;					if(Character.hp < 2){
;						Character.hp = 2;
;					}
;					Console.WriteLine(HitpointsString + Character.hp);
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
print_characteristics:
	Write YourCharacteristicsString
	WriteLine Character.name
	mov bx, word[Character.hp]
	cmp bx, 1
	jg .healthy
		mov word[Character.hp], 2
		mov bx, 2
	.healthy:
	Write HitPointsString
	call print_dec
	call new_line
	call new_line
	call wait_key
ret

