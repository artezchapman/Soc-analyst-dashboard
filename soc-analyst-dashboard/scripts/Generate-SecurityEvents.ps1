# Generate-SecurityEvents.ps1
# Creates realistic Windows security events for SOC analysis demonstration
# Author: Artez Chapman
# Purpose: Generate synthetic security data for threat detection testing

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [int]$Hours = 24,
    
    [Parameter(Mandatory=$false)]
    [int]$EventCount = 10000,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\data\sample-logs\"
)

Write-Host "SOC Analyst Dashboard - Security Event Generator" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Ensure output directory exists
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Host "Created output directory: $OutputPath" -ForegroundColor Green
}

# Generate timestamp range
$EndTime = Get-Date
$StartTime = $EndTime.AddHours(-$Hours)

Write-Host "Generating $EventCount events over $Hours hours..." -ForegroundColor Yellow
Write-Host "Time Range: $($StartTime.ToString('yyyy-MM-dd HH:mm:ss')) to $($EndTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Yellow

# Define realistic source IPs (mix of internal and external)
$InternalIPs = @(
    "192.168.1.100", "192.168.1.101", "192.168.1.102", "192.168.1.150",
    "10.0.0.10", "10.0.0.11", "10.0.0.25", "10.0.0.50",
    "172.16.1.10", "172.16.1.20", "172.16.2.5"
)

$ExternalIPs = @(
    "203.0.113.15", "198.51.100.25", "203.0.113.195", "198.51.100.178",
    "185.220.101.42", "185.220.102.8", "45.33.32.156", "104.244.72.115"
)

$MaliciousIPs = @(
    "185.220.101.42", "45.33.32.156", "104.244.72.115", "203.0.113.195"
)

# Define realistic usernames
$ValidUsers = @(
    "jsmith", "mbrown", "agarcia", "kwilson", "lmiller", "ddavis", "smartin",
    "rjohnson", "ewilliams", "slee", "admin", "administrator", "service_account"
)

$AttackerUsers = @(
    "admin", "administrator", "root", "test", "user", "guest", "postgres", "oracle"
)

# Initialize collections
$SecurityEvents = @()
$NetworkEvents = @()
$FileEvents = @()

# Generate normal security events (80% of total)
$NormalEventCount = [int]($EventCount * 0.8)
Write-Host "Generating $NormalEventCount normal security events..." -ForegroundColor Green

for ($i = 0; $i -lt $NormalEventCount; $i++) {
    $EventTime = $StartTime.AddMinutes((Get-Random -Maximum ([int]($Hours * 60))))
    $SourceIP = $InternalIPs | Get-Random
    $User = $ValidUsers | Get-Random
    
    # Normal successful logons (Event ID 4624)
    if ((Get-Random -Maximum 10) -lt 7) {
        $SecurityEvents += [PSCustomObject]@{
            Timestamp = $EventTime.ToString("yyyy-MM-dd HH:mm:ss")
            EventID = 4624
            EventType = "Successful Logon"
            SourceIP = $SourceIP
            Username = $User
            Severity = "Information"
            Description = "An account was successfully logged on"
        }
    }
    # Normal file access events
    else {
        $SecurityEvents += [PSCustomObject]@{
            Timestamp = $EventTime.ToString("yyyy-MM-dd HH:mm:ss")
            EventID = 4656
            EventType = "File Access"
            SourceIP = $SourceIP
            Username = $User
            Severity = "Information"
            Description = "A handle to an object was requested"
        }
    }
}

# Generate brute force attack events (8% of total)
$BruteForceCount = [int]($EventCount * 0.08)
Write-Host "Generating $BruteForceCount brute force attack events..." -ForegroundColor Red

$AttackerIP = $ExternalIPs | Get-Random
$TargetUser = $AttackerUsers | Get-Random
$AttackStartTime = $StartTime.AddHours((Get-Random -Maximum ($Hours - 2)))

