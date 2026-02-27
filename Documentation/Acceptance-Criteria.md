# Acceptance Criteria

**Source of truth:** `.cursor/build-specs/` (00-FULL-SCOPE.md and component specs 01–09). This document derives testable acceptance criteria from those specs. Used for test coverage, validation, and **systematic issue finding**. Updated by verify-implementation (Validate-all-spec or normal verification).

---

## How to use this to find issues

1. **For each AC row:** Confirm the **Coverage** — if "None" or "Integration only", run the scenario manually or add a test; fix any mismatch with the **Statement**.
2. **Risk / issue column:** Where an issue number appears (e.g. I-9), read [Issues-and-Risks.md](Issues-and-Risks.md) for that issue; ensure it is fixed and that regression is covered (test or manual check).
3. **Thoroughness section (below):** Use the "Areas to audit" and "Gap list" to target missing tests and edge cases; add tests or document limitations.
4. **After any fix:** Add or update the corresponding AC or regression AC; run tests; update Issues-and-Risks if the fix resolves an issue.

---

## Criteria by build-spec

| ID | Statement | Build-spec | Risk / issue | Coverage |
|----|-----------|------------|--------------|----------|
| **00-FULL-SCOPE / flow** |
| AC-001 | Stage1: ORG 0x7C00, 512 B; loads sectors 2+ to 0x8000; jumps to Stage2 | 00-FULL-SCOPE §2, §4 | — | Boot smoke |
| AC-002 | Stage2: ORG 0x8000; DEBUG build runs RunTests instead of game | 00-FULL-SCOPE §2 | I-16 (Test sync) | Test image |
| AC-003 | Intro: instructions Y/N → old or new game; new → dungeon #, continues, roll, shop, read_dungeon, game_loop; old → load_game, game_loop; command 12 → quit → boot | 00-FULL-SCOPE §3 | — | Playwright smoke |
| **01-Character** |
| AC-004 | 7 attributes (STR, DEX, CON, CHAR, WIS, INT) + Gold; each stat = 3d6 (3–18); if stat is 7 then Gold = stat×15 (105) | 01-Character §1 | — | Player.asm (gold); Roll implicit |
| AC-005 | Classes: Fighter, Cleric, Wizard only | 01-Character §2 | — | Roll Character, Shop |
| AC-006 | Initial HP: Fighter 1–8, Wizard 1–4, Cleric 1–6; minimum 2 HP (C(0)=1 → 2) | 01-Character §3 | — | Player.asm |
| AC-007 | Character.continues stored as single byte (1 or 2); does not overwrite .weapon | 01-Character; Intro | **I-4** (fixed) | None — regression |
| **02-Shop-and-Items** |
| AC-008 | Items table: 15 entries, indices 1–15; names and prices per 02-Shop §1 (SWORD 10 … SPARE FOOD 5) | 02-Shop §1 | — | Shop; Inventory.asm |
| AC-009 | Shop: input 1–15; deduct P(Y) from Gold; reject if C(7)-P(Y)<0 | 02-Shop §2 | — | Shop.asm |
| AC-010 | Cleric cannot buy: MACE (4), LEATHER MAIL (8), CHAIN MAIL (9), TLTE MAIL (10), or Y>10 | 02-Shop §3 | — | Shop.asm |
| AC-011 | Wizard cannot buy: DAGGER (3), LEATHER MAIL (8), or Y>10 | 02-Shop §3 | — | Shop.asm |
| AC-012 | check_inventory(item) returns slot index for **item** (e.g. 12 = spikes), not item−1 | 02-Shop; 06-Move (trap) | **I-9** (fixed) | Inventory.asm (add/check 7 only) — **needs spike/rope check** |
| AC-013 | remove_from_inventory(slot) clears **that slot** (index as-is), does not write to slot+1 | 02-Shop; 06-Move (trap) | **I-10** (fixed) | None — **regression needed** |
| **03-Monsters** |
| AC-014 | 10 monster types: MAN, GOBLIN, TROLL, SKELETON, BALROG, OCHRE JELLY, GREY OOZE, GNOME, KOBOLD, MUMMY; .name, .str, .dex, .hp, .initHP, .initGold, .gold | 03-Monsters §1 | — | GameMonstersTests |
| AC-015 | Monster 10 (MUMMY) has non-zero .initHP / .gold for table completeness | 03-Monsters §1 | — | GameMonstersTests |
| **04-Dungeon-and-Tiles** |
| AC-016 | CurrentDungeon 625 B; indices 0–24 for x,y; get_tile_number(y*25+x) with 0≤x,y≤24 | 04-Dungeon §1 | **I-17** (contract) | GameDungeonTests (bounds only) |
| AC-017 | get_tile_number: callers ensure 0≤x,y≤24; no in-code bounds check | 04-Dungeon §1; 06-Move §5 | I-17 | Documented; no test |
| AC-018 | Tile codes 0–8: 0=empty, 1=wall, 2=trap, 3=secret door, 4=door, 5=monster, 6=gold, 7=strength, 8=constitution | 04-Dungeon §2 | — | Move.asm; game |
| AC-019 | read_dungeon: copy from Dungeons + DungeonNumber*625 into CurrentDungeon; for each cell if value 0, ~3% set 7, ~3% set 8 at **that index** | 04-Dungeon §3, §4 | **I-1** (fixed) | None — **regression needed** |
| AC-020 | DungeonNumber stored as single byte; does not overwrite Difficulty | Intro; 04-Dungeon | **I-7** (fixed) | None — regression |
| AC-021 | game_loop_welcome loads DungeonNumber as byte (zero-extend); print_dec shows dungeon # only | 05-Commands §2; Game Loop | **I-8** (fixed) | None — regression |
| **05-Commands-and-Loop** |
| AC-022 | Commands 0–12 map to: 0=pass, 1=move, 2=open door, 3=search, 4=switch weapon, 5=fight, 6=look, 7=save, 8=use magic, 9=buy magic, 10=cheat, 11=buy HP, 12=quit; invalid → re-prompt | 05-Commands §1 | — | Get Command.asm; integration |
| AC-023 | Game loop: save_game, game_loop_welcome, get_command (short list; "yes" → long list), loop; command 12 → boot | 05-Commands §2 | — | Game Loop.asm |
| **06-Move-and-Tile-Handling** |
| AC-024 | check_tile(0): advance_position, "Done", pass | 06-Move §2 | — | Game |
| AC-025 | check_tile(1): hit_wall (message, chance 1 HP damage) | 06-Move §2 | — | Game |
| AC-026 | check_tile(2): fall_in_trap; uses check_inventory(12)=spikes, remove_from_inventory for spikes; rope 11; damage chance, possible death | 06-Move §2 | I-9, I-10 | Game — **trap+inventory regression** |
| AC-027 | check_tile(3): find_secret_door — roll_d6>4 finds door (advance_position), else hit_wall | 06-Move §2 | **I-13** (fixed) | None — regression |
| AC-028 | check_tile(5): run_into_monster (message, chance lose 6 HP), pass | 06-Move §2 | — | Game |
| AC-029 | check_tile(6): find_gold (random gold), then hit_wall | 06-Move §2 | — | Game |
| AC-030 | check_tile(7): increase_strength, clear_tile, then advance_position | 06-Move §2 | — | Game |
| AC-031 | check_tile(8): increase_con, clear_tile, then advance_position | 06-Move §2 | — | Game |
| AC-032 | clear_tile: set tile to 0; 20% poison (roll_d4 HP loss); then advance_position | 06-Move §3 | — | Game |
| AC-033 | move: prompt direction (R/L/U/D); compute new (x,y); call check_tile with new coords; callers keep 0≤x,y≤24 | 06-Move §1, §5 | I-17 | Game |
| **07-Combat** |
| AC-034 | CurrentMonster.range is word; does not overwrite .hit; save/load uses same layout (SaveCurrentMonster.range dw) | 07-Combat; Dungeon.asm; GameSave | **I-5** (fixed) | None — regression |
| AC-035 | CurrentMonster.type stored as byte; does not overwrite .x | Battle.asm | **I-6** (fixed) | None — regression |
| AC-036 | monster_killed: add monster.gold to Character.gold; reset .hp to .initHP, .gold to .initGold | 07-Combat §2 | — | GameMonstersTests; game |
| AC-037 | monster_attack: hit/miss from .dex; damage from .str | 07-Combat §2 | — | Game |
| AC-038 | Player HP≤0 → death; continues (Character.continues) for extra life | 07-Combat §4 | — | Player.asm; game |
| **08-Save-Load** |
| AC-039 | game_save: SaveCharacter (length-prefixed name), SaveCurrentMonster, SaveDungeonNumber, SaveDifficulty, SaveMonsters, SaveCurrentDungeon (625 B) | 08-Save §1 | — | GameSave.asm |
| AC-040 | save_game: copy Character→SaveCharacter, CurrentMonster→SaveCurrentMonster, DungeonNumber, Difficulty, Monsters→SaveMonsters, CurrentDungeon→SaveCurrentDungeon; disk_save base **0x8000** | 08-Save §2 | **I-3** (fixed) | None — regression |
| AC-041 | load_game: restore from game_save (disk or template); old game path → game_loop | 08-Save §3, §4 | — | Game |
| AC-042 | New-game name: length word set before StringCopy so WriteLine displays name correctly | 08-Save; GameSave | **I-12** (fixed) | Game (manual new game + load) |
| **I/O and helpers** |
| AC-043 | wait_key: blocking read (AH=0x00 int 0x16); does not return until key pressed | KeyboardIO; 00-FULL-SCOPE | **I-2** (fixed) | None — regression (intro/prompts) |
| **Testing / Architecture** |
| AC-044 | roll_d6 returns value in 1–6 | 01-Character (3d6); Dice.asm | — | GameDiceTests |
| AC-045 | Player: add_hp, lose_hp, add_gold, remove_gold; no overflow/underflow of gold or HP outside spec | 01-Character; Player.asm | — | GamePlayerTests |
| AC-046 | Unit tests run in Playwright; section markers; no Fail; Test/Libraries kept in sync with SourceFiles for duplicated code | Testing; Architecture | I-16 | playwright/tests/assembly/suite.spec.js |

