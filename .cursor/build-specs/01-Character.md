# Component spec: Character

Character creation, attributes, classes, and initial HP. Traceable to BASIC and Documentation/Data-Structures.md.

## 1. Attributes (7 + Gold)

- Strength, Dexterity, Constitution, Charisma, Wisdom, Intelligence, Gold.
- BASIC: C(1)..C(6), C(7)=GOLD. Port: Character.str, .dex, .con, .char, .wis, .int, .gold.
- Rolling (BASIC 470-570): For each of 7, roll 3d6 (sum three R=INT(RND(0)*6+1)). If stat 7 then multiply by 15 (Gold).
- Port: Same 3d6 and Gold*15. Roll Character.asm; Dice.asm.

## 2. Class

- BASIC: INPUT C$(0). Options FIGHTER, CLERIC, WIZARD. NONE re-rolls. Port: Character.class (16 B).
- See Roll Character.asm, set_character_class; Common.asm Classes.

## 3. Initial hit points

- Fighter: C(0)=INT(RND(0)*8+1) so 1-8 HP.
- Wizard: 1-4 HP. Cleric: 1-6 HP.
- BASIC 1101-1110: If C(0)=1 then C(0)=2 (min 2 HP).
- Port: Same ranges and minimum per Player.asm / Roll Character.asm.

## 4. Runtime state (port)

Data-Structures.md: Character .name, .class, .hp, .str, .dex, .con, .char, .wis, .int, .gold, .continues, .weapon, .itemCount, .inventory, cleric/wizard spells, .x, .y. Combat: .crit_damage, .damage, .armor, .weapon_range.

## 5. Acceptance

- AC-001: 7 attributes + Gold (3d6, Gold*15). AC-002: Fighter, Cleric, Wizard.
- Tests: Test/Game/Player.asm (HP, gold).
