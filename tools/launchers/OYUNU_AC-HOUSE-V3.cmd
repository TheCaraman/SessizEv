@echo off
rem Development target: HOUSE-ATMOS-004 / 0.1.2-dev.20261116.3
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0workers\codex-house-atmosphere-v3\tools\Start-Game.ps1" -GodotPath "%~dp0tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe"
if errorlevel 1 pause