---

## Regression AC (fixed issues)

These criteria guard against reverting fixes. Prefer adding automated tests; otherwise verify manually when touching the area.

| ID | Fixed issue | Required behavior | Test / check |
|----|-------------|-------------------|--------------|
| R-1 | I-1 read_dungeon | Loop over 0..624; only where cell=0 apply roll_d100≥97 for 7 or 8 at **that index**; never write at wrong index | Unit test with fixed RandSeed (planned GameLogicTests) |
| R-2 | I-2 wait_key | AH=0x00 before int 0x16 (blocking) | Manual: intro "press key" actually waits |
| R-3 | I-3 disk_save | Base 0x8000 for sector calculation in DiskIO.asm | Save then load; state correct |
| R-4 | I-4 get_continues | Store BL only into Character.continues | Unit or manual: continues=1/2, weapon unchanged |
| R-5 | I-5 CurrentMonster.range | .range resw 1; store word; SaveCurrentMonster.range dw | Combat + save/load |
| R-6 | I-6 CurrentMonster.type | Store BL only for .type | Combat type correct after encounter |
| R-7 | I-7 DungeonNumber | Store BL only | Welcome shows correct dungeon # |
| R-8 | I-8 game_loop_welcome | Load byte, zero-extend for print_dec | Welcome shows dungeon # not (Difficulty<<8|DungeonNumber) |
| R-9 | I-9 check_inventory | No dec al; search for actual item (e.g. 12=spikes) | check_inventory(12) finds spikes |
| R-10 | I-10 remove_from_inventory | No inc al; write to slot index as-is | remove clears correct slot |
| R-11 | I-12 name layout | New game: string_length before StringCopy so length word set | New game name displays |
| R-12 | I-13 find_secret_door | roll_d6>4 → advance_position (find door); ≤4 → hit_wall | Move onto secret door: 5,6 find; 1–4 wall |

