@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

pushd "%TEMP%"

:: determine the version of windows since dism in windows 7 lacks cleanup-image
:: http://stackoverflow.com/questions/13212033/get-windows-version-in-a-batch-file
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j

if "%VERSION%" == "6.1" (
    echo ==^> Running Disk Cleanup
    C:\Windows\System32\cleanmgr.exe /sagerun:10﻿
) else (
    echo ==^> Running DISM to remove old components
    Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
)

echo ==^> Cleaning up old Windows Update files
    for /d %%i in ("%SystemRoot%\SoftwareDistribution\Download\*.*") do rmdir /q /s "%%~i"

echo ==^> Cleaning "%TEMP%" directories >&2

for /d %%i in ("%TEMP%\*.*") do rmdir /q /s "%%~i"

echo ==^> Cleaning "%TEMP%" files >&2

for %%i in ("%TEMP%\*.*") do if /i not "%%~nxi" equ "%~nx0" echo del /f /q /s "%%~i"

echo ==^> Cleaning "%SystemRoot%\TEMP" directories >&2

for /d %%i in ("%SystemRoot%\TEMP\*.*") do rmdir /q /s "%%~i"

echo ==^> Cleaning "%SystemRoot%\TEMP" files >&2

for %%i in ("%SystemRoot%\TEMP\*.*") do if /i not "%%~nxi" equ "%~nx0" echo del /f /q /s "%%~i"

echo ==^> Removing potentially corrupt recycle bin
:: see http://www.winhelponline.com/blog/fix-corrupted-recycle-bin-windows-7-vista/
rmdir /q /s %SystemDrive%\$Recycle.bin

echo ==^> Cleaning ISOs in "%USERPROFILE%"

for %%i in (VBoxGuestAdditions.iso windows.iso) do if exist "%USERPROFILE%\%%~i" del /f "%USERPROFILE%\%%~i"

:exit0

@ping 127.0.0.1
@ver>nul

@goto :exit

:exit1

@ping 127.0.0.1
@verify other 2>nul

:exit

@echo ==^> Script exiting with errorlevel %ERRORLEVEL%
@exit /b %ERRORLEVEL%
