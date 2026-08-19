@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  Run fix_xdma_mlite.tcl via Vivado batch mode, save timestamped logs
REM  Fix: xdma_0/M_AXI_LITE dangling (XDMA DMA engine Code 10)
REM ============================================================

set "VIVADO_BIN=D:\workspace\fpga\myinstall\Vivado\2018.3\bin"
set "TCL_FILE=D:\workspace\trae\day01\0702\acz7015-xdma-linux\fpga\can_integration\fix_xdma_mlite.tcl"
set "LOG_DIR=D:\workspace\trae\day01\0702\acz7015-xdma-linux\fpga\can_integration\logs"

REM ---- locale-safe timestamp (YYYYMMDD_HHMMSS) ----
set "TS="
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value 2^>nul') do set "DT=%%I"
if defined DT set "TS=%DT:~0,8%_%DT:~8,6%"
if not defined TS set "TS=no_ts_%RANDOM%"

set "LOG_FILE=%LOG_DIR%\fix_xdma_mlite_%TS%.log"
set "JOU_FILE=%LOG_DIR%\fix_xdma_mlite_%TS%.jou"

REM ---- precheck ----
if not exist "%VIVADO_BIN%\vivado.bat" (
    echo [ERROR] vivado.bat not found: %VIVADO_BIN%\vivado.bat
    pause
    exit /b 1
)
if not exist "%TCL_FILE%" (
    echo [ERROR] TCL not found: %TCL_FILE%
    pause
    exit /b 1
)
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo ============================================================
echo  VIVADO : %VIVADO_BIN%\vivado.bat
echo  TCL    : %TCL_FILE%
echo  LOG    : %LOG_FILE%
echo  JOU    : %JOU_FILE%
echo ============================================================
echo.

cd /d "%VIVADO_BIN%"
call vivado.bat -mode batch -source "%TCL_FILE%" -log "%LOG_FILE%" -journal "%JOU_FILE%"
set "RC=%errorlevel%"

echo.
if "%RC%" neq "0" (
    echo [ERROR] Vivado exited with code %RC%
    echo          Check log: %LOG_FILE%
    pause
    exit /b %RC%
)

echo [DONE] Vivado finished successfully.
echo        Log saved: %LOG_FILE%
echo        Jou saved: %JOU_FILE%
echo.
echo Tip: grep the log for "ERROR" or "M_AXI_LITE 地址空间" to verify.
pause
endlocal