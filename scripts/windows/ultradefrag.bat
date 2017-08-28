@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined PACKER_SEARCH_PATHS set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:

if not defined SEVENZIP_32_URL set SEVENZIP_32_URL=http://7-zip.org/a/7z1604.msi
if not defined SEVENZIP_64_URL set SEVENZIP_64_URL=http://www.7-zip.org/a/7z1604-x64.msi

if not defined ULTRADEFRAG_32_URL set ULTRADEFRAG_32_URL=http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-7.0.2.bin.i386.zip
if not defined ULTRADEFRAG_64_URL set ULTRADEFRAG_64_URL=http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-7.0.2.bin.amd64.zip

goto :main

::::::::::::
:install_sevenzip
::::::::::::

if defined ProgramFiles(x86) (
  set SEVENZIP_URL=%SEVENZIP_64_URL%
) else (
  set SEVENZIP_URL=%SEVENZIP_32_URL%
)

pushd .

set SEVENZIP_EXE=
set SEVENZIP_DLL=
for %%i in (7z.exe) do set SEVENZIP_EXE=%%~$PATH:i
if defined SEVENZIP_EXE goto return0

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined SEVENZIP_EXE @if exist "%%~i\7z.exe" set SEVENZIP_EXE=%%~i\7z.exe

if not defined SEVENZIP_EXE goto get_sevenzip

@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined SEVENZIP_DLL @if exist "%%~i\7z.dll" set SEVENZIP_DLL=%%~i\7z.dll

if not defined SEVENZIP_DLL goto get_sevenzip

ver >nul
call :copy_sevenzip
if not errorlevel 1 goto return0

:get_sevenzip

for %%i in ("%SEVENZIP_URL%") do set SEVENZIP_MSI=%%~nxi
set SEVENZIP_DIR=%TEMP%\sevenzip
set SEVENZIP_PATH=%SEVENZIP_DIR%\%SEVENZIP_MSI%

echo ==^> Creating "%SEVENZIP_DIR%"
mkdir "%SEVENZIP_DIR%"
cd /d "%SEVENZIP_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%SEVENZIP_URL%" "%SEVENZIP_PATH%"
) else (
  echo ==^> Downloading "%SEVENZIP_URL%" to "%SEVENZIP_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%SEVENZIP_URL%', '%SEVENZIP_PATH%')" <NUL
)
if not exist "%SEVENZIP_PATH%" goto return1

echo ==^> Installing "%SEVENZIP_PATH%"
msiexec /qb /i "%SEVENZIP_PATH%"

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: msiexec /qb /i "%SEVENZIP_PATH%"
ver>nul

set SEVENZIP_INSTALL_DIR=

for %%i in ("%ProgramFiles%" "%ProgramW6432%" "%ProgramFiles(x86)%") do if exist "%%~i\7-Zip" set SEVENZIP_INSTALL_DIR=%%~i\7-Zip

if exist "%SEVENZIP_INSTALL_DIR%" cd /D "%SEVENZIP_INSTALL_DIR%" & goto find_sevenzip

echo ==^> ERROR: Directory not found: "%ProgramFiles%\7-Zip"

goto return1

:find_sevenzip

set SEVENZIP_EXE=

for /r %%i in (7z.exe) do if exist "%%~i" set SEVENZIP_EXE=%%~i

if not exist "%SEVENZIP_EXE%" echo ==^> ERROR: Failed to unzip "%SEVENZIP_PATH%" & goto return1

set SEVENZIP_DLL=

for /r %%i in (7z.dll) do if exist "%%~i" set SEVENZIP_DLL=%%~i

if not exist "%SEVENZIP_DLL%" echo ==^> ERROR: Failed to unzip "%SEVENZIP_PATH%" & goto return1

:copy_sevenzip

echo ==^> Copying "%SEVENZIP_EXE%" to "%SystemRoot%"
copy /y "%SEVENZIP_EXE%" "%SystemRoot%\" || goto return1
copy /y "%SEVENZIP_DLL%" "%SystemRoot%\" || goto return1

:return0

popd
ver>nul

goto return

:return1

popd
verify other 2>nul

:return

goto :eof

::::::::::::
:main
::::::::::::

if defined ProgramFiles(x86) (
  set ULTRADEFRAG_URL=%ULTRADEFRAG_64_URL%
) else (
  set ULTRADEFRAG_URL=%ULTRADEFRAG_32_URL%
)

for %%i in ("%ULTRADEFRAG_URL%") do set ULTRADEFRAG_ZIP=%%~nxi
set ULTRADEFRAG_DIR=%TEMP%\ultradefrag
set ULTRADEFRAG_PATH=%ULTRADEFRAG_DIR%\%ULTRADEFRAG_ZIP%

echo ==^> Creating "%ULTRADEFRAG_DIR%"
mkdir "%ULTRADEFRAG_DIR%"
pushd "%ULTRADEFRAG_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%ULTRADEFRAG_URL%" "%ULTRADEFRAG_PATH%"
) else (
  echo ==^> Downloading "%ULTRADEFRAG_URL%" to "%ULTRADEFRAG_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%ULTRADEFRAG_URL%', '%ULTRADEFRAG_PATH%')" <NUL
)
if not exist "%ULTRADEFRAG_PATH%" goto exit1

call :install_sevenzip
if errorlevel 1 goto exit1

echo ==^> Unzipping "%ULTRADEFRAG_PATH%" to "%ULTRADEFRAG_DIR%"
7z e -y -o"%ULTRADEFRAG_DIR%" "%ULTRADEFRAG_PATH%" *\udefrag.exe *\*.dll

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: 7z e -o"%ULTRADEFRAG_DIR%" "%ULTRADEFRAG_PATH%"
ver>nul

for /r %%i in (udefrag.exe) do if exist "%%~i" set ULTRADEFRAG_EXE=%%~i

if not exist "%ULTRADEFRAG_EXE%" echo ==^> ERROR: File not found: udefrag.exe in "%ULTRADEFRAG_DIR%" & goto exit1

echo ==^> Running UltraDefrag on %SystemDrive%
"%ULTRADEFRAG_EXE%" --optimize --repeat %SystemDrive%

@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%ULTRADEFRAG_EXE%" --optimize --repeat %SystemDrive%
ver>nul

popd

echo ==^> Removing "%ULTRADEFRAG_DIR%"
rmdir /q /s "%ULTRADEFRAG_DIR%"

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
