@echo off
curl -L -o anydesk.bat https://raw.githubusercontent.com/huuhieu17/freerdp/refs/heads/main/anydesk.bat
curl -L -o getAnyDeskID.bat https://raw.githubusercontent.com/huuhieu17/freerdp/refs/heads/main/getAnyDeskID.bat
curl -L -o loop.bat https://raw.githubusercontent.com/huuhieu17/freerdp/refs/heads/main/loop.bat
curl -L -o show.bat https://raw.githubusercontent.com/huuhieu17/freerdp/refs/heads/main/show.bat
pip install pyautogui --quiet
pip install psutil --quiet
curl -s -L -o time.py https://raw.githubusercontent.com/huuhieu17/freerdp/refs/heads/main/timelimit.py
curl -s -L -o C:\Users\Public\Desktop\Winrar.exe https://www.rarlab.com/rar/winrar-x64-621.exe
powershell -Command "Invoke-WebRequest 'https://github.com/chieunhatnang/VM-QuickConfig/releases/download/1.6.1/VMQuickConfig.exe' -OutFile 'C:\Users\Public\Desktop\VMQuickConfig.exe'"
C:\Users\Public\Desktop\Winrar.exe /S
del C:\Users\Public\Desktop\Winrar.exe
del /f "C:\Users\Public\Desktop\Epic Games Launcher.lnk" > errormsg.txt 2>&1
del /f "C:\Users\Public\Desktop\Unity Hub.lnk" > errormsg.txt 2>&1
set password=nk0ckhun9
powershell -Command "Set-LocalUser -Name 'runneradmin' -Password (ConvertTo-SecureString -AsPlainText '%password%' -Force)"
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0 /f
tzutil /s "Sri Lanka Standard Time"