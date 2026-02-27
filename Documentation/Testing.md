# Testing

Strategy for tests in this repo, plus a step-by-step guide for adding a new unit test. **Most flows are unit tested** (assembly in `Test/`); those unit tests **run in Playwright** (test image in v86, serial assertions). UI-style tests are minimal (game boot smoke only).

---

## Strategy

### Unit tests – run in Playwright

1. Build the test image (`--debug` `--automated`). It contains `RunTests` and every test routine.
2. Playwright loads that image in the v86 emulator and runs it.
3. Tests print to the screen (and to COM1); Playwright polls serial and asserts on section markers and the absence of `Fail`.

**Where:** `Test/Tests.asm` and its includes: `Test/Libraries/` (Memory, Print, Math/Int, Strings, IO) and `Test/Game/` for game logic (Dice, Player, Dungeon, Inventory, Monsters, LogicTests). Add new routines and call them from `RunTests`.

**How:** Add a routine, call it from `RunTests`, use `PrintSuccess`/`PrintFail`. For game code in `SourceFiles/`, add the test under `Test/Game/` and include it from Stage2 (DEBUG) after the source it depends on. Add a section marker in `playwright/support/emulator.js` and a test in `playwright/tests/assembly/suite.spec.js`.

**What is covered:** Memory, Print, Int (parse_int, get_root), Strings; Game: Dice (roll_d6), Player (add_hp, lose_hp, add_gold, remove_gold), Dungeon (get_y_bounds, get_x_bounds, get_tile_number), Inventory (add/check/remove, including spikes), Monsters (10 types), LogicTests (read_dungeon 7/8, DungeonNumber byte, CurrentMonster layout).

### Playwright specs

- **Assembly suite** (`playwright/tests/assembly/suite.spec.js`): Runs the test image once; one Playwright test per section plus full-suite completion. This is how unit tests are executed.
- **Game smoke** (`playwright/tests/game/smoke.spec.js`): Runs the game image (no DEBUG); boot and keyboard input only.

### Summary

| Goal | Prefer | Avoid |
|------|--------|--------|
| Test library/game logic | Unit tests in `Test/` (run in Playwright) | Long UI flows |
| Test that the game runs | Short Playwright smoke (boot + input) | Deep UI scenarios |
| Add coverage for a new flow | New routine in `Test/` called from `RunTests` | New end-to-end UI test |

**Run tests:** From repo root, `npm test` builds both images and runs all Playwright specs.

---

## Adding a new unit test (step-by-step)

Checklist for adding a **game logic** unit test that runs in the assembly suite (v86 + Playwright).

### 1. Create the test file: `Test/Game/<Name>.asm`

- **Naming:** Match the routine name to the Playwright section id (e.g. `GameFooTests` → `"GameFooTests"`).
- **Layout:** Optional `section .data` with a string your test prints; `section .text` with a single entry routine.

**Template:**

```asm
; Unit tests for game logic: <short description>.
; <Routine under test> is from SourceFiles/... (included in Stage2 before this).
section .data
	GameFooTestString NewString "Testing Foo (game logic):"

section .text
GameFooTests:
	WriteLine GameFooTestString
	; Set up minimal state (e.g. set [Character.hp], [RandSeed], etc.)
	; call <game_routine>
	; cmp / jl / jg / etc. then:
	; call PrintSuccess or call PrintFail
	ret
```

Use `PrintSuccess`/`PrintFail`. The first line you print should be unique so Playwright can match it in SECTION_MARKERS.

### 2. Include the test from Stage2 (DEBUG only)

In **SourceFiles/Stage2.asm**, add **after** the game module you are testing:

```asm
	%ifdef DEBUG
		%include "../Test/Game/<Name>.asm"
	%endif
```

### 3. Call the test from `RunTests`: `Test/Tests.asm`

Add in run order (before `WriteLine AllTestsPassedString`):

```asm
	call GameFooTests
	%ifndef AUTOMATED
	call wait_key
	%endif
	call clear_screen
```

The routine’s source is included from Stage2; Tests.asm only needs the `call`.

### 4. Register section: `playwright/support/emulator.js`

In `SECTION_MARKERS`, add (in the same order as RunTests, before `Done`):

```js
{ id: "GameFooTests", patterns: ["Testing Foo (game logic):"] },
```

### 5. Add a Playwright test: `playwright/tests/assembly/suite.spec.js`

```js
test("Game: foo (<short description>) run without failure", async () => {
  if (!runResult) throw new Error("Emulator run did not complete");
  expect(runResult.parsed.sections).toContain("GameFooTests");
  expect(runResult.parsed.hasFail).toBe(false);
});
```

### 6. Run and confirm

From repo root: `npm test`. All tests (including the new one) must pass.

**Checklist summary:** Create Test/Game/\<Name\>.asm → include from Stage2 after game source → add call in Tests.asm → add to SECTION_MARKERS → add test in suite.spec.js → run `npm test`. See also **Assembly-and-Test-Conventions** in `.cursor/rules/` and [Issues-and-Risks.md](Issues-and-Risks.md).
