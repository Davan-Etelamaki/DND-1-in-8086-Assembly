#!/usr/bin/env node
/**
 * Minimal HTTP server that serves the repo root so that
 * /tools/emulator.html and /Compiled/Bin/OS.bin are available for v86.
 * Usage: node scripts/serve.js [port]
 * Returns the server instance (call server.close() to stop).
 */
const http = require("http");
const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const port = parseInt(process.argv[2] || process.env.PORT || "3847", 10);

const mime = {
  ".html": "text/html",
  ".js": "application/javascript",
  ".bin": "application/octet-stream",
  ".wasm": "application/wasm",
};

const server = http.createServer((req, res) => {
  const url = req.url === "/" ? "/tools/emulator.html" : req.url;
  const pathname = url.replace(/\?.*$/, "").replace(/^\//, "");
  const file = path.join(root, pathname);
  if (!file.startsWith(root) || pathname.includes("..")) {
    res.writeHead(403);
    res.end();
    return;
  }
  fs.readFile(file, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end("Not found");
      return;
    }
    const ext = path.extname(file);
    res.setHeader("Content-Type", mime[ext] || "application/octet-stream");
    res.end(data);
  });
});

server.listen(port, () => {
  console.log("Serving at http://localhost:" + port);
  console.log("Emulator: http://localhost:" + port + "/tools/emulator.html");
});

module.exports = server;
