@echo off
python -c "import pyautogui as pag; pag.click(785, 17, duration=2)"
python -c "import pyautogui as pag; pag.click(903, 64, duration=2)"
start "" /MAX "C:\Users\Public\Desktop\VMQuickConfig"
python -c "import pyautogui as pag; pag.click(147, 489, duration=2)"
python -c "import pyautogui as pag; pag.click(156, 552, duration=2)"
python -c "import pyautogui as pag; pag.click(587, 14, duration=2)"
echo ..........................................................
echo .....Steve Free RDP................................
echo ..........................................................
echo Your Device Name: %username%@%computername%