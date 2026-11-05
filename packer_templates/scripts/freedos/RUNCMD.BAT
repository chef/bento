@ECHO OFF
REM ===========================================================================
REM Bento FreeDOS Command Wrapper (RUNCMD.BAT)
REM Usage: C:\BENTO\RUNCMD.BAT <REQ_ID> <COMMAND...>
REM Executes the target command or batch file and prints deterministic framing
REM markers with the resulting %ERRORLEVEL%.
REM ===========================================================================

SET BENTO_REQ=%1
SHIFT
ECHO ===START_%BENTO_REQ%===
%1 %2 %3 %4 %5 %6 %7 %8 %9
ECHO ===EXIT_%BENTO_REQ%:%ERRORLEVEL%===
SET BENTO_REQ=
