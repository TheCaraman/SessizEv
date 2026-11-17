$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$gameRoot = Split-Path $projectRoot -Parent
$runtime = Join-Path $gameRoot 'runtime\continuous'
$pidPath = Join-Path $runtime 'host.pid'
$alive = $false
if (Test-Path -LiteralPath $pidPath) {
    $hostTaskId = (Get-Content -LiteralPath $pidPath -Raw).Trim()
    if ($hostTaskId -match '^\d+$') {
        $process = Get-CimInstance Win32_Process -Filter "ProcessId = $hostTaskId" -ErrorAction SilentlyContinue
        $alive = $null -ne $process -and $process.CommandLine -like '*tools*automation*coordinator.py*'
    }
}
Write-Output $(if ($alive) { 'Coordinator: RUNNING' } else { 'Coordinator: STOPPED (saved task status is historical)' })
$statePath = Join-Path $runtime 'state.json'
if (Test-Path -LiteralPath $statePath) {
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    foreach ($property in $state.tasks.PSObject.Properties) {
        Write-Output "$($property.Name): $($property.Value.status) - $($property.Value.detail)"
    }
} else { Write-Output 'No task state yet.' }
