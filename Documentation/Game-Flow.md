# Game Flow

High-level flow of the game from intro through the main command loop.

## Overview

1. **Boot** → clear screen → **intro**
2. **Intro** → instructions (Y/N) → new or old game
3. **New game**: get dungeon number → get continues → roll character → item shop → print character and equipment → **read_dungeon**
4. **Old game**: **load_game** (restore from in-memory save template)
5. **Game loop**: save_game → welcome (dungeon # and position) → **get_command** → then repeatedly **get_command_from_user** (read command 0–12 and run the corresponding action). Command 12 = quit → jump back to boot (restart).

## Intro phase (Intro.asm)

- **intro**: Prints title (3 lines), then **instructions**, then **new_or_old**.
- **instructions**: Asks “need instructions?”; Y/YES → print “Who said” and wait for key; N/NO → continue.
- **new_or_old**: Asks new vs old. **OLD** → `load_game` and return. Otherwise → **get_dungeon_num** → **get_continues** → **roll_character** → **item_shop** → **print_characteristics_and_eq** → **read_dungeon** and return.
- **get_dungeon_num**: Prompts for dungeon number; loops until non-zero; stores in `DungeonNumber`.
- **get_continues**: Prompts for 1 or 2; stores in `Character.continues`.

## Game loop (Game Loop.asm)

- **game_loop**: Calls **save_game**, then **game_loop_welcome**, then **get_command**, then an infinite loop that only calls **get_command_from_user**.
- **game_loop_welcome**: Prints “welcome” + dungeon number, then position (Character.x, Character.y), then newline.
- **quit**: Jumps to `boot` (restart from Stage2).

## Commands (Get Command.asm)

**get_command**: Prints the short command list; if the user types the equivalent of “yes”, prints a longer list (CommandStrings indices 0–4).

**get_command_from_user**: Reads a line, parses it as an integer with **parse_int**, then dispatches by value:

| Cmd | Action | Source file |
|-----|--------|-------------|
| 0 | **pass** | Pass.asm |
| 1 | **move** | Move.asm |
| 2 | **open_door** | Open Door.asm |
| 3 | **search** | Search.asm |
| 4 | **switch_weapon** | SwitchWeapon.asm |
| 5 | **fight** | Fight.asm |
| 6 | **look_around** | Look Around.asm |
| 7 | **save_game** | Load Game.asm |
| 8 | **use_magic** | Use Magic.asm |
| 9 | **buy_magic** | Buy Magic.asm |
| 10 | **cheat** | Cheat.asm |
| 11 | **buy_hp** | Buy HP.asm |
| 12 | **quit** | Game Loop.asm |

Any other number prints “invalid” (CommandStrings index 6), calls **wait_key**, and prompts again.

## Move and tile handling (Move.asm)

**move**: Shows current (x, y), prompts for direction (R/L/U/D or RIGHT/LEFT/UP/DOWN), then calls **check_tile** with the new (x, y).

**check_tile**: Gets tile at (x, y) from CurrentDungeon and branches:

- **0** (empty) → **advance_position** (update Character.x/y, “Done”, then **pass**).
- **2** (trap) → **fall_in_trap** (damage chance, spikes/rope checks, possible death). Trap handling relies on **check_inventory** and **remove_from_inventory** for spikes (item 12) and rope (item 11); fixes to those routines correct this behavior (see [Issues-and-Risks](Issues-and-Risks.md)).
- **3** (secret door) → **find_secret_door** (roll to find or hit_wall).
- **5** (monster) → **run_into_monster** (message, chance to lose 6 HP, then **pass**).
- **6** (gold) → **find_gold** (random gold, then **hit_wall**).
- **7** (strength) → **increase_strength** then **clear_tile** (move onto tile).
- **8** (constitution) → **increase_con** then **clear_tile**.
- **1** or other → **hit_wall** (message, chance to lose 1 HP, then **pass**).

**clear_tile**: Sets tile to 0, 20% chance “poison” (lose roll_d4 HP), then **advance_position**.

## Fight and battle

- **fight** (Fight.asm): Initiates or continues combat with the current monster (direction, range, attack).
- **Battle.asm**: Shared battle logic (e.g. damage, monster turn, death).

## Other actions (brief)

- **pass**: Advance time/turn (e.g. monster movement or similar).
- **open_door**: Attempt to open a door in a direction.
- **search**: Search for traps/secret doors.
- **switch_weapon**: Choose weapon from inventory.
- **look_around**: Describe current room/area.
- **save_game**: Copy live state into the save block and call **disk_save**.
- **use_magic**: Choose and cast a cleric or wizard spell.
- **buy_magic**: Purchase spells (gold).
- **cheat**: Debug/cheat action.
- **buy_hp**: Pay gold to restore HP.

After each action (except quit), control returns to the main loop and **get_command_from_user** is called again.
