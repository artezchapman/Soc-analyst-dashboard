<#
.SYNOPSIS
    Generate synthetic Security and Network event CSVs for the SOC Analyst Dashboard.

.DESCRIPTION
    Produces two CSV files under data\logs\:
      - SecurityEvents_<timestamp>.csv
      - NetworkEvents_<timestamp>.csv

    It also updates rolling copies in data\sample-logs\:
      - security_events.csv
      - network_events.csv

    The script is ASCII-safe (no emoji), uses strict mode, creates required folders,
    and provides robust error handling with a transcript saved to data\logs\.

.PARAMETER Hours
    How many hours back in time to spread events across (default: 24).

.PARAMETER EventCount
    Total number of SECURITY events to generate (default: 1000).
    Network events are generated at ~60% of this count by default.

.PARAMETER OutputBasePath
    Root folder for data subfolders. If not provided, defaults to ..\data relative to this script.

.PARAMETER Seed
    Optional integer seed for reproducible random output.

.EXAMPLE
    .\Generate-SecurityEvents.ps1

.EXAMPLE
    .\Generate-SecurityEvents.ps1 -Hours 6 -EventCount 1500 -Verbose

.EXAMPLE
    .\Generate-SecurityEvents.ps1 -OutputBasePath 'D:\SOCDemo\data' -Seed 42
#>

[CmdletBinding()]
param(
    [ValidateRange(1, 720)]
    [int]$Hours = 24,

    [ValidateRange(1, 1000000)]
    [int]$EventCount = 1000,

    [string]$OutputBasePath,

    [int]$Seed
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Ensure UTF-8 console if supported (safe no-op otherwise)
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false) } catch { }

# Resolve base paths
$scriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($OutputBasePath)) {
    $basePath = Join-Path $scriptRoot '..\data'
} else {
    $basePath = $OutputBasePath
}
$logsPath    = Join-Path $basePath 'logs'
$samplePath  = Join-Path $basePath 'sample-logs'
$reportsPath = Join-Path $basePath 'reports'     # reserved for other scripts in the repo

# Create directories if missing
New-Item -ItemType Directory -Force -Path $logsPath, $samplePath, $reportsPath | Out-Null

# Start transcript
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$transcriptPath = Join-Path $logsPath "Generate-SecurityEvents_$timestamp.log"
try { Start-Transcript -Path $transcriptPath -ErrorAction SilentlyContinue | Out-Null } catch { }

# RNG (seedable)
if ($PSBoundParameters.ContainsKey('Seed')) {
    $script:Rand = [System.Random]::new($Seed)
} else {
    $script:Rand = [System.Random]::new()
}

# -------------------------
# Utility Functions
# -------------------------
function Get-Rand([int]$min, [int]$max) {
    # Returns an int in [min, max)
    $script:Rand.Next($min, $max)
}
function Get-RandDouble {
    # Returns double in [0,1)
    $script:Rand.NextDouble()
}
function Get-RandomFrom([object[]]$Array) {
    if (-not $Array -or $Array.Count -eq 0) { return $null }
    $Array[ (Get-Rand 0 $Array.Count) ]
}
function New-RandomPrivateIP {
    # Generate a private IPv4 (RFC1918)
    $range = Get-Rand 0 3
    switch ($range) {
        0 { # 10.0.0.0/8
            [ipaddress]("{0}.{1}.{2}.{3}" -f 10, (Get-Rand 0 255), (Get-Rand 0 255), (Get-Rand 1 254))
        }
        1 { # 172.16.0.0/12
            [ipaddress]("{0}.{1}.{2}.{3}" -f (Get-Rand 172 173), (Get-Rand 16 32), (Get-Rand 0 255), (Get-Rand 1 254))
        }
        default { # 192.168.0.0/16
            [ipaddress]("{0}.{1}.{2}.{3}" -f 192, 168, (Get-Rand 0 255), (Get-Rand 1 254))
        }
    }
}
function New-RandomPublicIP {
    # A simplistic public IPv4 generator avoiding private ranges
    while ($true) {
        $oct1 = Get-Rand 1 223
        if ($oct1 -in 10, 127, 172, 192) { continue } # avoid private/special ranges in octet 1
        [ipaddress]("{0}.{1}.{2}.{3}" -f $oct1, (Get-Rand 0 255), (Get-Rand 0 255), (Get-Rand 1 254))
        return
    }
}
function New-RandomIP([switch]$PreferPrivate) {
    if ($PreferPrivate -or ((Get-RandDouble) -lt 0.7)) {
        return (New-RandomPrivateIP).ToString()
    } else {
        return (New-RandomPublicIP).ToString()
    }
}
function New-RandomPort {
    # ephemeral/user ports mostly
    $r = Get-RandDouble
    if ($r -lt 0.15) { return Get-Rand 1 1024 }      # well-known rarely
    return Get-Rand 1024 65535
}
function New-RandomTime([int]$HoursBack) {
    $seconds = Get-Rand 0 ($HoursBack * 3600)
    (Get-Date).AddSeconds(-$seconds)
}

