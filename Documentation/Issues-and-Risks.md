# Issues and Risks

Assessment of potential bugs and risks in the DND-1 8086 Assembly port. This document is for awareness and for planning fixes. When an issue is fixed in code, update its entry to note **Fixed** and the change (e.g. file and fix summary).

## Risks when fixing

Keep these in mind when applying fixes:

- **Inventory (issues 9 and 10):** Fixing `check_inventory` and `remove_from_inventory` changes behavior: trap handling (e.g. `fall_in_trap`) will correctly find and consume spikes (item 12) and rope (item 11). Add or run regression tests after these fixes to lock in the new behavior.
- **Save/Character name (issue 12):** Issue 12 is fixed (new-game writer now sets length word before StringCopy). If changing the save format later, re-audit name consumers per the **Audit: Name consumers** section below.
- **get_tile_number (issue 17):** Callers must pass 0 ≤ x, y ≤ 24. Adding bounds checks or clamping would require a design choice (assert in DEBUG vs. clamp vs. comment-only); document the contract in code or here.
- **Test/Libraries sync (issue 16):** When adding or changing regression tests, ensure the DEBUG build tests the game’s code (SourceFiles); keep Test/Libraries in sync with SourceFiles for any duplicated code so tests remain valid.

---

## Critical / Correctness

### 1. `read_dungeon` loop logic (Load Game.asm, ~lines 42–58)

**Issue:** The loop that is supposed to place random strength (7) and constitution (8) tiles on empty cells is wrong in several ways.

- The condition `cmp cx, 0` / `jne .skip` means the inner block runs only when `cx == 0` — i.e. a single iteration, not for each of 625 cells.
- When that block runs, the second roll’s check `jl .skip` appears *after* `mov bx, cx` and `mov byte [CurrentDungeon + bx], 8`, so tile value 8 is written unconditionally at index 0.
- The intended index for writing should be the loop index (0..624), not the random value in `bx` (which is 0–99 from `roll_d100`).

**Intended behavior (from comment):** For each cell in CurrentDungeon, if the cell is 0, then with ~4% chance set 7 (strength) and with ~4% chance set 8 (constitution).

**Fix:** Rewrite the loop to iterate by index (e.g. 0 to 624), check `CurrentDungeon[index] == 0`, then use two separate `roll_d100` checks and store 7 or 8 at that index when the roll is ≥ 97.

**Fixed:** Loop rewritten in Load Game.asm: index 0..624, only process cells where `CurrentDungeon[index] == 0`, two roll_d100 calls, store 7 or 8 at that index when roll ≥ 97.

---

### 2. `wait_key` does not wait (Libraries/IO/KeyboardIO.asm, ~lines 49–51)

**Issue:** `wait_key` uses `int 0x16` with **AH = 0x01**. That function only *checks* whether a key is available; it returns immediately and does not block. For “press any key to continue” behavior, **AH = 0x00** (read key, blocking) is required.

**Impact:** All prompts that call `wait_key` (intro “Who said”, invalid command, battle messages, etc.) will not actually pause; the game will continue without waiting for a keypress. The same applies where `get_key` is used for “press any key” (e.g. Roll Character.asm line 55): both use AH=0x01 and do not block.

**Fix:** Use `mov ax, 0x00` before `int 0x16` in `wait_key` so the BIOS waits for a key.

**Fixed:** KeyboardIO.asm: `wait_key` now uses `mov ax, 0x00` before `int 0x16` (blocking read).

---

### 3. `disk_save` wrong base address (Libraries/IO/DiskIO.asm, lines 97 and 107)

**Issue:** `disk_save` computes the sector number from the save buffer address by subtracting and later adding **0x9000**. Stage2 is built with `ORG 0x8000` and loaded at 0x8000; the `.data` section (including `game_save`) lives in that same image. The base for the sector calculation should be **0x8000**, not 0x9000.

**Impact:** The sector number passed to BIOS write is wrong; the save may be written to the wrong disk sector and not restore correctly on “old game,” or may overwrite part of Stage2.

**Fix:** Use 0x8000 instead of 0x9000 in the subtract and add so the sector calculation matches the actual load address.

**Fixed:** DiskIO.asm: both subtract and add in `disk_save` now use 0x8000.

---

### 4. `get_continues` stores word into byte (Game/Intro.asm, line 204)

**Issue:** `Character.continues` is declared as `resb 1` (one byte). The code does `mov [Character.continues], bx`, which stores a full word (2 bytes). The second byte overwrites `Character.weapon`, corrupting the weapon index.

**Fix:** Store only the low byte, e.g. `mov [Character.continues], bl`, or change `.continues` to `resw 1` and ensure the rest of the Character layout is still correct.

**Fixed:** Intro.asm: `mov [Character.continues], bl`.

---

### 5. `CurrentMonster.range` is byte but used as word (Dungeon.asm vs Battle.asm, Fight.asm)

