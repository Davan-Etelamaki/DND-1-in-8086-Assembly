# Component spec: Commands and game loop

Command list, dispatch, and main loop. Traceable to BASIC and Game-Flow.md.

---

## 1. Command list (BASIC 1550–1670)

**BASIC PRINT:** "1=MOVE 2=OPEN DOOR 3=SEARCH FOR TRAPS AND SECRET DOORS", "4=SWITCH WEAPON HN HAND 5=FIGHT", "6=LOOK AROUND 7=SAVE GAME 8=USE MAGIC 9=BUY MAGIC", "0=PASS 11=BUY H.P." Then INPUT T. Dispatch: T=11→10830, T=12→11000 (quit), T=1→2170 (move), T=2→3130, T=3→3430, T=4→3640, T=5→3750, T=6→6390, T=7→6610, etc.

**Numeric mapping:**

| T (BASIC) | Action |
|-----------|--------|
| 0 | Pass |
| 1 | Move |
| 2 | Open door |
| 3 | Search |
| 4 | Switch weapon |
| 5 | Fight |
| 6 | Look around |
| 7 | Save game |
| 8 | Use magic |
| 9 | Buy magic |
| 10 | (Cheat — port) |
| 11 | Buy HP |
| 12 | Quit |

**Port:** get_command_from_user parses integer 0–12; same mapping. Get Command.asm; CommandStrings; invalid → "invalid", wait_key, re-prompt.

---

## 2. Game loop (BASIC 1480–1600, port Game Loop.asm)

- Print "WELCOME TO DUNGEON #"; D; "YOU ARE AT ("; G; ","; H; ")".
- "COMANDS LIST" / input; if "YES" print full list.
- "COMMAND="; INPUT T; dispatch by T; then loop back.

**Port:** game_loop: save_game, game_loop_welcome (dungeon #, position), get_command (short list; "yes" → long list), then infinite loop get_command_from_user. Command 12 → quit → jump to boot.

---

## 3. Acceptance

- AC-007: Commands 0–12 dispatch to pass, move, open_door, search, switch_weapon, fight, look_around, save_game, use_magic, buy_magic, cheat, buy_hp, quit.
- Tests: Integration (game flow); no dedicated unit test for dispatch.
