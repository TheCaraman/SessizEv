$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$gameRoot = Split-Path $projectRoot -Parent
$runtime = Join-Path $gameRoot 'runtime\continuous'
$scriptPath = Join-Path $PSScriptRoot 'coordinator.py'
$configuration = Join-Path $gameRoot 'queue.continuous.json'
$settings = Get-Content (Join-Path $gameRoot 'settings.local.json') -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Force $runtime | Out-Null
$pidPath = Join-Path $runtime 'host.pid'
if (Test-Path -LiteralPath $pidPath) {
    $hostTaskId = (Get-Content -LiteralPath $pidPath -Raw).Trim()
    if ($hostTaskId -match '^\d+$') {
        $existing = Get-CimInstance Win32_Process -Filter "ProcessId = $hostTaskId" -ErrorAction SilentlyContinue
        if ($existing -and $existing.CommandLine.Contains($scriptPath)) {
            Write-Output "Coordinator already running: $hostTaskId"
            exit 0
        }
    }
}
$stopPath = Join-Path $gameRoot 'STOP_CONTINUOUS'
if (Test-Path -LiteralPath $stopPath) { Remove-Item -LiteralPath $stopPath }
$arguments = @(('"' + $scriptPath + '"'), '--config', ('"' + $configuration + '"'))
$process = Start-Process -FilePath $settings.python -ArgumentList $arguments -WorkingDirectory $gameRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtime 'host.stdout.log') -RedirectStandardError (Join-Path $runtime 'host.stderr.log')
Set-Content -LiteralPath $pidPath -Value $process.Id
Write-Output "Coordinator started: $($process.Id). Status: DURUM_OTOMATIK.txt"
