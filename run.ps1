<#
.SYNOPSIS
    One-touch launcher for Smart AI Library Management System.
.DESCRIPTION
    Checks Java, checks port 8080, packages JAR if needed, starts Spring Boot, and auto-opens browser.
#>

$Host.UI.RawUI.WindowTitle = "Smart AI Library Management System - One Touch Launcher"
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "      SMART AI LIBRARY MANAGEMENT SYSTEM - ONE TOUCH LAUNCHER" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check Java
Write-Host "[1/3] Checking Java runtime environment..." -ForegroundColor Yellow
try {
    $javaVer = & java -version 2>&1
    Write-Host "Found Java: $($javaVer[0])" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Java is not installed or not found in PATH. Java 17+ is required." -ForegroundColor Red
    pause
    exit 1
}

# 2. Check Port 8080
Write-Host "[2/3] Checking port 8080 status..." -ForegroundColor Yellow
$portOccupied = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue
if ($portOccupied) {
    try {
        $req = [System.Net.WebRequest]::Create("http://localhost:8080/login")
        $res = $req.GetResponse()
        if ($res.StatusCode -eq 200) {
            Write-Host "[INFO] Smart AI Library Management System is already active and running!" -ForegroundColor Green
            Write-Host "[INFO] Opening browser to http://localhost:8080/login ..." -ForegroundColor Cyan
            Start-Process "http://localhost:8080/login"
            
            Write-Host ""
            Write-Host "---------------------------------------------------------------------" -ForegroundColor White
            Write-Host " PORTAL URL    : http://localhost:8080" -ForegroundColor Cyan
            Write-Host ""
            Write-Host " PRE-CONFIGURED LOGINS:" -ForegroundColor White
            Write-Host "   * Student : username=student   password=student123" -ForegroundColor Green
            Write-Host "   * Staff   : username=staff     password=staff123" -ForegroundColor Yellow
            Write-Host "   * Admin   : username=admin     password=admin123" -ForegroundColor Magenta
            Write-Host "---------------------------------------------------------------------" -ForegroundColor White
            Write-Host ""
            Write-Host "Press enter to exit launcher window." -ForegroundColor Gray
            Read-Host
            exit 0
        }
    } catch {
        Write-Host "[INFO] Freeing port 8080 from stale background process..." -ForegroundColor Yellow
        $pidToKill = $portOccupied[0].OwningProcess
        Stop-Process -Id $pidToKill -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
}

# 3. Check and prepare JAR
$jarPath = Join-Path $PSScriptRoot "target\smart-library-system-1.0.0.jar"
if (-not (Test-Path $jarPath)) {
    Write-Host "[3/3] Packaging executable JAR with Maven wrapper..." -ForegroundColor Yellow
    & "$PSScriptRoot\mvnw.cmd" package -DskipTests
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Build failed." -ForegroundColor Red
        pause
        exit 1
    }
} else {
    Write-Host "[3/3] Application JAR verified: $jarPath" -ForegroundColor Green
}

# 4. Display credentials
Write-Host ""
Write-Host "---------------------------------------------------------------------" -ForegroundColor White
Write-Host " PORTAL URL    : http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host " PRE-CONFIGURED LOGINS:" -ForegroundColor White
Write-Host "   * Student : username=student   password=student123" -ForegroundColor Green
Write-Host "   * Staff   : username=staff     password=staff123" -ForegroundColor Yellow
Write-Host "   * Admin   : username=admin     password=admin123" -ForegroundColor Magenta
Write-Host "---------------------------------------------------------------------" -ForegroundColor White
Write-Host ""

# Background job to open browser once ready
Start-Job -ScriptBlock {
    Start-Sleep -Seconds 3
    for ($i = 0; $i -lt 30; $i++) {
        try {
            $req = [System.Net.WebRequest]::Create("http://localhost:8080/login")
            $res = $req.GetResponse()
            if ($res.StatusCode -eq 200) {
                Start-Process "http://localhost:8080/login"
                break
            }
        } catch {
            Start-Sleep -Seconds 1
        }
    }
} | Out-Null

Write-Host "Starting Spring Boot application..." -ForegroundColor Green
Write-Host "(Your browser will automatically open to http://localhost:8080/login when ready)" -ForegroundColor Gray
Write-Host ""

& java -jar $jarPath
