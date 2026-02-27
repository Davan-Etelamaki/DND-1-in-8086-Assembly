# Build DND-1 bootable image (OS.bin) without make.
# Usage: .\Scripts\Build.ps1 [Debug]
#   Debug: build with -DDEBUG so Stage2 runs RunTests instead of the game.
# Requires: NASM on PATH. Output: Compiled\Bin\OS.bin

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$SourceFiles = Join-Path $Root "SourceFiles"
$CompiledSource = Join-Path $Root "Compiled\Source"
$CompiledBin = Join-Path $Root "Compiled\Bin"
$Stage1Asm = Join-Path $SourceFiles "Stage1.asm"
$Stage2Asm = Join-Path $SourceFiles "Stage2.asm"
$Stage1Out = Join-Path $CompiledSource "stage1.com"
$Stage2Out = Join-Path $CompiledSource "stage2.com"
$OsBin = Join-Path $CompiledBin "OS.bin"

$Debug = $args -contains "Debug" -or $args -contains "debug" -or $args -contains "-D"

foreach ($d in $CompiledSource, $CompiledBin) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

# NASM: -f bin, include path, optional -DDEBUG
$NasmArgs = @("-f", "bin", "-i", "$SourceFiles\")
if ($Debug) {
    $NasmArgs += "-DDEBUG"
    Write-Host "Building DEBUG image (tests enabled)..."
} else {
    Write-Host "Building release image..."
}

& nasm $NasmArgs $Stage1Asm -o $Stage1Out
& nasm $NasmArgs $Stage2Asm -o $Stage2Out

$s1 = [System.IO.File]::ReadAllBytes($Stage1Out)
$s2 = [System.IO.File]::ReadAllBytes($Stage2Out)
$all = $s1 + $s2
[System.IO.File]::WriteAllBytes($OsBin, $all)

Write-Host "Built: $OsBin"
if ($Debug) {
    Write-Host "Run in QEMU to execute tests: qemu-system-i386 -m 16 -hda $OsBin"
}
