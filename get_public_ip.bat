@echo off
setlocal enabledelayedexpansion

echo Retrieving public IP address...
REM Try multiple public IP services via PowerShell; take the first non-empty response
for /f "usebackq delims=" %%A in (`powershell -NoProfile -WindowStyle Hidden -Command ^
    " $urls = @('https://api.ipify.org','https://ipinfo.io/ip','https://ifconfig.me'); ^
      foreach($u in $urls){ try { $r = Invoke-RestMethod -Uri $u -UseBasicParsing -TimeoutSec 5; if($r -and $r.Trim() -ne ''){ Write-Output $r.Trim(); break } } catch { } } " 2^>nul`) do (
    set "PUBLIC_IP=%%A"
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
    echo  - PowerShell restricted or blocked
    echo  - All public IP services failed or timed out
    echo.
    echo You can try running this command manually in PowerShell:
    echo  Invoke-RestMethod -Uri 'https://api.ipify.org'
)

pause
endlocal
