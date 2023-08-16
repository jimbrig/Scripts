TITLE Services Start State Backup Script by Tech Journey
@echo off
@echo ================================================================
@echo Windows Services Start State Backup Script (C) 2008 Tech Journey
@echo ================================================================
@echo.
@echo This script will backup all services with current state of Startup Type
@echo.
pause

REM Get current date and time
for /f "tokens=1, 2, 3, 4 delims=-/. " %%j in ('Date /T') do set FILENAME=Services_%%j_%%k_%%l_%%m
for /f "tokens=1, 2 delims=: " %%j in ('TIME /T') do set FILENAME=%FILENAME%_%%j_%%k.bat

REM Get all service name
sc query type= service state= all| findstr /r /C:"SERVICE_NAME:" >tmpsrv.txt
echo Saving Service Start State In %FILENAME% ...

REM save service start state into batch file
echo @echo Restore The Service Start State Saved At %TIME% %DATE% >"%FILENAME%"
echo @pause >>"%FILENAME%"

for /f "tokens=2 delims=:" %%j in (tmpsrv.txt) do @( sc qc %%j |findstr START_TYPE >tmpstype.txt && for /f "tokens=4 delims=:_ " %%s in (tmpstype.txt) do @echo sc config %%j start= %%s >>"%FILENAME%")
echo @pause >>"%FILENAME%"

del tmpsrv.txt
del tmpstype.txt

echo Services Start State Saved in %FILENAME%.
pause
