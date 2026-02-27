; Unit tests for game logic: inventory (Game/Libraries/Inventory.asm).
; Character, add_to_inventory, check_inventory, remove_from_inventory from SourceFiles (included in Stage2).
; Covers AC-012, AC-013, R-9, R-10: check_inventory(item) finds correct item; remove_from_inventory(slot) clears that slot.
section .data
	GameInventoryTestString NewString "Testing Inventory (add, check, remove):"

section .text
GameInventoryTests:
	WriteLine GameInventoryTestString
	; add_to_inventory(item): item in AL. Start with itemCount=0, add 7, then check_inventory(7) -> 1
	mov byte [Character.itemCount], 0
	mov al, 7
	call add_to_inventory
	mov al, 7
	call check_inventory
	mov bx, ax
	mov cx, 1
	call int_assert_equal
	; check_inventory(12) and remove_from_inventory: add spikes (12) and mace (4); check 12 returns slot; remove that slot; check 12 not found
	mov byte [Character.itemCount], 0
	mov al, 12
	call add_to_inventory
	mov al, 4
	call add_to_inventory
	mov al, 12
	call check_inventory
	mov bx, ax
	mov cx, 1
	call int_assert_equal
	mov ax, 1
	call remove_from_inventory
	mov al, 12
	call check_inventory
	mov bx, ax
	mov cx, 0xFFFF
	call int_assert_equal
	ret