**Issue:** In `Data/Variables/Dungeon.asm`, `CurrentMonster.range` is `resb 1`. In Battle.asm (lines 78, 83) the code does `mov [CurrentMonster.range], bx`, and in Fight.asm all comparisons use `cmp word [CurrentMonster.range], ...`. The value can be up to 1000 (from `get_root` or the 1000 constant). So the code expects a word; storing BX overwrites the following byte (`CurrentMonster.hit`). Save format in GameSave.asm correctly has `SaveCurrentMonster.range` as `dw 0`.

**Impact:** Range is corrupted; combat range checks are wrong; and when saving/loading, `SaveCurrentMonsterLength` is 9 bytes (range is word in save) but runtime `CurrentMonster` is only 8 bytes (range is byte). So `load_game` writes 9 bytes into an 8-byte structure, corrupting the first byte of `CurrentDungeon`.

**Fix:** Change `CurrentMonster.range` to `resw 1` in Dungeon.asm so runtime layout matches the save and code.

**Fixed:** Data/Variables/Dungeon.asm: `CurrentMonster.range` changed to `resw 1`.

---

### 6. `CurrentMonster.type` stored as word (Battle.asm, line 305)

**Issue:** `CurrentMonster.type` is `resb 1`. In `check_for_random_encounter`, the code does `mov [CurrentMonster.type], bx`. That stores a word and overwrites `CurrentMonster.x` with the high byte.

**Fix:** Store only the low byte: `mov [CurrentMonster.type], bl`.

**Fixed:** Battle.asm: `mov [CurrentMonster.type], bl`.

---

### 7. `DungeonNumber` stored as word (Intro.asm, line 160)

**Issue:** `DungeonNumber` is `resb 1`. In `get_dungeon_num`, the code does `mov [DungeonNumber], bx`, storing a word. The high byte overwrites `Difficulty`.

**Fix:** Store only the low byte: `mov [DungeonNumber], bl`.

**Fixed:** Intro.asm: `mov [DungeonNumber], bl`.

---

### 8. `game_loop_welcome` loads DungeonNumber as word (Game Loop.asm, line 37)

**Issue:** The code does `mov bx, [DungeonNumber]`, loading two bytes (DungeonNumber and Difficulty). So the value passed to `print_dec` is `(Difficulty << 8) | DungeonNumber`, not just the dungeon number.

**Fix:** Load byte and zero-extend, e.g. `mov bl, [DungeonNumber]` then `xor bh, bh` (or `mov bh, 0`).

**Fixed:** Game Loop.asm: `mov bl, [DungeonNumber]` then `xor bh, bh` before `print_dec`.

---

### 9. `check_inventory` searches for wrong item value (Game/Libraries/Inventory.asm, line 29)

**Issue:** The code does `dec al` before the loop, then compares `al` with `Character.inventory + bx`. So it searches for **item − 1** instead of **item**. For example, `check_inventory(12)` (spikes) looks for 11 (FLASK OF OIL) in the inventory, so spikes are never found and trap handling can behave incorrectly.

**Fix:** Remove the `dec al` so the comparison uses the actual item number passed in AL.

**Fixed:** Inventory.asm: removed `dec al` in `check_inventory`.

---

### 10. `remove_from_inventory` writes to wrong slot (Game/Libraries/Inventory.asm, line 70)

**Issue:** The routine receives the inventory slot index (from `check_inventory`) in AX. It does `inc al` then uses `bl = al` to index `Character.inventory`. So it writes the “last item” into slot **index + 1** instead of **index**, leaving the requested slot unchanged and corrupting the next slot.

**Fix:** Do not increment AL; use the slot index as-is when writing to `Character.inventory + bx`.

**Fixed:** Inventory.asm: removed `inc al` in `remove_from_inventory`.

---

## Medium / Consistency and portability

### 11. Comment typo in Stage1 (SourceFiles/Stage1.asm, line 22)

Comment says “Set our starting address to 0x9000” but the code uses `0x8000`. Harmless for execution but misleading for maintenance.

**Fixed:** Stage1.asm: comment updated to say 0x8000.

---

### 12. SaveCharacter vs Character name layout (GameSave.asm vs Character.asm) — FIXED

**Issue:** The save template uses a length-prefixed name (e.g. `dw 6, "SHAVS", 0` then padding to 16 bytes). WriteLine expects length-prefixed (first word = length). The **new-game** path used `StringCopy bx, Character.name` with `bx = InputStringBuffer`; InputStringBuffer had no length word (bytes 0–1 unused), so the copied "length" was 0 or garbage and **new-game name printed blank or garbage**. The **load_game** path was correct.

**Fix applied:** In [Game/Roll Character.asm](SourceFiles/Game/Roll Character.asm), immediately before `StringCopy bx, Character.name`, added `mov bx, InputStringBuffer` and `call string_length`. The `string_length` routine writes the string length (counting from InputStringBuffer+2) as a word at InputStringBuffer+0, so StringCopy now copies a correct length-prefixed name and WriteLine displays the new-game name correctly. No save-format or reader change.

---

### 13. `find_secret_door` condition inverted (Game/Game Loop/Actions/Move.asm, ~lines 377–386)

**Issue:** The comment says “if(roll_d6 > 4)” then find door (i.e. 5 or 6). The code does `cmp bx, 4` then `jg .wall`, so 5 or 6 go to `.wall` (hit_wall) and 1–4 find the door. So the door is found 4/6 of the time instead of the intended 2/6.

