# Test-SOCDashboard.ps1
# Quick validation test for SOC Analyst Dashboard
# Runs a complete workflow test with minimal data

Write-Host "=== SOC Analyst Dashboard - System Test ===" -ForegroundColor Cyan
Write-Host "Running complete workflow validation..." -ForegroundColor Yellow
Write-Host ""

# Test 1: Generate small dataset
Write-Host "1. Testing security event generation..." -ForegroundColor Yellow
try {
    & ".\scripts\Generate-SecurityEvents.ps1" -Hours 1 -EventCount 500
    Write-Host "   ✅ Event generation: PASSED" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Event generation: FAILED - $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Brute force detection
Write-Host "2. Testing brute force detection..." -ForegroundColor Yellow
try {
    & ".\scripts\Detect-BruteForce.ps1"
    Write-Host "   ✅ Brute force detection: PASSED" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Brute force detection: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Malware detection
Write-Host "3. Testing malware detection..." -ForegroundColor Yellow
try {
    & ".\scripts\Detect-Malware.ps1"
    Write-Host "   ✅ Malware detection: PASSED" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Malware detection: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Check file outputs
Write-Host "4. Validating output files..." -ForegroundColor Yellow
$ExpectedFiles = @(
    ".\data\sample-logs\security_events.csv",
    ".\data\sample-logs\network_events.csv",
    ".\data\reports\brute_force_summary.csv",
    ".\data\reports\malware_communications.csv"
)

foreach ($File in $ExpectedFiles) {
    if (Test-Path $File) {
        Write-Host "   ✅ $File exists" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  $File missing" -ForegroundColor Yellow
    }
}

Write-Host ""

# Test 5: Dashboard files
Write-Host "5. Checking dashboard files..." -ForegroundColor Yellow
$DashboardFiles = @(
    ".\dashboard\index.html",
    ".\dashboard\css\styles.css",
    ".\dashboard\js\dashboard.js"
)

foreach ($File in $DashboardFiles) {
    if (Test-Path $File) {
        Write-Host "   ✅ $File exists" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $File missing" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== TEST COMPLETE ===" -ForegroundColor Cyan
Write-Host "To open dashboard: start .\dashboard\index.html" -ForegroundColor Yellow
Write-Host "Reports located in: .\data\reports\" -ForegroundColor Yellow
