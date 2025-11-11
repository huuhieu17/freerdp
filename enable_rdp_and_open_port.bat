@echo off
REM -------------------------------
REM enable_rdp_and_open_port.bat
REM Chạy với quyền Administrator
REM -------------------------------

REM --- CONFIG ---
REM Nếu muốn đổi port, thay đổi RDP_PORT; để mặc định 3389
set RDP_PORT=3389

REM Bật Remote Desktop (fDenyTSConnections = 0)
echo Enabling Remote Desktop...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >nul

REM Bật NLA (UserAuthentication = 1) - khuyến nghị
echo Enabling Network Level Authentication (NLA)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f >nul

REM Nếu muốn thay đổi port RDP (uncomment phần dưới và set RDP_PORT phía trên)
if "%RDP_PORT%" NEQ "3389" (
  echo Changing RDP port to %RDP_PORT%...
  REM PortNumber là REG_DWORD, ghi giá trị decimal
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d %RDP_PORT% /f >nul
)

REM Đảm bảo Remote Desktop service khởi động tự động và start service
echo Configuring and starting TermService...
sc config TermService start= auto >nul
net start TermService >nul 2>&1

REM Mở Firewall cho port RDP (TCP)
echo Creating Windows Firewall rule for RDP port %RDP_PORT%...
netsh advfirewall firewall add rule name="Allow RDP TCP %RDP_PORT%" dir=in action=allow protocol=TCP localport=%RDP_PORT% profile=any >nul

REM (Tùy) Mở UDP 3389 nếu cần (RemoteFX / UDP transport) - uncomment nếu muốn
REM netsh advfirewall firewall add rule name="Allow RDP UDP 3389" dir=in action=allow protocol=UDP localport=3389 profile=any

echo.
echo Done.
echo - Remote Desktop should be enabled.
echo - Firewall rule "Allow RDP TCP %RDP_PORT%" added.
echo Note: If you changed port, clients must connect to ip:port (e.g. 192.0.2.1:%RDP_PORT%).
pause
