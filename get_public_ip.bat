@echo off
setlocal

echo Retrieving public IP address...

set "TMPFILE=%TEMP%\public_ip.txt"
if exist "%TMPFILE%" del "%TMPFILE%" >nul 2>&1

REM Use Invoke-WebRequest and redirect output to ASCII file
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "(Invoke-WebRequest https://api.ipify.org -UseBasicParsing).Content | Out-File -FilePath '%TMPFILE%' -Encoding ascii" 2>nul

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
    echo   (Invoke-WebRequest https://api.ipify.org -UseBasicParsing).Content
)

pause
endlocal
