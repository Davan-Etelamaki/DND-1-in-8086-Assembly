// @ts-check
/**
 * Assembly test suite (Test/Tests.asm) run in the v86 emulator.
 * One shared emulator run (beforeAll), then one test per section plus a final completion test.
 * See playwright/README.md for documentation of each test.
 */
const { test, expect } = require("@playwright/test");
const path = require("path");
const { runEmulatorUntilDone, parseSerialOutput } = require("../../support/emulator.js");

const port = Number(process.env.PORT) || 3848;
const diskUrl = `http://localhost:${port}/Compiled/Bin/OS.bin`;
const emulatorUrl = `http://localhost:${port}/tools/emulator.html?disk=${encodeURIComponent(diskUrl)}`;

/** @type {{ fullSerial: string, parsed: ReturnType<typeof parseSerialOutput>, page: import('@playwright/test').Page } | null} */
let runResult = null;

test.describe("Assembly test suite in v86 emulator", () => {
  test.beforeAll(async ({ browser }) => {
    const page = await browser.newPage();
    const result = await runEmulatorUntilDone(page, emulatorUrl);
    runResult = { ...result, page };
  });

  test.afterAll(async () => {
    if (runResult?.page) await runResult.page.close();
  });

  /** MemoryFunctions.asm: mem_copy copies a string to a destination; string_assert_equal verifies equality. */
  test("Memory: mem_copy and string comparison run without failure", async ({}, testInfo) => {
    if (!runResult) throw new Error("Emulator run did not complete");
    await attachArtifactsIfFirst(runResult, testInfo);
    expect(runResult.parsed.sections).toContain("MemoryFunctionTests");
    expect(runResult.parsed.hasFail).toBe(false);
  });

  /** Print.asm: print_string, print_dec, new_line; 27 rows printed and ypos/cursor asserted. */
  test("Print: print_string, print_dec, new_line and cursor (ypos) run without failure", async () => {
    if (!runResult) throw new Error("Emulator run did not complete");
    expect(runResult.parsed.sections).toContain("PrintTest");
    expect(runResult.parsed.hasFail).toBe(false);
  });

  /** Int.asm: parse_int (invalid, 1052, -1052, 1, 32767) and get_root (25→5, 81→9, etc.). */
  test("Integer: parse_int and get_root (parsing and integer square root) run without failure", async () => {
    if (!runResult) throw new Error("Emulator run did not complete");
    expect(runResult.parsed.sections).toContain("IntTests");
    expect(runResult.parsed.hasFail).toBe(false);
  });

  /** StringFunctions.asm: string_compare, to_upper, to_lower, substr, string_copy, get_string_array. */
  test("String: compare, to_upper, to_lower, substring, copy run without failure", async () => {
    if (!runResult) throw new Error("Emulator run did not complete");
    expect(runResult.parsed.sections).toContain("StringFunctionTests");
    expect(runResult.parsed.hasFail).toBe(false);
  });

  /** Test/Game/Dice.asm: roll_d6 with fixed seed returns value in [1,6] (game flow unit test). */
  test("Game: dice (roll_d6) run without failure", async () => {
    if (!runResult) throw new Error("Emulator run did not complete");
    expect(runResult.parsed.sections).toContain("GameDiceTests");
    expect(runResult.parsed.hasFail).toBe(false);
  });

  /** Test/Game/Player.asm: add_hp, lose_hp, add_gold, remove_gold (game flow unit test). */
  test("Game: player (HP and gold) run without failure", async () => {
    if (!runResult) throw new Error("Emulator run did not complete");
    expect(runResult.parsed.sections).toContain("GamePlayerTests");
    expect(runResult.parsed.hasFail).toBe(false);
  });

  /** Test/Game/Dungeon.asm: get_y_bounds, get_x_bounds (game flow unit test). */
  test("Game: dungeon (bounds) run without failure", async () => {
    if (!runResult) throw new Error("Emulator run did not complete");
    expect(runResult.parsed.sections).toContain("GameDungeonTests");
    expect(runResult.parsed.hasFail).toBe(false);
  });

  /** Test/Game/Inventory.asm: add_to_inventory, check_inventory (game flow unit test). */
  test("Game: inventory (add, check) run without failure", async () => {
    if (!runResult) throw new Error("Emulator run did not complete");
    expect(runResult.parsed.sections).toContain("GameInventoryTests");
    expect(runResult.parsed.hasFail).toBe(false);
  });

  /** Test/Game/Monsters.asm: 10 monster types per DND1 spec (game flow unit test). */
  test("Game: monsters (10 types per spec) run without failure", async () => {
    if (!runResult) throw new Error("Emulator run did not complete");
    expect(runResult.parsed.sections).toContain("GameMonstersTests");
    expect(runResult.parsed.hasFail).toBe(false);
  });

  /** Test/Game/LogicTests.asm: read_dungeon 7/8 placement, DungeonNumber byte, CurrentMonster layout (gap tests). */
  test("Game: logic (read_dungeon, DungeonNumber, CurrentMonster) run without failure", async () => {
    if (!runResult) throw new Error("Emulator run did not complete");
    expect(runResult.parsed.sections).toContain("GameLogicTests");
    expect(runResult.parsed.hasFail).toBe(false);
  });

  /** Tests.asm: all sections ran and the suite printed ALL_TESTS_PASSED with no Fail. */
  test("Full suite completes with ALL_TESTS_PASSED and no Fail", async () => {
    if (!runResult) throw new Error("Emulator run did not complete");
    expect(runResult.parsed.sections).toContain("Done");
    expect(runResult.parsed.hasAllTestsPassed).toBe(true);
    expect(runResult.parsed.hasFail).toBe(false);
  });
});

/** Attach serial log and optional screenshot to the first test that calls this. */
async function attachArtifactsIfFirst(runResult, testInfo) {
  await testInfo.attach("serial-output.txt", {
    body: runResult.fullSerial || "(empty)",
    contentType: "text/plain",
  });
  if (runResult.parsed.lastLines) {
    await testInfo.attach("serial-output-tail.txt", {
      body: runResult.parsed.lastLines,
      contentType: "text/plain",
    });
  }
  if (runResult.parsed.hasFail || !runResult.parsed.hasAllTestsPassed) {
    const canvas = runResult.page.locator("#screen_container canvas").first();
    if ((await canvas.count()) > 0) {
      await testInfo.attach("emulator-screen.png", {
        body: await canvas.screenshot(),
        contentType: "image/png",
      });
    }
  }
}
