# Unstick-Git.ps1
# A script to kill zombie Git/VS Code processes and clear lock files in AVD
# Run this when VS Code hangs or Git commands stop responding.

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   AVD GIT & VS CODE RESCUE TOOL" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# --- STEP 1: KILL ZOMBIE PROCESSES ---
# We use Stop-Process because 'taskkill' is often missing in locked-down AVDs.
# We silence errors because we don't care if the process isn't running.

$zombies = @(
    "code",                      # VS Code
    "git",                       # Git core
    "git-remote-https",          # Network operations
    "git-credential-manager",    # Auth helper
    "bash",                      # Git Bash terminal
    "sh",                        # Shell
    "ssh-agent",                 # SSH keys
    "Cloudpaging Player"         # The virtualization container
)

Write-Host "`n[1/2] Hunting for zombie processes..." -ForegroundColor Yellow

foreach ($procName in $zombies) {
    $running = Get-Process -Name $procName -ErrorAction SilentlyContinue
    if ($running) {
        Write-Host "   Killing: $procName ($($running.Count) instances)..." -ForegroundColor Red
        $running | Stop-Process -Force -ErrorAction SilentlyContinue
    }
}
Write-Host "   Process cleanup complete." -ForegroundColor Green

# --- STEP 2: REMOVE LOCK FILES ---
# Asks you where your code is, then hunts for index.lock files that prevent git actions.

Write-Host "`n[2/2] Checking for lock files..." -ForegroundColor Yellow
$repoPath = Read-Host "   Paste the path to your source code folder (e.g. C:\Users\You\Source)"

if (Test-Path -Path $repoPath) {
    Write-Host "   Scanning $repoPath for 'index.lock'..." -ForegroundColor Gray
    
    # Recursively find index.lock files. Limiting depth to 4 to prevent scanning the whole disk.
    $lockFiles = Get-ChildItem -Path $repoPath -Filter "index.lock" -Recurse -Depth 5 -ErrorAction SilentlyContinue
    
    if ($lockFiles) {
        foreach ($file in $lockFiles) {
            Write-Host "   Deleting lock file: $($file.FullName)" -ForegroundColor Red
            Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
        }
        Write-Host "   Lock files deleted." -ForegroundColor Green
    } else {
        Write-Host "   No lock files found." -ForegroundColor Green
    }
} else {
    Write-Host "   Invalid path skipped." -ForegroundColor Gray
}

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "   DONE. Try opening VS Code now." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Start-Sleep -Seconds 3