for ($i = 0; $i -lt $BruteForceCount; $i++) {
    $EventTime = $AttackStartTime.AddMinutes((Get-Random -Maximum 120))
    
    $SecurityEvents += [PSCustomObject]@{
        Timestamp = $EventTime.ToString("yyyy-MM-dd HH:mm:ss")
        EventID = 4625
        EventType = "Failed Logon"
        SourceIP = $AttackerIP
        Username = $TargetUser
        Severity = "Warning"
        Description = "An account failed to log on - possible brute force attempt"
    }
}

# Generate malware communication events (5% of total)
$MalwareCount = [int]($EventCount * 0.05)
Write-Host "Generating $MalwareCount malware communication events..." -ForegroundColor Red

for ($i = 0; $i -lt $MalwareCount; $i++) {
    $EventTime = $StartTime.AddMinutes((Get-Random -Maximum ([int]($Hours * 60))))
    $InfectedHost = $InternalIPs | Get-Random
    $MaliciousServer = $MaliciousIPs | Get-Random
    
    $NetworkEvents += [PSCustomObject]@{
        Timestamp = $EventTime.ToString("yyyy-MM-dd HH:mm:ss")
        SourceIP = $InfectedHost
        DestinationIP = $MaliciousServer
        Port = @(80, 443, 8080, 9999) | Get-Random
        Protocol = "TCP"
        Bytes = Get-Random -Minimum 1024 -Maximum 102400
        EventType = "Malware Communication"
        Severity = "High"
        Description = "Suspicious outbound connection to known malicious IP"
    }
}

# Generate data exfiltration events (2% of total)
$ExfilCount = [int]($EventCount * 0.02)
Write-Host "Generating $ExfilCount data exfiltration events..." -ForegroundColor Red

for ($i = 0; $i -lt $ExfilCount; $i++) {
    # Data exfiltration typically happens during off-hours
    $OffHour = Get-Random -Minimum 22 -Maximum 6
    if ($OffHour -gt 12) { $OffHour -= 24 }
    
    $EventTime = $StartTime.AddDays((Get-Random -Maximum 1)).Date.AddHours($OffHour).AddMinutes((Get-Random -Maximum 60))
    $SourceHost = $InternalIPs | Get-Random
    $ExternalServer = $ExternalIPs | Get-Random
    $SuspiciousUser = $ValidUsers | Get-Random
    
    # Large file transfer event
    $NetworkEvents += [PSCustomObject]@{
        Timestamp = $EventTime.ToString("yyyy-MM-dd HH:mm:ss")
        SourceIP = $SourceHost
        DestinationIP = $ExternalServer
        Port = 443
        Protocol = "HTTPS"
        Bytes = Get-Random -Minimum 104857600 -Maximum 1073741824  # 100MB to 1GB
        EventType = "Large Data Transfer"
        Severity = "Critical"
        Description = "Unusually large data transfer during off-hours"
    }
    
    # Corresponding file access event
    $FileEvents += [PSCustomObject]@{
        Timestamp = $EventTime.AddMinutes(-5).ToString("yyyy-MM-dd HH:mm:ss")
        EventID = 4663
        EventType = "Sensitive File Access"
        SourceIP = $SourceHost
        Username = $SuspiciousUser
        FileName = @("employees.xlsx", "financial_data.csv", "customer_db.sql", "passwords.txt") | Get-Random
        Severity = "High"
        Description = "Access to sensitive file during unusual hours"
    }
}

# Fill remaining events with normal network traffic
$RemainingCount = $EventCount - $SecurityEvents.Count - $NetworkEvents.Count - $FileEvents.Count
Write-Host "Generating $RemainingCount normal network events..." -ForegroundColor Green

for ($i = 0; $i -lt $RemainingCount; $i++) {
    $EventTime = $StartTime.AddMinutes((Get-Random -Maximum ([int]($Hours * 60))))
    $SourceHost = $InternalIPs | Get-Random
    $DestHost = $ExternalIPs | Get-Random
    
    $NetworkEvents += [PSCustomObject]@{
        Timestamp = $EventTime.ToString("yyyy-MM-dd HH:mm:ss")
        SourceIP = $SourceHost
        DestinationIP = $DestHost
        Port = @(80, 443, 53, 993, 995) | Get-Random
        Protocol = @("HTTP", "HTTPS", "DNS", "IMAPS", "POP3S") | Get-Random
        Bytes = Get-Random -Minimum 512 -Maximum 51200
        EventType = "Normal Traffic"
        Severity = "Information"
        Description = "Normal network communication"
    }
}

