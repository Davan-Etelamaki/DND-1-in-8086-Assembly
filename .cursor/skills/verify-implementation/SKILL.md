---
description: >
  Verifies implementation: derives Acceptance Criteria from spec, creates tests
  for AC that lack coverage, runs tests, and reports. Assembly + Test/ + playwright + docs.
alwaysApply: false
---

# Skill: verify-implementation

## Purpose

Controlled verification phase to ensure the implementation:

1. Has **Acceptance Criteria** derived from the spec and documented (Documentation/Acceptance-Criteria.md)
2. Has **tests** for each AC; creates missing tests (Test/ or Playwright per Documentation/Testing.md)
3. Passes automated tests (unit + Playwright)
4. Has Documentation/ updated when behavior or flow changed
5. Stays within repo conventions (assembly, Test/, playwright, scripts)

This Skill:
- Derives Acceptance Criteria from spec docs: **`.cursor/build-specs/`** (README.md, 00-FULL-SCOPE.md, and component specs 01–09), plus Documentation/ (DND1-Spec-Web-References.md, Game-Flow.md, Data-Structures.md, Architecture.md, Testing.md), and writes/updates Documentation/Acceptance-Criteria.md
- For each AC: checks if a test already exists (Test/Game/, Test/Libraries/, playwright/tests/); if not, creates the test following Documentation/Testing.md (assembly unit test in Test/ with RunTests + emulator section + suite.spec.js, or Playwright smoke when appropriate)
- Runs the project test suite (e.g. `npm test`)
- Produces a Verification Report or Spec Validation Report including AC and tests created

This Skill does NOT:
- Refactor architecture or change dependency versions
- Introduce new patterns unrelated to spec-derived AC

────────────────────────────
INPUTS
────────────────────────────

Required:
- Scope: <short description of what was implemented, e.g. "game flow unit tests" or "Stage2 move logic"> — or "validate all spec" when running full spec validation
- Paths: <list of main files changed> — or key areas (e.g. SourceFiles/, Test/, playwright/tests/) when Scope is "validate all spec"

Optional:
- ValidateAllSpec: true — when set (e.g. from RUN_BUILD_PIPELINE with no Spec/Feature), run full spec validation: load all spec docs, compare with codebase, run tests, output Spec Validation Report
- MajorDeviationThreshold: not used (kept for compatibility)

────────────────────────────
PROCESS (normal verification)
────────────────────────────

1) Load context
- List of files changed (Paths)
- Relevant docs: **`.cursor/build-specs/`** (component spec for the area being verified, e.g. 04-Dungeon, 06-Move, 08-Save-Load); Documentation/Testing.md, Build-and-Run.md, Game-Flow.md (if game logic); Documentation/DND1-Spec-Web-References.md when verifying game-behavior or spec alignment

2) Derive Acceptance Criteria and ensure tests exist
- From the spec docs relevant to Scope, derive testable Acceptance Criteria (e.g. "Character has 7 attributes + gold", "Commands 0–12 dispatch correctly", "Tile types 0–8 behave per Game-Flow").
- Write or update **Documentation/Acceptance-Criteria.md**: list each AC with an ID (AC-001, AC-002, …), short statement, source doc, and test coverage (file/name or "none").
- For each AC that has no test coverage: create the test following Documentation/Testing.md:
  - **Game/logic behavior** → assembly unit test in Test/Game/ (or Test/Libraries/): add routine, call from RunTests in Test/Tests.asm, include from Stage2.asm under DEBUG after the source it uses; add section in playwright/support/emulator.js (SECTION_MARKERS) and a test in playwright/tests/assembly/suite.spec.js.
  - **Boot/UI or high-level flow** → add to Playwright game smoke (playwright/tests/game/smoke.spec.js) only if minimal and non-flaky.
- Record: AC added/updated, tests created (file list or "none").

3) Run tests
- Execute project test command (e.g. `npm test`). If Playwright is used for the changed area, run Playwright per playwright/README.md.
- Record: pass / fail / skipped (with reason)

4) Doc check
- If implementation changed behavior or flow: confirm Documentation/ was updated (e.g. Game-Flow.md, Architecture.md, Data-Structures.md, or DND1-Spec-Web-References.md mapping if port behavior was aligned to the reference spec).
- If not updated and change is behavioral: report as "Documentation update recommended".

