@echo off
setlocal

set PASSWORD=nk0ckhun9

echo [1/3] Downloading AnyDesk...
powershell -Command "Invoke-WebRequest -Uri 'https://download.anydesk.com/AnyDesk.exe' -OutFile '%TEMP%\AnyDesk.exe'"

echo [2/3] Installing AnyDesk silently...
"%TEMP%\AnyDesk.exe" /install /silent

registry ===
timeout /t 5 > nul

echo [3/3] Setting unattended access password...

powershell -Command ^
"$p = '%PASSWORD%';" ^
"$bytes = [System.Text.Encoding]::UTF8.GetBytes($p);" ^
"Set-ItemProperty -Path 'HKLM:\SOFTWARE\AnyDesk' -Name 'Password' -Value $bytes"

echo Done!
pause
