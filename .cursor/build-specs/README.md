# Build specs (DND #1)

Component specs and full-scope documentation for the **DND-1 8086 Assembly** port. Built from the in-repo spec page (Documentation/DND1-Spec-Web-References.md), associated web references, and the **original BASIC source** (Richard Garriott DND1, 1977; see [GitHub Gist 11137495](https://gist.github.com/bussiere/11137495)).

---

## Purpose

- **Single place** for authoritative, component-level specs derived from the original game and web refs.
- **Traceability** from BASIC lines and references to port behavior (Documentation/, SourceFiles/).
- **Use by:** Plan-From-Requirements, Implement-From-Plan, verify-implementation, and manual implementation/review.

---

## Contents

| Document | Description |
|----------|-------------|
| [00-FULL-SCOPE.md](00-FULL-SCOPE.md) | Full scope, sources, in/out of scope, flow summary, port mapping, index of component specs. |
| [01-Character.md](01-Character.md) | Character: 7 attributes + Gold, 3d6, Gold×15, classes (Fighter/Cleric/Wizard), initial HP. |
| [02-Shop-and-Items.md](02-Shop-and-Items.md) | Shop flow, 15 items and prices, class restrictions (Cleric/Wizard). |
| [03-Monsters.md](03-Monsters.md) | 10 monster types, table layout, combat use. |
| [04-Dungeon-and-Tiles.md](04-Dungeon-and-Tiles.md) | Grid 25×25, tile codes 0–8, read_dungeon, random 7/8. |
| [05-Commands-and-Loop.md](05-Commands-and-Loop.md) | Command list 0–12, get_command, game loop. |
| [06-Move-and-Tile-Handling.md](06-Move-and-Tile-Handling.md) | move, check_tile, advance_position, trap, doors, monster, gold, strength, constitution. |
| [07-Combat.md](07-Combat.md) | fight, battle, monster stats, damage, death, gold. |
| [08-Save-Load.md](08-Save-Load.md) | game_save layout, save_game, load_game, old game. |
| [09-BASIC-Source-Excerpts.md](09-BASIC-Source-Excerpts.md) | Key BASIC lines for traceability. |

---

## References

- **In-repo:** Documentation/DND1-Spec-Web-References.md, Game-Flow.md, Data-Structures.md, Architecture.md, Testing.md, Acceptance-Criteria.md.
- **Web:** Ultima Codex (handwritten notes), Polygon (port article), Shroud of the Avatar (contest, dnd1.php), GitHub Gist bussiere/11137495 (BASIC source).

---

## Relationship to other docs

- **Documentation/** — Current port behavior, build, test, issues. Build-specs reference these and add **component-level** and **BASIC-level** detail.
- **Documentation/Acceptance-Criteria.md** — Acceptance criteria derived from spec; build-specs are the spec source for those AC.
- **.cursor/rules/** — Plan-From-Requirements and Implement-From-Plan can use build-specs as the spec source when planning or implementing features.
