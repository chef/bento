ECHO OFF
REM ===========================================================================
REM Bento MS-DOS Serial/Telnet Guest Agent (VAGAGENT.BAT)
REM Compatible with MS-DOS 1.25, 2.0, and 4.00.
REM Redirects console I/O to COM1 so Vagrant and Packer can execute DOS
REM commands, capture stdout/stderr and %ERRORLEVEL%, and transfer files.
REM ===========================================================================

SERINIT.COM
CTTY COM1
ECHO ===BENTO_MSDOS_READY===


