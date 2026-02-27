; Unit tests for game logic: player HP and gold (Game/Libraries/Player.asm).
; Character, add_hp, lose_hp, add_gold, remove_gold are from SourceFiles (included in Stage2).
section .data
	GamePlayerTestString NewString "Testing Player (HP and gold):"

section .text
GamePlayerTests:
	WriteLine GamePlayerTestString
	; add_hp: Character.hp = 10, add 5 -> expect 15
	mov word [Character.hp], 10
	mov ax, 5
	call add_hp
	mov bx, [Character.hp]
	mov cx, 15
	call int_assert_equal
	; lose_hp: Character.hp = 20, lose 5 -> expect 15
	mov word [Character.hp], 20
	mov ax, 5
	call lose_hp
	mov bx, [Character.hp]
	mov cx, 15
	call int_assert_equal
	; add_gold: Character.gold = 100, add 50 -> expect 150
	mov word [Character.gold], 100
	mov ax, 50
	call add_gold
	mov bx, [Character.gold]
	mov cx, 150
	call int_assert_equal
	; remove_gold: Character.gold = 100, remove 30 -> expect 70
	mov word [Character.gold], 100
	mov ax, 30
	call remove_gold
	mov bx, [Character.gold]
	mov cx, 70
	call int_assert_equal
	ret
