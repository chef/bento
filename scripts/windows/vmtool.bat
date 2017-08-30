@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (a:\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

if not defined PACKER_SEARCH_PATHS set PACKER_SEARCH_PATHS="%USERPROFILE%" a: b: c: d: e: f: g: h: i: j: k: l: m: n: o: p: q: r: s: t: u: v: w: x: y: z:
if not defined SEVENZIP_32_URL set SEVENZIP_32_URL=http://7-zip.org/a/7z1604.msi
if not defined SEVENZIP_64_URL set SEVENZIP_64_URL=http://7-zip.org/a/7z1604-x64.msi
if not defined VBOX_ISO_URL set VBOX_ISO_URL=http://download.virtualbox.org/virtualbox/5.1.22/VBoxGuestAdditions_5.1.22.iso
if not defined VMWARE_TOOLS_TAR_URL set VMWARE_TOOLS_TAR_URL=https://softwareupdate.vmware.com/cds/vmw-desktop/ws/12.5.5/5234757/windows/packages/tools-windows.tar
goto main

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
echo "%PACKER_BUILDER_TYPE%" | findstr /i "vmware" >nul
if not errorlevel 1 goto vmware
echo "%PACKER_BUILDER_TYPE%" | findstr /i "virtualbox" >nul
if not errorlevel 1 goto virtualbox
echo "%PACKER_BUILDER_TYPE%" | findstr /i "parallels" >nul
if not errorlevel 1 goto parallels
echo ==^> ERROR: Unknown PACKER_BUILDER_TYPE: "%PACKER_BUILDER_TYPE%"
pushd .
goto exit1

::::::::::::
:vmware
::::::::::::
if defined ProgramFiles(x86) (
  set VMWARE_TOOLS_SETUP_EXE=setup64.exe
) else (
  set VMWARE_TOOLS_SETUP_EXE=setup.exe
)
for %%i in ("%VMWARE_TOOLS_TAR_URL%") do set VMWARE_TOOLS_TAR=%%~nxi
set VMWARE_TOOLS_DIR=%TEMP%\vmware
set VMWARE_TOOLS_TAR_PATH=%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_TAR%
set VMWARE_TOOLS_ISO=windows.iso
mkdir "%VMWARE_TOOLS_DIR%"
pushd "%VMWARE_TOOLS_DIR%"
set VMWARE_TOOLS_SETUP_PATH=
:vmware_tools_setup_path_search
@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined VMWARE_TOOLS_SETUP_PATH @if exist "%%~i\VMwareToolsUpgrader.exe" set VMWARE_TOOLS_SETUP_PATH=%%~i\%VMWARE_TOOLS_SETUP_EXE%
if defined VMWARE_TOOLS_SETUP_PATH goto install_vmware_tools
:: vmware_tools_setup_path_search isn't defined
:: if not defined VMWARE_TOOLS_SETUP_PATH ( if defined VMWARE_TOOLS_MOUNTED goto vmware_tools_setup_path_search )
set VMWARE_TOOLS_ISO_PATH=
@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined VMWARE_TOOLS_ISO_PATH @if exist "%%~i\%VMWARE_TOOLS_ISO%" set VMWARE_TOOLS_ISO_PATH=%%~i\%VMWARE_TOOLS_ISO%

:: if windows.iso is zero bytes, then download it
set _VMWARE_TOOLS_SIZE=0
if defined VMWARE_TOOLS_ISO_PATH for %%i in (%VMWARE_TOOLS_ISO_PATH%) do set _VMWARE_TOOLS_SIZE=%%~zi
if %_VMWARE_TOOLS_SIZE% EQU 0 set VMWARE_TOOLS_ISO_PATH=

if defined VMWARE_TOOLS_ISO_PATH goto install_vmware_tools_from_iso
if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%VMWARE_TOOLS_TAR_URL%" "%VMWARE_TOOLS_TAR_PATH%"
) else (
  echo ==^> Downloading "%VMWARE_TOOLS_TAR_URL%" to "%VMWARE_TOOLS_TAR_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%VMWARE_TOOLS_TAR_URL%', '%VMWARE_TOOLS_TAR_PATH%')" <NUL
)
if not exist "%VMWARE_TOOLS_TAR_PATH%" goto exit1
call :install_sevenzip
if errorlevel 1 goto exit1
7z e -y -o"%VMWARE_TOOLS_DIR%" "%VMWARE_TOOLS_TAR_PATH%" *tools-windows*
if exist  "%VMWARE_TOOLS_DIR%\*.iso" (
	ren  "%VMWARE_TOOLS_DIR%\*.iso" "windows.iso"
	set VMWARE_TOOLS_ISO_PATH=%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_ISO%
)
if defined VMWARE_TOOLS_ISO_PATH goto install_vmware_tools_from_iso
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: 7z e "%VMWARE_TOOLS_TAR_PATH%"
ver>nul
set VMWARE_TOOLS_INSTALLER_PATH=
for %%i in ("%VMWARE_TOOLS_DIR%\tools-windows-*.exe") do set VMWARE_TOOLS_INSTALLER_PATH=%%~i
if not exist "%VMWARE_TOOLS_INSTALLER_PATH%" echo ==^> ERROR: Failed to unzip "%VMWARE_TOOLS_TAR_PATH%" & goto exit1
"%VMWARE_TOOLS_INSTALLER_PATH%" /s
set VMWARE_TOOLS_PROGRAM_FILES_DIR=%ProgramFiles%\VMware
if defined ProgramFiles(x86) set VMWARE_TOOLS_PROGRAM_FILES_DIR=%ProgramFiles(x86)%\VMware
if not exist "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" echo ==^> ERROR: Directory not found: "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" & goto exit1
set VMWARE_TOOLS_PROGRAM_FILES_ISO=
for /r "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" %%i in (%VMWARE_TOOLS_ISO%) do if exist "%%~i" set VMWARE_TOOLS_PROGRAM_FILES_ISO=%%~i
if not exist "%VMWARE_TOOLS_PROGRAM_FILES_ISO%" echo ==^> ERROR: File not found: "%VMWARE_TOOLS_ISO%" in "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" & goto exit1
set VMWARE_TOOLS_ISO_PATH="%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_ISO%"
copy /y "%VMWARE_TOOLS_PROGRAM_FILES_ISO%" "%VMWARE_TOOLS_ISO_PATH%"
if not exist "%VMWARE_TOOLS_ISO_PATH%" echo ==^> ERROR: File not found: "%VMWARE_TOOLS_ISO_PATH%" & goto exit1
rmdir /q /s "%VMWARE_TOOLS_PROGRAM_FILES_DIR%\tools-windows" || ver>nul
rmdir "%VMWARE_TOOLS_PROGRAM_FILES_DIR%" || ver>nul

