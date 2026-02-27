// @ts-check
/**
 * Shared helpers for running the assembly test suite in the v86 emulator
 * and parsing serial (COM1) output. Used by assembly suite specs.
 */

const POLL_INTERVAL_MS = 200;
const SERIAL_TAIL_LEN = 150000;
const RUN_TIMEOUT_MS = 55000;

/**
 * Section markers printed by the assembly tests (Test/Tests.asm and included libs).
 * Order matches the run order: existing unit tests → game flow tests → Done.
 */
const SECTION_MARKERS = [
  { id: "MemoryFunctionTests", patterns: ["Testing Memory Copy:"] },
  { id: "PrintTest", patterns: ["Testing Print", "Print Test Complete"] },
  { id: "IntTests", patterns: ["Testing Parse Int", "Testing Get Root"] },
  {
    id: "StringFunctionTests",
    patterns: [
      "Testing Sring Functions",
      "Testing String Compare:",
      "Testing To Lower:",
      "Testing To Upper:",
      "Testing String Copy:",
    ],
  },
  { id: "GameDiceTests", patterns: ["Testing Dice (game logic):"] },
  { id: "GamePlayerTests", patterns: ["Testing Player (HP and gold):"] },
  { id: "GameDungeonTests", patterns: ["Testing Dungeon (get_y_bounds, get_x_bounds, get_tile_number):"] },
  { id: "GameInventoryTests", patterns: ["Testing Inventory (add, check, remove):"] },
  { id: "GameMonstersTests", patterns: ["Testing Monsters (10 types per spec):"] },
  { id: "GameLogicTests", patterns: ["Testing Game Logic (read_dungeon, DungeonNumber, CurrentMonster):"] },
  { id: "Done", patterns: ["ALL_TESTS_PASSED"] },
];

const delay = (ms) => new Promise((r) => setTimeout(r, ms));

/**
 * Read the last `tailLen` bytes of serial output from the emulator page.
 * @param {import('@playwright/test').Page} page
 * @param {number} [tailLen]
 * @returns {Promise<string>}
 */
function getSerialTail(page, tailLen = SERIAL_TAIL_LEN) {
  return page.evaluate((len) => {
    const arr = window.__v86SerialOutput || [];
    const start = Math.max(0, arr.length - len);
    return arr.slice(start).map((c) => String.fromCharCode(c)).join("");
  }, tailLen);
}

/**
 * Parse serial text for section markers, Fail, and ALL_TESTS_PASSED.
 * @param {string} text
 * @returns {{ sections: string[], hasFail: boolean, hasAllTestsPassed: boolean, lastLines: string }}
 */
function parseSerialOutput(text) {
  const sections = [];
  const seen = new Set();
  for (const { id, patterns } of SECTION_MARKERS) {
    for (const p of patterns) {
      if (text.includes(p) && !seen.has(id)) {
        seen.add(id);
        sections.push(id);
        break;
      }
    }
  }
  return {
    sections,
    hasFail: /\bFail\b/.test(text),
    hasAllTestsPassed: /ALL_TESTS_PASSED/.test(text),
    lastLines: text.slice(-800).trim(),
  };
}

/**
 * Get the full serial buffer as a string (avoids losing early output when buffer is large).
 * @param {import('@playwright/test').Page} page
 * @returns {Promise<string>}
 */
function getFullSerial(page) {
  return page.evaluate(() => {
    const arr = window.__v86SerialOutput || [];
    return arr.map((c) => String.fromCharCode(c)).join("");
  });
}

/**
 * Run the emulator page until ALL_TESTS_PASSED, Fail, or timeout.
 * @param {import('@playwright/test').Page} page
 * @param {string} emulatorUrl
 * @param {import('@playwright/test').TestInfo} [testInfo]
 * @returns {Promise<{ fullSerial: string, parsed: ReturnType<typeof parseSerialOutput> }>}
 */
async function runEmulatorUntilDone(page, emulatorUrl, testInfo) {
  await page.goto(emulatorUrl, { waitUntil: "domcontentloaded", timeout: 15000 });
  await page.waitForFunction(() => Array.isArray(window.__v86SerialOutput), { timeout: 5000 });
  await delay(3000);

  const sectionProgress = [];
  const deadline = Date.now() + RUN_TIMEOUT_MS;

  while (Date.now() < deadline) {
    const chunk = await getSerialTail(page);
    const parsed = parseSerialOutput(chunk);

    for (const sec of parsed.sections) {
      if (!sectionProgress.includes(sec)) {
        sectionProgress.push(sec);
        if (testInfo) testInfo.annotations.push({ type: "section", description: `Started: ${sec}` });
        if (sec !== "Done") console.log(`  [emulator] ${sec} started`);
      }
    }

    if (parsed.hasAllTestsPassed && !parsed.hasFail) break;
    if (parsed.hasFail) break;
    await delay(POLL_INTERVAL_MS);
  }

  const fullSerial = await getFullSerial(page);
  return { fullSerial, parsed: parseSerialOutput(fullSerial) };
}

module.exports = {
  POLL_INTERVAL_MS,
  SERIAL_TAIL_LEN,
  RUN_TIMEOUT_MS,
  SECTION_MARKERS,
  delay,
  getSerialTail,
  parseSerialOutput,
  runEmulatorUntilDone,
};
