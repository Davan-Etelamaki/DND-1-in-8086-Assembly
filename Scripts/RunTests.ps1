# Run automated tests: build DEBUG image, run in QEMU with serial on stdout, parse result.
# Exit 0 if ALL_TESTS_PASSED seen and no "Fail"; exit 1 otherwise.
# Requires: NASM, qemu-system-i386. Optional: run from repo root.

$ErrorActionPreference = "Stop"
$Root = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { Get-Location }
$OsBin = Join-Path $Root "Compiled\Bin\OS.bin"
$TimeoutSeconds = 15
$OutFile = Join-Path $env:TEMP "dnd1-test-output.txt"

# Build debug image (same as Build.ps1 Debug)
$SourceFiles = Join-Path $Root "SourceFiles"
$CompiledSource = Join-Path $Root "Compiled\Source"
$CompiledBin = Join-Path $Root "Compiled\Bin"
$Stage1Asm = Join-Path $SourceFiles "Stage1.asm"
$Stage2Asm = Join-Path $SourceFiles "Stage2.asm"
$Stage1Out = Join-Path $CompiledSource "stage1.com"
$Stage2Out = Join-Path $CompiledSource "stage2.com"

foreach ($d in $CompiledSource, $CompiledBin) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

& nasm -f bin -i "$SourceFiles\" -DDEBUG $Stage1Asm -o $Stage1Out
& nasm -f bin -i "$SourceFiles\" -DDEBUG -DAUTOMATED $Stage2Asm -o $Stage2Out
$s1 = [System.IO.File]::ReadAllBytes($Stage1Out)
$s2 = [System.IO.File]::ReadAllBytes($Stage2Out)
[System.IO.File]::WriteAllBytes($OsBin, $s1 + $s2)

# Run QEMU: serial to stdout, no display, timeout
$QemuArgs = @("-m", "16", "-hda", $OsBin, "-nographic", "-serial", "stdio")
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "qemu-system-i386"
$psi.Arguments = $QemuArgs -join " "
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$psi.WorkingDirectory = $Root
$p = [System.Diagnostics.Process]::Start($psi)
$done = $p.WaitForExit($TimeoutSeconds * 1000)
if (-not $done) {
    $p.Kill($true)
}
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
$p.WaitForExit() | Out-Null
[System.IO.File]::WriteAllText($OutFile, $stdout + $stderr, [System.Text.Encoding]::UTF8)

$hasPassed = $stdout -match "ALL_TESTS_PASSED"
$hasFail = $stdout -match "\bFail\b"
if ($hasPassed -and -not $hasFail) {
    Write-Host "Tests PASSED (serial output contained ALL_TESTS_PASSED, no Fail)."
    exit 0
}
if ($hasFail) {
    Write-Host "Tests FAILED (output contained 'Fail')."
    exit 1
}
if (-not $hasPassed) {
    Write-Host "Tests INCOMPLETE or TIMEOUT (ALL_TESTS_PASSED not seen). Output in $OutFile"
    exit 1
}
exit 1
