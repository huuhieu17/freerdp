@echo off
REM -------------------------------
REM enable_rdp_and_open_port.bat
REM Run as Administrator
REM -------------------------------

REM --- CONFIG ---
set RDP_PORT=3389

echo Enabling Remote Desktop...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f >nul

echo Enabling Network Level Authentication (NLA)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f >nul

if "%RDP_PORT%" NEQ "3389" (
  echo Changing RDP port to %RDP_PORT%...
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d %RDP_PORT% /f >nul
)

echo Configuring and starting TermService...
sc config TermService start= auto >nul
net start TermService >nul 2>&1

echo Creating Windows Firewall rule for RDP port %RDP_PORT%...
netsh advfirewall firewall add rule name="Allow RDP TCP %RDP_PORT%" dir=in action=allow protocol=TCP localport=%RDP_PORT% profile=any >nul

echo.
echo Done.
echo - Remote Desktop is enabled.
echo - Firewall rule "Allow RDP TCP %RDP_PORT%" added.
echo Note: If you changed the port, connect using ip:port (e.g. 192.0.2.1:%RDP_PORT%).
pause
