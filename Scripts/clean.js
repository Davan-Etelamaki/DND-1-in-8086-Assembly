#!/usr/bin/env node
const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const files = [
  path.join(root, "Compiled", "Source", "stage1.com"),
  path.join(root, "Compiled", "Source", "stage2.com"),
  path.join(root, "Compiled", "Bin", "OS.bin"),
];

files.forEach((f) => {
  if (fs.existsSync(f)) {
    fs.unlinkSync(f);
    console.log("Removed:", f);
  }
});
