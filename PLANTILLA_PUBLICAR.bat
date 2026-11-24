@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul 2>nul

rem PLANTILLA: antes de usar, reemplazar REPO y BUNDLE_NAME por valores reales.
set "REPO=https://github.com/Somospopups/REEMPLAZAR.git"
set "BUNDLE_NAME=cambio-nombre-fecha.bundle"
set "TMPDIR=%TEMP%\publicar-cambio-%RANDOM%-%RANDOM%"
set "ALREADY="
set "NEW_SHA="
set "REMOTE_SHA="

echo [1/4] Comprobando Git y el bundle...
where git >nul 2>nul
if errorlevel 1 (
  echo Falta Git for Windows. Instala desde https://git-scm.com/download/win y vuelve a abrir el BAT.
  goto :error
)
if not exist "%~dp0%BUNDLE_NAME%" (
  echo Falta el bundle "%BUNDLE_NAME%" junto a este BAT.
  goto :error
)

echo [2/4] Clonando la version actual del repo...
git clone --branch main --single-branch "%REPO%" "%TMPDIR%"
if errorlevel 1 goto :error
cd /d "%TMPDIR%"
if errorlevel 1 goto :error

git fetch "%~dp0%BUNDLE_NAME%" HEAD
if errorlevel 1 goto :error
for /f "tokens=1,2" %%A in ('git cherry origin/main FETCH_HEAD 2^>nul') do if "%%A"=="-" set "ALREADY=1"
if defined ALREADY goto :already

echo Aplicando el commit de la actualizacion...
git -c user.name="Arena Agent" -c user.email="arena-agent@users.noreply.github.com" cherry-pick FETCH_HEAD
if errorlevel 1 (
  rem Un cherry-pick vacio suele significar que el parche ya existe.
  git diff --quiet
  if not errorlevel 1 (
    git diff --cached --quiet
    if not errorlevel 1 (
      git cherry-pick --abort >nul 2>nul
      goto :already
    )
  )
  git cherry-pick --abort >nul 2>nul
  echo Hay un conflicto o un cambio incompatible. No se publica nada.
  goto :error
)

echo [3/4] Enviando con push normal, sin force...
git push origin main
if errorlevel 1 goto :error
for /f "delims=" %%H in ('git rev-parse HEAD 2^>nul') do set "NEW_SHA=%%H"
for /f "tokens=1" %%H in ('git ls-remote origin refs/heads/main 2^>nul') do set "REMOTE_SHA=%%H"
if not defined NEW_SHA goto :error
if not defined REMOTE_SHA goto :error
if not "%NEW_SHA%"=="%REMOTE_SHA%" goto :error

echo [4/4] PUBLICACION VERIFICADA: %REMOTE_SHA%
goto :success

:already
echo Este cambio ya estaba publicado. No hace falta repetirlo.
goto :success

:success
cd /d "%TEMP%" >nul 2>nul
if exist "%TMPDIR%" rmdir /s /q "%TMPDIR%" >nul 2>nul
echo Listo. GitHub Pages puede tardar un minuto en actualizarse.
pause
exit /b 0

:error
echo.
echo No se pudo completar o verificar la publicacion. No se informa exito.
cd /d "%TEMP%" >nul 2>nul
if defined TMPDIR if exist "%TMPDIR%" rmdir /s /q "%TMPDIR%" >nul 2>nul
pause
exit /b 1
