@echo off
rem Development target: HOUSE-ATMOS-004 / isolated night demo
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0workers\codex-house-atmosphere-v3\tools\Start-Game.ps1" -GodotPath "%~dp0tools\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe" -NightDemo
if errorlevel 1 pause
