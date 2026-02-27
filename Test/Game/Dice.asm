; Unit tests for game logic: dice (used in combat, treasure, etc.).
; RandSeed and roll_d6 are from SourceFiles/Libraries/Math/ (included in Stage2 after this).
section .data
	GameDiceTestString NewString "Testing Dice (game logic):"

section .text
GameDiceTests:
	WriteLine GameDiceTestString
	mov word [RandSeed], 12345
	call roll_d6
	cmp bx, 1
	jl .fail
	cmp bx, 6
	jg .fail
	call PrintSuccess
	ret
.fail:
	call PrintFail
	ret
