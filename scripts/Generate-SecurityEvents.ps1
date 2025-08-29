# Generate-SecurityEvents.ps1
# Professional SOC Analyst Dashboard - Security Event Generator
# Generates realistic security events for threat detection testing

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [int]$Hours = 24,
    
    [Parameter(Mandatory=$false)]
    [int]$EventCount = 10000,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\data\logs"
)

# Create output directory if it doesn't exist
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Host "Created output directory: $OutputPath" -ForegroundColor Green
}

# Create logs and reports subdirectories
$LogsPath = Join-Path $OutputPath "logs"
$ReportsPath = ".\data\reports"

if (!(Test-Path $LogsPath)) {
    New-Item -ItemType Directory -Path $LogsPath -Force | Out-Null
}
if (!(Test-Path $ReportsPath)) {
    New-Item -ItemType Directory -Path $ReportsPath -Force | Out-Null
}

Write-Host "=== SOC Analyst Dashboard - Security Event Generator ===" -ForegroundColor Cyan
Write-Host "Generating $EventCount security events over $Hours hours..." -ForegroundColor Yellow

# Define realistic data sets
$UserAccounts = @(
    "jsmith", "mdavis", "kwilson", "rjohnson", "sgarcia", "tmiller", "awilliams", "dbrown",
    "cjones", "mmartinez", "ladmin", "backup_user", "service_account", "guest", "administrator",
    "devops", "analyst", "manager", "contractor", "intern", "security_admin", "network_admin"
)

$SourceIPs = @(
    "192.168.1.101", "192.168.1.102", "192.168.1.103", "192.168.1.104", "192.168.1.105",
    "10.0.0.50", "10.0.0.51", "10.0.0.52", "10.0.0.53", "10.0.0.54",
    "172.16.10.20", "172.16.10.21", "172.16.10.22", "172.16.10.23", "172.16.10.24"
)

$SuspiciousIPs = @(
    "185.220.100.240", "45.133.1.87", "103.94.109.26", "194.147.78.23", "89.248.165.199",
    "91.134.203.44", "217.182.132.79", "195.123.245.167", "178.62.193.84", "159.89.214.31",
    "146.70.106.89", "104.248.144.120", "167.172.184.166", "139.59.166.93", "165.227.88.15"
)

$EventTypes = @(
    @{Type="UserLogin"; Severity="Info"; Description="User authentication attempt"},
    @{Type="UserLogout"; Severity="Info"; Description="User session terminated"},
    @{Type="FileAccess"; Severity="Info"; Description="File system access"},
    @{Type="NetworkConnection"; Severity="Info"; Description="Network connection established"},
    @{Type="FailedLogin"; Severity="Warning"; Description="Authentication failure"},
    @{Type="PrivilegeEscalation"; Severity="High"; Description="Privilege escalation attempt"},
    @{Type="SuspiciousProcess"; Severity="High"; Description="Suspicious process execution"},
    @{Type="MalwareDetection"; Severity="Critical"; Description="Potential malware detected"},
    @{Type="DataExfiltration"; Severity="Critical"; Description="Unusual data transfer"},
    @{Type="BruteForceAttempt"; Severity="High"; Description="Multiple failed login attempts"},
    @{Type="C2Communication"; Severity="Critical"; Description="Command and control communication"},
    @{Type="RansomwareActivity"; Severity="Critical"; Description="File encryption activity detected"}
)

$Applications = @(
    "Windows Logon", "Active Directory", "File Server", "Web Application", "Database Server",
    "Email Server", "VPN Gateway", "Firewall", "IDS/IPS", "Antivirus", "SIEM", "Backup System",
    "Domain Controller", "Print Server", "Terminal Server", "Web Server", "FTP Server"
)

$Destinations = @(
    "DC01.corp.local", "FILE01.corp.local", "WEB01.corp.local", "DB01.corp.local",
    "MAIL01.corp.local", "DNS01.corp.local", "DHCP01.corp.local", "BACKUP01.corp.local",
    "suspicious-domain.net", "malware-c2.com", "data-exfil.org", "crypto-miner.net"
)

# Initialize event collection
$SecurityEvents = @()
$StartTime = (Get-Date).AddHours(-$Hours)

Write-Host "Event generation started at: $(Get-Date)" -ForegroundColor Green
Write-Host "Simulating events from: $StartTime to $(Get-Date)" -ForegroundColor Green

