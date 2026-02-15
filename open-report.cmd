@echo off
setlocal enabledelayedexpansion

set "ROOT_DIR=%~dp0"
set "REPORT_DIR=%ROOT_DIR%cypress\reports"

if not "%REPORT_PATH%"=="" (
  if not exist "%REPORT_PATH%" (
    echo Report not found at REPORT_PATH=%REPORT_PATH%
    exit /b 1
  )
  set "REPORT=%REPORT_PATH%"
) else (
  if not exist "%REPORT_DIR%" (
    echo No Cypress HTML report found in %REPORT_DIR%.
    echo Run tests first (for example: runtests.cmd bvt^), then run open-report.cmd.
    echo Or set REPORT_PATH to a specific report file.
    exit /b 1
  )

  set "REPORT="
  for /f "delims=" %%F in ('dir /b /a:-d /o:-d "%REPORT_DIR%\*.html" 2^>nul') do (
    if "!REPORT!"=="" set "REPORT=%REPORT_DIR%\%%F"
  )

  if "!REPORT!"=="" (
    echo No Cypress HTML report found in %REPORT_DIR%.
    echo Run tests first (for example: runtests.cmd bvt^), then run open-report.cmd.
    echo Or set REPORT_PATH to a specific report file.
    exit /b 1
  )
)

echo Opening report: %REPORT%
start "" "%REPORT%"
