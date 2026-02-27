; Unit tests for game logic: Monsters table (10 monster types per DND1 spec).
; Structures (monster_size, monster) and Monsters are from SourceFiles (included in Stage2).
section .data
	GameMonstersTestString NewString "Testing Monsters (10 types per spec):"

section .text
GameMonstersTests:
	WriteLine GameMonstersTestString
	; Verify 10th monster (index 9, MUMMY) has non-zero initHP (spec: 10 monster types)
	mov ax, 9
	mov cx, monster_size
	mul cx
	mov bx, Monsters
	add bx, ax
	cmp word [bx + monster.initHP], 0
	jle .fail
	call PrintSuccess
	ret
.fail:
	call PrintFail
	ret
