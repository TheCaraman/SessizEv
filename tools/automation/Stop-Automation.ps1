New-Item -ItemType File -Force -Path (Join-Path $PSScriptRoot 'STOP') | Out-Null
Write-Output 'Stop requested. The active agent stops within a few seconds; test phase stops at its timeout/boundary. Partial work is preserved.'
