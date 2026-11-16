$ErrorActionPreference = 'Stop'
$settings = Get-Content (Join-Path $PSScriptRoot 'settings.local.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$stop = Join-Path $PSScriptRoot 'STOP'
if (Test-Path -LiteralPath $stop) { Remove-Item -LiteralPath $stop }
$runtime = Join-Path $PSScriptRoot 'runtime'
New-Item -ItemType Directory -Force $runtime | Out-Null
# An explicit new start rechecks previously missing authentication on the next attempt.
$statePath = Join-Path $runtime 'state.json'
if (Test-Path -LiteralPath $statePath) {
    $state = Get-Content $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($provider in $state.providers.PSObject.Properties) {
        if ($provider.Value.reason -eq 'auth') { $provider.Value.retry_after = 0 }
    }
    $state | ConvertTo-Json -Depth 20 | Set-Content $statePath -Encoding UTF8
}
$arguments = @(
    ('"' + (Join-Path $PSScriptRoot 'controller\supervisor.py') + '"'),
    '--config', ('"' + (Join-Path $PSScriptRoot 'queue.json') + '"')
)
$process = Start-Process -FilePath $settings.python -ArgumentList $arguments -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtime 'host.stdout.log') -RedirectStandardError (Join-Path $runtime 'host.stderr.log')
Set-Content -LiteralPath (Join-Path $runtime 'host.pid') -Value $process.Id
Write-Output "Started. Status: $(Join-Path $PSScriptRoot 'DURUM.txt')"
