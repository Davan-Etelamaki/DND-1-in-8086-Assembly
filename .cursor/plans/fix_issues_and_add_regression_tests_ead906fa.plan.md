---
name: Fix issues and add regression tests
overview: Fix all 17 documented issues in SourceFiles in priority order, then add a robust regression test suite that runs in the existing DEBUG build and exercises the fixed game logic (math, inventory, dungeon, RNG) with deterministic seeds and clear pass/fail output.
todos: []
isProject: false
---

# Fix issues and add regression tests

## Scope

- **Fixes:** Apply all fixes from [Documentation/Issues-and-Risks.md](Documentation/Issues-and-Risks.md) in the **SourceFiles** tree only. Test/Libraries stay as the test harness; do not duplicate fixes there.
- **Tests:** Add new regression tests that run when `DEBUG` is defined, call the **game's** code (already included in Stage2 before Tests.asm), and cover the fixed behavior. Use a fixed RNG seed where needed so dungeon and dice tests are reproducible.

---

## Phase 1: Critical fixes (no new tests yet)

Fix in this order to avoid cascading breakage (e.g. layout first so save/load is consistent).

### 1.1 Layout and byte/word consistency

- **[Data/Variables/Dungeon.asm](SourceFiles/Data/Variables/Dungeon.asm)**  
Change `CurrentMonster.range` from `resb 1` to `resw 1` so runtime layout matches [GameSave.asm](SourceFiles/Data/Variables/GameSave.asm) and Fight/Battle code. No other layout change needed; SaveCurrentMonster already has `.range` as `dw`.
- **[Game/Intro.asm](SourceFiles/Game/Intro.asm)**  
  - Line 160: `mov [DungeonNumber], bx` → `mov [DungeonNumber], bl`.  
  - Line 204: `mov [Character.continues], bx` → `mov [Character.continues], bl`.
- **[Game/Game Loop/Actions/Battle.asm](SourceFiles/Game/Game Loop/Actions/Battle.asm)**  
  - Lines 78 and 83: keep `mov [CurrentMonster.range], bx` (now correct because .range is word).  
  - Line 305: `mov [CurrentMonster.type], bx` → `mov [CurrentMonster.type], bl`.
- **[Game/Game Loop.asm](SourceFiles/Game/Game Loop.asm)**  
Line 37: replace `mov bx, [DungeonNumber]` with load-byte-and-zero-extend, e.g. `mov bl, [DungeonNumber]` then `xor bh, bh`.

### 1.2 I/O and disk