---

## Thoroughness: areas to audit and gap list

Use this to find remaining issues and missing tests.

### Areas to audit (per component)

- **Boot / Stage1/2:** Sector count, load address 0x8000, DEBUG vs normal entry. (I-11 comment fixed.)
- **Intro:** get_dungeon_num (byte store I-7), get_continues (byte store I-4), flow to roll or load.
- **Roll Character:** 3d6×7, Gold×15 when 7, class, initial HP ranges and min 2. Name length word (I-12).
- **Shop:** 15 items, prices, Gold deduct, class restrictions (Cleric/Wizard). Inventory add.
- **Inventory:** check_inventory **by item number** (I-9), remove_from_inventory **by slot** (I-10). Trap uses 11=rope, 12=spikes.
- **Load Game:** read_dungeon loop (I-1), copy 625 bytes, random 7/8 only on cell=0 at correct index. load_game restores all blocks.
- **Dungeon:** get_tile_number 0≤x,y≤24 (I-17); no bounds check. Bounds helpers get_y_bounds, get_x_bounds.
- **Game loop:** save_game, game_loop_welcome (DungeonNumber byte load I-8), get_command 0–12.
- **Move:** check_tile for 0,1,2,3,5,6,7,8; trap uses inventory (I-9, I-10); find_secret_door roll>4 (I-13); clear_tile 20% poison.
- **Combat:** CurrentMonster .type byte (I-6), .range word (I-5); monster_killed gold and reset; player death, continues.
- **Save/Load:** game_save layout; disk_save 0x8000 (I-3); SaveCharacter name length-prefixed; load restores state.
- **Keyboard:** wait_key blocking (I-2); get_key where "press any key" is intended.

