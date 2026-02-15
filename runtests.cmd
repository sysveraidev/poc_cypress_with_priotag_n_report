@echo off
setlocal enabledelayedexpansion

REM ============================================
REM Usage helper
REM ============================================
if "%~1"=="" goto :usage

set "FIRST_ARG=%~1"
set "RAW_TAGS="
set "INCLUDES="
set "EXCLUDES="
set "GREP_TAGS="

REM ============================================
REM Map priority -> initial tag
REM ============================================
if /i "%FIRST_ARG%"=="bvt" set "RAW_TAGS=@bvt"
if /i "%FIRST_ARG%"=="must" set "RAW_TAGS=@must"
if /i "%FIRST_ARG%"=="should" set "RAW_TAGS=@should"
if /i "%FIRST_ARG%"=="could" set "RAW_TAGS=@could"
if /i "%FIRST_ARG%"=="flaky" set "RAW_TAGS=@flaky"
if "%RAW_TAGS%"=="" (
  if not "%FIRST_ARG:~0,1%"=="@" (
    if not "%FIRST_ARG:~0,2%"=="-@" (
      echo Tag must start with @ (or -@ to exclude): %FIRST_ARG%
      goto :usage
    )
  )
  set "RAW_TAGS=%FIRST_ARG%"
)

shift
:collect
if "%~1"=="" goto :aftercollect
if not "%~1:~0,1%"=="@" (
  if not "%~1:~0,2%"=="-@" (
    echo Tag must start with @ (or -@ to exclude): %~1
    goto :usage
  )
)
set "RAW_TAGS=%RAW_TAGS% %~1"
shift
goto :collect
:aftercollect

for %%T in (%RAW_TAGS%) do (
  set "CUR=%%T"
  if "!CUR:~0,2!"=="-@" (
    set "EXCLUDES=!EXCLUDES! !CUR:~1!"
  ) else (
    set "INCLUDES=!INCLUDES! !CUR!"
  )
)

if "%INCLUDES%"=="" (
  echo At least one include tag is required (example: @bvt -@flaky)
  goto :usage
)

for %%I in (%INCLUDES%) do (
  set "EXPR=%%I"
  for %%E in (%EXCLUDES%) do (
    set "EXPR=!EXPR!+-%%E"
  )
  if "!GREP_TAGS!"=="" (
    set "GREP_TAGS=!EXPR!"
  ) else (
    set "GREP_TAGS=!GREP_TAGS! !EXPR!"
  )
)

REM ============================================
REM Pretty output
REM ============================================
echo.
echo ======================================
echo Running Cypress tests
echo Input    : %RAW_TAGS%
echo grepTags : %GREP_TAGS%
echo ======================================
echo.

REM ============================================
REM Run Cypress (tag-based)
REM ============================================
npx cypress run --env grepTags="%GREP_TAGS%",grepFilterSpecs=true,grepOmitFiltered=true --browser chrome --headed
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
echo Usage: runtests.cmd [bvt^|must^|should^|could^|flaky] [@tag ...] [-@tag ...]
echo.
exit /b 1
