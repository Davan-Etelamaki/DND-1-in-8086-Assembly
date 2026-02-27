# Build the bootable image. Requires NASM. On Windows, use Git Bash for make, or Scripts/Build.ps1.
NASM = nasm -f bin -i "SourceFiles/"
STAGE1 = Compiled/Source/stage1.com
STAGE2 = Compiled/Source/stage2.com
OSBIN = Compiled/Bin/OS.bin

.PHONY: all build clean debug debug-automated test run test-run

all: build

build: $(OSBIN)

$(OSBIN): $(STAGE1) $(STAGE2)
	@mkdir -p Compiled/Bin
	cat "$(STAGE1)" "$(STAGE2)" > "$(OSBIN)"

$(STAGE1): SourceFiles/Stage1.asm
	@mkdir -p Compiled/Source
	$(NASM) SourceFiles/Stage1.asm -o $(STAGE1)

$(STAGE2): SourceFiles/Stage2.asm
	@mkdir -p Compiled/Source
	$(NASM) SourceFiles/Stage2.asm -o $(STAGE2)

clean:
	rm -f $(STAGE1) $(STAGE2) $(OSBIN)

# Build with tests enabled (RunTests instead of game). Run in QEMU to see test output.
debug: NASM := $(NASM) -DDEBUG
debug: $(STAGE1)
	@mkdir -p Compiled/Source
	$(NASM) SourceFiles/Stage2.asm -o $(STAGE2)
	@mkdir -p Compiled/Bin
	cat "$(STAGE1)" "$(STAGE2)" > "$(OSBIN)"
	@echo "DEBUG image built: $(OSBIN). Run in QEMU to execute tests."

# Build for automated test-run: DEBUG + AUTOMATED (no wait_key), serial output.
debug-automated: NASM := $(NASM) -DDEBUG -DAUTOMATED
debug-automated: $(STAGE1)
	@mkdir -p Compiled/Source
	$(NASM) SourceFiles/Stage2.asm -o $(STAGE2)
	@mkdir -p Compiled/Bin
	cat "$(STAGE1)" "$(STAGE2)" > "$(OSBIN)"

# Build and run in QEMU (requires qemu-system-i386). Use 'make debug run' for tests.
run: build
	qemu-system-i386 -m 16 -hda $(OSBIN)

# Alias: build debug image and remind how to run tests.
test: debug
	@echo "Run: qemu-system-i386 -m 16 -hda $(OSBIN)"
	@echo "Or: make test-run (build, run in QEMU with serial, parse result)"

# Build debug image, run QEMU with -nographic -serial stdio, parse for ALL_TESTS_PASSED / Fail. Exit 0/1.
test-run: debug-automated
	@Scripts/run_tests.sh
