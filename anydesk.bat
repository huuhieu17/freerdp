@echo off
setlocal

:: === Tùy chỉnh mật khẩu tại đây ===
set PASSWORD=nk0ckhun9

:: === Bước 1: Tải AnyDesk ===
echo [1/3] Downloading AnyDesk...
powershell -Command "Invoke-WebRequest -Uri 'https://download.anydesk.com/AnyDesk.exe' -OutFile '%TEMP%\AnyDesk.exe'"

:: === Bước 2: Cài đặt silent ===
echo [2/3] Installing AnyDesk silently...
"%TEMP%\AnyDesk.exe" /install /silent

:: === Đợi 5s để AnyDesk hoàn tất khởi tạo registry ===
timeout /t 5 > nul

:: === Bước 3: Thiết lập mật khẩu Unattended Access ===
echo [3/3] Setting unattended access password...

:: Convert mật khẩu sang hex UTF-8 và ghi vào Registry
powershell -Command ^
"$p = '%PASSWORD%';" ^
"$bytes = [System.Text.Encoding]::UTF8.GetBytes($p);" ^
"Set-ItemProperty -Path 'HKLM:\SOFTWARE\AnyDesk' -Name 'Password' -Value $bytes"

echo Done!
pause
