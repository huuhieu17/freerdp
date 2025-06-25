@echo off
setlocal

set PASSWORD=nk0ckhun9

echo [1/3] Downloading AnyDesk EXE...
powershell -Command "Invoke-WebRequest -Uri 'https://download.anydesk.com/AnyDesk.exe' -OutFile '%TEMP%\AnyDesk.exe'"

echo [2/3] Installing AnyDesk...
"%TEMP%\AnyDesk.exe" /install

timeout /t 5 > nul

echo [3/3] Setting unattended access password...
powershell -Command "$p = '%PASSWORD%'; $bytes = [System.Text.Encoding]::UTF8.GetBytes($p); Set-ItemProperty -Path 'HKLM:\SOFTWARE\AnyDesk' -Name 'Password' -Value $bytes"

FOR /F "tokens=3*" %%A IN ('reg query "HKLM\SOFTWARE\AnyDesk" /v Alias 2^>nul') DO (
    echo Your AnyDesk ID is: %%A
)

echo Done!
pause
