@echo off
echo Starting AnyDesk...
start "" "C:\Program Files (x86)\AnyDesk\AnyDesk.exe"
timeout /t 2 > nul

echo Retrieving AnyDesk ID...
FOR /F "tokens=3*" %%A IN ('reg query "HKLM\SOFTWARE\AnyDesk" /v Alias 2^>nul') DO (
    echo Your AnyDesk ID is: %%A
)
pause
