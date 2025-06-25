@echo off
setlocal

set "PASSWORD=nk0ckhun9"

echo [1/4] Downloading AnyDesk...
powershell -Command "Invoke-WebRequest -Uri 'https://download.anydesk.com/AnyDesk.exe' -OutFile '%TEMP%\AnyDesk.exe'"

echo [2/4] Installing AnyDesk silently...
"%TEMP%\AnyDesk.exe" --install "C:\Program Files (x86)\AnyDesk" --silent

timeout /t 5 > nul

echo [3/4] Setting password...
echo %PASSWORD% | "C:\Program Files (x86)\AnyDesk\AnyDesk.exe" --set-password

echo [4/4] Checking installation...

if exist "C:\Program Files (x86)\AnyDesk\AnyDesk.exe" (
    echo [✓] AnyDesk installed.
) else (
    echo [✗] AnyDesk not found.
)

tasklist /FI "IMAGENAME eq AnyDesk.exe" | find /I "AnyDesk.exe" >nul
if %ERRORLEVEL%==0 (
    echo [✓] AnyDesk is running.
) else (
    echo [✗] AnyDesk is not running.
)

FOR /F "tokens=3*" %%A IN ('reg query "HKLM\SOFTWARE\AnyDesk" /v Alias 2^>nul') DO (
    echo AnyDesk ID: %%A
)

pause
