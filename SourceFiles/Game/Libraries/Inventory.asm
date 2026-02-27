; Inventory: check_inventory(item), remove_from_inventory(slot), add_to_inventory(item). Uses Character.itemCount, Character.inventory.
section .text
;********************************************************************************
;   check_inventory
;   Purpose:
;      To check a player's inventory for a given item
;           Prototype:
;               Byte check_inventory(Byte item);
;           Algorithm:
;               Byte check_inventory(Byte item){
;					for(int x = Character.itemCount; x > 0; x--){
;						if(Character.inventory[x] == item) return x
;					}
;					return -1;
;               }
;               
;   Entry:
;       Byte item number in AX
;   Exit:
;       Byte inventory number in AX
;   Uses:
;       AX, BX
;   Exceptions:
;       
;*******************************************************************************
check_inventory:
	push bx
	mov bh, 0
	mov bl, byte[Character.itemCount]
	.loop:
		cmp al, byte[Character.inventory + bx]
		je .yes
	dec bx
	jnz .loop
	.no:
		mov ax, -1
		jmp .return
	.yes:
		mov ax, bx
	.return:
		pop bx
ret

;********************************************************************************
;   remove_from_inventory
;   Purpose:
;      To remove an item from the player's inventory
;           Prototype:
;               void remove_from_inventory(Byte item);
;           Algorithm:
;               void remove_from_inventory(Byte item){
;					int temp = Character.inventory[Character.itemCount -1];
;					Character.inventory[item] = temp;
;					Character.itemCount--;
;               }
;               
;   Entry:
;       Byte inventory number in AX
;   Exit:
;       None
;   Uses:
;       AX, BX, CX
;   Exceptions:
;       
;*******************************************************************************
remove_from_inventory:
	push bx
	mov bh, 0
	push cx
		mov bl, [Character.itemCount]
		dec bl
		mov cl, [Character.inventory + bx]
		mov bl, al
		mov [Character.inventory + bx], cl
		mov [Character.itemCount], bl
	pop cx
	pop bx
ret

;********************************************************************************
;   add_to_inventory
;   Purpose:
;      To add an item to the player's inventory
;           Prototype:
;               void add_to_inventory(Byte item);
;           Algorithm:
;               void add_to_inventory(Byte item){
;					Character.itemCount++;
;					Character.inventory[Character.itemCount] = item;
;               }
;               
;   Entry:
;       Byte inventory number in AX
;   Exit:
;       None
;   Uses:
;       AX, BX, CX
;   Exceptions:
;       
;*******************************************************************************
add_to_inventory:
	push bx
	mov bh, 0
	push cx
		mov bl, [Character.itemCount]
		inc bl
		mov [Character.inventory + bx], al
		mov [Character.itemCount], bl
	pop cx
	pop bx
ret
