# DND #1 — Full scope and references

Full-scope documentation for the DND-1 8086 Assembly port. Sourced from Richard Garriott's DND #1 (1977), the original BASIC source, and in-repo Documentation. Component specs live in this directory; see [README](README.md).

---

## 1. Sources and references

| Source | Description | Use |
|--------|-------------|-----|
| **Original BASIC** | DND1, ~1500 lines, (C) 1977–2014 Richard Garriott. OS/8 BASIC (PDP-8). | Authoritative behavior: data layout, command numbers, formulas. Excerpts in [09-BASIC-Source-Excerpts.md](09-BASIC-Source-Excerpts.md). |
| **GitHub Gist** | [bussiere/11137495](https://gist.github.com/bussiere/11137495) — “The code source of DND1 by Richard Garriott”. | Copy of BASIC source. |
| **Shroud of the Avatar** | [DND1 contest](https://www.shroudoftheavatar.com/?p=39149), [dnd1.php](https://www.shroudoftheavatar.com/dnd1.php) (source download). | Official contest and source distribution. |
| **Ultima Codex** | [Handwritten DND #1 design notes](https://gallery.ultimacodex.com/richard-garriotts-handwritten-dnd1-notes/). | Dungeon grid semantics (0–4: empty, roll, trap, secret door, door). |
| **Polygon** | [Richard Garriott wants you to port this proto-RPG](https://www.polygon.com/2014/4/16/5620132/richard-garriott-wants-you-to-port-this-proto-rpg-teletype-game). | Context: 10×10 grid, ASCII (* space $ U D), 20s delay, teletype. |
| **In-repo docs** | Documentation/ (Game-Flow, Data-Structures, Architecture, DND1-Spec-Web-References, etc.). | Current port behavior and mapping. |

---

## 2. High-level scope

**In scope for this port**

- Two-stage boot (Stage1 load Stage2 at 0x8000); no OS.
- Intro: title, instructions (Y/N), old vs new game.
- New game: dungeon #, continues (1 or 2), roll 7 stats (3d6, Gold×15), class (Fighter/Cleric/Wizard), initial HP by class, item shop (15 items, class restrictions), read dungeon, enter game loop.
- Old game: load from save (in-memory template + disk).
- Game loop: save_game, welcome (dungeon #, position), command prompt; commands 0–12 (pass, move, open door, search, switch weapon, fight, look around, save game, use magic, buy magic, cheat, buy HP, quit).
- Dungeon: 25×25 tile grid (this port); tile types 0–8 (empty, wall, trap, secret door, monster, gold, strength, constitution).
- Move: direction input, check_tile, advance_position / trap / secret door / monster / gold / strength / constitution / hit_wall.
- Combat: fight, battle (monster table: 10 types), damage, death, gold.
- Magic: use_magic, buy_magic (cleric/wizard spells).
- Save/load: game_save block to disk, load_game restores state.
- All behavior and data layouts traceable to BASIC and/or Documentation.

**Out of scope (original only or deferred)**

- 10×10 teletype print with ~20s delay; ASCII (*, space, $, U, D) as display.
- External dungeon files (DNG1–DNG6, GMSTR); port uses embedded Dungeons array.
- “NONE” class re-roll and name check (“SHAVS”) as in BASIC; port may simplify.
- Exact PDP-11/OS-8 BASIC semantics (e.g. RND, file I/O); port uses 8086/NASM and BIOS.

---

## 3. Flow summary (port)

1. **Boot** → get_seed, clear_screen, **intro**.
2. **Intro** → instructions (Y/N) → old or new game.
3. **New game** → get_dungeon_num → get_continues → roll_character (7 stats, class, HP) → item_shop → print_characteristics_and_eq → **read_dungeon** → game_loop.
4. **Old game** → load_game → game_loop.
5. **Game loop** → save_game → game_loop_welcome → get_command → loop: get_command_from_user (0–12) → action → repeat. Command 12 (quit) → boot.

---

## 4. Port mapping (original → this repo)

| Aspect | Original (BASIC / references) | This port |
|--------|------------------------------|-----------|
| Map | D(0..25,0..25) in BASIC; 10×10 display in refs | 25×25 CurrentDungeon (625 B); see Data-Structures, Move |
| Character | C(0)=HP, C(1..6)=STR..INT, C(7)=GOLD, C$(0)=class | Character.* (hp, str, dex, con, char, wis, int, gold, class) |
| Initial HP | Fighter 1–8, Wizard 1–4, Cleric 1–6 | Per Roll Character / Player |
| Items | 15 items, I$(M), P(M); indices 1–15 | Items table; indices 1–15 |
| Monsters | 10 types, B$(M), B(M,1..6) | Monsters table (monster struct × 10) |
| Commands | T=0,1,2,3,4,5,6,7,8,9,11,12 (+ 10 cheat) | 0–12 (pass, move, …, cheat, buy_hp, quit) |
| Tiles | 0–4 in notes; BASIC D(M,N) 0,7,8 for empty/str/con | 0–8: empty, wall, trap, secret door, monster, gold, 7, 8 |
| Save | Not fully visible in excerpt | game_save block, disk_save, load_game |

---

## 5. Component spec index

| Spec | Content |
|------|--------|
| [01-Character.md](01-Character.md) | Stats (7 + Gold), 3d6 and Gold×15, classes, initial HP |
| [02-Shop-and-Items.md](02-Shop-and-Items.md) | 15 items, prices, class restrictions (Cleric/Wizard), shop flow |
| [03-Monsters.md](03-Monsters.md) | 10 monster types, table layout, combat use |
| [04-Dungeon-and-Tiles.md](04-Dungeon-and-Tiles.md) | Grid size, tile codes, read_dungeon, random 7/8 |
| [05-Commands-and-Loop.md](05-Commands-and-Loop.md) | Command list 0–12, get_command, game loop |
| [06-Move-and-Tile-Handling.md](06-Move-and-Tile-Handling.md) | move, check_tile, advance_position, trap, doors, monster, gold, strength, constitution |
| [07-Combat.md](07-Combat.md) | fight, battle, monster stats, damage, death |
| [08-Save-Load.md](08-Save-Load.md) | game_save layout, save_game, load_game, old game |
| [09-BASIC-Source-Excerpts.md](09-BASIC-Source-Excerpts.md) | Key BASIC lines for traceability |

---

## 6. Acceptance and verification

- **Acceptance Criteria:** Documentation/Acceptance-Criteria.md (derived from spec; used by verify-implementation).
- **Tests:** Unit tests in Test/ (Game + Libraries), Playwright assembly suite + game smoke. See Documentation/Testing.md (strategy and adding tests).
- **Validation:** RUN_BUILD_PIPELINE with no Spec/Feature runs Validate-all-spec (AC, tests, alignment).
