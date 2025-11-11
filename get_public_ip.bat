@echo off
setlocal

echo Retrieving public IP address...

REM Temp file for PowerShell output
set "TMPFILE=%TEMP%\public_ip.txt"
if exist "%TMPFILE%" del "%TMPFILE%" >nul 2>&1

REM Run PowerShell to query multiple public IP services; write first non-empty response to temp file
powershell -NoProfile -WindowStyle Hidden -Command ^
"foreach($u in @('https://api.ipify.org','https://ipinfo.io/ip','https://ifconfig.me')){try{$r = Invoke-RestMethod -Uri $u -TimeoutSec 5; if($r -and $r.ToString().Trim() -ne ''){ $r.ToString().Trim() | Out-File -FilePath '%TMPFILE%' -Encoding ASCII; break }}catch{}} " 2>nul

REM Read result if exists
set "PUBLIC_IP="
if exist "%TMPFILE%" (
    set /p PUBLIC_IP=<"%TMPFILE%"
    del "%TMPFILE%" >nul 2>&1
)

if defined PUBLIC_IP (
    echo.
    echo Public IP: %PUBLIC_IP%
    echo.
    echo Example RDP connect string (if your router forwards port to this machine):
    echo    mstsc /v:%PUBLIC_IP%:3389
) else (
    echo.
    echo Could not determine public IP. Possible reasons:
    echo  - No internet connection
    echo  - PowerShell blocked by policy
    echo  - All public IP services failed or timed out
    echo.
    echo Try running in PowerShell:
    echo  Invoke-RestMethod -Uri 'https://api.ipify.org'
)

pause
endlocal
