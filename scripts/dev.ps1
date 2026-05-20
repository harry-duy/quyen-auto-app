$root = Split-Path -Parent $PSScriptRoot

# Load backend/.env into the current process so Spring Boot picks up DB_PASSWORD etc.
$envFile = Join-Path $root 'backend\.env'
if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -match '^\s*[^#]\S+=.*' } | ForEach-Object {
        $parts = $_ -split '=', 2
        [System.Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), 'Process')
    }
}

$backendCmd  = '.\mvnw.cmd spring-boot:run'
$customerCmd = 'flutter run --flavor customer -t lib/main.dart'
$staffCmd    = 'flutter run --flavor staff -t lib/main_staff.dart'

if (Get-Command wt -ErrorAction SilentlyContinue) {
    # Windows Terminal — 3 tabs trong cung 1 cua so
    $sep = '`;'
    wt new-tab --title "Backend"  --startingDirectory "$root\backend" powershell -NoExit -Command $backendCmd $sep `
       new-tab --title "Customer" --startingDirectory $root           powershell -NoExit -Command $customerCmd $sep `
       new-tab --title "Staff"    --startingDirectory $root           powershell -NoExit -Command $staffCmd
} else {
    # Fallback — 3 cua so PowerShell rieng
    Start-Process powershell -WorkingDirectory "$root\backend" `
        -ArgumentList '-NoExit', '-Command', $backendCmd

    Start-Process powershell -WorkingDirectory $root `
        -ArgumentList '-NoExit', '-Command', $customerCmd

    Start-Process powershell -WorkingDirectory $root `
        -ArgumentList '-NoExit', '-Command', $staffCmd
}

Write-Host ""
Write-Host "  Started: Backend | Customer app | Staff app" -ForegroundColor Cyan
Write-Host "  Backend API: http://localhost:8080" -ForegroundColor Gray
Write-Host ""
