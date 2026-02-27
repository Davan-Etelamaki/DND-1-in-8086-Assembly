# Component spec: Save and load

Save block layout, save_game, load_game, old game. Traceable to Data-Structures.md (GameSave.asm) and Load Game.asm.

---

## 1. Save block (game_save, port)

**Layout (GameSave.asm):**

- **SaveCharacter** — Same logical layout as Character; name length-prefixed (dw length, string, padding to 16 B). SaveCharacterLength for copy size.
- **SaveCurrentMonster**, SaveCurrentMonsterLength — Current monster state.
- **SaveDungeonNumber**, SaveDifficulty — 1 B each.
- **SaveMonsters**, SaveMonstersLength — Full Monsters table.
- **SaveCurrentDungeon** — 625 B (25×25).

---

## 2. save_game (port)

Copy Character → SaveCharacter, CurrentMonster → SaveCurrentMonster, DungeonNumber, Difficulty, Monsters → SaveMonsters, CurrentDungeon → SaveCurrentDungeon. Call **disk_save** with game_save, sector count, boot drive. Load Game.asm; DiskIO.asm (base 0x8000 for sector calculation).

---

## 3. load_game (port)

Restore from game_save (in-memory template or from disk). Copy SaveCharacter → Character, SaveCurrentMonster → CurrentMonster, SaveDungeonNumber, SaveDifficulty, SaveMonsters → Monsters, SaveCurrentDungeon → CurrentDungeon. Used for "old game" path.

---

## 4. Old game (BASIC 400, 1770)

IF Q$="OLD" THEN 01770 → load saved state and go to game start (welcome, command loop).

**Port:** new_or_old → OLD → load_game, then return into flow that leads to game_loop.

---

## 5. Acceptance

- Save/load preserves character, dungeon, monsters, current dungeon map.
- Name display: length-prefixed name in SaveCharacter; fixed per Issues-and-Risks issue 12.
- Tests: Save/load exercised in game; disk_save base 0x8000 per Issues-and-Risks fix.