**Fix:** Either swap the labels so that `jg` goes to advance_position (find door) and the other branch goes to hit_wall, or change the compare so that “find door” corresponds to roll > 4.

**Fixed:** Move.asm: roll > 4 now goes to advance_position (find door); roll ≤ 4 goes to hit_wall.

---

## Low / Robustness and maintenance

### 14. No input length check before parse_int

**Issue:** `get_user_input` limits input to 250 characters; `parse_int` then parses from that buffer. An extremely long numeric string could theoretically overflow the word-sized `IntBuffer` used in `parse_int`. Impact is low for normal command input (single digits or small numbers).

---

### 15. Disk error handling

**Issue:** On `disk_load` or `disk_save` failure, the code calls `disk_error`, which prints “Disk read error !” and then `cli`/`hlt`. There is no retry or way to return to the game. Document as a known limitation; improvement would require a different error path (e.g. retry or prompt).

---

### 16. DEBUG build and Test directory

**Issue:** With `%define DEBUG`, Stage2 includes `../Test/Tests.asm` and runs tests instead of the game. The Test directory contains its own copies of some Libraries. If those copies drift from `SourceFiles/Libraries`, tests may not reflect current behavior. Keep Test in sync when using DEBUG or running tests.

---

### 17. No bounds check in get_tile_number (Game/Libraries/Dungeon.asm)

**Issue:** `get_tile_number` computes the linear index from (cx, dx) as (y*25 + x) and returns it. There is no check that x and y are in 0..24. If a caller passes invalid coordinates (e.g. from bad input or off-by-one), the returned index can be outside 0..624 and accesses to `CurrentDungeon + bx` could read or write out of bounds. Low risk if all callers guarantee valid coordinates.

**Documented:** Game/Libraries/Dungeon.asm: comment added that callers must pass 0 ≤ x (CX), y (DX) ≤ 24; no bounds check in routine.

---

## Summary

| Severity   | Count | Status |
|-----------|-------|--------|
| Critical  | 10    | **All fixed:** 1 read_dungeon, 2 wait_key, 3 disk_save, 4 get_continues, 5 CurrentMonster.range, 6 CurrentMonster.type, 7 DungeonNumber store, 8 game_loop_welcome load, 9 check_inventory, 10 remove_from_inventory |
| Medium    | 3     | **All fixed:** 11 Stage1 comment, 12 name layout, 13 find_secret_door |
| Low       | 4     | 14 parse_int overflow, 15 disk error handling, 16 DEBUG/Test sync; 17 get_tile_number — contract documented in code |

All critical and medium issues from this list are now fixed. Low issues 14–16 remain as documented; issue 17 has a caller contract comment in Dungeon.asm.

---

## Fix and test plan (phases)

Implementation order for the issues above; regression tests lock in fixes.

**Phase 1 (critical):** Layout (CurrentMonster.range → resw 1); byte stores (DungeonNumber, continues, CurrentMonster.type → store bl); word load (game_loop_welcome: load DungeonNumber as byte); I/O (wait_key AH=0x00, disk_save 0x8000); game logic (read_dungeon loop, check_inventory/remove_from_inventory, find_secret_door). **Done.**

**Phase 2 (medium/low):** Stage1 comment 0x8000; save/name fix (see Audit below); get_tile_number contract in code. **Done.**

**Phase 3 (regression tests):** Test/Game/LogicTests.asm (read_dungeon, DungeonNumber, CurrentMonster), plus Dungeon get_tile_number and Inventory spikes/remove in existing tests. **Done.** Keep Test/Libraries in sync with SourceFiles.

**Phase 4:** Mark fixes in this doc; update Build-and-Run/Testing if test list changes. **Ongoing.**

---

## Audit: Name consumers (SaveCharacter / Character.name) — COMPLETE {#audit-name-consumers-savecharacter--charactername}

For **issue 12** (SaveCharacter vs Character name layout). Goal: identify every reader/writer of Character.name or SaveCharacter name; expect either (A) raw 16 bytes or (B) length-prefixed (word + string + padding).

**Call sites:** Roll Character.asm ~58: StringCopy to Character.name (source InputStringBuffer was not length-prefixed → wrong length word). Roll Character.asm ~372: WriteLine Character.name (expects B). Load Game.asm: mem_copy(SaveCharacter, Character) — bulk copy. GameSave.asm: SaveCharacter.name is B (length + "SHAVS" + padding).

**WriteLine/GetString:** Expect B (first word = length, then string). **string_copy:** Expects source length-prefixed, writes length-prefixed. **get_user_input:** Writes from InputStringBuffer+2; bytes 0–1 not set → not length-prefixed.

**Conclusion:** New-game path was broken (length 0 or garbage). **Fix implemented:** Before StringCopy in Roll Character.asm, call `string_length` with BX = InputStringBuffer so length word is written at InputStringBuffer+0; StringCopy then copies correct length-prefixed name. Both new-game and load_game now display the name correctly. If you change save format later, re-audit all name consumers.