:install_vmware_tools_from_iso
call :install_sevenzip
if errorlevel 1 goto exit1
echo ==^> Extracting the VMWare Tools installer
7z e -o"%VMWARE_TOOLS_DIR%" "%VMWARE_TOOLS_ISO_PATH%" "%VMWARE_TOOLS_SETUP_EXE%"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: 7z e -o"%VMWARE_TOOLS_DIR%" "%VMWARE_TOOLS_ISO_PATH%" "%VMWARE_TOOLS_SETUP_EXE%"
ver>nul
set VMWARE_TOOLS_SETUP_PATH=%VMWARE_TOOLS_DIR%\%VMWARE_TOOLS_SETUP_EXE%
if not exist "%VMWARE_TOOLS_SETUP_PATH%" echo ==^> Unable to unzip "%VMWARE_TOOLS_ISO_PATH%" & goto exit1

:install_vmware_tools
echo ==^> Installing VMware tools
"%VMWARE_TOOLS_SETUP_PATH%" /S /v "/qn REBOOT=R ADDLOCAL=ALL"
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%VMWARE_TOOLS_SETUP_PATH%" /S /v "/qn REBOOT=R ADDLOCAL=ALL"
ver>nul
goto exit0

::::::::::::
:virtualbox
::::::::::::
if exist "%SystemDrive%\Program Files (x86)" (
  set VBOX_SETUP_EXE=VBoxWindowsAdditions-amd64.exe
) else (
  set VBOX_SETUP_EXE=VBoxWindowsAdditions-x86.exe
)
for %%i in ("%VBOX_ISO_URL%") do set VBOX_ISO=%%~nxi
set VBOX_ISO_DIR=%TEMP%\virtualbox
set VBOX_ISO_PATH=%VBOX_ISO_DIR%\%VBOX_ISO%
set VBOX_ISO=VBoxGuestAdditions.iso
mkdir "%VBOX_ISO_DIR%"
pushd "%VBOX_ISO_DIR%"
set VBOX_SETUP_PATH=
@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined VBOX_SETUP_PATH @if exist "%%~i\%VBOX_SETUP_EXE%" set VBOX_SETUP_PATH=%%~i\%VBOX_SETUP_EXE%
if defined VBOX_SETUP_PATH goto install_vbox_guest_additions

@for %%i in (%PACKER_SEARCH_PATHS%) do @if exist "%%~i\%VBOX_ISO%" set VBOX_ISO_PATH=%%~i\%VBOX_ISO%

