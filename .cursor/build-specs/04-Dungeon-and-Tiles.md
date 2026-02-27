# Component spec: Dungeon and tiles

Grid dimensions, tile codes, and read_dungeon behavior. Traceable to BASIC and handwritten notes (Ultima Codex).

---

## 1. Grid size

**BASIC:** DIM D(50,50); loop FOR M=0 TO 25, N=0 TO 25 → 26×26 grid (indices 0–25). Player start G=INT(RND(0)*24+2), H=INT(RND(0)*24+2) → 2–25.

**References:** Handwritten notes describe dungeon as grid of numbers (0–4). Polygon: 10×10 *display* around player.

**Port:** CurrentDungeon 625 B = 25×25 (indices 0–24). get_tile_number contract: 0 ≤ x, y ≤ 24. See Data-Structures.md, Dungeon.asm, LookupTables.asm (rows).

---

## 2. Tile codes

**Handwritten notes (Ultima Codex):** 0=navigable, 1=roll (random/encounter), 2=trap, 3=secret door, 4=regular door.

**BASIC 1431–1448:** D(M,N)=0 or READ from file. If D(M,N)=0 then: RND(0)<.97 else D(M,N)=7; RND(0)<.97 else D(M,N)=8. So 7=strength, 8=constitution on empty cells (~3% each).

**Port (Data-Structures, Move.asm):**

| Value | Meaning |
|-------|---------|
| 0 | Empty (passable) |
| 1 | Wall |
| 2 | Trap |
| 3 | Secret door |
| 4 | (Door — open_door) |
| 5 | Monster |
| 6 | Gold |
| 7 | Strength bonus |
| 8 | Constitution bonus |

---

## 3. read_dungeon (BASIC 1410–1460, port Load Game.asm)

- RESTORE #D (dungeon file by number D).
- FOR M=0 TO 25, N=0 TO 25: D(M,N)=0; if D<>0 READ D(M,N). If D(M,N)=0 then with ~3% set 7, ~3% set 8.
- Port: copy from Dungeons array (DungeonNumber*625) into CurrentDungeon; same random 7/8 on empty (see Issues-and-Risks.md read_dungeon fix).

---

## 4. Dungeons array (port)

Dungeons.asm: array of dungeon maps; each 625 B (25×25), row-major. read_dungeon copies one dungeon into CurrentDungeon.

---

## 5. Acceptance

- AC-004: Tile codes 0–8 per Data-Structures.
- AC-006: Dungeon 25×25 (625 B); get_tile_number 0 ≤ x,y ≤ 24.
- Tests: Dungeon.asm (get_y_bounds, get_x_bounds); Move/check_tile behavior in game.
