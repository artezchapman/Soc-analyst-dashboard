# Detect-BruteForce.ps1
# Analyzes security events for brute force attack patterns
# Author: Artez Chapman
# Purpose: Demonstrate SOC analyst threat detection capabilities

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$LogPath = ".\data\sample-logs\security_events.csv",
    
    [Parameter(Mandatory=$false)]
    [int]$FailureThreshold = 10,
    
    [Parameter(Mandatory=$false)]
    [int]$TimeWindowMinutes = 60,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\docs\incident-reports\"
)

Write-Host "SOC Analyst Dashboard - Brute Force Detection Engine" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# Ensure output directory exists
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Host "Created output directory: $OutputPath" -ForegroundColor Green
}

# Check if log file exists
if (!(Test-Path $LogPath)) {
    Write-Host "❌ Error: Log file not found at $LogPath" -ForegroundColor Red
    Write-Host "Run Generate-SecurityEvents.ps1 first to create sample data" -ForegroundColor Yellow
    exit 1
}

Write-Host "📊 Analysis Parameters:" -ForegroundColor Yellow
Write-Host "   • Log File: $LogPath" -ForegroundColor White
Write-Host "   • Failure Threshold: $FailureThreshold attempts" -ForegroundColor White  
Write-Host "   • Time Window: $TimeWindowMinutes minutes" -ForegroundColor White
Write-Host ""