:: if VBoxGuestAdditions.iso is zero bytes, then download it
set _VBOX_ISO_SIZE=0
if exist "%VBOX_ISO_PATH%" for %%i in (%VBOX_ISO_PATH%) do set _VBOX_ISO_SIZE=%%~zi
if %_VBOX_ISO_SIZE% GTR 0 goto install_vbox_guest_additions_from_iso

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%VBOX_ISO_URL%" "%VBOX_ISO_PATH%"
) else (
  echo ==^> Downloading "%VBOX_ISO_URL%" to "%VBOX_ISO_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%VBOX_ISO_URL%', '%VBOX_ISO_PATH%')" <NUL
)
if not exist "%VBOX_ISO_PATH%" goto exit1

:install_vbox_guest_additions_from_iso
call :install_sevenzip
if errorlevel 1 goto exit1
echo ==^> Extracting the VirtualBox Guest Additions installer
7z x -o"%VBOX_ISO_DIR%" "%VBOX_ISO_PATH%" "%VBOX_SETUP_EXE%" cert
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: 7z e -o"%VBOX_ISO_DIR%" "%VBOX_ISO_PATH%" "%VBOX_SETUP_EXE%"
ver>nul
set VBOX_SETUP_PATH=%VBOX_ISO_DIR%\%VBOX_SETUP_EXE%
if not exist "%VBOX_SETUP_PATH%" echo ==^> Unable to unzip "%VBOX_ISO_PATH%" & goto exit1

:install_vbox_guest_additions
echo ==^> Installing Oracle certificate to keep install silent
powershell -Command "Get-ChildItem %VBOX_ISO_DIR%\cert\ -Filter vbox*.cer | ForEach-Object { %VBOX_ISO_DIR%\cert\VBoxCertUtil.exe add-trusted-publisher $_.FullName --root $_.FullName }" <NUL
echo ==^> Installing VirtualBox Guest Additions
"%VBOX_SETUP_PATH%" /S
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%VBOX_SETUP_PATH%" /S
ver>nul
goto :exit0

::::::::::::
:parallels
::::::::::::
set PARALLELS_INSTALL=PTAgent.exe

set PARALLELS_DIR=%TEMP%\parallels
set PARALLELS_PATH=%PARALLELS_DIR%\%PARALLELS_INSTALL%
set PARALLELS_ISO=prl-tools-win.iso
mkdir "%PARALLELS_DIR%"
pushd "%PARALLELS_DIR%"
set PARALLELS_ISO_PATH=
@for %%i in (%PACKER_SEARCH_PATHS%) do @if not defined PARALLELS_ISO_PATH @if exist "%%~i\%PARALLELS_ISO%" set PARALLELS_ISO_PATH=%%~i\%PARALLELS_ISO%
REM parallels tools don't have a download :(
call :install_sevenzip
if errorlevel 1 goto exit1
echo ==^> Extracting the Parallels Tools installer
echo ==^>   to %PARALLELS_DIR%\*
7z x -o"%PARALLELS_DIR%" "%PARALLELS_ISO_PATH%"
ping 127.0.0.1
echo ==^> Installing Parallels Tools
echo ==^>   from %PARALLELS_PATH%
"%PARALLELS_PATH%" /install_silent
REM parallels tools installer tends to exit while the install agent
REM is still running, need to sleep while it's running so we don't
REM delete the tools.
@if errorlevel 1 echo=^> WARNING: Error %ERRORLEVEL% was returned by: "%PARALLELS_PATH%" /install_silent
ver>nul
echo ==^> Cleaning up Parallels Tools install
del /F /S /Q "%PARALLELS_DIR"
echo ==^> Removing "%PARALLELS_ISO_PATH"
del /F "%PARALLELS_ISO_PATH"
goto :exit0

:exit0
@ver>nul
@goto :exit

:exit1
@verify other 2>nul
@goto :exit

:exit
@set _ERRORLEVEL=%ERRORLEVEL%
@echo ==^> Script exiting with errorlevel %_ERRORLEVEL%
@popd
@ping 127.0.0.1

@if %_ERRORLEVEL% gtr 0 (@call :error) else (@call :pause)
@goto :_exit

:error
@if not defined PACKER_PAUSE_ON_ERROR goto :eof
@echo Packer paused. Press Ctrl-C to abort:
@pause
@goto :eof

:pause
@if PACKER_PAUSE leq 0 goto :eof
@set _TEMPNAME=%TEMP%\%~nx0-%RANDOM%.tmp
@for /L %%i in (1,1,%PACKER_PAUSE%) do @call :pause1 %%i
@del "%_TEMPNAME%"
@goto :eof

:pause1
@echo.|time|findstr /R /C:": [0-9]">%_TEMPNAME%
@for /F "tokens=5* " %%a in (%_TEMPNAME%) do @echo %%a: Waiting %1 of %PACKER_PAUSE% seconds...
@choice /C Y /N /T 1 /D Y /M " " >NUL
@goto :eof

:_exit
@exit /b %_ERRORLEVEL%
