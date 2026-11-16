@echo off
setlocal enabledelayedexpansion
title Smart AI Library Management System

echo =====================================================================
echo       SMART AI LIBRARY MANAGEMENT SYSTEM - ONE TOUCH LAUNCHER
echo =====================================================================
echo.

:: 1. Check Java
echo [1/3] Checking Java runtime environment...
where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Java is not installed or not in PATH. Please install Java 17+.
    pause
    exit /b 1
)

:: 2. Check Port 8080
echo [2/3] Checking port 8080 status...
netstat -ano | findstr :8080 | findstr LISTENING >nul 2>nul
if %errorlevel% equ 0 (
    powershell -NoProfile -Command "try { $r = [System.Net.WebRequest]::Create('http://localhost:8080/login').GetResponse(); if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
    if !errorlevel! equ 0 (
        echo [INFO] Smart AI Library Management System is already active and running!
        echo [INFO] Opening browser to http://localhost:8080/login ...
        start http://localhost:8080/login
        goto :display_info
    ) else (
        echo [INFO] Freeing port 8080 from previous background process...
        for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080 ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>nul
        timeout /t 2 /nobreak >nul
    )
)

:: 3. Prepare JAR
cd /d "%~dp0"
set JAR_FILE=target\smart-library-system-1.0.0.jar
if not exist "%JAR_FILE%" (
    echo Executable JAR not found. Packaging with Maven wrapper...
    call mvnw.cmd package -DskipTests
    if %errorlevel% neq 0 (
        echo [ERROR] Maven build failed.
        pause
        exit /b 1
    )
)

:display_info
echo [3/3] Starting Smart AI Library Management System...
echo.
echo ---------------------------------------------------------------------
echo  PORTAL URL    : http://localhost:8080
echo.
echo  PRE-CONFIGURED LOGINS:
echo   * Student : username=student   password=student123
echo   * Staff   : username=staff     password=staff123
echo   * Admin   : username=admin     password=admin123
echo ---------------------------------------------------------------------
echo.

:: If already running and opened browser, we can stay open for reference or exit
netstat -ano | findstr :8080 | findstr LISTENING >nul 2>nul
if %errorlevel% equ 0 (
    echo Application is running at http://localhost:8080. Press any key to exit this launcher window.
    pause >nul
    exit /b 0
)

echo Launching browser automatically once server is ready...
start "" powershell -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Seconds 3; for ($i=0; $i -lt 30; $i++) { try { $r = [System.Net.WebRequest]::Create('http://localhost:8080/login').GetResponse(); if ($r.StatusCode -eq 200) { Start-Process 'http://localhost:8080/login'; break } } catch { Start-Sleep -Seconds 1 } }"

java -jar "%JAR_FILE%"

if %errorlevel% neq 0 (
    echo.
    echo Application process stopped with code %errorlevel%.
    pause
)
