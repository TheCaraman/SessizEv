param([string]$GodotPath = $env:GODOT_BIN, [int]$TimeoutSeconds = 90, [string]$AudioDriver = '', [string[]]$SelectedTests, [switch]$KeepProjectCopy)
$ErrorActionPreference = 'Stop'
$tests = @('arrival_scheduler_test', 'arrival_integration_test', 'arrival_validation_test', 'day4_broadcast_test', 'accusation_test', 'day4_closure_test', 'night_witness_test', 'settings_test', 'door_transition_test', 'night_observation_test', 'isolation_test', 'resident_judgment_test', 'day4_review_test', 'save_write_test', 'house_night_events_test', 'room_lighting_test', 'night_watch_test', 'night_state_test', 'night_timeline_test', 'door_audio_test', 'presentation_test', 'power_incident_test', 'shelter_test', 'campaign_test', 'day2_test', 'menu_test', 'day12_integration_test', 'interaction_test', 'house_layout_test', 'porch_test', 'stairs_test', 'player_movement_test')
# Optional subset of the whitelist above. Checked before Godot starts or any
# file is written. "-File" passes "a,b" as one string, so commas also split.
$selectedMode = $PSBoundParameters.ContainsKey('SelectedTests')
if ($selectedMode) {
    $requested = @($SelectedTests | ForEach-Object { "$_" -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
    if ($requested.Count -eq 0) { throw 'SelectedTests is empty; name at least one suite from the whitelist.' }
    $unknown = @($requested | Where-Object { $tests -notcontains $_ })
    if ($unknown.Count -gt 0) { throw "Unknown SelectedTests: $($unknown -join ', '). Allowed: $($tests -join ', ')" }
    $duplicates = @($requested | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
    if ($duplicates.Count -gt 0) { throw "SelectedTests repeats: $($duplicates -join ', ')" }
    # Keep the whitelist order so a subset runs exactly as in the full run.
    $tests = @($tests | Where-Object { $requested -contains $_ })
}
$project = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not $GodotPath) {
    $local = Join-Path $project '..\tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe'
    if (Test-Path -LiteralPath $local) { $GodotPath = $local }
    else { $GodotPath = (Get-Command godot -ErrorAction Stop).Source }
}
$GodotPath = (Resolve-Path -LiteralPath $GodotPath).Path
$testData = Join-Path ([IO.Path]::GetTempPath()) ('tqh-tests-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testData | Out-Null
Write-Output "Logs and project copy: $testData"
$testProject = Join-Path $testData 'project'
# Copy current files, including uncommitted edits, but exclude editor caches and Git.
& robocopy $project $testProject /E /XD .git .godot build tools /XF override.cfg /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw 'Could not create isolated project copy' }
$userDirName = 'TheQuietHours-Tests/' + (Split-Path $testData -Leaf)
$override = "[application]`nconfig/use_custom_user_dir=true`nconfig/custom_user_dir_name=`"$userDirName`"`n"
[IO.File]::WriteAllText((Join-Path $testProject 'override.cfg'), $override, (New-Object Text.UTF8Encoding $false))
function Invoke-GodotCheck([string[]]$Arguments, [string]$Expected = '') {
    $caseName = 'import'
    foreach ($argument in $Arguments) {
        if ($argument -like 'res://tests/*.tscn') { $caseName = [IO.Path]::GetFileNameWithoutExtension($argument) }
    }
    $outFile = Join-Path $testData "$caseName.stdout.log"
    $errFile = Join-Path $testData "$caseName.stderr.log"
    # Start-Process needs explicit quotes around arguments containing spaces.
    $quoted = @($Arguments | ForEach-Object { '"' + $_ + '"' })
    # The stairs suite walks 30 real routes at 60/30 Hz (about 210 seconds).
    # Keep its physical timing intact rather than accelerating the simulation.
    $caseTimeout = if ($caseName -eq 'stairs_test') { [Math]::Max($TimeoutSeconds, 300) } else { $TimeoutSeconds }
    $process = Start-Process -FilePath $GodotPath -ArgumentList $quoted -WindowStyle Hidden -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
    $null = $process.Handle
    if (-not $process.WaitForExit($caseTimeout * 1000)) {
        $process.Kill()
        throw "Godot $caseName timed out after $caseTimeout seconds"
    }
    $process.WaitForExit()
    $process.Refresh()
    $log = (Get-Content -LiteralPath $outFile -Raw) + (Get-Content -LiteralPath $errFile -Raw)
    if ($process.ExitCode -ne 0 -or $log -match '(?m)(SCRIPT ERROR:|ERROR:|FAIL:)') { throw $log }
    if ($log -match 'ObjectDB instances were leaked|Leaked instance:') {
        if ($AudioDriver) { throw "Audio-backed check leaked objects: $caseName`n$log" }
        Write-Warning "Object lifetime warning in $caseName; inspect $errFile. This run does not prove hardware audio cleanup."
    }
    if ($Expected -and -not $log.Contains($Expected)) { throw "Missing result: $Expected`n$log" }
    if ($Expected) { $log -split "`n" | Where-Object { $_ -match 'TEST: PASS' } | Write-Output }
}
Invoke-GodotCheck @('--headless', '--path', $testProject, '--import')
foreach ($test in $tests) {
    $arguments = @('--headless')
    # Godot processes these switches in order: headless sets Dummy, so the
    # explicit audio driver must follow it.
    if ($AudioDriver) { $arguments += @('--audio-driver', $AudioDriver) }
    $arguments += @('--path', $testProject, "res://tests/$test.tscn")
    Invoke-GodotCheck $arguments 'TEST: PASS'
}
if ($AudioDriver) {
    Invoke-GodotCheck @('--headless', '--audio-driver', $AudioDriver, '--path', $testProject, 'res://tests/audio_lifecycle_test.tscn', '--', "--expected-driver=$AudioDriver") 'AUDIO LIFECYCLE TEST: PASS'
}
if ($selectedMode) {
    # Never the full-run wording: a subset is not a full PASS.
    $audioNote = if ($AudioDriver) { " Hardware audio lifecycle ($AudioDriver) also passed; it is not counted in the selected total." } else { ' Hardware audio lifecycle was NOT run.' }
    Write-Output "Selected $($tests.Count) test suites passed: $($tests -join ', '). This is a partial run, not the full suite.$audioNote"
} elseif ($AudioDriver) {
    Write-Output "All $($tests.Count + 1) test suites passed (including hardware audio lifecycle)."
} else {
    Write-Output "All $($tests.Count) core test suites passed. Hardware audio lifecycle was NOT run; pass -AudioDriver WASAPI on Windows."
}
if ($KeepProjectCopy) {
    Write-Output "Project and isolated user data kept: $testData / $userDirName"
} else {
    # Delete only this successfully completed run. Never scan other test folders.
    $runName = Split-Path $testData -Leaf
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
    $expectedRun = [IO.Path]::GetFullPath((Join-Path $tempRoot $runName))
    $expectedProject = [IO.Path]::GetFullPath((Join-Path $expectedRun 'project'))
    $userRoot = [IO.Path]::GetFullPath((Join-Path $env:APPDATA 'TheQuietHours-Tests'))
    $expectedUser = [IO.Path]::GetFullPath((Join-Path $userRoot $runName))
    $actualUser = [IO.Path]::GetFullPath((Join-Path $env:APPDATA $userDirName))
    if ($runName -notmatch '^tqh-tests-[a-f0-9]{32}$' -or
        [IO.Path]::GetFullPath($testData) -ne $expectedRun -or
        [IO.Path]::GetFullPath($testProject) -ne $expectedProject -or
        $actualUser -ne $expectedUser) {
        throw 'Refusing cleanup: resolved paths do not belong to this isolated run.'
    }
    Remove-Item -LiteralPath $expectedProject -Recurse -Force -ErrorAction Stop
    if (Test-Path -LiteralPath $expectedUser) {
        Remove-Item -LiteralPath $expectedUser -Recurse -Force -ErrorAction Stop
    }
    Write-Output "Logs kept: $testData; this run's verified project/user directories removed. Use -KeepProjectCopy for native review."
}
