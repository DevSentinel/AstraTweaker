:: Astra — 🔐 Enforce Privacy, Security, & better performance in general.

:: -- 🤔 How to use
::  📙 Start by opening up the program.
::  📙 Sometimes there will be choiceboxes to pick tweaks.
::  📙 After you choose any tweaks, it will apply it.

:: -- 🧐 Why Astra
::  ✔️ Rich Tweak Pool with choiceboxes, being fully customizable.
::  ✔️ No need to run any compiled software on your system, just run the simple script.
::  ✔️ Open-source and free (both free as in beer and free as in speech).

:: Software
@ECHO OFF
SETLOCAL EnableDelayedExpansion
TITLE Astra Tweaker - Windows 10
MODE con: cols=104 lines=28
chcp 65001 >nul 2>&1
cd /d "%~dp0"

set "VERSION=2.0.0"
set "VERSION_INFO=22/05/2022"

call:SETCONSTANTS >nul 2>&1

ver | find "10." >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo.
    echo  !RED!ERROR: !S_WHITE!Your current Windows version is not supported.
    echo.
    echo  Press any key to exit . . .
    pause >nul && exit
)

openfiles >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo.
    echo  !S_WHITE!You are not running as !RED!Administrator!S_WHITE!...
    echo  Right-click and select !S_GREEN!^'Run as Administrator^' !S_WHITE!and try again...
    echo.
    echo  Press any key to exit . . .
    pause >nul && exit
)

ping -n 1 "google.com" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo.
    echo  !RED!ERROR: !S_WHITE!No internet connection found
    echo.
    echo  Please make sure you are connected to the internet and try again . . .
    pause >nul && exit
)

set "NEEDEDFILES=modules/choicebox.exe modules/nsudo.exe modules/devicecleanup.exe modules/DevManView.exe resources/procexp.exe resources/Plan.pow resources/SetTimerResolutionService.exe resources/nvidiaProfileInspector.exe resources/BaseProfile.nip"
for %%i in (!NEEDEDFILES!) do (
    if not exist %%i (
        set "MISSINGFILES=True"
        echo !RED!ERROR: !S_GREEN!%%i !S_WHITE!is missing
    )
)
if "!MISSINGFILES!"=="True" echo. & echo Downloading missing files please wait...!S_GREEN!
for %%i in (!NEEDEDFILES!) do if not exist %%i call:CURL "0" "https://raw.githubusercontent.com/ArtanisInc/Post-Tweaks/main/%%i" "%%i"

whoami /user | find /i "S-1-5-18" >nul 2>&1
if !ERRORLEVEL! neq 0 call "modules\nsudo.exe" -U:T -P:E "%~dpnx0" && exit



