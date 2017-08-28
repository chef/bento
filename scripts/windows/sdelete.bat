@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined SDELETE_URL set SDELETE_URL=http://web.archive.org/web/20160404120859if_/http://live.sysinternals.com/sdelete.exe

for %%i in ("%SDELETE_URL%") do set SDELETE_EXE=%%~nxi
set SDELETE_DIR=%TEMP%\sdelete
set SDELETE_PATH=%SDELETE_DIR%\%SDELETE_EXE%

echo ==^> Creating "%SDELETE_DIR%"
mkdir "%SDELETE_DIR%"
pushd "%SDELETE_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%SDELETE_URL%" "%SDELETE_PATH%"
) else (
  echo ==^> Downloading "%SDELETE_URL%" to "%SDELETE_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%SDELETE_URL%', '%SDELETE_PATH%')" <NUL
)
if not exist "%SDELETE_PATH%" goto exit1

reg add HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f

echo ==^> Running SDelete on %SystemDrive%
"%SDELETE_PATH%" -z %SystemDrive%

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%SDELETE_PATH%" -z %SystemDrive%
ver>nul

popd

echo ==^> Removing "%SDELETE_DIR%"
rmdir /q /s "%SDELETE_DIR%"

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
