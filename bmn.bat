@echo off

rem if password define then make sure it is encrypted
if defined password call passget

setlocal enabledelayedexpansion

rem for debug purposes
set PYTHONPATH=D:\Dropbox\Projets\boomoney

rem check version of Python
set py=2
for /f "delims=" %%a in ('python --version 2^>nul ^| findstr "3"') do echo set "py=3"

rem make sure we are using Python3
if %py%==2 (
    set "python3_path="
    for /f "delims=" %%a in ('dir /b D:\Python3* 2^>nul') do set "python3_path=%%a"
    set "PATH=D:\!python3_path!;%PATH%"
)

rem capture password
if defined password goto next
set "psCommand=powershell -Command "$pword = read-host 'Enter Password' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set password=%%p

:next
set args=%*

kpscript %~dp0\bmn.kps

endlocal