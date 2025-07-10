@echo off
REM ============================================================================
REM  TLS Inspection CA Certificate Installation Script for Windows 11
REM ============================================================================

setlocal enabledelayedexpansion

REM Ensure we are in the script directory
cd /d "%~dp0"

REM Use the first argument as the cert file name
if "%~1"=="" (
    echo ❌ No certificate file provided.
    echo Usage: %~nx0 your-cert.pem
    exit /b 1
)

set CERT_FILE=%~1

echo ====================================================================
echo  Installing TLS Inspection CA Certificate
echo ====================================================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as Administrator
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

REM Check if certificate file exists
if not exist "%CERT_FILE%" (
    echo [ERROR] Certificate file not found: %CERT_FILE%
    echo Please ensure the certificate file is in the correct location
    pause
    exit /b 1
)

echo [INFO] Certificate file found: %CERT_FILE%
echo.

REM Install CA certificate to System Root Store (for Chrome, Edge, IE)
echo [1/4] Installing CA certificate to Windows System Root Store...
certutil -addstore "Root" "%CERT_FILE%"
if %errorLevel% neq 0 (
    echo [ERROR] Failed to install certificate to System Root Store
    pause
    exit /b 1
)
echo [✓] Certificate installed to System Root Store

REM Install CA certificate to Current User Root Store (backup)
echo [2/4] Installing CA certificate to Current User Root Store...
certutil -addstore -user "Root" "%CERT_FILE%"
if %errorLevel% neq 0 (
    echo [WARNING] Failed to install certificate to Current User Root Store
) else (
    echo [✓] Certificate installed to Current User Root Store
)

REM Firefox Certificate Installation (if Firefox is installed)
echo [3/4] Checking for Firefox installation...
set "FIREFOX_INSTALLED=0"

if exist "%PROGRAMFILES%\Mozilla Firefox\firefox.exe" (
    set "FIREFOX_INSTALLED=1"
    set "FIREFOX_PATH=%PROGRAMFILES%\Mozilla Firefox"
)

if exist "%PROGRAMFILES(X86)%\Mozilla Firefox\firefox.exe" (
    set "FIREFOX_INSTALLED=1"
    set "FIREFOX_PATH=%PROGRAMFILES(X86)%\Mozilla Firefox"
)

if !FIREFOX_INSTALLED! equ 1 (
    echo [INFO] Firefox detected at: !FIREFOX_PATH!
    echo [INFO] Firefox uses its own certificate store
    echo [INFO] Certificate must be installed manually in Firefox:
    echo        1. Open Firefox
    echo        2. Go to Settings ^> Privacy ^& Security
    echo        3. Scroll to Certificates ^> View Certificates
    echo        4. Authorities tab ^> Import
    echo        5. Select: %CERT_FILE%
    echo        6. Check "Trust this CA to identify websites"
    echo.
) else (
    echo [INFO] Firefox not detected
)

REM Clear certificate caches
echo [4/4] Clearing certificate caches...
certutil -setreg chain\ChainCacheResyncFiletime @now >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Failed to clear certificate cache
) else (
    echo [✓] Certificate cache cleared
)

echo.
echo ====================================================================
echo  Installation Summary
echo ====================================================================
echo [✓] CA Certificate installed to Windows System Root Store
echo [✓] CA Certificate installed to Current User Root Store
echo [✓] Certificate caches cleared
echo.


echo.
echo ====================================================================
echo  Post-Installation Instructions
echo ====================================================================
echo.
echo 1. RESTART ALL BROWSERS (Chrome, Edge, Firefox)
echo    - Close all browser windows completely
echo    - Wait 30 seconds
echo    - Reopen browsers
echo.
echo 2. For Firefox (if installed):
echo    - Follow the manual installation steps shown above
echo.
echo 3. Test TLS Inspection:
echo    - Browse to any HTTPS website
echo    - Certificate should be accepted without warnings
echo.
echo 4. Troubleshooting:
echo    - If certificate warnings persist, clear browser cache
echo    - Chrome: chrome://settings/clearBrowserData
echo    - Edge: edge://settings/clearBrowserData
echo    - Firefox: Clear all browsing data
echo.
echo ====================================================================
echo  Installation Complete
echo ====================================================================
echo.
echo The CA certificate has been installed successfully.
echo TLS Inspection should now work without certificate warnings.
echo.
pause