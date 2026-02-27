#!/usr/bin/env node
/**
 * Build game + test images, start the static server, then run Playwright tests
 * (assembly suite + game smoke tests). Exit code = Playwright exit code.
 */
const { spawnSync, spawn } = require("child_process");
const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const port = Number(process.env.PORT) || 3848;

process.env.PORT = String(port);

// 1) Build game image (OS-game.bin) for game smoke tests
const gameBuildResult = spawnSync(
  process.execPath,
  [path.join(__dirname, "build.js"), "--game"],
  { cwd: root, stdio: "inherit" }
);
if (gameBuildResult.status !== 0) {
  console.error("Game build failed. Ensure NASM is on PATH.");
  process.exit(gameBuildResult.status ?? 1);
}

// 2) Build debug+automated image (OS.bin) for assembly tests
const testBuildResult = spawnSync(
  process.execPath,
  [path.join(__dirname, "build.js"), "--debug", "--automated"],
  { cwd: root, stdio: "inherit" }
);
if (testBuildResult.status !== 0) {
  console.error("Test image build failed. Ensure NASM is on PATH.");
  process.exit(testBuildResult.status ?? 1);
}

const osBin = path.join(root, "Compiled", "Bin", "OS.bin");
const osGameBin = path.join(root, "Compiled", "Bin", "OS-game.bin");
if (!fs.existsSync(osBin)) {
  console.error("Expected test image not found:", osBin);
  process.exit(1);
}
if (!fs.existsSync(osGameBin)) {
  console.error("Expected game image not found:", osGameBin);
  process.exit(1);
}

// 3) Start server (must stay up while Playwright runs)
const server = require("./serve.js");

server.once("listening", () => {
  // 4) Run Playwright tests (async spawn so server event loop can serve requests)
  const child = spawn(
    "npx",
    ["playwright", "test", "--config=playwright/playwright.config.js"],
    {
      cwd: root,
      env: { ...process.env, PORT: String(port) },
      stdio: "inherit",
      shell: true,
    }
  );
  child.on("close", (code) => {
    server.close();
    process.exit(code ?? 1);
  });
});
