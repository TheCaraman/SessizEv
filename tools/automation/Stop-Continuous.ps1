$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$gameRoot = Split-Path $projectRoot -Parent
Set-Content -LiteralPath (Join-Path $gameRoot 'STOP_CONTINUOUS') -Value 'Owner stop requested'
Write-Output 'Stop requested. Worker tree is preserved; the current child is stopped by the coordinator.'
