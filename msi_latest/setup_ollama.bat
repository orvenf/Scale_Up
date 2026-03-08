@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Scale Up - Ollama Setup
color 0A

echo.
echo  ===================================================
echo    Scale Up - Ollama Configuration
echo    Sets CORS, keep-alive, and warms your model
echo  ===================================================
echo.

:: ── Check if Ollama is installed ──────────────────────────────────────
where ollama >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo  [FAIL] Ollama is not installed or not in PATH.
    echo         Download from: https://ollama.com
    echo.
    pause
    exit /b 1
)
echo  [OK] Ollama found: 
ollama --version 2>nul || echo         (version check unavailable)
echo.

:: ── Set OLLAMA_ORIGINS system env var ─────────────────────────────────
echo  [....] Setting OLLAMA_ORIGINS=* (allows Scale Up to connect)...
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v OLLAMA_ORIGINS >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo  [OK] OLLAMA_ORIGINS already set.
) else (
    setx OLLAMA_ORIGINS "*" /M >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo  [OK] OLLAMA_ORIGINS=* set as system variable.
    ) else (
        echo  [WARN] Could not set system variable. Run this script as Administrator.
        echo         Or set manually: System Properties ^> Environment Variables ^> New
        echo         Name: OLLAMA_ORIGINS   Value: *
    )
)

:: ── Set OLLAMA_KEEP_ALIVE system env var ──────────────────────────────
echo  [....] Setting OLLAMA_KEEP_ALIVE=-1 (model stays loaded permanently)...
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v OLLAMA_KEEP_ALIVE >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo  [OK] OLLAMA_KEEP_ALIVE already set.
) else (
    setx OLLAMA_KEEP_ALIVE "-1" /M >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo  [OK] OLLAMA_KEEP_ALIVE=-1 set as system variable.
    ) else (
        echo  [WARN] Could not set system variable. Run this script as Administrator.
        echo         Or set manually: System Properties ^> Environment Variables ^> New
        echo         Name: OLLAMA_KEEP_ALIVE   Value: -1
    )
)
echo.

:: ── Apply env vars to current session ─────────────────────────────────
set "OLLAMA_ORIGINS=*"
set "OLLAMA_KEEP_ALIVE=-1"

:: ── Restart Ollama ────────────────────────────────────────────────────
echo  [....] Restarting Ollama...
taskkill /f /im ollama.exe >nul 2>&1
timeout /t 2 /nobreak >nul

:: Start Ollama in background
start "" /min ollama serve
timeout /t 3 /nobreak >nul

:: Verify it's running
curl -s http://127.0.0.1:11434/ >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo  [OK] Ollama is running on port 11434.
) else (
    echo  [WARN] Ollama may still be starting. Waiting 5 more seconds...
    timeout /t 5 /nobreak >nul
    curl -s http://127.0.0.1:11434/ >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo  [OK] Ollama is running.
    ) else (
        echo  [FAIL] Ollama did not start. Check if another instance is running.
        pause
        exit /b 1
    )
)
echo.

:: ── List installed models ─────────────────────────────────────────────
echo  [....] Installed models:
echo  ---------------------------------------------------
ollama list 2>nul
echo  ---------------------------------------------------
echo.

:: ── Ask which model to warm up ────────────────────────────────────────
set "MODEL="
set /p MODEL="  Enter model name to warm up (e.g. gemma3:4b): "

if "%MODEL%"=="" (
    echo  [SKIP] No model specified. You can warm up later with:
    echo         curl http://127.0.0.1:11434/api/generate -d "{\"model\":\"YOUR_MODEL\",\"keep_alive\":-1,\"prompt\":\"hi\",\"stream\":false}"
    echo.
    goto :done
)

:: ── Warm up the model ─────────────────────────────────────────────────
echo.
echo  [....] Warming up %MODEL% (this may take 30-60 seconds on first load)...
curl -s http://127.0.0.1:11434/api/generate -d "{\"model\":\"%MODEL%\",\"keep_alive\":-1,\"prompt\":\"hello\",\"stream\":false}" >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo  [OK] %MODEL% is loaded and ready.
) else (
    echo  [FAIL] Could not warm up %MODEL%. Check if the model is installed:
    echo         ollama pull %MODEL%
)

:done
echo.
echo  ===================================================
echo    Setup Complete
echo.
echo    In Scale Up Config, use:
echo      API Key:     http://127.0.0.1:11434
echo      Model:       %MODEL%
echo.
echo    Remember: use 127.0.0.1, not localhost
echo  ===================================================
echo.
pause
