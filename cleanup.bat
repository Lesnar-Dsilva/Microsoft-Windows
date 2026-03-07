@echo off
color 0f

title Check Health

sfc /scannow
echo.

dism /online /cleanup-image /checkhealth
echo.

dism /online /cleanup-image /scanhealth
echo.

dism /online /cleanup-image /restorehealth
echo.

sfc /scannow
echo.

echo Cleanup Complete.

pause
exit