@echo off

set f=%~1
set g=%~2
set e=%~3
set var=VAL_%f%_%g%_%e%
set var=%var: =--WS--%
rem call echo.%var% = %%%var%%% >&2
if defined %var% (
    setlocal EnableDelayedExpansion
    call :decrypt %var% dec
    rem call echo.%var% decrypted %%%var%%% to !dec!>&2
    echo.!dec!
    endlocal
    exit /B
)

echo.keypassget.bat should not be used directly. >&2
echo.Use bmn.bat as entry point >&2

exit /B

:strLen string len -- returns the length of a string
::                 -- string [in]  - variable name containing the string being measured for length
::                 -- len    [out] - variable to be used to return the string length
:: Many thanks to 'sowgtsoi', but also 'jeb' and 'amel27' dostips forum users helped making this short and efficient
:$created 20081122 :$changed 20101116 :$categories StringOperation
:$source https://www.dostips.com
(   SETLOCAL ENABLEDELAYEDEXPANSION
    set "str=A!%~1!"&rem keep the A up front to ensure we get the length and not the upper bound
                     rem it also avoids trouble in case of empty string
    set "len=0"
    for /L %%A in (12,-1,0) do (
        set /a "len|=1<<%%A"
        for %%B in (!len!) do if "!str:~%%B,1!"=="" set /a "len&=~1<<%%A"
    )
)
( ENDLOCAL & REM RETURN VALUES
    IF "%~2" NEQ "" SET /a %~2=%len%
)
EXIT /b


:decrypt string decrypted_string -- returns the decrypted string
::                 -- string              [in]  - string being decrypted
::                 -- decrypted_string    [out] - variable to be used to return the decrypted string
(   SETLOCAL ENABLEDELAYEDEXPANSION
    set "str=!%~1!"
    set "enc="

    rem magic number 
    set magic=F45A9B6C

    if not defined str goto :end_decrypt
    if "!str!"=="" goto :end_decrypt
    if not "!str:~0,8!"=="!magic!" (
        echo "Bad magic in !str!!"
        goto :end_decrypt
    )

    set "strlen_enc=!str:~8,8!"
    set "str=!str:~16!"
    set /a strlen=0x!strlen_enc!
    set /a end=2 * !strlen! - 1
    set p=
    for /l %%C in (0,2,!end!) DO (
        set c=!str:~%%C,2!
        set p=!p!0x!c!
    )

    for /F "delims==" %%i IN ('forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo.!p!"') DO set "enc=%%i"
:end_decrypt
    rem
)
( ENDLOCAL & REM RETURN VALUES
    IF "%~2" NEQ "" SET %~2=%enc%
)
EXIT /b