# -------------------------
# Data Sources
# -------------------------
$computers = @(
    'WIN10LAB', 'SRV-DC1', 'SRV-FILE1', 'SRV-WEB1', 'SRV-SIEM1', 'SRV-SQL1', 'SRV-REMOTE1'
)
$users = @(
    'Administrator','jsmith','achapman','svc_web','svc_sql','mgarcia','tnguyen','bpatel','hlee','kparker'
)
$processes = @(
    'cmd.exe','powershell.exe','conhost.exe','svchost.exe','rundll32.exe','wscript.exe','mshta.exe',
    'chrome.exe','winword.exe','outlook.exe','teams.exe','sqlservr.exe','python.exe','node.exe'
)
$protocols = @('TCP','UDP')
$wellKnownPorts = @(22, 23, 25, 53, 80, 110, 135, 139, 143, 389, 443, 445, 587, 8080, 8443, 3389)
$netActions = @('ALLOW','ALLOW','ALLOW','ALLOW','BLOCK') # light bias to ALLOW
$directions = @('INBOUND','OUTBOUND')

# Security Event Types (ID -> Name) with rough weights
$securityTypes = @(
    @{ Id = 4624; Name = 'An account was successfully logged on'; Weight = 52 }
    @{ Id = 4625; Name = 'An account failed to log on';         Weight = 20 }
    @{ Id = 4688; Name = 'A new process has been created';      Weight = 18 }
    @{ Id = 4720; Name = 'A user account was created';          Weight = 3  }
    @{ Id = 4723; Name = 'An attempt was made to change a password'; Weight = 3 }
    @{ Id = 4768; Name = 'A Kerberos authentication ticket (TGT) was requested'; Weight = 4 }
)

# Build a weighted cumulative distribution for picking security event types
$cum = 0
$weightedSecurity = foreach ($t in $securityTypes) {
    $cum += [int]$t.Weight
    [pscustomobject]@{Id=$t.Id; Name=$t.Name; Cum=$cum}
}
$maxWeight = $weightedSecurity[-1].Cum

function Pick-SecurityType {
    $r = Get-Rand 1 ($maxWeight + 1)
    foreach ($w in $weightedSecurity) {
        if ($r -le $w.Cum) { return $w }
    }
    $weightedSecurity[-1]
}

# -------------------------
# Generate Security Events
# -------------------------
Write-Verbose "Generating $EventCount security events over the past $Hours hour(s)..."
$securityEvents = New-Object System.Collections.Generic.List[object]

for ($i = 0; $i -lt $EventCount; $i++) {
    $etype     = Pick-SecurityType
    $time      = New-RandomTime -HoursBack $Hours
    $computer  = Get-RandomFrom $computers
    $user      = Get-RandomFrom $users
    $srcIP     = New-RandomIP -PreferPrivate
    $status    = if ($etype.Id -eq 4625) { 'FAILURE' } else { 'SUCCESS' }
    $targetUsr = if ($etype.Id -in 4720,4723) { Get-RandomFrom $users } else { $null }
    $proc      = if ($etype.Id -eq 4688) { Get-RandomFrom $processes } else { $null }
    $desc      = switch ($etype.Id) {
        4624 { 'Successful logon' }
        4625 { 'Failed logon (bad password or unknown user)' }
        4688 { 'Process creation observed' }
        4720 { 'New user account created' }
        4723 { 'Password change attempt' }
        4768 { 'Kerberos TGT requested' }
        default { 'Security event' }
    }

    $securityEvents.Add([pscustomobject]@{
        Timestamp   = $time.ToString('s')                     # ISO-like sortable
        EventID     = $etype.Id
        EventName   = $etype.Name
        Computer    = $computer
        User        = $user
        SourceIP    = $srcIP
        TargetUser  = $targetUsr
        Process     = $proc
        Status      = $status
        Description = $desc
    })
}

