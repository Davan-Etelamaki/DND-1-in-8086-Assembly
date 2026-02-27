# Documentation index

Quick pointer to where to find what in this repo. Use this when you need the right doc fast (e.g. for planning, implementing, or debugging).

---

## Repository layout (summary)

| Path | Purpose |
|------|---------|
| **SourceFiles/** | Stage1, Stage2; Game/ (Intro, Roll Character, Shop, Load Game, Game Loop, Actions); Data/ (Constants, Variables, Strings); Libraries/ (Graphics, Strings, Memory, Math, IO) |
| **Test/** | Tests.asm (runner); Game/ (Dice, Player, Dungeon, Inventory, Monsters, LogicTests); Libraries/ (Int, Strings, Memory, Print, IO) |
| **Scripts/** | build.js, run-tests.js, serve.js, start.js |
| **Documentation/** | This folder: design, build, test, issues, acceptance criteria |
| **Dungeons/** | DNG1.txt–DNG6.txt and README (dungeon data; extraction script in Scripts/) |
| **playwright/** | Tests run in v86 emulator; suite.spec.js, game smoke |
| **.cursor/build-specs/** | 00-FULL-SCOPE.md, 01–09 component specs (source of truth for AC) |

---

## Core design and behavior

| Need | Document |
|------|----------|
| **Game flow** — boot, intro, loop, commands, move/tile handling, fight, save | [Game-Flow.md](Game-Flow.md) |
| **Data layout** — Character, Dungeon, tile codes, Items, Spells, Monsters, save format | [Data-Structures.md](Data-Structures.md) |
| **Architecture** — boot sequence, memory map, Stage1/Stage2, module organization | [Architecture.md](Architecture.md) |
| **Reference spec** — Richard Garriott DND #1 (1977) from web refs; mapping to this port | [DND1-Spec-Web-References.md](DND1-Spec-Web-References.md) |
| **Build specs** — Full-scope and component specs (from spec + BASIC + web); component-level detail | [.cursor/build-specs/](../.cursor/build-specs/README.md) |
| **DNG1–DNG6** — Dungeon data files (editable .txt); format, extraction, and mapping to Dungeons.asm | [Dungeons/README.md](../Dungeons/README.md) |

---

## Build, run, and test

| Need | Document |
|------|----------|
| **Build and run** — NASM, Make/PowerShell/Node, QEMU, v86, debug vs release | [Build-and-Run.md](Build-and-Run.md) |
| **Testing** — strategy, coverage, and step-by-step for adding a unit test | [Testing.md](Testing.md) |

---

## Quality and fixes

| Need | Document |
|------|----------|
| **Known issues and risks** — bugs, fix notes, fix/test phases, name-consumer audit | [Issues-and-Risks.md](Issues-and-Risks.md) |
| **Acceptance Criteria** — derived from build-specs; test coverage and gap list | [Acceptance-Criteria.md](Acceptance-Criteria.md) |

---

## Pipeline and logging

| Need | Document |
|------|----------|
| **Build log** — pipeline runs, Git metadata, what was built | [ai-build-log.md](ai-build-log.md) |

---

## Cursor rules and skills (reference)

| Purpose | Location |
|---------|----------|
| Plan from requirements/spec | Rule: **Plan-From-Requirements** |
| Implement from plan | Rule: **Implement-From-Plan** |
| Log build to ai-build-log | Rule: **Log-Build** |
| Assembly and test conventions | Rule: **Assembly-and-Test-Conventions** |
| When debugging or fixing | Rule: **When-Debugging-or-Fixing** |
| Verify + derive AC + add tests | Skill: **verify-implementation** |
| Full pipeline (plan → implement → verify → log) | Skill: **build-and-test-pipeline** (RUN_BUILD_PIPELINE) |

---

*This index is for navigation. Prefer the linked documents for detailed content.*
