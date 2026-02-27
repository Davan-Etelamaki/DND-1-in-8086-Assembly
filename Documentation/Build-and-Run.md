# Build and Run

How to build the bootable image and run it (emulator or real hardware).

## Requirements

- **NASM** (Netwide Assembler). The build uses `-f bin` (raw binary) and targets 8086. For the Node scripts (`npm run build`, `npm start`, `npm test`), if NASM is not on PATH, the script looks for it in `C:\Program Files\NASM` on Windows; you can also set **NASM_PATH** to the full path to the `nasm` executable. **Linux CI:** install NASM before building (e.g. `apt-get install -y nasm`); see [.github/workflows/ci.yml](../.github/workflows/ci.yml) for an example.
- **Make** (optional): On Windows, use **Git Bash** for `make`, or use **PowerShell** with `Scripts/Build.ps1` (no make required).

## Build (Makefile)

From the repository root:

| Command | Description |
|---------|-------------|
| `make` or `make build` | Build **OS.bin** (Stage1 + Stage2). |
| `make clean` | Remove compiled artifacts. |
| `make debug` | Build with tests enabled (RunTests instead of game); no need to edit source. |
| `make run` | Build then run in QEMU (requires `qemu-system-i386`). |
| `make test` | Same as `make debug`; prints the QEMU command to run tests. |
| `make test-run` | Build debug image, run QEMU with serial on stdout, parse for pass/fail; exit 0/1 (scriptable). |

Build steps:

1. Assembles **Stage1.asm** → `Compiled/Source/stage1.com`
2. Assembles **Stage2.asm** → `Compiled/Source/stage2.com`
3. Concatenates them into **`Compiled/Bin/OS.bin`**

NASM is invoked with `-f bin` and `-i "SourceFiles/"`. The result is the full bootable image: sector 1 = Stage1 (512 bytes), sectors 2+ = Stage2.

## Build (Windows without make)

- **`Scripts/Build.ps1`** — PowerShell script. From repo root: `.\Scripts\Build.ps1` (release) or `.\Scripts\Build.ps1 Debug` (test build). Uses NASM and produces the same `Compiled/Bin/OS.bin` as the Makefile. No `cat` or make required.
- **`Scripts/Run.bat`** — Legacy: builds from `SourceFiles` with a different layout (includes `padding.asm`). Prefer the Makefile or Build.ps1 for a standard build.
- **`Scripts/CopytoVHD.bat`** — Example of writing a built image to a physical disk/partition (path and device are machine-specific).
- **`Scripts/create vhdd.bat`** — Creates a fixed 5 MB VHD via diskpart for testing.

## Running

1. Build **OS.bin** (see above).
2. Run in an emulator, e.g.:
   - **QEMU**: `qemu-system-i386 -m 16 -hda Compiled/Bin/OS.bin`
   - Or use the QEMU command inside `Scripts/Run.bat` after fixing paths.
3. Or write **OS.bin** to a bootable disk/VHD (e.g. first sector + following sectors) and boot from it. The game does not require an OS; it uses BIOS interrupts for disk and keyboard.

## Debug build and testing

You do **not** need to edit source to enable tests. Use:

- **Make:** `make debug` (passes `-DDEBUG` to NASM for Stage2).
- **PowerShell:** `.\Scripts\Build.ps1 Debug`.

Stage2 then includes `Test/Tests.asm` and calls `RunTests` instead of the game. Run the resulting **OS.bin** in QEMU to see test output.

**RunTests** runs: `MemoryFunctionTests`, `PrintTest`, `IntTests`, `StringFunctionTests`. These exercise memory copy, print, integer parsing and `get_root`, and string helpers. They call into the game code in SourceFiles.

**Workflow:** After code changes, run `make debug` (or `Build.ps1 Debug`), then start QEMU with the image and confirm test output. Keep **Test/Libraries** in sync with **SourceFiles** if Test uses its own copies. A planned expansion is game-logic regression tests (inventory, dungeon, RNG with fixed seed).

## Automated testing (scriptable, no GUI)

When **DEBUG** is defined, the debug build also sends all character output to the **serial port (COM1)** via BIOS int 14h, in addition to video. For scripted runs, build with **-DAUTOMATED** as well (e.g. `make test-run` or `RunTests.ps1`); that skips `wait_key` between tests so the run does not block on input. You can run QEMU with serial redirected to the host so tests can be driven from the shell and pass/fail determined by parsing output.

- **QEMU command for automated runs:**  
  `qemu-system-i386 -m 16 -hda Compiled/Bin/OS.bin -nographic -serial stdio`  
  All test output then appears on stdout (no display). The test harness prints a final line `ALL_TESTS_PASSED` on success; any test failure prints `Fail`.

- **Run automated tests (exit 0 = pass, 1 = fail):**
  - **Make (Git Bash / Unix):** `make test-run` — builds debug image, runs QEMU with the above options, timeouts after 15 s, then parses output for `ALL_TESTS_PASSED` and `Fail`.
  - **PowerShell (Windows):** `.\Scripts\RunTests.ps1` — same idea: builds debug, runs QEMU, captures stdout, exits 0 only if `ALL_TESTS_PASSED` is present and `Fail` is not.

Requirements: NASM and **qemu-system-i386**. The scripts create the debug image themselves; no need to run `make debug` first.

## Build and test with Node (npm) — alternate workflow

The Node/npm workflow is an **alternative** to Make and PowerShell, not a replacement. Use it if you prefer driving build and test from Node (e.g. CI, or future Playwright/browser-based tests).

If you have **Node.js 18+**, the Node workflow uses **[v86](https://copy.sh/v86/)** (browser-based x86 emulator). No QEMU required for Node.

| Script | Description |
|--------|-------------|
| `npm start` | Build **OS.bin** and run the game in the browser (v86). Starts a local server and opens the emulator page. |
| `npm run build` | Build **OS.bin** (release). Uses NASM from PATH, **NASM_PATH**, or (on Windows) `Program Files\NASM`. |
| `npm run build:debug` | Build with tests enabled (RunTests instead of game). |
| `npm run clean` | Remove `Compiled/Source/*.com` and `Compiled/Bin/OS.bin`. |
| `npm run test` | Build debug+automated image, run **existing tests** in v86 (headless browser), parse serial; exit 0 or 1. Requires **NASM** and **Playwright** (`npx playwright install` once). |
| `npm run test:qemu` | Same as `npm test`. |
| `npm run test:playwright` | Run the same existing tests via [Playwright](https://playwright.dev/) (see below). |

Build requires NASM. Running and testing in Node use v86 (no QEMU).

## Playwright testing

Playwright runs the assembly test suite and minimal game smoke tests. See **[Testing.md](Testing.md)** for the strategy: **most flows are unit tested** (assembly harness in `Test/`); Playwright is for running those unit tests in v86 and for a short game boot smoke.

- **Layout:** Config and specs under **`playwright/`**. See [playwright/README.md](../playwright/README.md) for structure and each test.
- **Behavior:** `npm test` builds both the game and test images, starts a local server, then runs Playwright (assembly suite + game smoke).

After `npm install`, run `npx playwright install` once to install browser binaries.