# -------------------------
# Generate Network Events (~60% of security volume)
# -------------------------
$netCount = [int][math]::Ceiling($EventCount * 0.6)
Write-Verbose "Generating $netCount network events..."
$networkEvents = New-Object System.Collections.Generic.List[object]

for ($i = 0; $i -lt $netCount; $i++) {
    $time  = New-RandomTime -HoursBack $Hours
    $dir   = Get-RandomFrom $directions

    $srcIP = $null; $dstIP = $null; $srcPort = $null; $dstPort = $null

    if ($dir -eq 'INBOUND') {
        $srcIP = New-RandomIP
        $dstIP = (New-RandomPrivateIP).ToString()
        $srcPort = New-RandomPort

        if ((Get-RandDouble) -lt 0.55) {
            $dstPort = Get-RandomFrom $wellKnownPorts
        } else {
            $dstPort = New-RandomPort
        }
    } else {
        $srcIP = (New-RandomPrivateIP).ToString()
        $dstIP = New-RandomIP

        if ((Get-RandDouble) -lt 0.25) {
            $srcPort = Get-RandomFrom $wellKnownPorts
        } else {
            $srcPort = New-RandomPort
        }

        $dstPort = New-RandomPort
    }

    $proto = Get-RandomFrom $protocols
    $act   = Get-RandomFrom $netActions
    $rule  = if ($act -eq 'BLOCK') { 'Default-Deny' } else { 'Allow-Standard' }

    $bytes   = Get-Rand 200 200000
    $packets = Get-Rand 3 1200

    $u = $null
    if ((Get-RandDouble) -lt 0.15) { $u = Get-RandomFrom $users }

    $note = ''
    if ($act -eq 'BLOCK') { $note = 'Potential noise or policy match' }

    $networkEvents.Add([pscustomobject]@{
        Timestamp = $time.ToString('s')
        Direction = $dir
        Protocol  = $proto
        SrcIP     = $srcIP
        SrcPort   = $srcPort
        DstIP     = $dstIP
        DstPort   = $dstPort
        Action    = $act
        Rule      = $rule
        Bytes     = $bytes
        Packets   = $packets
        Computer  = Get-RandomFrom $computers
        User      = $u
        Note      = $note
    })
}

# -------------------------
# Write Outputs
# -------------------------
$secOut = Join-Path $logsPath ("SecurityEvents_{0}.csv" -f $timestamp)
$netOut = Join-Path $logsPath ("NetworkEvents_{0}.csv" -f $timestamp)

try {
    Write-Verbose "Writing $secOut ..."
    $securityEvents |
        Sort-Object { $_.Timestamp } |
        Export-Csv -Path $secOut -NoTypeInformation -Encoding utf8

    Write-Verbose "Writing $netOut ..."
    $networkEvents  |
        Sort-Object { $_.Timestamp } |
        Export-Csv -Path $netOut -NoTypeInformation -Encoding utf8

    # Maintain rolling "latest" copies for the dashboard
    $sampleSec = Join-Path $samplePath 'security_events.csv'
    $sampleNet = Join-Path $samplePath 'network_events.csv'

    Copy-Item -Path $secOut -Destination $sampleSec -Force
    Copy-Item -Path $netOut -Destination $sampleNet -Force
}
catch {
    $err = $_ | Out-String
    Write-Warning "Failed to write output CSVs.`n$err"
    $err | Out-File -FilePath (Join-Path $logsPath 'generation_errors.log') -Append
    throw
}

# -------------------------
# Done
# -------------------------
Write-Host 'Security Analyst Dashboard - Event Generation Complete!' -ForegroundColor Green
Write-Host ("Security CSV : {0}" -f $secOut) -ForegroundColor DarkGray
Write-Host ("Network  CSV : {0}" -f $netOut) -ForegroundColor DarkGray
Write-Host ("Transcript  : {0}" -f $transcriptPath) -ForegroundColor DarkGray

# Stop transcript
try { Stop-Transcript | Out-Null } catch { }
