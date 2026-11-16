@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Start-Game.ps1" -NightDemo
if errorlevel 1 pause
