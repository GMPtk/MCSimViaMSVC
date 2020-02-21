@setlocal
@setlocal enabledelayedexpansion

@set rootdir=%~dp0
@set target=%~1

@set vcvars=
@set platform=32
@set "VS2019=%ProgramFiles(x86)%\Microsoft Visual Studio\2019"

@if exist "%VS2019%\BuildTools\VC\Auxiliary\Build\vcvars%platform%.bat" (
  @set "vcvars=%VS2019%\BuildTools\VC\Auxiliary\Build\vcvars%platform%.bat"
)

@if "%vcvars%" == "" (
  @if exist "%VS2019%\Enterprise\VC\Auxiliary\Build\vcvars%platform%.bat" (
    @set "vcvars=%VS2019%\Enterprise\VC\Auxiliary\Build\vcvars%platform%.bat"
  )
)

@if "%vcvars%" == "" (
  @echo.
  @echo Failed to initialize MS build tools
  @exit /b 1
)

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

  @if exist "!targetDir!!targetName!.c" (
    @del "!targetDir!!targetName!.c"
  )

  "%MOD%" "%target%" "!targetDir!!targetName!.c"

  @if not exist "!targetDir!!targetName!.c" (
    @exit /b 1
  )

  @if exist "!targetDir!!targetName!.exe" (
    @del "!targetDir!!targetName!.exe"
  )

  cl "%rootdir%sim\*.c" "!targetDir!!targetName!.c" gsl.lib /O2 /Fo:"%rootdir%sim\obj/" /Fe:"!targetDir!!targetName!.exe" /I"%rootdir%sim" /I"%rootdir%sim\gsl-2.7" /link /LIBPATH:"%rootdir%sim\gsl-2.7\.libs"

  @if not exist "!targetDir!!targetName!.exe" (
    @exit /b 1
  )

  @echo Created !targetDir!!targetName!.exe

  @exit /b 0
)

@if not exist "%rootdir%out" (
  mkdir "%rootdir%out"
)

@for /f %%M in ("%rootdir%target\*.model") do @(

  @echo.
  @echo Building sim for %%~nM...

  @if exist "%rootdir%out\%%~nM.c" (
    @del "%rootdir%out\%%~nM.c"
  )

  "%MOD%" "%rootdir%target\%%~nM.model" "%rootdir%out\%%~nM.c"

  @if not exist "%rootdir%out\%%~nM.c" (
    @echo.
    @echo Failed to generate .c file for %%~nM
    @exit /b 1
  )

  @echo ...compiling...

  @if exist "%rootdir%out\%%~nM.exe" (
    @del "%rootdir%out\%%~nM.exe"
  )

  cl "%rootdir%sim\*.c" "%rootdir%out\%%~nM.c" gsl.lib /O2 /Fo:"%rootdir%sim\obj/" /Fe:"%rootdir%out\%%~nM.exe" /I"%rootdir%sim" /I"%rootdir%sim\gsl-2.7" /link /LIBPATH:"%rootdir%sim\gsl-2.7\.libs"

  @if not exist "%rootdir%out\%%~nM.exe" (
    @echo.
    @echo Failed to compile/link .c file for %%~nM
    @exit /b 1
  )

  @echo.
  @echo ...done...created %%~nM.exe

)
