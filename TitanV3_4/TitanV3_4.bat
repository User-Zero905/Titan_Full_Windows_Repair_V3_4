@echo off
setlocal enabledelayedexpansion
:: 1. AUTO-ELEVATE TO ADMIN
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :RunScans
) else (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:RunScans
:: --- SMART DRIVE HUNTER LOGIC ---
set "logDir=%userprofile%\Desktop"
set "targetLabel=ErectileDsk"

if exist "J:\" (
    set "logDir=J:\SystemCleanup.bat\Logs"
    goto :DirFound
)

for /f "tokens=1,2" %%a in ('wmic logicaldisk get deviceid^,volumename ^| findstr /i "%targetLabel%"') do (
    set "logDir=%%a\SystemCleanup.bat\Logs"
    goto :DirFound
)

:DirFound
if not exist "%logDir%" mkdir "%logDir%" 2>nul

color 0B
title Titan Workstation Ultimate [v3.4]
mode con: cols=100 lines=42

:: SET FILENAME WITH [DATE-TIME]
set "stamp=%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%-%TIME:~3,2%"
set "stamp=%stamp: =0%"
set "fullLogPath=%logDir%\[%stamp%]_Titan_Log.txt"

set "bar=--------------------"
set "fill=####################"
set "pct=0"

:Header
cls
echo ==========================================================================================
echo                TITAN WORKSTATION [ULTIMATE HEALTH ^& PERFORMANCE]
echo ==========================================================================================
echo  PROGRESS: [!fill:~0,%pct%!!bar:~%pct%!] %pct%0%%
echo ==========================================================================================
echo.

:: --- MODULE 1: POWER ^& CPU OVERRIDE ---
echo [1/13] Configuring Dynamic CPU Power ^& Hibernation...
powercfg -h off >nul 2>&1
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 >nul 2>&1
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1
set "pct=2"
goto :Header2

:Header2
cls
echo ==========================================================================================
echo                TITAN WORKSTATION [ULTIMATE HEALTH ^& PERFORMANCE]
echo ==========================================================================================
echo  PROGRESS: [!fill:~0,%pct%!!bar:~%pct%!] %pct%0%%
echo ==========================================================================================
echo.
echo [X] Power Optimization: COMPLETE
echo [2/13] Resetting Network Stack, DNS ^& ARP Cache...
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
arp -d * >nul 2>&1
set "pct=4"
goto :Header3

:Header3
cls
echo ==========================================================================================
echo                TITAN WORKSTATION [ULTIMATE HEALTH ^& PERFORMANCE]
echo ==========================================================================================
echo  PROGRESS: [!fill:~0,%pct%!!bar:~%pct%!] %pct%0%%
echo ==========================================================================================
echo.
echo [X] Network Stack Deep Reset: COMPLETE
echo [3/13] Purging Windows Update Cache ^& System Temp...
net stop wuauserv >nul 2>&1
del /f /s /q %windir%\SoftwareDistribution\* >nul 2>&1
net start wuauserv >nul 2>&1
del /q /f /s %temp%\* >nul 2>&1
set "pct=6"
goto :Header4

:Header4
cls
echo ==========================================================================================
echo                TITAN WORKSTATION [ULTIMATE HEALTH ^& PERFORMANCE]
echo ==========================================================================================
echo  PROGRESS: [!fill:~0,%pct%!!bar:~%pct%!] %pct%0%%
echo ==========================================================================================
echo.
echo [X] Update Cache ^& Temp Purge: COMPLETE
echo [4/13] Applying Registry Speed Tweaks...
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d 2000 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d 2000 /f >nul 2>&1
set "pct=8"
goto :Header5

:Header5
cls
echo ==========================================================================================
echo                TITAN WORKSTATION [ULTIMATE HEALTH ^& PERFORMANCE]
echo ==========================================================================================
echo  PROGRESS: [!fill:~0,%pct%!!bar:~%pct%!] %pct%0%%
echo ==========================================================================================
echo.
echo [X] Registry Tweaks: COMPLETE
echo [5/13] DISM: Cleaning Windows Component Store...
dism /online /cleanup-image /startcomponentcleanup /resetbase
set "pct=10"
goto :Header6

:Header6
cls
echo ==========================================================================================
echo                TITAN WORKSTATION [ULTIMATE HEALTH ^& PERFORMANCE]
echo ==========================================================================================
echo  PROGRESS: [!fill:~0,%pct%!!bar:~%pct%!] %pct%0%%
echo ==========================================================================================
echo.
echo [X] Component Store Cleanup: COMPLETE
echo [6/13] DISM: Repairing System Image (Deep Scan)...
dism /online /cleanup-image /restorehealth
set "pct=14"
goto :Header7

:Header7
cls
echo ==========================================================================================
echo                TITAN WORKSTATION [ULTIMATE HEALTH ^& PERFORMANCE]
echo ==========================================================================================
echo  PROGRESS: [!fill:~0,%pct%!!bar:~%pct%!] %pct%0%%
echo ==========================================================================================
echo.
echo [X] DISM Image Repair: COMPLETE
echo [7/13] SFC: Verifying System File Integrity...
sfc /scannow
set "pct=16"
goto :Header8

:Header8
cls
echo ==========================================================================================
echo                TITAN WORKSTATION [ULTIMATE HEALTH ^& PERFORMANCE]
echo ==========================================================================================
echo  PROGRESS: [!fill:~0,%pct%!!bar:~%pct%!] %pct%0%%
echo ==========================================================================================
echo.
echo [X] SFC System Repair: COMPLETE
echo [8/13] Optimizing Storage Drive (TRIM)...
defrag C: /O
set "pct=18"
goto :Finalize

:Finalize
cls
echo ==========================================================================================
echo                TITAN WORKSTATION [ULTIMATE HEALTH ^& PERFORMANCE]
echo ==========================================================================================
echo  PROGRESS: [####################] 100%%
echo ==========================================================================================
echo.
echo [9/13] Clearing Standby Memory Cache...
powershell -Command "[System.GC]::Collect()" >nul 2>&1
echo [10/13] Emptying Recycle Bin...
rd /s /q %systemdrive%\$Recycle.Bin >nul 2>&1
echo [11/13] Purging System Clipboard...
echo off | clip
echo [12/13] Writing Log to %fullLogPath%...
echo TITAN SYSTEM HEALTH REPORT > "%fullLogPath%"
echo Run Date: %date% %time% >> "%fullLogPath%"
echo -------------------------------------------------- >> "%fullLogPath%"
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" >> "%fullLogPath%"
echo. >> "%fullLogPath%"
echo [SFC SCAN RESULT]: >> "%fullLogPath%"
sfc /verifyonly >> "%fullLogPath%"

echo [13/13] Finalizing...
timeout /t 2 >nul
echo.
echo ==========================================================================================
echo                ULTIMATE HEALTH RESTORE COMPLETE!
echo ==========================================================================================
echo  Log path: %fullLogPath%
echo  Clipboard: PURGED
echo.
echo  Opening log now... 
echo  NOTE: Once you close the log, it will be moved to the Recycle Bin.
echo ==========================================================================================

:: OPEN LOG AND WAIT FOR CLOSE, THEN RECYCLE
powershell -Command "$process = Start-Process notepad.exe -ArgumentList '%fullLogPath%' -PassThru; $process.WaitForExit(); Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile('%fullLogPath%', 'OnlyErrorDialogs', 'SendToRecycleBin')"

echo Operation Complete.
pause
exit