# Import security events
Write-Host "📂 Loading security events..." -ForegroundColor Yellow
try {
    $SecurityEvents = Import-Csv -Path $LogPath
    Write-Host "✅ Loaded $($SecurityEvents.Count) security events" -ForegroundColor Green
} catch {
    Write-Host "❌ Error loading security events: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Filter failed logon events (Event ID 4625)
$FailedLogons = $SecurityEvents | Where-Object { $_.EventID -eq 4625 }
Write-Host "🔍 Found $($FailedLogons.Count) failed logon attempts" -ForegroundColor Yellow

if ($FailedLogons.Count -eq 0) {
    Write-Host "ℹ️  No failed logon events found - no brute force threats detected" -ForegroundColor Green
    exit 0
}

# Group failed logons by source IP
$AttacksByIP = $FailedLogons | Group-Object SourceIP | Sort-Object Count -Descending

Write-Host "`n🎯 Analyzing attack patterns..." -ForegroundColor Yellow

$BruteForceAttacks = @()

foreach ($Attack in $AttacksByIP) {
    $SourceIP = $Attack.Name
    $FailureCount = $Attack.Count
    $Events = $Attack.Group
    
    Write-Host "   • $SourceIP`: $FailureCount attempts" -ForegroundColor White
    
    # Check if this IP exceeds the failure threshold
    if ($FailureCount -ge $FailureThreshold) {
        # Analyze timing to confirm it's within our time window
        $Timestamps = $Events | ForEach-Object { [DateTime]$_.Timestamp } | Sort-Object
        $FirstAttempt = $Timestamps[0]
        $LastAttempt = $Timestamps[-1]
        $AttackDuration = ($LastAttempt - $FirstAttempt).TotalMinutes
        
        # Get targeted usernames
        $TargetedUsers = ($Events | Group-Object Username | Sort-Object Count -Descending).Name -join ", "
        
        # Determine severity based on attack characteristics
        $Severity = if ($FailureCount -ge 50) { "Critical" }
                   elseif ($FailureCount -ge 25) { "High" } 
                   else { "Medium" }
        
        $BruteForceAttack = [PSCustomObject]@{
            SourceIP = $SourceIP
            FailureCount = $FailureCount
            FirstSeen = $FirstAttempt.ToString("yyyy-MM-dd HH:mm:ss")
            LastSeen = $LastAttempt.ToString("yyyy-MM-dd HH:mm:ss")
            Duration = [Math]::Round($AttackDuration, 2)
            TargetedUsers = $TargetedUsers
            UniqueUsers = ($Events | Group-Object Username | Measure-Object).Count
            Severity = $Severity
            Status = "Active"
            ThreatType = "Brute Force Attack"
        }
        
        $BruteForceAttacks += $BruteForceAttack
        
        Write-Host "      🚨 THREAT DETECTED - $Severity severity" -ForegroundColor Red
        Write-Host "         Duration: $([Math]::Round($AttackDuration, 2)) minutes" -ForegroundColor White
        Write-Host "         Targeted users: $TargetedUsers" -ForegroundColor White
    }
}

# Display results
Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "🔍 BRUTE FORCE DETECTION RESULTS" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan

if ($BruteForceAttacks.Count -eq 0) {
    Write-Host "✅ No brute force attacks detected" -ForegroundColor Green
    Write-Host "   All failed logon attempts are within normal thresholds" -ForegroundColor White
} else {
    Write-Host "🚨 BRUTE FORCE ATTACKS DETECTED: $($BruteForceAttacks.Count)" -ForegroundColor Red
    Write-Host ""
    
    foreach ($Attack in $BruteForceAttacks | Sort-Object FailureCount -Descending) {
        $SeverityColor = switch ($Attack.Severity) {
            "Critical" { "Magenta" }
            "High" { "Red" }
            "Medium" { "Yellow" }
            default { "White" }
        }
        
        Write-Host "┌─ Attack from $($Attack.SourceIP) [$($Attack.Severity)]" -ForegroundColor $SeverityColor
        Write-Host "├─ Attempts: $($Attack.FailureCount) over $($Attack.Duration) minutes" -ForegroundColor White
        Write-Host "├─ Time Range: $($Attack.FirstSeen) → $($Attack.LastSeen)" -ForegroundColor White
        Write-Host "├─ Targeted Users: $($Attack.TargetedUsers)" -ForegroundColor White
        Write-Host "└─ Unique Accounts: $($Attack.UniqueUsers)" -ForegroundColor White
        Write-Host ""
    }
}

# Generate incident reports
if ($BruteForceAttacks.Count -gt 0) {
    Write-Host "📄 Generating incident reports..." -ForegroundColor Yellow
    
    foreach ($Attack in $BruteForceAttacks) {
        $IncidentID = "BF-$(Get-Date -Format 'yyyyMMdd-HHmmss')-$($Attack.SourceIP -replace '\.','')"
        
        $IncidentReport = @"
SECURITY INCIDENT REPORT
========================

Incident ID: $IncidentID
Report Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Analyst: SOC Analyst Dashboard (Automated Detection)
Classification: $($Attack.Severity) Severity Brute Force Attack

THREAT SUMMARY
--------------
Threat Type: $($Attack.ThreatType)
Source IP: $($Attack.SourceIP)
Status: $($Attack.Status)
Risk Level: $($Attack.Severity)

ATTACK DETAILS
--------------
Failed Login Attempts: $($Attack.FailureCount)
Attack Duration: $($Attack.Duration) minutes
First Observed: $($Attack.FirstSeen)
Last Observed: $($Attack.LastSeen)
Targeted Usernames: $($Attack.TargetedUsers)
Unique Accounts Targeted: $($Attack.UniqueUsers)

IMPACT ASSESSMENT
-----------------
• Potential account compromise if attack succeeds
• Resource exhaustion from repeated authentication attempts
• Possible reconnaissance for valid usernames
• Risk of account lockouts affecting legitimate users

RECOMMENDED ACTIONS
-------------------
IMMEDIATE (0-15 minutes):
1. Block source IP $($Attack.SourceIP) at firewall/WAF
2. Monitor for successful logins from this IP
3. Check if any targeted accounts were compromised
4. Review account lockout policies

SHORT-TERM (15-60 minutes):
1. Analyze logs for additional attack patterns
2. Verify security controls are functioning properly
3. Notify affected users if accounts were locked
4. Update threat intelligence feeds with attacker IP

LONG-TERM (1+ hours):
1. Review and strengthen password policies
2. Consider implementing CAPTCHA or rate limiting
3. Evaluate need for multi-factor authentication
4. Conduct security awareness training

TECHNICAL DETAILS
-----------------
Detection Method: Failed logon event analysis (Event ID 4625)
Threshold: $FailureThreshold failed attempts in $TimeWindowMinutes minutes
Attack Pattern: Repetitive authentication failures from single IP
Confidence Level: High (automated signature match)

EVIDENCE PRESERVATION
--------------------
• Security event logs: $LogPath
• Source IP reputation: To be checked
• Network flow data: Available for analysis
• System integrity: To be verified

STATUS: OPEN - Requires immediate attention
PRIORITY: $($Attack.Severity)
ASSIGNED TO: SOC Analyst (Manual review required)

--- END REPORT ---
"@

        $ReportPath = "$OutputPath\$IncidentID.txt"
        $IncidentReport | Out-File -FilePath $ReportPath -Encoding UTF8
        Write-Host "   ✅ Report saved: $IncidentID.txt" -ForegroundColor Green
    }
    
    # Export summary data for dashboard
    $BruteForceAttacks | Export-Csv -Path "$OutputPath\brute_force_summary.csv" -NoTypeInformation
    Write-Host "   📊 Summary data: brute_force_summary.csv" -ForegroundColor Green
}

# Generate detection metrics
$DetectionMetrics = [PSCustomObject]@{
    Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    TotalEvents = $SecurityEvents.Count
    FailedLogons = $FailedLogons.Count
    UniqueSourceIPs = ($FailedLogons | Group-Object SourceIP | Measure-Object).Count
    ThreatsDetected = $BruteForceAttacks.Count
    CriticalThreats = ($BruteForceAttacks | Where-Object {$_.Severity -eq "Critical"}).Count
    HighThreats = ($BruteForceAttacks | Where-Object {$_.Severity -eq "High"}).Count
    MediumThreats = ($BruteForceAttacks | Where-Object {$_.Severity -eq "Medium"}).Count
    AnalysisTime = [Math]::Round(((Get-Date) - (Get-Date)).TotalSeconds, 2)
}

$DetectionMetrics | Export-Csv -Path "$OutputPath\detection_metrics.csv" -NoTypeInformation -Append

Write-Host "`n📈 DETECTION METRICS" -ForegroundColor Cyan
Write-Host "   • Total Events Analyzed: $($DetectionMetrics.TotalEvents)" -ForegroundColor White
Write-Host "   • Failed Logon Events: $($DetectionMetrics.FailedLogons)" -ForegroundColor White
Write-Host "   • Unique Source IPs: $($DetectionMetrics.UniqueSourceIPs)" -ForegroundColor White
Write-Host "   • Threats Detected: $($DetectionMetrics.ThreatsDetected)" -ForegroundColor $(if ($DetectionMetrics.ThreatsDetected -gt 0) {'Red'} else {'Green'})"

if ($BruteForceAttacks.Count -gt 0) {
    Write-Host "   • Critical: $($DetectionMetrics.CriticalThreats) | High: $($DetectionMetrics.HighThreats) | Medium: $($DetectionMetrics.MediumThreats)" -ForegroundColor White
}

Write-Host "`n🎯 NEXT STEPS" -ForegroundColor Yellow
if ($BruteForceAttacks.Count -gt 0) {
    Write-Host "   1. Review generated incident reports in $OutputPath" -ForegroundColor White
    Write-Host "   2. Implement recommended blocking actions" -ForegroundColor White
    Write-Host "   3. Monitor for successful logins from identified IPs" -ForegroundColor White
    Write-Host "   4. Run additional analysis scripts for comprehensive threat hunting" -ForegroundColor White
} else {
    Write-Host "   ✅ No immediate action required - continue monitoring" -ForegroundColor Green
    Write-Host "   📊 Consider running network traffic analysis for additional threats" -ForegroundColor White
}

Write-Host "`n✅ Brute force analysis completed!" -ForegroundColor Green