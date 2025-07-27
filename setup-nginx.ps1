# PowerShell script to setup Nginx configuration

$ErrorActionPreference = 'Stop'

# Function to check if running as administrator
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Check if running as administrator
if (-not (Test-Administrator)) {
    Write-Error "This script must be run as Administrator. Please restart PowerShell as Administrator."
    exit 1
}

# Check if Nginx is installed and get its path
$nginxPath = $null
try {
    $nginxPath = (Get-Command nginx -ErrorAction SilentlyContinue).Source
} catch {
    Write-Error "Nginx is not found in PATH. Please install Nginx first."
    exit 1
}

# Get Nginx root directory
$nginxRoot = Split-Path -Parent $nginxPath

# Backup existing nginx.conf if it exists
$nginxConfPath = Join-Path $nginxRoot "conf\nginx.conf"
if (Test-Path $nginxConfPath) {
    $backupPath = "$nginxConfPath.backup"
    Copy-Item -Path $nginxConfPath -Destination $backupPath -Force
    Write-Host "Backed up existing nginx.conf to $backupPath"
}

# Copy our sample configuration
$sampleConfPath = Join-Path $PSScriptRoot "nginx.sample.conf"
if (-not (Test-Path $sampleConfPath)) {
    Write-Error "nginx.sample.conf not found in the current directory"
    exit 1
}

Copy-Item -Path $sampleConfPath -Destination $nginxConfPath -Force
Write-Host "Copied nginx.sample.conf to $nginxConfPath"

# Create necessary directories for logs
$logPath = Join-Path $nginxRoot "logs"
if (-not (Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath -Force
}

# Test the nginx configuration
$testResult = & nginx -t 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Nginx configuration test failed: $testResult"
    exit 1
}

# Restart Nginx
Write-Host "Restarting Nginx..."
try {
    # Stop Nginx if it's running
    $nginxProcess = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
    if ($nginxProcess) {
        & nginx -s stop
        Start-Sleep -Seconds 2
    }
    
    # Start Nginx
    Start-Process -FilePath "nginx" -NoNewWindow
    Write-Host "Nginx has been started successfully"
} catch {
    Write-Error "Failed to restart Nginx: $_"
    exit 1
}

Write-Host "Nginx configuration has been updated and service restarted."
Write-Host "You can access the application at http://localhost:8080"