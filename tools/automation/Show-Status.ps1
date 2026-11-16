$settings = Get-Content (Join-Path $PSScriptRoot 'settings.local.json') -Raw -Encoding UTF8 | ConvertFrom-Json
& $settings.python (Join-Path $PSScriptRoot 'controller\supervisor.py') --config (Join-Path $PSScriptRoot 'queue.json') --status
