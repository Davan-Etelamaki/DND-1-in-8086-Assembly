#!/usr/bin/env node
/**
 * Build and run the application in v86 (browser). No QEMU required.
 * Usage: npm start  (or node scripts/start.js)
 * Requires: NASM on PATH. Opens the default browser to the emulator page.
 */
const { spawnSync } = require("child_process");
const path = require("path");
const server = require("./serve.js");

const root = path.resolve(__dirname, "..");
const port = 3847;
process.env.PORT = String(port);

const buildResult = spawnSync(process.execPath, [path.join(__dirname, "build.js")], {
  cwd: root,
  stdio: "inherit",
});
if (buildResult.status !== 0) {
  process.exit(buildResult.status ?? 1);
}

const url = "http://localhost:" + port + "/";
const platform = process.platform;
let openCmd, openArgs;
if (platform === "win32") {
  openCmd = "cmd";
  openArgs = ["/c", "start", "", url];
} else if (platform === "darwin") {
  openCmd = "open";
  openArgs = [url];
} else {
  openCmd = "xdg-open";
  openArgs = [url];
}
require("child_process").spawn(openCmd, openArgs, { stdio: "ignore", detached: true });

console.log("Application loaded in browser. Close the terminal or press Ctrl+C to stop the server.");
server.on("close", () => process.exit(0));