:: ----------------------------------------------------------------------------------
:: ---------------------------------FUNCTIONS----------------------------------------
:: ----------------------------------------------------------------------------------
:SETCONSTANTS
:: Colors and Text Format
set "CMDLINE=RED=[31m,S_GRAY=[90m,S_RED=[91m,S_GREEN=[92m,S_YELLOW=[93m,S_MAGENTA=[95m,S_WHITE=[97m,B_BLACK=[40m,B_YELLOW=[43m,UNDERLINE=[4m,_UNDERLINE=[24m"
set "%CMDLINE:,=" & set "%"
:: Check Computer Type
for /f "delims=:{}" %%i in ('wmic path Win32_systemenclosure get ChassisTypes^| findstr [0-9]') do set "CHASSIS=%%i"
for %%i in (8 9 10 11 12 14 18 21 13 31 32 30) do if "!CHASSIS!"=="%%i" set "PC_TYPE=LAPTOP/TABLET"
for %%i in (3 4 5 6 7 15 16 34 35 36) do if "!CHASSIS!"=="%%i" set "PC_TYPE=DESKTOP"
:: Check GPU
wmic path Win32_VideoController get Name | findstr "NVIDIA" >nul 2>&1 && set "GPU=NVIDIA"
wmic path Win32_VideoController get Name | findstr "AMD ATI" >nul 2>&1 && set "GPU=AMD"
wmic path Win32_VideoController get Name | findstr "Intel" >nul 2>&1 && set "GPU=INTEL"
:: Check HT/SMT
for /f "skip=1" %%i in ('wmic CPU get NumberOfCores') do set "CORES=%%i"
for /f "skip=1" %%i in ('wmic CPU get NumberOfLogicalProcessors') do set "LOGICAL_PROCESSORS=%%i"
if !CORE! lss !LOGICAL_PROCESSORS! (set "HT_SMT=ON") else set "HT_SMT=OFF"
:: Check Wi-Fi
wmic path WIN32_NetworkAdapter where NetConnectionID="Wi-Fi" get NetConnectionStatus | findstr "2" >nul 2>&1 && set "NIC_TYPE=WIFI"
:: Check VC++ Redistributable
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes" /ve >nul 2>&1
if !ERRORLEVEL! equ 1 set "VC=NOT_INSTALLED"
:: SvcHost
for /f "skip=1" %%i in ('wmic os get TotalVisibleMemorySize') do if not defined SVCHOST (set /a SVCHOST=%%i+1024000)
:: User SID
for /f %%i in ('wmic path Win32_UserAccount where name^="%username%" get sid ^| findstr "S-"') do set "USER_SID=%%i"
goto:eof

:NIC_SETTINGS
for /f "tokens=1,2*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}" /s /v "*IfType"^| findstr /i "HKEY 0x6 0x47"') do if /i "%%i" neq "*IfType" (set "REGPATH_NIC=%%i") else (for /f %%a in ('reg query "!REGPATH_NIC!" /v "%~1"^| findstr "HKEY"') do reg add "%%a" /v "%~1" /t REG_SZ /d "%~2" /f) >nul 2>&1
goto:eof

:POWERSHELL
chcp 437 >nul 2>&1 & powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command %* >nul 2>&1 & chcp 65001 >nul 2>&1
goto:eof

:CHOCO [Package]
if not exist "%ProgramData%\chocolatey" (
    call:POWERSHELL "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && set "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    call "%ProgramData%\chocolatey\bin\RefreshEnv.cmd"
)
choco install -y --limit-output --ignore-checksums %*
goto:eof

:CURL [Argument] [URL] [Directory]
if not exist "%WinDir%\System32\curl.exe" if not exist "%ProgramData%\chocolatey\lib\curl" call:CHOCO curl
if "%~1"=="0" curl -k -L --progress-bar "%~2" --create-dirs -o "%~3"
if "%~1"=="1" curl --silent "%~2" --create-dirs -o "%~3"
goto:eof

:MSGBOX [Text] [Argument] [Title]
echo WScript.Quit Msgbox(Replace("%~1","\n",vbCrLf),%~2,"%~3") >"%TMP%\msgbox.vbs"
cscript /nologo "%TMP%\msgbox.vbs"
set "exitCode=!ERRORLEVEL!" & del /f /q "%TMP%\msgbox.vbs" >nul 2>&1
exit /b %exitCode%

:SHORTCUT [Name] [Path] [TargetPath] [WorkingDirectory]
echo Set WshShell=WScript.CreateObject^("WScript.Shell"^) >"%TMP%\shortcut.vbs"
echo Set lnk=WshShell.CreateShortcut^("%~2\%~1.lnk"^) >>"%TMP%\shortcut.vbs"
echo lnk.TargetPath="%~3" >>"%TMP%\shortcut.vbs"
echo lnk.WorkingDirectory="%~4" >>"%TMP%\shortcut.vbs"
echo lnk.WindowStyle=4 >>"%TMP%\shortcut.vbs"
echo lnk.Save >>"%TMP%\shortcut.vbs"
cscript /nologo "%TMP%\shortcut.vbs" & del /f /q "%TMP%\shortcut.vbs" >nul 2>&1
goto:eof
