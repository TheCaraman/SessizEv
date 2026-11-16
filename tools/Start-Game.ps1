param(
    [switch]$NightDemo,
    [switch]$PrepareOnly,
    [string]$GodotPath = $env:GODOT_BIN
)
$ErrorActionPreference = 'Stop'
$sourceProject = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not $GodotPath) {
    $GodotPath = Join-Path $sourceProject '..\tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe'
}
$consoleEngine = (Resolve-Path -LiteralPath $GodotPath).Path
if (-not $consoleEngine.EndsWith('_console.exe')) {
    $pairedConsole = $consoleEngine.Substring(0, $consoleEngine.Length - 4) + '_console.exe'
    if (Test-Path -LiteralPath $pairedConsole) { $consoleEngine = $pairedConsole }
}
$engineVersion = (& $consoleEngine --version | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $engineVersion -notmatch '^4\.7\.2\.stable') {
    throw 'Bu proje Godot 4.7.2 stable gerektiriyor. GODOT_BIN ile dogru console.exe yolunu belirt.'
}
$playEngine = $consoleEngine.Replace('_console.exe', '.exe')
if (-not (Test-Path -LiteralPath $playEngine)) { $playEngine = $consoleEngine }
$launchProject = $sourceProject
$launchId = [guid]::NewGuid().ToString('N')
$launchCache = Join-Path $env:LOCALAPPDATA ('TheQuietHours\playtests\' + $launchId)
New-Item -ItemType Directory -Path $launchCache | Out-Null
$scene = ''
$userData = 'Normal campaign preferences and saves'
if ($NightDemo) {
    $launchProject = Join-Path $launchCache 'project'
    & robocopy $sourceProject $launchProject /E /XD .git .godot docs tools build /XF override.cfg /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -ge 8) { throw 'Deneme projesi kopyalanamadi.' }
    $userData = 'TheQuietHours-Playtests/night-watch/' + $launchId
    $overrideText = "[application]`nconfig/name=`"The Quiet Hours - Night Demo`"`nconfig/use_custom_user_dir=true`nconfig/custom_user_dir_name=`"$userData`"`n"
    [IO.File]::WriteAllText((Join-Path $launchProject 'override.cfg'), $overrideText, (New-Object Text.UTF8Encoding $false))
    $scene = 'res://tests/manual_night_watch.tscn'
}
# Refresh imported assets before launching. Each run keeps its diagnostic logs.
$importOut = Join-Path $launchCache 'import-stdout.log'
$importErr = Join-Path $launchCache 'import-stderr.log'
$importArguments = @('--headless', '--path', $launchProject, '--import') | ForEach-Object { '"' + $_ + '"' }
$importProcess = Start-Process -FilePath $consoleEngine -ArgumentList $importArguments -WindowStyle Hidden -PassThru -RedirectStandardOutput $importOut -RedirectStandardError $importErr
$null = $importProcess.Handle
if (-not $importProcess.WaitForExit(120000)) {
    $importProcess.Kill()
    throw "Varlik ice aktarma zaman asimina ugradi. Log: $launchCache"
}
$importProcess.WaitForExit()
$importProcess.Refresh()
$importText = (Get-Content -LiteralPath $importOut -Raw) + (Get-Content -LiteralPath $importErr -Raw)
if ($importProcess.ExitCode -ne 0 -or $importText -match '(?m)(SCRIPT ERROR:|ERROR:)') {
    throw "Varliklar ice aktarilamadi. Log: $launchCache"
}
$launchInfo = [ordered]@{
    mode = $(if ($NightDemo) { 'night_demo' } else { 'campaign' })
    project = $launchProject
    scene = $scene
    user_data = $userData
    engine = $playEngine
    engine_version = $engineVersion
    logs = $launchCache
}
$infoJson = $launchInfo | ConvertTo-Json
[IO.File]::WriteAllText((Join-Path $launchCache 'launch.json'), $infoJson, (New-Object Text.UTF8Encoding $false))
if ($PrepareOnly) {
    Write-Output $infoJson
    exit 0
}
$playArguments = @('--path', $launchProject, '--windowed')
if ($scene) { $playArguments += $scene }
$quotedPlayArguments = $playArguments | ForEach-Object { '"' + $_ + '"' }
# This is the interactive game, not a background helper.
Start-Process -FilePath $playEngine -ArgumentList $quotedPlayArguments -WindowStyle Normal | Out-Null
