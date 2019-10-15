@echo off
setlocal

set thisdir=%~dp0
set configuration=Debug
set runtests=true

:parseargs
if "%1" == "" goto argsdone
if /i "%1" == "-c" (
    set configuration=%2
    shift
    shift
    goto parseargs
)
if /i "%1" == "-notest" (
    set runtests=false
    shift
    goto parseargs
)

echo Unsupported argument: %1
goto error

:argsdone

:: IxMilia.Dxf needs a custom invocation to generate code
call %~dp0src\IxMilia.Dxf\build-and-test.cmd -notest -c %configuration%
if errorlevel 1 echo Error pre-building IxMilia.Dxf && exit /b 1

:: build
set SOLUTION=%~dp0IxMilia.Converters.sln
dotnet restore %SOLUTION%
if errorlevel 1 exit /b 1
dotnet build %SOLUTION% -c %configuration%
if errorlevel 1 exit /b 1

:: test
if /i "%runtests%" == "true" (
    dotnet test "%SOLUTION%" -c %configuration% --no-restore --no-build
    if errorlevel 1 goto error
)
