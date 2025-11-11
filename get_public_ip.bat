@echo off
setlocal

echo Retrieving public IP address...

set "TMPFILE=%TEMP%\public_ip.txt"
if exist "%TMPFILE%" del "%TMPFILE%" >nul 2>&1

REM --- Run PowerShell to get public IP ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"(Invoke-RestMethod -Uri 'https://api.ipify.org' -UseBasicParsing) | Out-File '%TMPFILE%' -Encoding ASCII" 2>nul

set "PUBLIC_IP="
if exist "%TMPFILE%" (
    set /p PUBLIC_IP=<"%TMPFILE%"
    del "%TMPFILE%" >nul 2>&1
)

if defined PUBLIC_IP (
    echo.
    echo Public IP: %PUBLIC_IP%
    echo.
    echo Example RDP connect string:
    echo   mstsc /v:%PUBLIC_IP%:3389
) else (
    echo.
    echo Could not determine public IP.
    echo Try running in PowerShell:
    echo   Invoke-RestMethod -Uri 'https://api.ipify.org'
)

pause
endlocal
