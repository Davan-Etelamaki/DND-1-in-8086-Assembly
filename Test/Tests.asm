; Test runner for DND-1 8086 Assembly. Invoked from Stage2 when DEBUG is defined.
; Calls each test suite in order; %include pulls in Test/Libraries (Int, Strings, Memory, Print, IO).
section .data
	Success NewString "Success"
	Fail NewString "Fail"
	AllTestsPassedString NewString "ALL_TESTS_PASSED"

section .text
RunTests:
	call clear_screen
	call MemoryFunctionTests
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
	call PrintTest
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
	call IntTests
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
	call StringFunctionTests
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
	call GameDiceTests
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
	call GamePlayerTests
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
	call GameDungeonTests
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
	call GameInventoryTests
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
	call GameMonstersTests
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
	call GameLogicTests
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
	WriteLine AllTestsPassedString
	ret

	%include "../Test/Libraries/Math/Int.asm"
	%include "../Test/Libraries/Strings/StringFunctions.asm"
	%include "../Test/Libraries/Memory/MemoryFunctions.asm"
	%include "../Test/Libraries/Graphics/Print.asm"
	%include "../Test/Libraries/IO/KeyboardIO.asm"
	%include "../Test/Libraries/IO/DiskIO.asm"

