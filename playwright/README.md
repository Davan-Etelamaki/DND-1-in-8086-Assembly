# Playwright tests for DND-1 8086 Assembly

Playwright runs two things in the **v86** emulator:

1. **Assembly test suite (unit tests)** — Unit tests live in `Test/` and run **in Playwright**: the test image runs `RunTests` in v86, prints to COM1, and Playwright polls serial and asserts per section. Any new unit tests you add (in `Test/`) run in this same Playwright run. See [Documentation/Testing.md](../Documentation/Testing.md).
2. **Game smoke tests (minimal UI)** — The game image boots; we only check that it displays and accepts keyboard input. Detailed game behaviour is unit tested in `Test/` and runs in Playwright like the rest.

## How to run

- **From repo root (recommended):**  
  `npm test` — builds both the **game** image (`OS-game.bin`) and the **test** image (`OS.bin`), starts the static server, then runs all Playwright tests (assembly + game).
- **Playwright only (server must already be running):**  
  `npx playwright test --config=playwright/playwright.config.js`  
  Set `PORT` if the server is not on 3848. Both `Compiled/Bin/OS.bin` and `Compiled/Bin/OS-game.bin` must exist (run `node scripts/build.js --game` and `node scripts/build.js --debug --automated` first).

## Folder structure

```
playwright/
  playwright.config.js   # Playwright config (testDir, timeouts, reporters)
  support/
    emulator.js         # Shared helpers: serial polling, parsing, run until done
  tests/
    assembly/
      suite.spec.js     # Assembly suite: one emulator run, then one test per section
    game/
      smoke.spec.js     # Game smoke: boot and keyboard input
  README.md             # This file
```

## Test layout

**Assembly suite** (`suite.spec.js`): Covers **existing** unit tests (Memory, Print, Int, String) and **game flow** unit tests (e.g. Dice). One emulator run in `beforeAll`, then one Playwright test per section:

| Test name | What is being tested |
|-----------|----------------------|
| **Memory: mem_copy and string comparison run without failure** | `mem_copy` and string comparison. Source: `Test/Libraries/Memory/MemoryFunctions.asm`. |
| **Print: print_string, print_dec, new_line and cursor (ypos) run without failure** | Print and cursor. Source: `Test/Libraries/Graphics/Print.asm`. |
| **Integer: parse_int and get_root (parsing and integer square root) run without failure** | `parse_int` and `get_root`. Source: `Test/Libraries/Math/Int.asm`. |
| **String: compare, to_upper, to_lower, substring, copy run without failure** | String functions. Source: `Test/Libraries/Strings/StringFunctions.asm`. |
| **Game: dice (roll_d6) run without failure** | `roll_d6` with fixed seed returns 1–6. Source: `Test/Game/Dice.asm`. |
| **Game: player (HP and gold) run without failure** | `add_hp`, `lose_hp`, `add_gold`, `remove_gold`. Source: `Test/Game/Player.asm`. |
| **Game: dungeon (bounds) run without failure** | `get_y_bounds`, `get_x_bounds`. Source: `Test/Game/Dungeon.asm`. |
| **Game: inventory (add, check) run without failure** | `add_to_inventory`, `check_inventory`. Source: `Test/Game/Inventory.asm`. |
| **Full suite completes with ALL_TESTS_PASSED and no Fail** | All sections ran and the suite printed `ALL_TESTS_PASSED`. Source: `Test/Tests.asm`. |

### Game smoke tests (`tests/game/smoke.spec.js`) – minimal UI only

These are **not** full flow tests; game logic should be unit tested in `Test/` (see [Documentation/Testing.md](../Documentation/Testing.md)).

| Test name | What is being tested |
|-----------|----------------------|
| **Game image boots and displays content (title / intro)** | Game image boots in v86; canvas gets non-zero size. |
| **Game accepts keyboard input (intro prompts respond to keys)** | Sending keys does not crash; canvas remains valid. |

## Artifacts

- The **first test** that runs attaches:
  - **serial-output.txt** — full serial output from the test run.
  - **serial-output-tail.txt** — last 800 characters.
  - **emulator-screen.png** — screenshot of the emulator canvas (only when the run failed or did not reach `ALL_TESTS_PASSED`).

View them in the HTML report:  
`npx playwright show-report playwright/playwright-report`

## Source of truth

- Assembly test flow: `Test/Tests.asm` (and the asm files it includes).
- Game flow: `SourceFiles/Stage2.asm` (when DEBUG is not set): `intro` → `game_loop`.
- Emulator UI: `tools/emulator.html`.
- Build: `scripts/build.js --game` → `Compiled/Bin/OS-game.bin` (game). `scripts/build.js --debug --automated` → `Compiled/Bin/OS.bin` (assembly tests).
