@echo off
setlocal enabledelayedexpansion
set "INPUT_DIR=.\lua\�ű�Դ��"
set "OUTPUT_DIR=.\lua"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
for %%F in ("%INPUT_DIR%\*.lua") do (
    set "filename=%%~nF"
    jm.exe -b "%%F" "%OUTPUT_DIR%\!filename!.lua"
)
echo ������ɣ�
pause