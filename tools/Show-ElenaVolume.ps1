param([string]$GodotPath = 'E:\TheQuietHours\tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference='Stop'
$source=Split-Path $PSScriptRoot -Parent
$run=Join-Path $env:TEMP ('tqh-elena-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $run | Out-Null
& robocopy $source $run /E /XD .git .godot source_art tools docs /XF override.cfg /NFL /NDL /NJH /NJS /NP | Out-Null
if($LASTEXITCODE -ge 8){throw 'Preview copy failed'}
$settings="[application]`nconfig/use_custom_user_dir=true`nconfig/custom_user_dir_name=`"TheQuietHours-Tests/$(Split-Path $run -Leaf)`"`n"
[IO.File]::WriteAllText((Join-Path $run 'override.cfg'),$settings)
& $GodotPath --headless --path $run --import *> (Join-Path $run 'import.log')
if($LASTEXITCODE -ne 0){throw "Import failed; inspect $run"}
$gui=$GodotPath.Replace('_console.exe','.exe')
# Interactive model review requested by the owner.
Start-Process -FilePath $gui -ArgumentList @('--path',('"'+$run+'"'),'--resolution','1280x960','res://scenes/dev/elena_volume_review.tscn') -WindowStyle Normal
Write-Output "Isolated Elena model review: $run"