# Generate events
for ($i = 0; $i -lt $EventCount; $i++) {
    # Generate realistic timestamp within the specified hour range
    $RandomSeconds = Get-Random -Minimum 0 -Maximum ($Hours * 3600)
    $EventTime = $StartTime.AddSeconds($RandomSeconds)
    
    # Determine if this should be a suspicious event (10% chance)
    $IsSuspicious = (Get-Random -Minimum 1 -Maximum 11) -eq 1
    
    if ($IsSuspicious) {
        # Generate suspicious event
        $EventType = Get-Random -InputObject ($EventTypes | Where-Object {$_.Severity -in @("High", "Critical")})
        $SourceIP = Get-Random -InputObject $SuspiciousIPs
        $UserAccount = Get-Random -InputObject @("unknown_user", "guest", "admin", "root", "test", "scanner")
        
        # FIXED: Handle off-hours properly (22-23 or 0-5)
        if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) {
            $OffHour = Get-Random -Minimum 22 -Maximum 24  # 10 PM - 11:59 PM
        } else {
            $OffHour = Get-Random -Minimum 0 -Maximum 6    # 12 AM - 5:59 AM
        }
        
        # Override event time to off-hours for more suspicious activity
        if ((Get-Random -Minimum 1 -Maximum 4) -eq 1) {
            $EventTime = $EventTime.Date.AddHours($OffHour).AddMinutes((Get-Random -Minimum 0 -Maximum 60))
        }
        
    } else {
        # Generate normal event
        $EventType = Get-Random -InputObject ($EventTypes | Where-Object {$_.Severity -eq "Info"})
        $SourceIP = Get-Random -InputObject $SourceIPs
        $UserAccount = Get-Random -InputObject $UserAccounts
    }
    
    # Generate additional event details
    $Application = Get-Random -InputObject $Applications
    $Destination = Get-Random -InputObject $Destinations
    $EventID = Get-Random -Minimum 1000 -Maximum 9999
    $ProcessID = Get-Random -Minimum 100 -Maximum 65535
    
    # Create event object
    $Event = [PSCustomObject]@{
        Timestamp = $EventTime.ToString("yyyy-MM-dd HH:mm:ss")
        EventID = $EventID
        EventType = $EventType.Type
        Severity = $EventType.Severity
        Description = $EventType.Description
        SourceIP = $SourceIP
        UserAccount = $UserAccount
        Application = $Application
        Destination = $Destination
        ProcessID = $ProcessID
        Status = if ($IsSuspicious) {"Failed"} else {(Get-Random -InputObject @("Success", "Success", "Success", "Failed"))}
        BytesTransferred = if ($EventType.Type -eq "DataExfiltration") {(Get-Random -Minimum 1000000 -Maximum 100000000)} else {(Get-Random -Minimum 1024 -Maximum 1048576)}
    }
    
    $SecurityEvents += $Event
    
    # Progress indicator
    if ($i % 1000 -eq 0) {
        $Progress = [math]::Round(($i / $EventCount) * 100, 1)
        Write-Progress -Activity "Generating Security Events" -Status "$Progress% Complete" -PercentComplete $Progress
    }
}

# Sort events by timestamp for realistic chronological order
$SecurityEvents = $SecurityEvents | Sort-Object Timestamp

# Generate output filename with timestamp
$OutputFile = Join-Path $LogsPath "SecurityEvents_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

# Export to CSV
try {
    $SecurityEvents | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
    Write-Host "`n✅ SUCCESS: Generated $($SecurityEvents.Count) security events" -ForegroundColor Green
    Write-Host "📁 Output file: $OutputFile" -ForegroundColor Green
    
    # Display summary statistics
    $SuspiciousCount = ($SecurityEvents | Where-Object {$_.Severity -in @("High", "Critical")}).Count
    $InfoCount = ($SecurityEvents | Where-Object {$_.Severity -eq "Info"}).Count
    $WarningCount = ($SecurityEvents | Where-Object {$_.Severity -eq "Warning"}).Count
    
    Write-Host "`n📊 Event Summary:" -ForegroundColor Cyan
    Write-Host "   Info Events: $InfoCount" -ForegroundColor White
    Write-Host "   Warning Events: $WarningCount" -ForegroundColor Yellow
    Write-Host "   High/Critical Events: $SuspiciousCount" -ForegroundColor Red
    Write-Host "   Time Range: $($SecurityEvents[0].Timestamp) to $($SecurityEvents[-1].Timestamp)" -ForegroundColor White
    
    Write-Host "`n🎯 Ready for threat detection analysis!" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Run: .\scripts\Detect-BruteForce.ps1" -ForegroundColor White
    Write-Host "  2. Run: .\scripts\Detect-Malware.ps1" -ForegroundColor White
    Write-Host "  3. Open: .\dashboard\index.html" -ForegroundColor White
    
} catch {
    Write-Error "Failed to export security events: $($_.Exception.Message)"
    exit 1
}

Write-Host "`n🔒 SOC Analyst Dashboard - Event Generation Complete! 🔒" -ForegroundColor Green