- **[Libraries/IO/KeyboardIO.asm](SourceFiles/Libraries/IO/KeyboardIO.asm)**  
In `wait_key`, use blocking read: `mov ax, 0x00` before `int 0x16` (instead of AH=0x01). Optionally add a comment that "press any key" call sites (including Roll Character's `get_key`) now rely on `wait_key` for blocking; if any still use `get_key` for that, change them to `wait_key`.
- **[Libraries/IO/DiskIO.asm](SourceFiles/Libraries/IO/DiskIO.asm)**  
In `disk_save`, change both `0x9000` to `0x8000` (lines 97 and 107).

### 1.3 Game logic bugs

- **[Game/Load Game.asm](SourceFiles/Game/Load Game.asm)** — `read_dungeon` loop (lines 42–58):  
Rewrite so that:
  - Loop index is 0..624 (e.g. `bx` = index, or `cx` counting down with index = 625-1-cx).
  - For each index, load `CurrentDungeon[index]`; if it is 0, call `roll_d100` twice; if first roll ≥ 97 store 7 at that index; if second roll ≥ 97 store 8 at that index. Use the loop index for the store, not the roll value.
- **[Game/Libraries/Inventory.asm](SourceFiles/Game/Libraries/Inventory.asm)**  
  - In `check_inventory`: remove the `dec al` (line 29) so the comparison uses the item number passed in AL.  
  - In `remove_from_inventory`: remove the `inc al` (line 70) and use the slot index in AL as-is when setting `bl` for `Character.inventory + bx`.
- **[Game/Game Loop/Actions/Move.asm](SourceFiles/Game/Game Loop/Actions/Move.asm)** — `find_secret_door` (~377–386):  
Align with comment "roll_d6 > 4" → find door. So when `bx > 4` (roll 5 or 6), go to the block that does `advance_position`; otherwise `hit_wall`. Swap the targets of the `cmp bx, 4` / `jg` so that `.wall` is the "roll ≤ 4" branch and the other branch is "find door".

---

## Phase 2: Medium and low fixes

- **[SourceFiles/Stage1.asm](SourceFiles/Stage1.asm)** line 22: fix comment to say `0x8000` (not 0x9000).
- **Phase 2.1 — Name-consumer audit (issue 12):** Before changing save format or consumers, complete the **name-consumer audit** so SaveCharacter vs Character.name is handled consistently.
  - **Goal:** Identify every read/write of **Character.name** or SaveCharacter name; for each, note whether it expects (A) raw 16 bytes or (B) length-prefixed. Then choose one of: (1) document + have the two `WriteLine Character.name` call sites skip the first word when displaying after load, (2) align save format so the first 16 bytes of the name block are raw name (no length word), or (3) align consumers to treat name as length-prefixed everywhere (and store new-game name with length word).
  - **Call sites (audit list):**  
    - [Game/Roll Character.asm](SourceFiles/Game/Roll Character.asm) ~58: `StringCopy bx, Character.name` (writes new-game name; expects A).  
    - [Game/Roll Character.asm](SourceFiles/Game/Roll Character.asm) ~372: `WriteLine Character.name` (in `print_characteristics`; expects A; after load_game prints garbage if name is length-prefixed).  
    - [Game/Load Game.asm](SourceFiles/Game/Load Game.asm): `mem_copy(SaveCharacter, Character, …)` (bulk copy; SaveCharacter.name is length-prefixed, so after load Character.name starts with length word).  
    - [Data/Variables/GameSave.asm](SourceFiles/Data/Variables/GameSave.asm): SaveCharacter.name is **B** (length word + "SHAVS" + padding).  
  - Full audit table and options are in [Documentation/Issues-and-Risks.md](Documentation/Issues-and-Risks.md#audit-name-consumers-savecharacter--charactername). **Do the audit first;** then implement the chosen option (document-only, align save, or align consumers).
- **get_tile_number bounds (low):** Add a short comment in [Game/Libraries/Dungeon.asm](SourceFiles/Game/Libraries/Dungeon.asm) that callers must pass 0≤x,y≤24; optionally add a clamp or assert in debug build. For this plan, comment-only is enough.
- **parse_int overflow / disk error / DEBUG sync:** No code change in this plan; already documented in Issues-and-Risks.

---

## Phase 3: Regression test suite

Goal: run in existing DEBUG build (`%define DEBUG` in Stage2), re-use current `RunTests` entry and pass/fail style (e.g. Success/Fail strings and `int_assert_equal`-style checks), and test **the game's** code (SourceFiles), not the Test library copies.

### 3.1 Test harness conventions

- **Single include of game code:** Stage2 already includes SourceFiles (Data, Game, Libraries) before `%ifdef DEBUG %include "../Test/Tests.asm"`. So `RunTests` and any new test routines should **call** the already-included labels (e.g. `parse_int`, `get_root`, `check_inventory`, `get_tile_number`, `read_dungeon`) and **not** re-include SourceFiles. Test/Libraries are only for extra test helpers (e.g. `int_assert_equal`, Success/Fail) and for any stub that must differ in test (e.g. optional "test double" for disk).  
- **Determinism:** For tests that use RNG, set `[RandSeed]` to a known value (e.g. 12345) before the test so results are reproducible.  
- **Pass/fail:** Re-use existing pattern: compare expected vs actual (in a register or memory), then `call PrintSuccess` or `call PrintFail` (and optionally print expected/actual). Existing IntTests use `int_assert_equal(bx, cx)` with BX=actual, CX=expected.

### 3.2 Tests to add (new file or files under Test/)

Add a new test module, e.g. **Test/GameLogicTests.asm**, included from [Test/Tests.asm](Test/Tests.asm) after existing test calls. It should define a single entry point (e.g. `GameLogicTests`) and be called from `RunTests` (so no `wait_key` between every subtest if you want; optionally one `wait_key` after the whole GameLogicTests block).

1. **Math / RNG (deterministic)**
  - Set `[RandSeed]` to a fixed value; call `roll_d100` (or `get_random`) a few times and compare against known values (precomputed for that seed).  
  - Optionally: `get_root` is already tested in IntTests; keep as-is.
2. **parse_int (game's version)**
  - Ensure tests use the same string layout as the game: length word then digits (e.g. use the same NewString or a buffer with first 2 bytes then "1052", etc.). Current IntTests in Test/Libraries/Math/Int.asm already use NewString (which has the word prefix), so they already test the game's `parse_int` correctly. No change required unless we add more parse_int cases (e.g. "0", empty, or overflow-length string).
3. **Inventory**
  - Setup: initialize `Character.itemCount` and a few `Character.inventory[i]` slots to known values (e.g. item 12 in slot 2, item 11 in slot 1).  
  - `check_inventory(12)`: expect AX = 2 (or the slot where you put 12).  
  - `check_inventory(99)` (or any not present): expect AX = -1 (0xFFFF).  
  - Then call `remove_from_inventory` with the returned slot; verify the slot now holds the last item and `itemCount` decreased.  
  - These tests validate fixes for issues 9 and 10.
4. **get_tile_number**
  - Call with (cx, dx) = (0,0), (24,24), (12,12); expect BX = 0, 624, 312. Ensures indexing formula is correct; no bounds check in code yet (comment-only for now).
5. **read_dungeon (deterministic)**
  - Set `[DungeonNumber]` to 0 (or a valid index). Fill a small region of `CurrentDungeon` with known values (or use a copy of one dungeon row). Set `[RandSeed]` to a fixed value. Call `read_dungeon`. Then sample a few indices that were 0 and check they are still 0 or were set to 7/8 according to the known RNG sequence for that seed. This guards against the old "only one iteration / wrong index" bug.
6. **DungeonNumber / welcome**
  - Set `[DungeonNumber]` = 5 and `[Difficulty]` = 0. In a test, simulate what `game_loop_welcome` does: load byte and zero-extend DungeonNumber into BX, then compare BX to 5. Ensures fix for issue 8 doesn't mix in Difficulty.
7. **CurrentMonster.range and .type**
  - Set `CurrentMonster.range` to a known word (e.g. 100) and `CurrentMonster.type` to 3. Read back and compare. Ensures layout and stores (issues 5 and 6) don't corrupt adjacent fields.

### 3.3 Test layout in RunTests

- In [Test/Tests.asm](Test/Tests.asm): after existing `StringFunctionTests` (and its `wait_key`), add `call GameLogicTests` and then `call wait_key` (or one key after all game-logic tests).  
- Include the new test file: e.g. `%include "GameLogicTests.asm"` (path relative to Test/).  
- GameLogicTests will need Character, Dungeon, RandSeed, rows, etc. — all already in the Stage2 image when DEBUG is defined, so no extra includes.

### 3.4 Optional: Dice tests

- With fixed `RandSeed`, call `roll_d6` (or similar) N times and check distribution or a few known values. Low priority; can be added after the above.

---

## Phase 4: Documentation and sync

- Update [Documentation/Issues-and-Risks.md](Documentation/Issues-and-Risks.md): mark each fixed issue as "Fixed" with a brief note (e.g. "Fixed in Phase 1.1") and leave the description for history.  
- Add a short "Testing" section to [Documentation/Build-and-Run.md](Documentation/Build-and-Run.md): how to build with DEBUG, run in emulator, and what RunTests covers (memory, print, int, string, game logic).  
- Optionally add a one-line note in README or Build-and-Run that Test/Libraries should be kept in sync with SourceFiles for any duplicated code (e.g. if Test ever includes a full copy of a library for isolation).

---

## Implementation order (todos)

1. **Fixes (Phase 1–2):** Dungeon.asm (range resw 1) → Intro.asm (bl for DungeonNumber and continues) → Battle.asm (bl for type) → Game Loop.asm (DungeonNumber load) → KeyboardIO (wait_key) → DiskIO (0x8000) → Load Game (read_dungeon loop) → Inventory (check_inventory, remove_from_inventory) → Move (find_secret_door) → Stage1 comment → **name-consumer audit (Phase 2.1)** then apply chosen option for save/name → get_tile_number comment.
2. **Tests (Phase 3):** Add Test/GameLogicTests.asm with GameLogicTests entry; implement inventory, get_tile_number, read_dungeon (with fixed seed), DungeonNumber/welcome, and CurrentMonster tests; wire into RunTests.
3. **Docs (Phase 4):** Update Issues-and-Risks and Build-and-Run.

---

## Risks and notes

- **Regression:** Fixing `check_inventory` and `remove_from_inventory` changes behavior; trap handling (e.g. fall_in_trap) will now find and remove spikes correctly. The new tests should lock that in.  
- **Save format (audit):** Complete the name-consumer audit (Phase 2.1) before changing SaveCharacter name layout. The audit lists call sites and three options (document + skip first word, align save format, or align consumers). See Phase 2.1 and [Documentation/Issues-and-Risks.md](Documentation/Issues-and-Risks.md#audit-name-consumers-savecharacter--charactername) for the full audit and options.  
- **Test data layout:** GameLogicTests must not rely on uninitialized BSS; explicitly set `Character.itemCount`, `Character.inventory`, and (for read_dungeon) either use a clean copy of a dungeon or set RandSeed and a known dungeon so expectations are clear.
