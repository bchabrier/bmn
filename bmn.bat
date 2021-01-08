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

rem from https://stackoverflow.com/questions/673523/how-do-i-measure-execution-time-of-a-command-on-the-windows-command-line
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set t=%%I
set /a t1 = %t:~8,1%*36000 + %t:~9,1%*3600 + %t:~10,1%*600 + %t:~11,1%*60 + %t:~12,1%*10 + %t:~13,1% && set t1=!t1!%t:~15,3%

kpscript %~dp0\bmn.kps

rem from https://stackoverflow.com/questions/673523/how-do-i-measure-execution-time-of-a-command-on-the-windows-command-line
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set t=%%I
set /a t2 = %t:~8,1%*36000 + %t:~9,1%*3600 + %t:~10,1%*600 + %t:~11,1%*60 + %t:~12,1%*10 + %t:~13,1% && set t2=!t2!%t:~15,3%
set /a t2-=t1 && if !t2! lss 0 set /a t2+=24*3600000

rem from https://stackoverflow.com/questions/673523/how-do-i-measure-execution-time-of-a-command-on-the-windows-command-line
set /a "h=t2/3600000,t2%%=3600000,m=t2/60000,t2%%=60000" && set t2=00000!t2!&& set t2=!t2:~-5!
if %h% leq 9 (set h=0%h%) && if %m% leq 9 (set m=0%m%)
set t2=%h%:%m%:%t2:~0,2%.%t2:~2,3%

echo Execution took %t2%


endlocal