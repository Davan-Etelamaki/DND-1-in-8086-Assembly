# DNG1–DNG6 dungeon files

Dungeon data files matching the **original DND #1** (1977) dungeon file names. The BASIC source used `FILE #1="DNG1"` through `FILE #6="DNG6"` and read a grid (e.g. 26×26 in BASIC) from each file.

## Status of original files

**No dumps of the 1977 PDP-11 DNG files have been found online.** References (e.g. [Ultima Codex](https://gallery.ultimacodex.com/richard-garriotts-handwritten-dnd1-notes/), [Polygon](https://www.polygon.com/2014/4/16/5620132/richard-garriott-wants-you-to-port-this-proto-rpg-teletype-game)) describe the format (tile codes 0–4 in handwritten notes: empty, roll, trap, secret door, door) but not the actual file contents. The Shroud of the Avatar [DND1 source](https://www.shroudoftheavatar.com/dnd1.php) and [GitHub Gist 11137495](https://gist.github.com/bussiere/11137495) provide the BASIC code that *reads* these files, not the files themselves.

The **DNG1.txt–DNG6.txt** files in this folder are therefore **derived from this port**: they are the first six dungeons (Dungeon1–Dungeon6) from `SourceFiles/Data/Constants/Dungeons.asm`, exported to a human‑editable text format. If original DNG files surface later, they can be added (e.g. as `DNG1-original.bin`) and compared or used to replace these.

## File format

- **DNG1.txt … DNG6.txt** — One file per dungeon. Each file has **25 lines** of **25 comma-separated values** (no spaces). Row order: row 0 (top) to row 24 (bottom). Values are tile codes **0–8** (see below).
- **Binary equivalent:** 625 bytes per dungeon, row-major (row 0, then row 1, …), one byte per cell. The game’s `read_dungeon` copies 625 bytes into `CurrentDungeon`; the port uses an embedded `Dungeons` array in `Dungeons.asm`, not runtime file I/O.

## Tile codes (this port)

| Value | Meaning        |
|-------|----------------|
| 0     | Empty (passable) |
| 1     | Wall           |
| 2     | Trap           |
| 3     | Secret door    |
| 4     | (Door)        |
| 5     | Monster        |
| 6     | Gold           |
| 7     | Strength bonus |
| 8     | Constitution bonus |

Original handwritten notes used 0–4 (empty, roll, trap, secret door, door); the port extends this with 5–8.

## Regenerating from .txt

To update `SourceFiles/Data/Constants/Dungeons.asm` from edited DNG*.txt files (e.g. after designing new maps), run:

```bash
node scripts/dng-to-asm.js
```

This reads `Dungeons/DNG1.txt`–`DNG6.txt` and overwrites the Dungeon1–Dungeon6 blocks in `Dungeons.asm` (Dungeon7–Dungeon10 are left unchanged). See `scripts/dng-to-asm.js` for the exact format expected.

## Extracting from Dungeons.asm

To (re)export Dungeon1–Dungeon6 from the current `Dungeons.asm` into DNG1.txt–DNG6.txt:

```bash
node scripts/extract-dng.js
```

This parses the `db` lines for each Dungeon1…Dungeon6 and writes the corresponding `Dungeons/DNGn.txt` files.
