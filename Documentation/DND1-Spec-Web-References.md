# Richard Garriott's DND #1 — Spec from Web References

This document summarizes the **historical specification** of Richard Garriott's DND #1 (1977) as derived from public web references. It serves as a reference for this 8086 Assembly port. There is no single official written spec; the following is synthesized from articles, galleries, and contest materials.

**Sources (examples):**
- [Richard Garriott's Handwritten DND #1 Design Notes](https://gallery.ultimacodex.com/richard-garriotts-handwritten-dnd1-notes/) (Ultima Codex)
- [Richard Garriott wants you to port this proto-RPG teletype game](https://www.polygon.com/2014/4/16/5620132/richard-garriott-wants-you-to-port-this-proto-rpg-teletype-game) (Polygon)
- [Richard Garriott's DND #1 Contest](https://www.shroudoftheavatar.com/?p=39149) (Shroud of the Avatar)
- Original BASIC source: [Shroud of the Avatar — DND1](https://www.shroudoftheavatar.com/dnd1.php)

---

## Origin and context

- **Year:** 1977.
- **Platform:** Teletype at Clear Creek High School (Houston, Texas), connected via acoustic modem to an offsite **PDP-11** minicomputer.
- **Language:** BASIC, ~1,500 lines. Code was typed onto paper tape, then read into a terminal connected to the PDP-11.
- **Purpose:** Garriott's father offered to split the cost of an Apple II if Richard could create a working RPG; DND #1 was that game. Garriott later wrote DND #2 through #28; DND #28 was rewritten for the Apple II as **Akalabeth** (precursor to Ultima).

---

## Core gameplay

- **Goal:** Explore a dungeon, find treasure, fight monsters.
- **Presentation:** Text-based; the dungeon was represented with **ASCII characters** as graphics:
  - `*` = walls  
  - space = corridors and rooms  
  - `$` = chest  
  - `U` = up ladder  
  - `D` = down ladder  
- **Map:** A **10×10 grid** around the player was printed. On each move (e.g. E for East), the game took ~**20 seconds** to recalculate and reprint the new map (teletype speed).
- **Input:** Commands such as E (east), and direction words (e.g. RIGHT/LEFT/UP/DOWN). No real-time display; turn-based.

---

## Character creation

- **Statistics:** Seven categories — **Strength, Dexterity, Constitution, Charisma, Wisdom, Intelligence, Gold**.
- **Rolling:** **3d6** for each stat; **Gold** was multiplied by **15**.
- **Classes:** Player chose one of three classes: **Fighter**, **Cleric**, or **Wizard**.

---

## Equipment and shop

Before entering the dungeon, players bought equipment from a **shop**. Items mentioned in references include:

- **Weapons:** Swords, daggers, maces, spears, bows, arrows.
- **Armor:** Leather mail, chain mail, plate mail.
- **Other:** Rope, spikes, oil flasks, silver crosses, spare food.

---

## Monsters

The game had **10 monster types**, each with different armor class, hit points, and treasure values:

- Men  
- Goblins  
- Trolls  
- Skeletons  
- Balrogs  
- Ochre jellies  
- Grey oozes  
- Gnomes  
- Kobolds  
- Mummies  

---

## Dungeon layout (from handwritten notes)

Garriott's handwritten design notes describe dungeon maps as **grids of numbers**, with each number denoting a cell type, for example:

- **0** = navigable (empty)  
- **1** = “roll” (random events/encounters)  
- **2** = traps  
- **3** = secret doors  
- **4** = regular doors  

(Exact mapping may vary; the notes are the primary source for tile semantics.)

---

## Mapping to this 8086 port

This repository is a **port** of DND #1 to 8086 Assembly (NASM, `-f bin`), runnable in a v86 emulator or on period hardware. The following alignments and differences are noted:

| Aspect | Original (1977) | This port |
|--------|------------------|-----------|
| **Map size** | 10×10 printed around player | 25×25 dungeon (see [Data-Structures](Data-Structures.md)); view/display is implementation-defined |
| **Display** | ASCII (*, space, $, U, D) on teletype | See [Architecture](Architecture.md), [Game-Flow](Game-Flow.md); no teletype delay |
| **Character** | 7 stats (3d6), Gold×15, Fighter/Cleric/Wizard | Same attributes and classes (see [Data-Structures](Data-Structures.md) — Character, Attributes, Items) |
| **Shop** | Weapons, armor, rope, spikes, etc. | Items table: swords, dagger, mace, spear, bow, arrows, armor, rope, spikes, oil, silver cross, food (see [Data-Structures](Data-Structures.md)) |
| **Monsters** | 10 types | Same 10: MAN, GOBLIN, TROLL, SKELETON, BALROG, OCHRE JELLY, GREY OOZE, GNOME, KOBOLD, MUMMY (see [Data-Structures](Data-Structures.md), Monsters.asm) |
| **Tiles** | 0–4 in notes (empty, roll, trap, secret door, door) | 0–8 in port: empty, wall, trap, secret door, (door), monster, gold, strength, constitution (see [Data-Structures](Data-Structures.md), [Game-Flow](Game-Flow.md)) |

For full flow, commands, and modules, see [Game-Flow](Game-Flow.md) and [Architecture](Architecture.md).

---

*Document generated for the DND-1-in-8086-Assembly project. Spec content is from public web references; no official Garriott/Origin spec document was used.*
