<#
.SYNOPSIS
    One-click runner for the SOC Analyst Dashboard demo.

.DESCRIPTION
    - Generates synthetic events
    - Runs brute-force and malware detections
    - Opens the dashboard in your default browser

.EXAMPLES
    .\Start-SOCDashboard.ps1
    .\Start-SOCDashboard.ps1 -Hours 12 -EventCount 8000
    .\Start-SOCDashboard.ps1 -NoBrowser
#>

[CmdletBinding()]
param(
    [ValidateRange(1,720)] [int] $Hours = 6,
    [ValidateRange(1,1000000)] [int] $EventCount = 2000,
    [switch] $NoBrowser
)

# Fail fast and write files as UTF-8
$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Allow child scripts this session
try { Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force } catch {}

# Resolve repo root and cd there
$Root = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
Set-Location $Root

# Paths
$scripts   = Join-Path $Root 'scripts'
$dataBase  = Join-Path $Root 'data'
$logsDir   = Join-Path $dataBase 'logs'
$reports   = Join-Path $dataBase 'reports'
$sample    = Join-Path $dataBase 'sample-logs'
$indexHtml = Join-Path $Root 'dashboard\index.html'

# Ensure folders
New-Item -ItemType Directory -Force -Path $logsDir, $reports, $sample | Out-Null

Write-Host '=== SOC Analyst Dashboard: Run Start ===' -ForegroundColor Cyan
Write-Host ('Repo Root      : {0}' -f $Root)      -ForegroundColor DarkGray
Write-Host ('Data (logs)    : {0}' -f $logsDir)   -ForegroundColor DarkGray
Write-Host ('Data (reports) : {0}' -f $reports)   -ForegroundColor DarkGray
Write-Host ('Data (samples) : {0}' -f $sample)    -ForegroundColor DarkGray
Write-Host ''

# 1) Generate synthetic data
Write-Host ("[1/3] Generating events (Hours={0}, EventCount={1})..." -f $Hours, $EventCount) -ForegroundColor Yellow
& (Join-Path $scripts 'Generate-SecurityEvents.ps1') -Hours $Hours -EventCount $EventCount -Verbose:$true

# 2) Run detections
Write-Host '[2/3] Running brute-force detection...' -ForegroundColor Yellow
& (Join-Path $scripts 'Detect-BruteForce.ps1') -OutputBasePath $dataBase -InputCsv (Join-Path $sample 'security_events.csv')

Write-Host '[2/3] Running malware detection...' -ForegroundColor Yellow
& (Join-Path $scripts 'Detect-Malware.ps1') -OutputBasePath $dataBase -InputCsv (Join-Path $sample 'network_events.csv')

# 3) Open dashboard
Write-Host '[3/3] Opening dashboard...' -ForegroundColor Yellow
if (-not $NoBrowser) {
    if (Test-Path $indexHtml) {
        Start-Process $indexHtml
        Write-Host ('Dashboard opened: {0}' -f $indexHtml) -ForegroundColor Green
    } else {
        Write-Warning ('Could not find dashboard at: {0}' -f $indexHtml)
    }
} else {
    Write-Host 'NoBrowser set - skipping dashboard open.' -ForegroundColor DarkGray
}

Write-Host ''
Write-Host '=== SOC Analyst Dashboard: Run Complete ===' -ForegroundColor Cyan
Write-Host ('Latest sample CSVs: {0}' -f $sample)  -ForegroundColor DarkGray
Write-Host ('Latest reports    : {0}' -f $reports) -ForegroundColor DarkGray
