#!/usr/bin/env bash
# Run automated tests: build DEBUG image, run in QEMU with serial on stdout, parse result.
# Exit 0 if ALL_TESTS_PASSED seen and no "Fail"; exit 1 otherwise.
# Requires: NASM, qemu-system-i386. Run from repo root.

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OSBIN="$ROOT/Compiled/Bin/OS.bin"
TIMEOUT=15
OUTFILE="${TMPDIR:-/tmp}/dnd1-test-output.txt"

# Build debug image with AUTOMATED (no wait_key) for scripted run
make -C "$ROOT" debug-automated 1>/dev/null

# Run QEMU with serial to stdout; run in background, sleep, then kill (portable: no GNU timeout required)
qemu-system-i386 -m 16 -hda "$OSBIN" -nographic -serial stdio > "$OUTFILE" 2>&1 &
QPID=$!
sleep ${TIMEOUT}
kill $QPID 2>/dev/null || true
wait $QPID 2>/dev/null || true

if grep -q "ALL_TESTS_PASSED" "$OUTFILE" && ! grep -q "\bFail\b" "$OUTFILE"; then
  echo "Tests PASSED (serial output contained ALL_TESTS_PASSED, no Fail)."
  exit 0
fi
if grep -q "\bFail\b" "$OUTFILE"; then
  echo "Tests FAILED (output contained 'Fail')."
  exit 1
fi
echo "Tests INCOMPLETE or TIMEOUT (ALL_TESTS_PASSED not seen). Output in $OUTFILE"
exit 1