# Export all events to CSV files
Write-Host "`nExporting events to CSV files..." -ForegroundColor Yellow

$SecurityEvents | Sort-Object Timestamp | Export-Csv -Path "$OutputPath\security_events.csv" -NoTypeInformation
Write-Host "Security events exported: $($SecurityEvents.Count) events -> security_events.csv" -ForegroundColor Green

$NetworkEvents | Sort-Object Timestamp | Export-Csv -Path "$OutputPath\network_events.csv" -NoTypeInformation  
Write-Host "Network events exported: $($NetworkEvents.Count) events -> network_events.csv" -ForegroundColor Green

$FileEvents | Sort-Object Timestamp | Export-Csv -Path "$OutputPath\file_events.csv" -NoTypeInformation
Write-Host "File events exported: $($FileEvents.Count) events -> file_events.csv" -ForegroundColor Green

# Generate summary report
$TotalEvents = $SecurityEvents.Count + $NetworkEvents.Count + $FileEvents.Count

$Summary = @"
SOC Analyst Dashboard - Event Generation Summary
===============================================
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Time Period: $($StartTime.ToString('yyyy-MM-dd HH:mm:ss')) to $($EndTime.ToString('yyyy-MM-dd HH:mm:ss'))

Event Breakdown:
- Security Events: $($SecurityEvents.Count)
  * Successful Logons: $(($SecurityEvents | Where-Object {$_.EventID -eq 4624}).Count)
  * Failed Logons (Brute Force): $(($SecurityEvents | Where-Object {$_.EventID -eq 4625}).Count)
  * File Access Events: $(($SecurityEvents | Where-Object {$_.EventID -eq 4656}).Count)

- Network Events: $($NetworkEvents.Count)
  * Normal Traffic: $(($NetworkEvents | Where-Object {$_.EventType -eq 'Normal Traffic'}).Count)
  * Malware Communications: $(($NetworkEvents | Where-Object {$_.EventType -eq 'Malware Communication'}).Count)
  * Large Data Transfers: $(($NetworkEvents | Where-Object {$_.EventType -eq 'Large Data Transfer'}).Count)

- File Events: $($FileEvents.Count)
  * Sensitive File Access: $($FileEvents.Count)

Total Events: $TotalEvents

Threat Indicators Planted:
- Brute Force Attacks: $(($SecurityEvents | Where-Object {$_.EventID -eq 4625} | Group-Object SourceIP | Measure-Object).Count) source IPs
- Malware Communications: $(($NetworkEvents | Where-Object {$_.EventType -eq 'Malware Communication'} | Group-Object DestinationIP | Measure-Object).Count) malicious destinations  
- Data Exfiltration: $(($NetworkEvents | Where-Object {$_.EventType -eq 'Large Data Transfer'}).Count) suspicious transfers

Files Created:
- $OutputPath\security_events.csv
- $OutputPath\network_events.csv  
- $OutputPath\file_events.csv
- $OutputPath\generation_summary.txt

Next Steps:
1. Run .\scripts\Detect-BruteForce.ps1 to analyze failed logons
2. Run .\scripts\Detect-Malware.ps1 to identify malicious communications
3. Run .\scripts\Analyze-NetworkTraffic.ps1 for traffic pattern analysis
4. Open .\dashboard\index.html to view SOC dashboard
"@

$Summary | Out-File -FilePath "$OutputPath\generation_summary.txt" -Encoding UTF8
Write-Host "`nGeneration Summary:" -ForegroundColor Cyan
Write-Host $Summary -ForegroundColor White

Write-Host "`n✅ Event generation completed successfully!" -ForegroundColor Green
Write-Host "📁 Files saved to: $OutputPath" -ForegroundColor Green
Write-Host "📊 Ready for threat analysis - run the detection scripts next!" -ForegroundColor Yellow