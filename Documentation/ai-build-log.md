# AI build log

Structured audit log for pipeline runs. New entries are prepended; footer is updated each run.

---

## 2025-02-26 — Validate-all-spec (RUN_BUILD_PIPELINE, no Spec/Feature)

**Pipeline**
- Runner: build-and-test-pipeline (Skill)
- VerificationPhase: true (Validate-all-spec)

**Git**
- Branch: master
- Commit (short): d36bc86
- Commit (full): d36bc86ce7c1f77a78530e8f97a830965ed2ba23

**What was built / changed**
- Validate-all-spec run. No code changes. Verification: Acceptance Criteria (Documentation/Acceptance-Criteria.md) and build-specs (.cursor/build-specs/ 00–09) checked; alignment confirmed. Gap list shows 7 covered by unit tests (read_dungeon, get_tile_number, check_inventory(12)/remove, DungeonNumber, CurrentMonster); remaining gaps (trap+spikes, find_secret_door, wait_key, disk_save, new-game name) are integration/manual.

**Files changed**
- Created: (none)
- Modified: (none)

**Tests**
- Unit tests added/updated: (none this run)
- npm test: 13 passed (assembly suite + game smoke)

**Spec Validation Report (summary)**
- .cursor/build-specs/: Aligns — AC derived from 00-FULL-SCOPE and 01–09; AC-001–AC-046 + R-1–R-12 documented.
- Documentation/Acceptance-Criteria.md: 46 AC + 12 regression AC; gap list updated with coverage status.
- Test coverage: GameDiceTests, GamePlayerTests, GameDungeonTests (bounds + get_tile_number), GameInventoryTests (add/check/remove 12), GameMonstersTests, GameLogicTests (read_dungeon 7/8, DungeonNumber byte, CurrentMonster layout); Playwright assembly suite + game smoke.
- Gaps (no unit test): trap+spikes/rope, find_secret_door roll>4, wait_key blocking, disk_save 0x8000, new-game name display — documented as integration or manual.

**Notes / TODO**
- None.

---

## 2025-02-27 — Validate-all-spec (RUN_BUILD_PIPELINE, no Spec/Feature)

**Pipeline**
- Runner: build-and-test-pipeline (Skill)
- VerificationPhase: true (Validate-all-spec)

**Git**
- Branch: master
- Commit (short): d36bc86
- Commit (full): d36bc86ce7c1f77a78530e8f97a830965ed2ba23

**What was built / changed**
- Validate-all-spec run. Acceptance Criteria derived from spec (DND1-Spec-Web-References, Game-Flow, Data-Structures, Architecture, Testing); tests created for AC that had no coverage (GameMonstersTests for AC-003: 10 monster types). No other game/source code changes.

**Files changed**
- Created: Documentation/Acceptance-Criteria.md, Test/Game/Monsters.asm
- Modified: SourceFiles/Stage2.asm, Test/Tests.asm, playwright/support/emulator.js, playwright/tests/assembly/suite.spec.js

**Tests**
- Unit tests added/updated: GameMonstersTests (10 monster types per DND1 spec)
- npm test: 12 passed (assembly suite + game smoke)

**Notes / TODO**
- Spec validation: all 5 spec docs checked; alignment good. Gaps: AC-004, AC-007, AC-008 have no dedicated unit test (tile behavior and command dispatch are integration-level).

---
Last Pipeline Execution: 2025-02-26
Runner: build-and-test-pipeline (Skill)
VerificationPhase: true (Validate-all-spec)
Branch: master
Commit (short): d36bc86
Commit (full): d36bc86ce7c1f77a78530e8f97a830965ed2ba23

---

## 2025-02-26 — Richard Garriott DND #1 spec from web references (RUN_BUILD_PIPELINE)

**Pipeline**
- Runner: build-and-test-pipeline (Skill)
- VerificationPhase: false

**Git**
- Branch: master
- Commit (short): d36bc86
- Commit (full): d36bc86ce7c1f77a78530e8f97a830965ed2ba23

**What was built / changed**
- Added Documentation/DND1-Spec-Web-References.md: spec for Richard Garriott's DND #1 (1977) derived from web references (Ultima Codex, Polygon, Shroud of the Avatar). Covers origin, gameplay, character creation (7 stats, 3d6, Gold×15, Fighter/Cleric/Wizard), shop items, 10 monsters, dungeon tile semantics, and mapping to this 8086 port.

**Files changed**
- Created: Documentation/DND1-Spec-Web-References.md
- Modified: (none)

**Tests**
- Unit/Playwright: npm test — 11 passed (assembly suite + game smoke).

**Notes / TODO**
- Spec is reference-only; no code changes. Optional: align tile semantics or map size with handwritten notes if desired.

