@ECHO OFF
REM ===========================================================================
REM OpenWatcom v2 DOS Build & Verification Script for FreeDOS (D:\BUILD.BAT)
REM ===========================================================================

IF EXIST C:\WATCOM\BINW\WCL.EXE C:\WATCOM\BINW\WCL.EXE -q -bcl=dos -fe=D:\HELLO16.EXE D:\HELLO16.C
IF EXIST C:\WATCOM\BINW\WCL386.EXE C:\WATCOM\BINW\WCL386.EXE -q -bcl=dos4g -fe=D:\HELLO32.EXE D:\HELLO32.C

IF EXIST D:\HELLO16.EXE D:\HELLO16.EXE > D:\OUT16.TXT
IF EXIST D:\HELLO32.EXE C:\BENTO\DOS4GW.EXE D:\HELLO32.EXE > D:\OUT32.TXT
