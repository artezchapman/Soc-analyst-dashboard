<#
Detects brute-force login patterns (EventID 4625) in security_events.csv.
#>

[CmdletBinding()]
param(
  [string]$InputCsv,
  [string]$OutputBasePath,
  [int]$WindowMinutes = 10,
  [int]$Threshold = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# Resolve default paths
$scriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($InputCsv))       { $InputCsv       = Join-Path (Join-Path $scriptRoot '..\data') 'sample-logs\security_events.csv' }
if ([string]::IsNullOrWhiteSpace($OutputBasePath)) { $OutputBasePath = Join-Path $scriptRoot '..\data' }

$reports = Join-Path $OutputBasePath 'reports'
New-Item -ItemType Directory -Force -Path $reports | Out-Null

if (-not (Test-Path $InputCsv)) {
  Write-Error "Input CSV not found: $InputCsv`nRun Generate-SecurityEvents.ps1 first."
}

# Load + normalize rows
$rows = @(Import-Csv -Path $InputCsv)
if (@($rows).Count -eq 0) {
  Write-Host "No rows found in $InputCsv" -ForegroundColor Yellow
  return
}

# Filter to failed logons
$failed = @(
  $rows | Where-Object { $_.EventID -eq '4625' -or [int]($_.EventID) -eq 4625 } |
  ForEach-Object {
    $ts = try { [datetime]::Parse($_.Timestamp) } catch { [datetime]::MinValue }
    [pscustomobject]@{
      Timestamp = $ts
      User      = $_.User
      SourceIP  = $_.SourceIP
      Computer  = $_.Computer
    }
  } | Where-Object { $_.Timestamp -gt [datetime]::MinValue }
)

if (@($failed).Count -eq 0) {
  Write-Host "No failed logons (4625) found." -ForegroundColor Yellow
  return
}

# Sliding window prep
$window   = [TimeSpan]::FromMinutes($WindowMinutes)
$findings = New-Object System.Collections.Generic.List[object]

# Group by (User, SourceIP)
$failed | Group-Object User, SourceIP | ForEach-Object {
  $groupEvents = @($_.Group | Sort-Object Timestamp)  # ensure array
  $n = $groupEvents.Count
  if ($n -lt $Threshold) { return }                   # impossible to hit threshold

  $left = 0
  for ($right = 0; $right -lt $n; $right++) {
    while ($groupEvents[$right].Timestamp - $groupEvents[$left].Timestamp -gt $window) { $left++ }
    $count = $right - $left + 1
    if ($count -ge $Threshold) {
      $first = $groupEvents[$left]
      $last  = $groupEvents[$right]
      $durationMin = [int]([math]::Ceiling(($last.Timestamp - $first.Timestamp).TotalMinutes))
      if ($durationMin -lt 1) { $durationMin = 1 }

      $slice = @($groupEvents[$left..$right])         # safe slice even when single item
      $computers = ($slice | Select-Object -ExpandProperty Computer -Unique) -join ','

      $findings.Add([pscustomobject]@{
        User            = $_.Group[0].User
        SourceIP        = $_.Group[0].SourceIP
        WindowMinutes   = $WindowMinutes
        Attempts        = $count
        FirstTimestamp  = $first.Timestamp.ToString('s')
        LastTimestamp   = $last.Timestamp.ToString('s')
        DurationMinutes = $durationMin
        Computers       = $computers
        SampleWindow    = ($first.Timestamp.ToString('s') + ' .. ' + $last.Timestamp.ToString('s'))
      })
    }
  }
}

# Deduplicate overlapping hits
$unique = @($findings | Sort-Object User, SourceIP, LastTimestamp -Unique)

# Write outputs
$stamp  = Get-Date -Format 'yyyyMMdd_HHmmss'
$csvOut = Join-Path $reports ("BruteForce_{0}.csv" -f $stamp)
$txtOut = Join-Path $reports ("BruteForce_{0}.txt" -f $stamp)

$unique | Export-Csv -Path $csvOut -NoTypeInformation -Encoding utf8

$threats = @($unique).Count
$sev = if ($threats -ge 10) { 'Critical' } elseif ($threats -ge 5) { 'High' } elseif ($threats -ge 1) { 'Medium' } else { 'Informational' }

$lines = @()
$lines += "BRUTE FORCE DETECTION REPORT"
$lines += "Generated : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$lines += "Source    : $InputCsv"
$lines += "Window    : $WindowMinutes minute(s)"
$lines += "Threshold : $Threshold attempts"
$lines += "Findings  : $threats  (Overall Severity: $sev)"
$lines += ""
foreach ($f in $unique) {
  $lines += (" - User={0}  IP={1}  Attempts={2}  Window={3}min  First={4}  Last={5}  Hosts=[{6}]" -f `
            $f.User, $f.SourceIP, $f.Attempts, $f.WindowMinutes, $f.FirstTimestamp, $f.LastTimestamp, $f.Computers)
}
$lines | Out-File -FilePath $txtOut -Encoding utf8

$fc = 'Green'; if ($threats -gt 0) { $fc = 'Red' }
Write-Host "Brute force detections: $threats  (Severity: $sev)" -ForegroundColor $fc
Write-Host "Report (TXT): $txtOut" -ForegroundColor DarkGray
Write-Host "Report (CSV): $csvOut" -ForegroundColor DarkGray
