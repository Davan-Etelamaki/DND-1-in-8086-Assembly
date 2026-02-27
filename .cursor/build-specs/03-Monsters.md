# Component spec: Monsters

Ten monster types, table layout, and use in combat. Traceable to BASIC and Data-Structures.md.

---

## 1. Monster table (10 types)

**BASIC 1150–1270:** DATA for 10 monsters. After READ: B(M,4)=B(M,3), B(M,5)=B(M,6), B(M,1)=1. So columns: name, then (AC/str?), dex, hp, initHP, initGold, gold. B(M,1)=1 (AC), B(M,2)=dex, B(M,3)=hp, B(M,4)=hp, B(M,5)=gold, B(M,6)=gold.

**BASIC DATA (1160–1240):**

| # | Name | Col1 | Dex | HP | InitGold | Gold |
|---|------|------|-----|-----|----------|------|
| 1 | MAN | 1 | 13 | 26 | 1 | 500 |
| 2 | GOBLIN | 2 | 13 | 24 | 1 | 600 |
| 3 | TROLL | 3 | 15 | 35 | 1 | 1000 |
| 4 | SKELETON | 4 | 22 | 12 | 1 | 50 |
| 5 | BALROG | 5 | 18 | 110 | 1 | 5000 |
| 6 | OCHRE JELLY | 6 | 11 | 20 | 1 | 0 |
| 7 | GREY OOZE | 7 | 11 | 13 | 1 | 0 |
| 8 | GNOME | 8 | 13 | 30 | 1 | 100 |
| 9 | KOBOLD | 9 | 15 | 16 | 1 | 500 |
| 10 | MUMMY | 10 | 16 | 30 | 1 | 100 |

**Port (Monsters.asm):** monster structure: .name (16 B), .str, .dex, .hp, .initHP, .initGold, .gold, .int (2 B each). NewMonster 'NAME', str, dex, hp, initGold, gold. Same 10 names and values; .str used in combat (port uses str where BASIC may use AC).

---

## 2. Use in combat

Monsters table is read by combat (Fight.asm, Battle.asm): type index, .str, .dex, .hp, .gold; on death gold to player, .hp reset to .initHP, .gold to .initGold. See [07-Combat.md](07-Combat.md).

---

## 3. Acceptance

- AC-003: 10 monster types (MAN, GOBLIN, TROLL, SKELETON, BALROG, OCHRE JELLY, GREY OOZE, GNOME, KOBOLD, MUMMY).
- Test: Test/Game/Monsters.asm (GameMonstersTests) — 10th monster has non-zero initHP.
