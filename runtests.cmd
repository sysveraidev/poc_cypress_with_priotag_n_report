@echo off
setlocal enabledelayedexpansion

REM ============================================
REM Usage helper
REM ============================================
if "%~1"=="" goto :usage

set "PRIORITY=%~1"
set "TAG="

REM ============================================
REM Map priority -> tag
REM ============================================
if /i "%PRIORITY%"=="bvt" set "TAG=@bvt"
if /i "%PRIORITY%"=="must" set "TAG=@must"
if /i "%PRIORITY%"=="should" set "TAG=@should"
if /i "%PRIORITY%"=="could" set "TAG=@could"
if /i "%PRIORITY%"=="flaky" set "TAG=@flaky"

if "%TAG%"=="" (
  echo Invalid priority: %PRIORITY%
  goto :usage
)

REM ============================================
REM Pretty output
REM ============================================
echo.
echo ======================================
echo Running Cypress tests
echo Priority : %PRIORITY%
echo Tag      : %TAG%
echo ======================================
echo.

REM ============================================
REM Run Cypress (tag-based)
REM ============================================
npx cypress run --env grepTags="%TAG%",grepFilterSpecs=true,grepOmitFiltered=true --browser chrome --headed
if errorlevel 1 goto :failed

echo.
echo Cypress finished successfully
exit /b 0

:failed
echo.
echo Cypress failed
exit /b 1

:usage
echo.
echo Usage: runtests.cmd [bvt^|must^|should^|could^|flaky]
echo.
exit /b 1