### Gap list (missing or weak coverage)

| Gap | AC / issue | Status / recommendation |
|-----|------------|-------------------------|
| read_dungeon random 7/8 at correct index | AC-019, R-1, I-1 | **Covered:** Test/Game/LogicTests.asm — fixed RandSeed, read_dungeon, assert 7/8 only where base=0 |
| get_tile_number in range 0–624 for valid inputs | AC-016, AC-017 | **Covered:** Test/Game/Dungeon.asm — (0,0), (12,12), (24,24) and tile read at index |
| check_inventory(12) and remove_from_inventory | AC-012, AC-026, R-9, R-10 | **Covered:** Test/Game/Inventory.asm — add 12 and 4, check 12→slot 1, remove slot 1, check 12→not found |
| Trap: spikes reduce damage / rope used | AC-026 | Integration/game only: enter trap with/without spikes; no dedicated unit test |
| find_secret_door roll>4 finds door | AC-027, R-12 | No unit test (would require Move/check_tile with tile 3 + fixed seed); manual or game |
| DungeonNumber byte store and welcome byte load | AC-020, AC-021, R-7, R-8 | **Covered:** LogicTests.asm — byte store 3, byte load and Difficulty unchanged; welcome print not asserted |
| CurrentMonster .range word, .type byte | AC-034, AC-035, R-5, R-6 | **Covered:** LogicTests.asm — set type=2, x=10, range=500; assert type, x, range unchanged |
| wait_key blocks | AC-043, R-2 | Manual: run game, confirm "press any key" waits |
| disk_save 0x8000 base | AC-040, R-3 | Integration: save then load old game, verify state |
| New-game name display | AC-042, R-11 | Playwright or manual: new game, enter name, confirm name in characteristics |

### Low / documented (no AC change)

- **I-14** parse_int: no input length overflow test; low impact.
- **I-15** disk error: cli/hlt on failure; documented.
- **I-16** Test/Libraries sync: documented; keep in sync.
- **I-17** get_tile_number contract: documented in code; callers must ensure 0≤x,y≤24.

---

## Notes

- When adding or refining AC, derive from the relevant build-spec (01–09) or 00-FULL-SCOPE; set **Build-spec source** to that file.
- **Coverage:** "None" or "Integration only" or "Game" = candidate for new test. "Regression needed" = add test to lock fix.
- After fixing an issue in Issues-and-Risks, add or update the corresponding R-n and AC row; run tests; mark issue Fixed in Issues-and-Risks.
- Last updated for thoroughness and issue-finding; refresh when specs, tests, or issues change.