5) Output Verification Report (see template below).

────────────────────────────
PROCESS (ValidateAllSpec: true — validate all spec)
────────────────────────────

When ValidateAllSpec is true (e.g. RUN_BUILD_PIPELINE with no Spec/Feature):

1) Load all spec docs
- **`.cursor/build-specs/`** — 00-FULL-SCOPE.md and component specs 01–09 (Character, Shop, Monsters, Dungeon/Tiles, Commands, Move/Tile, Combat, Save/Load, BASIC excerpts); see build-specs/README.md
- Documentation/DND1-Spec-Web-References.md (reference spec: character, classes, monsters, tiles, shop; mapping to port)
- Documentation/Game-Flow.md (intro, loop, commands, move/tile handling)
- Documentation/Data-Structures.md (Character, Dungeon, tile codes, Items, Spells, Monsters)
- Documentation/Architecture.md (boot, memory, modules)
- Documentation/Testing.md (strategy, unit vs Playwright)

2) Derive Acceptance Criteria from spec
- From each doc, extract testable Acceptance Criteria (e.g. "AC-001: Character has STR, DEX, CON, CHAR, WIS, INT, Gold"; "AC-002: Classes are Fighter, Cleric, Wizard"; "AC-003: 10 monster types"; "AC-004: Tile codes 0–8 per Data-Structures"; "AC-005: Commands 0–12 dispatch per Game-Flow"; "AC-006: 25×25 dungeon"; "AC-007: Boot: Stage1 loads Stage2 at 0x8000").
- Write or update **Documentation/Acceptance-Criteria.md**: table or list with AC-ID, statement, source doc, test (file/name or "none"). Create the file if it does not exist.

3) For each AC, ensure a test exists; create if missing
- Check Test/Game/, Test/Libraries/, and playwright/tests/ for coverage of each AC. If an AC has no corresponding test:
  - **Game/logic** → add assembly unit test: new file under Test/Game/ (or Test/Libraries/), routine called from RunTests in Test/Tests.asm, %include from Stage2.asm under DEBUG after dependencies, add section to playwright/support/emulator.js SECTION_MARKERS, add test case in playwright/tests/assembly/suite.spec.js (see existing GameDiceTests, GamePlayerTests, etc.).
  - **Boot/flow** → extend Playwright game smoke only when minimal.
- Record: AC count, tests created (files added/updated) or "no new tests needed".

4) Compare codebase to each spec (alignment check)
- For each doc: note alignment or gaps (e.g. "10 monster types" → Monsters.asm; "tile 0–8" → Move.asm, Data-Structures). Report only; code changes were limited to adding tests.

5) Run tests
- Execute `npm test`. Record: pass / fail / skipped.

6) Output Spec Validation Report

Report must contain:

## Spec Validation Report (Validate-all-spec)

## Acceptance Criteria
- Documentation/Acceptance-Criteria.md: <created | updated> — <N> AC listed
- Tests created for missing coverage: <list of files added/updated> or "none"

## Specs checked
- .cursor/build-specs/ (00-FULL-SCOPE, 01–09):
- DND1-Spec-Web-References.md:
- Game-Flow.md:
- Data-Structures.md:
- Architecture.md:
- Testing.md:

(For each: Aligns / Gaps: <short list or "none">)

## Test Results
- Command run: npm test
- Result: pass / fail / skipped

## Summary
- All spec validated: yes / no
- Gaps or recommendations: <list or "none">

────────────────────────────
VERIFICATION REPORT TEMPLATE (normal)
────────────────────────────

## Verification Report

## Scope
<Scope text>

## Files Changed
<Paths>

## Acceptance Criteria
- Acceptance-Criteria.md: <created | updated | unchanged>
- AC derived for scope: <count or list>
- Tests created for missing AC: <files> or "none"

## Test Results
- Command run:
- Result: pass / fail / skipped
- Notes (if any):

## Documentation
- Updated: yes / no / N/A
- Recommendation (if no): e.g. "Update Game-Flow.md for new move behavior"

## Summary
- Implementation verified: yes / no
- Blockers (if any):
