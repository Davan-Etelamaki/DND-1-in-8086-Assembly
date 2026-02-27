# Component spec: Shop and items

Item table (15 items), prices, shop flow, class restrictions. Traceable to BASIC and Data-Structures.md.

## 1. Item table (15 items)

BASIC DATA 280-310, 720: 15 items, indices 1-15. Port Items.asm: SWORD 10, 2-H-SWORD 15, DAGGER 3, MACE 5, SPEAR 2, BOW 25, ARROWS 2, LEATHER MAIL 15, CHAIN MAIL 30, TLTE MAIL 50, ROPE 1, SPIKES 1, FLASK OF OIL 2, SILVER CROSS 25, SPARE FOOD 5. Structure: item .name 16B, .price 2B. NewItem macro.

## 2. Shop flow (BASIC 670-1140)

BUYING WEAPONS; FAST OR NORM (skip or print list). Input Y (1-15). If C(7)-P(Y)<0 then COSTS TOO MUCH. Class checks else C(7)=C(7)-P(Y), W(X)=Y. EQ LIST to show inventory. Port: Shop.asm, item_shop, add_to_inventory.

## 3. Class restrictions (BASIC 1290-1390)

Cleric: cannot buy Y=4 MACE, 8 LEATHER MAIL, 9 CHAIN MAIL, Y>10. Wizard: cannot buy Y=3 DAGGER, 8 LEATHER MAIL, Y>10. Fighter: no restriction. Port: Shop.asm check_cleric_item, check_wizard_item; WizardCannotUseString, ClericCannotUseString.

## 4. Acceptance

AC-005: 15 items. Tests: Test/Game/Inventory.asm (add, check).
