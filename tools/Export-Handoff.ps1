param([string]$OutputDirectory = '')
$ErrorActionPreference = 'Stop'
$project = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$gitCommand = Get-Command git -ErrorAction SilentlyContinue
if ($gitCommand) { $git = $gitCommand.Source }
else { $git = Join-Path $env:ProgramFiles 'Git\cmd\git.exe' }
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $project '..\handoff' }
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$OutputDirectory = (Resolve-Path -LiteralPath $OutputDirectory).Path
$dirty = & $git -C $project status --porcelain
if ($LASTEXITCODE -ne 0) { throw 'Git status failed' }
if ($dirty) { throw 'Commit your changes before exporting; only committed files are included.' }
$head = & $git -C $project rev-parse --short HEAD
$archive = Join-Path $OutputDirectory "TheQuietHours-$head.zip"
$bundle = Join-Path $OutputDirectory "TheQuietHours-$head.bundle"
& $git -C $project archive --format=zip "--output=$archive" HEAD
if ($LASTEXITCODE -ne 0) { throw 'Source archive failed' }
& $git -C $project bundle create $bundle --all
if ($LASTEXITCODE -ne 0) { throw 'Git bundle failed' }
& $git -C $project bundle verify $bundle
if ($LASTEXITCODE -ne 0) { throw 'Git bundle verification failed' }
Get-FileHash -Algorithm SHA256 -LiteralPath $archive, $bundle | Format-Table -AutoSize
