# Component spec: Move and tile handling

Move command, direction input, check_tile branches, advance_position, trap, doors, monster, gold, strength, constitution. Traceable to Game-Flow.md and Move.asm.

---

## 1. Move command (port)

**move:** Show current (x, y), prompt for direction (R/L/U/D or RIGHT/LEFT/UP/DOWN). Compute new (x, y), call **check_tile** with new coordinates.

---

## 2. check_tile behavior (port)

Get tile at (x, y) from CurrentDungeon (get_tile_number). Branch by tile value:

| Tile | Action |
|------|--------|
| 0 (empty) | advance_position (update Character.x/y, "Done", then pass) |
| 1 (wall) | hit_wall (message, chance 1 HP damage, pass) |
| 2 (trap) | fall_in_trap (damage chance, spikes/rope checks, possible death). Uses check_inventory, remove_from_inventory for spikes 12, rope 11. |
| 3 (secret door) | find_secret_door (roll to find or hit_wall) |
| 5 (monster) | run_into_monster (message, chance lose 6 HP, pass) |
| 6 (gold) | find_gold (random gold, then hit_wall) |
| 7 (strength) | increase_strength then clear_tile (move onto tile) |
| 8 (constitution) | increase_con then clear_tile |
| other | hit_wall |

---

## 3. clear_tile (port)

Set tile to 0. 20% chance "poison" (lose roll_d4 HP). Then advance_position.

---

## 4. advance_position (port)

Update Character.x, Character.y to the new cell. Print "Done". Call pass.

---

## 5. Contract

**get_tile_number:** Callers must ensure 0 ≤ x, y ≤ 24. No in-code bounds check (Issues-and-Risks.md issue 17).

---

## 6. Acceptance

- AC-008: check_tile handles 0,1,2,3,5,6,7,8 per Game-Flow.
- Tests: Move behavior in game; trap/inventory in Issues-and-Risks (9, 10).
