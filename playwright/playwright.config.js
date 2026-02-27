// @ts-check
/**
 * Playwright config for DND-1 8086 Assembly.
 * Tests run the assembly test suite (Test/Tests.asm) in the v86 emulator and assert on serial output.
 * Run from repo root: npx playwright test --config=playwright/playwright.config.js
 * Or via npm test (builds, serves, then runs this).
 */
const path = require("path");

/** @type {import('@playwright/test').PlaywrightTestConfig} */
const config = {
  testDir: path.join(__dirname, "tests"),
  timeout: 90000,
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: 1,
  reporter: [
    ["list"],
    ["html", { open: "never", outputFolder: "playwright-report" }],
  ],
  use: {
    trace: "on-first-retry",
  },
};

module.exports = config;
