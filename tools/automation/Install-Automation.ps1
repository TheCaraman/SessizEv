param([string]$DestinationRoot = '')
$ErrorActionPreference = 'Stop'
$git = 'C:\Program Files\Git\cmd\git.exe'
$source = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not $DestinationRoot) {
    $documents = [Environment]::GetFolderPath('MyDocuments')
    if (-not $documents) { throw 'Documents folder is not available' }
    $DestinationRoot = Join-Path $documents 'TheQuietHours'
}
$DestinationRoot = [IO.Path]::GetFullPath($DestinationRoot)
if (Test-Path -LiteralPath $DestinationRoot) { throw "Destination already exists; no files overwritten: $DestinationRoot" }
New-Item -ItemType Directory -Path $DestinationRoot | Out-Null
$project = Join-Path $DestinationRoot 'project'
$branch = (& $git -C $source branch --show-current).Trim()
& $git clone --no-hardlinks -b $branch $source $project
if ($LASTEXITCODE -ne 0) { throw 'Clone failed' }
& $git -C $project switch -c automation/integration
if ($LASTEXITCODE -ne 0) { throw 'Integration branch failed' }
foreach ($field in @('user.name','user.email')) {
    $value = & $git -C $source config $field
    if ($value) { & $git -C $project config $field $value }
}
# Save tracked changes as a binary patch without PowerShell text transcoding.
$patch = Join-Path $DestinationRoot 'paused-work.patch'
$gitProcess = Start-Process -FilePath $git -ArgumentList @('-C', ('"' + $source + '"'), 'diff', '--binary', 'HEAD', ('--output="' + $patch + '"')) -Wait -PassThru -WindowStyle Hidden
if ($gitProcess.ExitCode -ne 0) { throw 'Could not snapshot working changes' }
if ((Get-Item -LiteralPath $patch).Length -gt 0) {
    & $git -C $project apply --binary $patch
    if ($LASTEXITCODE -ne 0) { throw 'Could not restore working changes' }
}
$untracked = & $git -c core.quotepath=false -C $source ls-files --others --exclude-standard
foreach ($file in $untracked) {
    $target = Join-Path $project $file
    New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
    Copy-Item -LiteralPath (Join-Path $source $file) -Destination $target
}
& $git -C $project add -A
if ($LASTEXITCODE -ne 0) { throw 'Could not preserve paused files' }
$changes = & $git -C $project status --porcelain
if ($changes) {
    & $git -C $project commit -m 'checkpoint: preserve paused work before unattended continuation'
    if ($LASTEXITCODE -ne 0) { throw 'Checkpoint failed' }
}
New-Item -ItemType Directory -Path (Join-Path $DestinationRoot 'controller') | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'supervisor.py') -Destination (Join-Path $DestinationRoot 'controller\supervisor.py')
$engineSource = Join-Path $source '..\tools\godot-4.7.2'
$engineTarget = Join-Path $DestinationRoot 'tools\godot-4.7.2'
New-Item -ItemType Directory -Force $engineTarget | Out-Null
Copy-Item -LiteralPath (Join-Path $engineSource 'Godot_v4.7.2-stable_win64.exe') -Destination $engineTarget
Copy-Item -LiteralPath (Join-Path $engineSource 'Godot_v4.7.2-stable_win64_console.exe') -Destination $engineTarget
$codex = (Get-Command codex.exe -ErrorAction Stop).Source
$claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
$python = 'C:\Program Files\WindowsApps\OpenAI.CodexPrimaryRuntime.v26-1112-737-0_26.1112.737.0_x64__3k8sg7r9htsxt\dependencies\python\python.exe'
if (-not (Test-Path -LiteralPath $python)) { throw 'Bundled Python missing' }
$config = Get-Content (Join-Path $PSScriptRoot 'queue.example.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$config.project = $project
$config.godot = Join-Path $engineTarget 'Godot_v4.7.2-stable_win64_console.exe'
$config.providers = @(
    @{name='codex'; executable=$codex; enabled=$true},
    @{name='claude'; executable=$claude; enabled=$true; max_turns=60}
)
$config | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $DestinationRoot 'queue.json') -Encoding UTF8
$local = @{python=$python; claude=$claude; root=$DestinationRoot}
$local | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $DestinationRoot 'settings.local.json') -Encoding UTF8
foreach ($name in @('Start-Automation.ps1','Stop-Automation.ps1','Show-Status.ps1','Claude-Login.ps1')) {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination (Join-Path $DestinationRoot $name)
}
@'
THE QUIET HOURS - Otomatik gelistirme

Baslat: Start-Automation.ps1 (PowerShell ile calistir)
Durdur: Stop-Automation.ps1 (yarim dosyalar korunur)
Durum: DURUM.txt veya Show-Status.ps1
Claude girisi: Claude-Login.ps1

Oyun projesi: project\project.godot
Gorev kuyrugu: queue.json
Gunlukler: runtime\
Asistanlarin ayri calisma kopyalari: workers\

Yalnizca testi gecen gorev project dalina alinir. Kuyruk iki gorevle sinirli.
Yeni API faturalandirmasi etkinlestirilmez; var olan hesap limitleri gecerlidir.
Kaynak oturum klasoru degistirilmedi; bu klasor bagimsiz kalici kopyadir.
Iki klasoru ayni anda elle degistirmeyin. Bundan sonra project klasorunu kullanin.
'@ | Set-Content -LiteralPath (Join-Path $DestinationRoot 'BASLA.txt') -Encoding UTF8
Write-Output "AUTOMATION_ROOT=$DestinationRoot"
