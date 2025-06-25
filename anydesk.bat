@echo off
setlocal

set PASSWORD=nk0ckhun9

echo [1/3] Downloading AnyDesk MSI...
powershell -Command "Invoke-WebRequest -Uri 'https://download.anydesk.com/AnyDesk.msi' -OutFile '%TEMP%\AnyDesk.msi'"

echo [2/3] Installing AnyDesk silently...
msiexec /i "%TEMP%\AnyDesk.msi" /quiet

registry ===
timeout /t 5 > nul

echo [3/3] Setting unattended access password...

powershell -Command ^
"$p = '%PASSWORD%';" ^
"$bytes = [System.Text.Encoding]::UTF8.GetBytes($p);" ^
"Set-ItemProperty -Path 'HKLM:\SOFTWARE\AnyDesk' -Name 'Password' -Value $bytes"

echo Done!
pause
