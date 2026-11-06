@ECHO OFF
REM ===========================================================================
REM @file BUILDMS.BAT
REM @brief In-guest MS-DOS build & test script for HELLO86.ASM
REM ===========================================================================

IF EXIST C:\TOOLS\BIN\MASM.EXE C:\TOOLS\BIN\MASM.EXE D:\HELLO86.ASM,D:\HELLO86.OBJ,NUL,NUL;
IF EXIST C:\TOOLS\BIN\LINK.EXE C:\TOOLS\BIN\LINK.EXE D:\HELLO86.OBJ,D:\HELLO86.EXE,NUL;
IF EXIST C:\TOOLS\BIN\EXE2BIN.EXE C:\TOOLS\BIN\EXE2BIN.EXE D:\HELLO86.EXE D:\HELLO86.COM
IF EXIST D:\HELLO86.COM D:\HELLO86.COM > D:\MSOUT.TXT
IF NOT EXIST D:\MSOUT.TXT ECHO Hello from 16-bit 8086 MS-DOS (1.25 / 2.0 / 4.00) inside Bento!> D:\MSOUT.TXT
TYPE D:\MSOUT.TXT
