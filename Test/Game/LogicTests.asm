; Unit tests for game logic gaps: read_dungeon 7/8 placement, DungeonNumber byte, CurrentMonster layout.
; Covers AC-019, AC-020, AC-034, AC-035, R-1, R-5, R-6, R-7.
; Requires: read_dungeon, RandSeed, DungeonNumber, Difficulty, Dungeon1, CurrentDungeon, CurrentMonster (from Stage2).
section .data
	GameLogicTestString NewString "Testing Game Logic (read_dungeon, DungeonNumber, CurrentMonster):"

section .text
GameLogicTests:
	WriteLine GameLogicTestString
	; ---- read_dungeon: 7/8 only where base dungeon has 0 ----
	mov byte [DungeonNumber], 0
	mov byte [Difficulty], 0
	mov word [RandSeed], 0x1234
	call read_dungeon
	xor si, si
.read_dungeon_loop:
	mov bx, si
	mov al, [Dungeon1 + bx]
	mov ah, [CurrentDungeon + bx]
	cmp al, 0
	jne .must_equal
	cmp ah, 0
	je .read_next
	cmp ah, 7
	je .read_next
	cmp ah, 8
	je .read_next
	jmp .read_fail
.must_equal:
	cmp al, ah
	jne .read_fail
.read_next:
	inc si
	cmp si, 625
	jl .read_dungeon_loop
	mov bx, 1
	mov cx, 1
	call int_assert_equal
	jmp .dungeon_done
.read_fail:
	mov bx, 0
	mov cx, 1
	call int_assert_equal
.dungeon_done:
	; ---- DungeonNumber byte store; Difficulty unchanged ----
	mov byte [Difficulty], 0x55
	mov byte [DungeonNumber], 3
	mov bl, [DungeonNumber]
	xor bh, bh
	mov cx, 3
	call int_assert_equal
	mov bl, [Difficulty]
	xor bh, bh
	mov cx, 0x55
	call int_assert_equal
	; ---- CurrentMonster .type byte, .range word (no corruption of .x or .hit) ----
	mov byte [CurrentMonster.type], 2
	mov byte [CurrentMonster.x], 10
	mov word [CurrentMonster.range], 500
	mov bl, [CurrentMonster.type]
	xor bh, bh
	mov cx, 2
	call int_assert_equal
	mov bl, [CurrentMonster.x]
	xor bh, bh
	mov cx, 10
	call int_assert_equal
	mov bx, [CurrentMonster.range]
	mov cx, 500
	call int_assert_equal
	ret
