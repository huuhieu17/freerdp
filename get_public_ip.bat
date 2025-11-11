@echo off
setlocal

REM File to save JSON
set "JSONFILE=%TEMP%\public_ip.json"
if exist "%JSONFILE%" del "%JSONFILE%" >nul 2>&1

REM --- Run PowerShell as a single line ---
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command " $ip = Invoke-RestMethod 'https://api.ipify.org'; @{ip=$ip} | ConvertTo-Json | Out-File '%JSONFILE%' -Encoding UTF8 "

REM Display the JSON
if exist "%JSONFILE%" (
    echo Public IP JSON:
    type "%JSONFILE%"
) else (
    echo Failed to retrieve public IP.
)

pause
endlocal
