# Component spec: Combat

Fight command, battle logic, monster stats, damage, death, gold. Traceable to Battle.asm, Fight.asm, Monsters.

---

## 1. Fight command (port)

**fight (Fight.asm):** Initiates or continues combat with current monster. Direction, range, attack. Uses CurrentMonster (type, position, range, etc.) and Monsters table (monster.str, .dex, .hp, .gold).

---

## 2. Battle logic (port Battle.asm)

- **monster_battle:** If monster HP ≤ 0 → monster_killed (give gold to player, reset monster .hp to .initHP, .gold to .initGold). Else monster_attack.
- **monster_attack:** Resolve hit/miss (dex, etc.); monster_hit / monster_hit_no_damage / monster_miss. Damage from monster.str.
- **monster_killed:** Add monster.gold to Character.gold; clear gold; reset HP and gold from init values.
- **monster_trapped:** Monster in trap: gold=0, etc.
- **monster_moves:** Monster movement on tile (get_tile_number, trap check).
- **reset_monsters:** Restore all 10 monster entries to initHP, initGold.

---

## 3. Monster stats in combat

From Monsters table: .str (damage), .dex (hit/evade), .hp (current), .initHP (reset), .gold (treasure), .initGold (reset). .int used for magic resistance or similar in port.

---

## 4. Player death

Player HP ≤ 0 → death handling (per Player.asm); continues (Character.continues) for extra life if applicable.

---

## 5. Acceptance

- Combat uses 10 monster types; damage and gold per Battle.asm.
- Tests: Combat exercised in game; monster table verified by GameMonstersTests.
