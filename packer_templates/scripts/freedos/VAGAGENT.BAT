@ECHO OFF
REM ===========================================================================
REM Bento FreeDOS Serial/Telnet Guest Agent (VAGAGENT.BAT)
REM Redirects console I/O to COM1 so Vagrant and Packer can execute DOS
REM commands, capture stdout/stderr and %ERRORLEVEL%, and transfer files.
REM ===========================================================================

IF EXIST C:\BENTO\SERINIT.COM C:\BENTO\SERINIT.COM
CTTY COM1
ECHO.
ECHO ===BENTO_FREEDOS_READY===
CD C:\
