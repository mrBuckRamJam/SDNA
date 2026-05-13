@echo off
set "CRINKLER_PATH=c:\sdna"
set "CRINKLER=%CRINKLER_PATH%\crinkler.exe"

:: Forza la chiusura della demo se è ancora aperta per sbloccare il file
taskkill /F /IM sdna.exe /T >nul 2>&1

:: Pulisce i vecchi file diagnostici per azzerare i messaggi del report
if exist "c:\sdna\main.obj" del "c:\sdna\main.obj"
if exist "c:\sdna\report_debug.html" del "c:\sdna\report_debug.html"

echo --- Diagnostica Ambiente (DEBUG) ---
if not exist "c:\sdna\main.asm" echo [ERRORE] Non trovo c:\sdna\main.asm
if not exist "%CRINKLER%" (
    echo [ERRORE] Non trovo %CRINKLER%
    echo Nella cartella %CRINKLER_PATH% vedo questi file:
    if exist "%CRINKLER_PATH%" (dir "%CRINKLER_PATH%" /b) else (echo La cartella %CRINKLER_PATH% non esiste!)
    echo.
    goto :error
)

where nasm >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERRORE] NASM non e nel PATH. Assicurati di averlo installato e aggiunto alle variabili d'ambiente.
    goto :error
)
echo ---------------------------

:: 1. Compila i file ASM in oggetti 32-bit
nasm -f win32 c:\sdna\main.asm -o c:\sdna\main.obj
if %errorlevel% neq 0 (
    echo Errore durante l'assemblaggio!
    goto :error
)

nasm -f win32 c:\sdna\4klang.asm -o c:\sdna\4klang.obj
if %errorlevel% neq 0 (
    echo Errore durante l'assemblaggio di 4klang.asm!
    goto :error
)

:: 2. Linka l'oggetto per creare l'eseguibile (.exe) - SENZA OPZIONI TINY
echo Linking con Crinkler (DEBUG MODE)...
:: Usiamo /LIBPATH:. per dire a Crinkler di guardare nella cartella corrente
:: Rimossi /TINYIMPORT e /TINYHEADER per facilitare il debug
"%CRINKLER%" /SUBSYSTEM:WINDOWS /LIBPATH:c:\sdna /ENTRY:main /EXPORT:NvOptimusEnablement /EXPORT:AmdPowerXpressRequestHighPerformance /REPORT:c:\sdna\report_debug.html c:\sdna\main.obj c:\sdna\4klang.obj kernel32.lib user32.lib gdi32.lib opengl32.lib winmm.lib /OUT:c:\sdna\sdna.exe
if %errorlevel% neq 0 (
    echo Errore durante il linking!
    goto :error
)

echo Build DEBUG completata! Eseguo sdna.exe...
if exist "c:\sdna\sdna.exe" (
    "c:\sdna\sdna.exe"
) else (
    echo [ERRORE] sdna.exe non e stato creato.
)
exit /b

:error
pause
exit /b