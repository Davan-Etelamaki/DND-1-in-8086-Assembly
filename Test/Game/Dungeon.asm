; Unit tests for game logic: dungeon bounds and get_tile_number (Game/Libraries/Dungeon.asm).
; Character, get_y_bounds, get_x_bounds, get_tile_number are from SourceFiles (included in Stage2).
section .data
	GameDungeonTestString NewString "Testing Dungeon (get_y_bounds, get_x_bounds, get_tile_number):"

section .text
GameDungeonTests:
	WriteLine GameDungeonTestString
	; get_y_bounds: Character.y=10, range=2 -> starty=8, endy=12
	mov byte [Character.y], 10
	mov ch, 2
	call get_y_bounds
	mov bl, cl
	xor bh, bh
	mov cx, 8
	call int_assert_equal
	mov bl, ch
	xor bh, bh
	mov cx, 12
	call int_assert_equal
	; get_x_bounds: Character.x=10, range=2 -> startx=8, endx=12
	mov byte [Character.x], 10
	mov dh, 2
	call get_x_bounds
	mov bl, dl
	xor bh, bh
	mov cx, 8
	call int_assert_equal
	mov bl, dh
	xor bh, bh
	mov cx, 12
	call int_assert_equal
	; get_tile_number: (0,0)->0, (12,12)->312, (24,24)->624; then verify tile read at that index
	mov byte [CurrentDungeon + 0], 5
	mov byte [CurrentDungeon + 312], 7
	mov byte [CurrentDungeon + 624], 6
	mov cx, 0
	mov dx, 0
	call get_tile_number
	mov al, [CurrentDungeon + bx]
	mov bl, al
	xor bh, bh
	mov cx, 5
	call int_assert_equal
	mov cx, 12
	mov dx, 12
	call get_tile_number
	mov al, [CurrentDungeon + bx]
	mov bl, al
	xor bh, bh
	mov cx, 7
	call int_assert_equal
	mov cx, 24
	mov dx, 24
	call get_tile_number
	mov al, [CurrentDungeon + bx]
	mov bl, al
	xor bh, bh
	mov cx, 6
	call int_assert_equal
	ret
