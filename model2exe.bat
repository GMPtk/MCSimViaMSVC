@setlocal
@setlocal enabledelayedexpansion

@set rootdir=%~dp0
@set target=%~1

@set vcvars=
@set vsver=2019
@set platform=32
@set "vsdir=%ProgramFiles(x86)%\Microsoft Visual Studio\%vsver%"

@for /D %%M in ("%vsdir%\*") do @(
  @if exist "%%M\VC\Auxiliary\Build\vcvars%platform%.bat" (
    @set "vcvars=%%M\VC\Auxiliary\Build\vcvars%platform%.bat"
    goto use_vcvars
  )
)

@echo.
@echo Failed to initialize MS build tools
@exit /b 1

:use_vcvars

@call "%vcvars%"

@set "MOD=%rootdir%mod\mod.exe"

@if not exist "%MOD%" (

  @echo.
  @echo Building mod...
  @echo.
  
  @if not exist "%rootdir%mod\obj\" (
    @mkdir "%rootdir%mod\obj\"
  )

  cl "%rootdir%mod\*.c" /Fe:"%rootdir%mod\mod.exe" /Fo:"%rootdir%mod\obj/" /O2 

  @if %ERRORLEVEL% neq 0 (
    @pause
    @exit /b 1
  )

  @echo.
  @echo ...done

)

@if not exist "%rootdir%sim\obj\" (
  mkdir "%rootdir%sim\obj\"
)

@if "%target%" NEQ "" (

  @for %%i in ("%target%") do @(
    @set targetName=%%~ni
    @set targetDir=%%~dpi
  )

  @set "target_c=!targetDir!!targetName!.c"
  @set "target_exe=!targetDir!!targetName!.exe"

  @if exist "!target_c!" (
    @del "!target_c!"
  )

  "%MOD%" "%target%" "!target_c!"

  @if not exist "!target_c!" (
    @exit /b 1
  )

  @if exist "!target_exe!" (
    @del "!target_exe!"
  )

  @call :sub_cl "!target_c!" "!target_exe!"

  @if not exist "!target_exe!" (
    @exit /b 1
  )

  @echo Created !target_exe!

  @exit /b 0
)

@if not exist "%rootdir%out" (
  mkdir "%rootdir%out"
)

@for /f %%M in ("%rootdir%target\*.model") do @(

  @echo.
  @echo Building sim for %%~nM...

  @set "target_c=%rootdir%out\%%~nM.c"
  @set "target_exe=%rootdir%out\%%~nM.exe"

  @if exist "!target_c!" (
    @del "!target_c!"
  )

  "%MOD%" "%rootdir%target\%%~nM.model" "!target_c!"

  @if not exist "!target_c!" (
    @echo.
    @echo Failed to generate .c file for %%~nM
    @exit /b 1
  )

  @echo ...compiling...

  @if exist "!target_exe!" (
    @del "!target_exe!"
  )

  @call :sub_cl "!target_c!" "!target_exe!"

  @if not exist "!target_exe!" (
    @echo.
    @echo Failed to compile/link .c file for %%~nM
    @exit /b 1
  )

  @echo.
  @echo ...done...created %%~nM.exe

)

@exit /b 0

:sub_cl
@set "model_c=%1"
@set "model_exe=%2"
cl "%rootdir%sim\*.c" "%model_c%" gsl.lib /O2 /Fo:"%rootdir%sim\obj/" /Fe:"%model_exe%" /I"%rootdir%sim" /I"%rootdir%sim\gsl-2.7" /link /LIBPATH:"%rootdir%sim\gsl-2.7\.libs"
@exit /b
