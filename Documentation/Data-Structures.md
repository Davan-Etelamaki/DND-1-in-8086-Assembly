# Data Structures and Constants

Reference for the main structures, variables, and constant tables used by the game.

## Structures (Structures.asm)

Defined in `SourceFiles/Data/Constants/Structures.asm`:

| Structure | Fields | Use |
|------------|--------|-----|
| **monster** | .name (16 B), .str, .dex, .hp, .initHP, .initGold, .gold, .int (each 2 B) | One monster type in the Monsters table. |
| **spell** | .name (20 B), .cost (2 B) | Wizard and cleric spell tables. |
| **item** | .name (16 B), .price (2 B) | Items table (weapons, armor, etc.). |
| **CharacterAttribute** | .name (8 B) | Attribute names (STR, DEX, …). |

Macros such as `NewMonster`, `NewSpell`, `NewItem`, `NewAttribute` build entries from these layouts.

## Character (Character.asm, .bss)

Runtime character state in `SourceFiles/Data/Variables/Character.asm`:

| Field | Size | Description |
|-------|------|--------------|
| **Statistics** (separate label) | | |
| .crit_damage, .damage, .armor, .weapon_range | 2 B each | Combat/stats. |
| **Character** | | |
| .name, .class | 16 B each | Name and class strings. |
| .hp, .str, .dex, .con, .char, .wis, .int | 2 B each | Hit points and attributes. |
| .gold | 2 B | Gold. |
| .continues | 1 B | Number of continues. |
| .weapon | 1 B | Current weapon index. |
| .itemCount | 1 B | Number of items in inventory. |
| .inventory | 100 B | Item indices. |
| .clericSpellCount, .clericSpells | 1 B + 100 B | Cleric spells. |
| .wizardSpellCount, .wizardSpells | 1 B + 100 B | Wizard spells. |
| .x, .y | 1 B each | Dungeon position. |

## Dungeon state (Dungeon.asm, .bss)

| Symbol | Size | Description |
|--------|------|--------------|
| DungeonNumber | 1 B | Selected dungeon index (1-based in prompts). |
| Difficulty | 1 B | Difficulty level. |
| **CurrentMonster** | | Active monster in combat. |
| .status, .type, .x, .y | 1 B each | |
| .distance_x, .distance_y | 1 B each | |
| .range | 2 B | Intended; runtime layout in Dungeon.asm should use `resw 1` to match save format and combat code (see [Issues-and-Risks](Issues-and-Risks.md) issue 5). |
| .hit | 1 B | |
| CurrentDungeon | 625 B | 25×25 tile map (one byte per cell). |

## Tile codes (CurrentDungeon byte values)

Used by Move/check_tile and read_dungeon:

| Value | Meaning |
|-------|---------|
| 0 | Empty (passable). |
| 1 | Wall. |
| 2 | Trap. |
| 3 | Secret door. |
| 5 | Monster. |
| 6 | Gold. |
| 7 | Strength bonus. |
| 8 | Constitution bonus. |

## Constants

### Attributes (Attributes.asm)

**CharacterAttributeNames**: STR, DEX, CON, CHAR, WIS, INT, GOLD (each 8 B via NewAttribute).

### Items (Items.asm)

**Items** table: SWORD (10), 2-H-SWORD (15), DAGGER (3), MACE (5), SPEAR (2), BOW (25), ARROWS (2), LEATHER MAIL (15), CHAIN MAIL (30), TLTE MAIL (50), ROPE (1), SPIKES (1), FLASK OF OIL (2), SILVER CROSS (25), SPARE FOOD (5). Indices 1–15; 0 is unused. Price in gold.

### Spells (Spells.asm)

- **WizardSpells**: empty, PUSH (75), KIHL (500), FIND TRAPS (200), TELEPORT (750), CHANGE 1+0 (600), M. M. #1–3 (100/200/300), FIND S.DOORS (200), CHANGE 0+1 (600).
- **ClericSpells**: empty, KILL (500), MAG. MISS #2 (200), CURE LIGHT #1 (200), FIND ALL TRAPS (200), MAG. MISS. #1/#3 (100/300), CURE LIGHT #2 (1000), FIND ALL S.DOORS (200).

Costs in gold when buying.

### Dungeons (Dungeons.asm)

**Dungeons**: Array of dungeon maps. Each dungeon is **625 bytes** (25×25), stored row by row. Index by `DungeonNumber` (0-based for addressing: `Dungeons + DungeonNumber*625`). `read_dungeon` copies the selected dungeon into **CurrentDungeon** and may add random 7/8 tiles on empty cells.

### LookupTables.asm

**rows**: 25 words — row offset for 2D indexing. `rows[y]` = y*25, so tile index = `y*25 + x` (or use `get_tile_number` in Dungeon.asm). **Contract:** Callers of `get_tile_number` must pass 0 ≤ x, y ≤ 24; there is no in-code bounds check (see [Issues-and-Risks](Issues-and-Risks.md) issue 17).

## Monsters (Monsters.asm, .data)

**Monsters**: Table of monster types (MAN, GOBLIN, TROLL, SKELETON, BALROG, OCHRE JELLY, GREY OOZE, GNOME, KOBOLD, MUMMY) with str, dex, hp, initHP, initGold, gold, int. Used for combat and gold; can be overwritten by load/save.

## Save format (GameSave.asm)

**game_save** is the in-memory save buffer written to disk by `save_game` and the template for “old game” in `load_game`. Layout:

- **SaveCharacter** — Same logical layout as **Character**, with the name stored as **length-prefixed** (e.g. `dw 6, "SHAVS", 0` then padding to 16 bytes). Display code (WriteLine) expects this format. Both the new-game path (Roll Character.asm sets the length word via `string_length` before StringCopy) and the load_game path (mem_copy of SaveCharacter) now provide a length-prefixed name, so the name displays correctly in both cases. See the **Audit: Name consumers** section in [Issues-and-Risks.md](Issues-and-Risks.md); issue 12 is fixed.
- **SaveCharacterLength** — Used as the size for copying Character ↔ SaveCharacter.
- **SaveCurrentMonster**, **SaveCurrentMonsterLength** — Current monster state.
- **SaveDungeonNumber**, **SaveDifficulty** — Single bytes.
- **SaveMonsters**, **SaveMonstersLength** — Full monster table.
- **SaveCurrentDungeon** — 625 bytes (25×25).

`save_game` copies Character, CurrentMonster, DungeonNumber, Difficulty, Monsters, CurrentDungeon into this block, then calls `disk_save` with `game_save`, sector count, and boot drive. `load_game` copies from the save block back into the live variables.
