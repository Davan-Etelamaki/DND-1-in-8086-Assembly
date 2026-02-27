#!/usr/bin/env node
/**
 * Build OS.bin using NASM. Uses NASM on PATH, or NASM_PATH env, or common install locations.
 * Usage: node scripts/build.js [--debug] [--automated] [--game]
 * --debug: pass -DDEBUG to Stage2 (run assembly tests instead of game)
 * --automated: pass -DAUTOMATED (skip wait_key in tests); implies --debug for test image
 * --game: build game image (no DEBUG) to OS-game.bin; use for game smoke tests
 */
const { spawnSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const sourceFiles = path.join(root, "SourceFiles");
const outSource = path.join(root, "Compiled", "Source");
const outBin = path.join(root, "Compiled", "Bin");
const stage1Asm = path.join(sourceFiles, "Stage1.asm");
const stage2Asm = path.join(sourceFiles, "Stage2.asm");
const stage1Out = path.join(outSource, "stage1.com");
const stage2Out = path.join(outSource, "stage2.com");
const osBin = path.join(outBin, "OS.bin");
const osGameBin = path.join(outBin, "OS-game.bin");

const args = process.argv.slice(2);
const gameBuild = args.includes("--game");
const debug = gameBuild ? false : args.includes("--debug");
const automated = gameBuild ? false : args.includes("--automated");
const outputPath = gameBuild ? osGameBin : osBin;

function findNasm() {
  if (process.env.NASM_PATH) {
    const p = process.env.NASM_PATH.trim();
    if (fs.existsSync(p)) return p;
  }
  const fromPath = spawnSync("nasm", ["-v"], { encoding: "utf8", stdio: "pipe" });
  if (fromPath.status === 0) return "nasm";
  if (process.platform === "win32") {
    const candidates = [
      path.join(process.env["ProgramFiles"] || "C:\\Program Files", "NASM", "nasm.exe"),
      path.join(process.env["ProgramFiles(x86)"] || "C:\\Program Files (x86)", "NASM", "nasm.exe"),
    ];
    for (const c of candidates) {
      if (fs.existsSync(c)) return c;
    }
  }
  console.error("NASM not found. Install from https://www.nasm.us/ or set NASM_PATH to the nasm executable.");
  process.exit(1);
}

const nasmExe = findNasm();

function run(cmd, args, opts = {}) {
  const r = spawnSync(cmd, args, { stdio: "inherit", ...opts });
  if (r.status !== 0) {
    process.exit(r.status ?? 1);
  }
}

[outSource, outBin].forEach((d) => {
  if (!fs.existsSync(d)) fs.mkdirSync(d, { recursive: true });
});

const nasmArgs = ["-f", "bin", "-i", sourceFiles + path.sep];
if (debug) nasmArgs.push("-DDEBUG");
if (automated) nasmArgs.push("-DAUTOMATED");

console.log("Building Stage1...");
run(nasmExe, [...nasmArgs, stage1Asm, "-o", stage1Out]);

console.log("Building Stage2...");
run(nasmExe, [...nasmArgs, stage2Asm, "-o", stage2Out]);

const s1 = fs.readFileSync(stage1Out);
const s2 = fs.readFileSync(stage2Out);
const MIN_DISK_SIZE = 1024 * 1024; // 1 MB - many BIOS/IDE expect a minimum disk size
let image = Buffer.concat([s1, s2]);
if (image.length < MIN_DISK_SIZE) {
  image = Buffer.concat([image, Buffer.alloc(MIN_DISK_SIZE - image.length)]);
}
fs.writeFileSync(outputPath, image);

console.log("Built:", outputPath);
if (gameBuild) {
  console.log("(Game image: intro + game loop; use for game smoke tests)");
}
if (debug) {
  console.log("(Debug image: runs tests instead of game)");
}
if (automated) {
  console.log("(Automated: no wait_key; use with npm test)");
}
