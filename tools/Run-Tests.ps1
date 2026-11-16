param([string]$GodotPath = $env:GODOT_BIN, [int]$TimeoutSeconds = 90)
$ErrorActionPreference = 'Stop'
$project = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not $GodotPath) {
    $local = Join-Path $project '..\tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe'
    if (Test-Path -LiteralPath $local) { $GodotPath = $local }
    else { $GodotPath = (Get-Command godot -ErrorAction Stop).Source }
}
$GodotPath = (Resolve-Path -LiteralPath $GodotPath).Path
$testData = Join-Path ([IO.Path]::GetTempPath()) ('tqh-tests-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testData | Out-Null
$testProject = Join-Path $testData 'project'
# Copy current files, including uncommitted edits, but exclude editor caches and Git.
& robocopy $project $testProject /E /XD .git .godot build tools /XF override.cfg /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw 'Could not create isolated project copy' }
$userDirName = 'TheQuietHours-Tests/' + (Split-Path $testData -Leaf)
$override = "[application]`nconfig/use_custom_user_dir=true`nconfig/custom_user_dir_name=`"$userDirName`"`n"
[IO.File]::WriteAllText((Join-Path $testProject 'override.cfg'), $override, (New-Object Text.UTF8Encoding $false))
function Invoke-GodotCheck([string[]]$Arguments, [string]$Expected = '') {
    $outFile = Join-Path $testData 'stdout.log'
    $errFile = Join-Path $testData 'stderr.log'
    # Start-Process needs explicit quotes around arguments containing spaces.
    $quoted = @($Arguments | ForEach-Object { '"' + $_ + '"' })
    $process = Start-Process -FilePath $GodotPath -ArgumentList $quoted -WindowStyle Hidden -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
    $null = $process.Handle
    if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
        $process.Kill()
        throw "Godot timed out after $TimeoutSeconds seconds"
    }
    $process.WaitForExit()
    $process.Refresh()
    $log = (Get-Content -LiteralPath $outFile -Raw) + (Get-Content -LiteralPath $errFile -Raw)
    if ($process.ExitCode -ne 0 -or $log -match '(?m)(SCRIPT ERROR:|ERROR:|FAIL:)') { throw $log }
    if ($Expected -and -not $log.Contains($Expected)) { throw "Missing result: $Expected`n$log" }
    if ($Expected) { $log -split "`n" | Where-Object { $_ -match 'TEST: PASS' } | Write-Output }
}
Invoke-GodotCheck @('--headless', '--path', $testProject, '--import')
foreach ($test in @('campaign_test', 'menu_test', 'interaction_test', 'house_layout_test', 'player_movement_test')) {
    Invoke-GodotCheck @('--headless', '--path', $testProject, "res://tests/$test.tscn") 'TEST: PASS'
}
Write-Output "All five test suites passed. Logs and project copy: $testData"
Write-Output "Isolated user data: $userDirName (under the platform application-data directory)"
