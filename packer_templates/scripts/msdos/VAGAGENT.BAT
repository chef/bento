@ECHO OFF
REM ===========================================================================
REM Bento MS-DOS Serial/Telnet Guest Agent (VAGAGENT.BAT)
REM Compatible with MS-DOS 1.25, 2.0, and 4.00.
REM Redirects console I/O to COM1 so Vagrant and Packer can execute DOS
REM commands, capture stdout/stderr and %ERRORLEVEL%, and transfer files.
REM ===========================================================================

IF EXIST C:\BENTO\SERINIT.COM C:\BENTO\SERINIT.COM
IF EXIST C:\SERINIT.COM C:\SERINIT.COM
CTTY COM1
ECHO.
ECHO ===BENTO_MSDOS_READY===
ECHO ===BENTO_FREEDOS_READY===
CD \

