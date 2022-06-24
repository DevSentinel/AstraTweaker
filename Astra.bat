::    Copyright (C) 2022 Astra
::
::    Permission is hereby granted, free of charge, to any person obtaining a copy  
::    of this software and associated documentation files (the "Software"), to deal 
::    in the Software without restriction, including without limitation the rights  
::    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     
::    copies of the Software, and to permit persons to whom the Software is         
::    furnished to do so, subject to the following conditions:                      
::                                                                                     
::    The above copyright notice and this permission notice shall be included in all
::    copies or substantial portions of the Software.                               
::                                                                                  
::    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    
::    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      
::    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   
::    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        
::    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
::    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
::    SOFTWARE.

@ECHO OFF
SETLOCAL EnableDelayedExpansion
mode con: cols=110 lines=37
title Astra Tweaker - Windows 10
chcp 65001 >nul

set "VERSION=2.0.0"
set "VERSION_INFO=17/06/2022"

call:SETFUNCTIONS >nul 2>&1

ver | find "10." >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo ERROR: Your current Windows Version is not Supported
    echo.
    echo Press any key to exit . . .
    pause >nul && exit
)

openfiles >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo !S_GRAY!You are not running as !RED!Administrator!S_GRAY!...
    echo This batch cannot do it's job without elevation!
    echo.
    echo Right-click and select !S_GREEN!^'Run as Administrator^' !S_GRAY!and try again...
    echo.
    echo Press any key to exit . . .
    pause >nul && exit
)

ping -n 1 "google.com" >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo !RED!ERROR: !S_GRAY!No internet connection found
    echo.
    echo Please make sure you are connected to the internet and try again . . .
    pause >nul && exit
)

:Main
echo                          :::      :::::::: ::::::::::: :::::::::      :::     
echo                        :+: :+:   :+:    :+:    :+:     :+:    :+:   :+: :+:   
echo                       +:+   +:+  +:+           +:+     +:+    +:+  +:+   +:+  
echo                      +#++:++#++: +#++:++#++    +#+     +#++:++#:  +#++:++#++: 
echo                      +#+     +#+        +#+    +#+     +#+    +#+ +#+     +#+ 
echo                      #+#     #+# #+#    #+#    #+#     #+#    #+# #+#     #+# 
echo                      ###     ###  ########     ###     ###    ### ###     ### 
pause >nul
:: ----------------------------------------------------------------------------------
:: ---------------------------------VARIABLES----------------------------------------
:: ----------------------------------------------------------------------------------

:SETFUNCTIONS
:: Colors and text format
set "CMDLINE=RED=[31m,S_GRAY=[90m,S_RED=[91m,S_GREEN=[92m,S_YELLOW=[93m,S_MAGENTA=[95m,S_WHITE=[97m,B_BLACK=[40m,B_YELLOW=[43m,UNDERLINE=[4m,_UNDERLINE=[24m"
set "%CMDLINE:,=" & set "%"
:: ECHOX
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set datetime=%%I
set datetime=!datetime:~0,8!-!datetime:~8,6!
:: Check Computer type
for /f "delims=:{}" %%i in ('wmic path Win32_systemenclosure get ChassisTypes^| findstr [0-9]') do set "CHASSIS=%%i"
for %%i in (8 9 10 11 12 14 18 21 13 31 32 30) do if "!CHASSIS!"=="%%i" set "PC_TYPE=LAPTOP/TABLET"
:: Check GPU
wmic path Win32_VideoController get Name | findstr "NVIDIA" >nul 2>&1 && set "GPU=NVIDIA"
wmic path Win32_VideoController get Name | findstr "AMD ATI" >nul 2>&1 && set "GPU=AMD"
wmic path Win32_VideoController get Name | findstr "Intel" >nul 2>&1 && set "GPU=INTEL"
:: Check VC++ Redistributable
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes" /ve >nul 2>&1
if !ERRORLEVEL! equ 1 set "VC=NOT_INSTALLED"
:: Power plan GUID
set "POWER_GUID=%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%-%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%-%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%-%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%-%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%"
:: Total memory and SvcHost
for /f "skip=1" %%i in ('wmic os get TotalVisibleMemorySize') do if not defined TOTAL_MEMORY set "TOTAL_MEMORY=%%i" & set /a SVCHOST=%%i+1024000
:: User SID
for /f %%i in ('wmic path Win32_UserAccount where name^="%username%" get sid ^| findstr "S-"') do set "USER_SID=%%i"
goto:eof