/**
 * Extracts Dungeon1–Dungeon6 from SourceFiles/Data/Constants/Dungeons.asm
 * into Dungeons/DNG1.txt … DNG6.txt (25 lines × 25 comma-separated values, no spaces).
 * Run from repo root: node Scripts/extract-dng.js
 */

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const asmPath = path.join(repoRoot, 'SourceFiles', 'Data', 'Constants', 'Dungeons.asm');
const outDir = path.join(repoRoot, 'Dungeons');

const asm = fs.readFileSync(asmPath, 'utf8');
const lines = asm.split(/\r?\n/);

function parseDbLine(line) {
  const m = line.match(/^\s*db\s+(.+)$/);
  if (!m) return null;
  return m[1].split(',').map(s => s.trim()).filter(Boolean);
}

function extractDungeon(startLabel) {
  const idx = lines.findIndex(l => l.trim() === startLabel + ':');
  if (idx === -1) return null;
  const rows = [];
  for (let i = idx + 1; i < lines.length && rows.length < 25; i++) {
    const vals = parseDbLine(lines[i]);
    if (vals && vals.length === 25) rows.push(vals);
    else if (vals) break; // not a db line or wrong length
  }
  return rows.length === 25 ? rows : null;
}

if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });

for (let n = 1; n <= 6; n++) {
  const label = 'Dungeon' + n;
  const grid = extractDungeon(label);
  if (!grid) {
    console.error('Failed to extract ' + label);
    process.exit(1);
  }
  const text = grid.map(row => row.join(',')).join('\n');
  const outPath = path.join(outDir, 'DNG' + n + '.txt');
  fs.writeFileSync(outPath, text, 'utf8');
  console.log('Wrote ' + outPath);
}

console.log('Done. DNG1–DNG6 extracted.');
