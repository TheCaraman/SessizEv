$settings = Get-Content (Join-Path $PSScriptRoot 'settings.local.json') -Raw -Encoding UTF8 | ConvertFrom-Json
& $settings.claude auth login --claudeai
if ($LASTEXITCODE -eq 0) { Write-Output 'Claude login completed. You can run Start-Automation.ps1.' }
