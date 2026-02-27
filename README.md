# DND-1-in-8086-Assembly

A port of Richard Garriott's DND #1 in pure 8086 Assembly.

## Repository layout

| Path | Purpose |
|------|---------|
| **SourceFiles/** | Boot (Stage1, Stage2) and game source (Game/, Data/, Libraries/) |
| **Test/** | Unit test runner (Tests.asm) and test modules (Game/, Libraries/) |
| **Scripts/** | Build and run (build.js, run-tests.js, serve.js, start.js) |
| **Documentation/** | Design, flow, data structures, build, testing, issues; see [Documentation/README.md](Documentation/README.md) for the full index |
| **Dungeons/** | DNG1–DNG6 dungeon data as editable text; see [Dungeons/README.md](Dungeons/README.md) |
| **playwright/** | Browser-based tests (v86 emulator); see [playwright/README.md](playwright/README.md) |
| **.cursor/build-specs/** | Component specs (source of truth for acceptance criteria) |

## What this is

This is a port of the original game to **bootable 8086 assembly**. The goal is a version that runs on any x86 machine from 1978 onward. The game is **bootable** (independent of any operating system) and uses only BIOS services (no hardware acceleration), so it is not dependent on specific hardware.

## Build and run

**Primary (Make / scripts):** From the repo root: `make` or `make build` (requires NASM; on Windows use Git Bash or `.\Scripts\Build.ps1`). Run: `make run` or `qemu-system-i386 -m 16 -hda Compiled/Bin/OS.bin`. Automated tests: `make test-run` or `.\Scripts\RunTests.ps1`.

**Alternate (Node/npm):** If you prefer Node.js 18+ as the driver, the Node workflow uses **[v86](https://copy.sh/v86/)** (browser-based x86 emulator), not QEMU:

- `npm start` — build **OS.bin** and run the game in your browser via v86 (starts a local server and opens the emulator page).
- `npm run build` — build **OS.bin** only (requires [NASM](https://www.nasm.us/) on PATH).
- `npm run build:debug` — build with tests enabled.
- `npm run test` — build test image, run existing tests in v86 (headless browser), parse serial; exit 0/1. Requires NASM and **Playwright** (`npx playwright install` once).
- `npm run test:playwright` — run the same existing tests via [Playwright](https://playwright.dev/) (see [Build and Run](Documentation/Build-and-Run.md#playwright-testing)).
- `npm run clean` — remove built artifacts.

The Node workflow is an **alternative**, not a replacement; Make/PowerShell + QEMU remain the primary way to build and test. Node uses v86 so you do not need QEMU for `npm start` or `npm test`.

**Requirements:** NASM for building. For running: QEMU (primary) or Node + browser (alternate). See [Documentation/Build-and-Run.md](Documentation/Build-and-Run.md) for all options.

## Documentation

**Full index:** [Documentation/README.md](Documentation/README.md)

- [Architecture](Documentation/Architecture.md) — Boot sequence, memory layout, module organization
- [Build and Run](Documentation/Build-and-Run.md) — Build steps, scripts, debug build
- [Data Structures](Documentation/Data-Structures.md) — Structures, variables, constants, save format
- [Game Flow](Documentation/Game-Flow.md) — Intro, commands, move/tile handling
- [Acceptance Criteria](Documentation/Acceptance-Criteria.md) — Testable criteria from build-specs; gap list and regression AC
- [Issues and Risks](Documentation/Issues-and-Risks.md) — Known bugs, assessment, risks when fixing, and (when applied) fix status
- [Issues and Risks](Documentation/Issues-and-Risks.md) — Known bugs, fix status, fix/test phases, and **name-consumer audit** (save/Character name)

## CI

[GitHub Actions](.github/workflows/ci.yml) runs on push and pull requests to `main`/`master`: installs NASM and Node on Ubuntu, runs `npm run build` and `npm test` (v86 in headless browser).

## Status

Currently in development; a beta is planned.
