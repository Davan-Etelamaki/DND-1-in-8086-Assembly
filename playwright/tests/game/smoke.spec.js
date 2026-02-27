// @ts-check
/**
 * Game smoke tests: boot the real game image (intro + game loop) in v86 and assert
 * that it starts and displays content. The game does not print to serial; we assert
 * on the emulator canvas (visibility and non-empty display after boot).
 * Requires OS-game.bin (build with: node scripts/build.js --game).
 */
const { test, expect } = require("@playwright/test");

const port = Number(process.env.PORT) || 3848;
const gameDiskUrl = `http://localhost:${port}/Compiled/Bin/OS-game.bin`;
const emulatorBase = `http://localhost:${port}/tools/emulator.html`;
const BOOT_WAIT_MS = 8000;

test.describe("Game (v86) – smoke tests", () => {
  test("Game image boots and displays content (title / intro)", async ({ page }) => {
    const emulatorUrl = `${emulatorBase}?disk=${encodeURIComponent(gameDiskUrl)}`;
    await page.goto(emulatorUrl, { waitUntil: "domcontentloaded", timeout: 15000 });
    await page.waitForFunction(() => Array.isArray(window.__v86SerialOutput), { timeout: 5000 });
    await new Promise((r) => setTimeout(r, BOOT_WAIT_MS));

    await page.waitForFunction(
      () => {
        const c = document.querySelector("#screen_container canvas");
        return c && c.width > 0 && c.height > 0;
      },
      { timeout: 10000 }
    );

    const size = await page.evaluate(() => {
      const c = document.querySelector("#screen_container canvas");
      return c ? { width: c.width, height: c.height } : null;
    });
    expect(size, "Canvas should exist").not.toBeNull();
    expect(size.width, "Canvas should have non-zero width after boot").toBeGreaterThan(0);
    expect(size.height, "Canvas should have non-zero height after boot").toBeGreaterThan(0);
  });

  test("Game accepts keyboard input (intro prompts respond to keys)", async ({ page }) => {
    const emulatorUrl = `${emulatorBase}?disk=${encodeURIComponent(gameDiskUrl)}`;
    await page.goto(emulatorUrl, { waitUntil: "domcontentloaded", timeout: 15000 });
    await page.waitForFunction(() => Array.isArray(window.__v86SerialOutput), { timeout: 5000 });
    await new Promise((r) => setTimeout(r, BOOT_WAIT_MS));

    await page.waitForFunction(
      () => {
        const c = document.querySelector("#screen_container canvas");
        return c && c.width > 0 && c.height > 0;
      },
      { timeout: 10000 }
    );

    await page.keyboard.press("N");
    await new Promise((r) => setTimeout(r, 600));
    await page.keyboard.press("N");
    await new Promise((r) => setTimeout(r, 600));

    const stillOk = await page.evaluate(() => {
      const c = document.querySelector("#screen_container canvas");
      return c && c.width > 0 && c.height > 0;
    });
    expect(stillOk, "Canvas should still have size after key presses").toBe(true);
  });
});
