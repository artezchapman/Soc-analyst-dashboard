SOC Analyst Dashboard (Demo)

A lightweight, self-contained SOC demo that:

Generates synthetic security + network events

Detects brute force patterns and suspicious malware-like comms

Displays a slick dashboard in your browser

Designed for easy evaluation by hiring teams: clone → run one command → see results.

🔧 Prerequisites

Windows with PowerShell

Windows PowerShell 5.1 or PowerShell 7+ (pwsh)

No external dependencies; everything runs locally

(Optional) Python 3 if you prefer to serve the dashboard via http.server (not required)

🚀 One-Touch Start (recommended)

From a PowerShell prompt in the repo root:

.\Start-SOCDashboard.ps1


This will:

Generate fresh synthetic logs

Run both detections

Open the dashboard (dashboard\index.html) in your default browser

Optional knobs:

# Simulate a larger window / more data
.\Start-SOCDashboard.ps1 -Hours 12 -EventCount 8000

# Generate + detect only (don't open browser)
.\Start-SOCDashboard.ps1 -NoBrowser

📂 Project Structure
Soc-analyst-dashboard/
├─ Start-SOCDashboard.ps1            # One-touch runner (generate → detect → open UI)
├─ scripts/
│  ├─ Generate-SecurityEvents.ps1    # Creates synthetic CSVs in data\sample-logs
│  ├─ Detect-BruteForce.ps1          # Reads security_events.csv → writes reports
│  └─ Detect-Malware.ps1             # Reads network_events.csv  → writes reports
├─ data/
│  ├─ logs/                          # Timestamped raw CSV outputs
│  ├─ sample-logs/                   # Rolling “latest” CSVs used by the dashboard
│  ├─ reports/                       # Detection outputs (CSV/TXT; optional JSON)
│  └─ threat-intel/                  # (Optional) .txt IOC lists (one per line)
└─ dashboard/
   ├─ index.html
   ├─ css/styles.css
   └─ js/dashboard.js

🧪 What Each Script Does
Generate-SecurityEvents.ps1

Produces security events (4624/4625/4688/4720/4723/4768) and network events

Writes timestamped CSVs to data\logs\ and rolling copies to:

data\sample-logs\security_events.csv

data\sample-logs\network_events.csv

Examples

.\scripts\Generate-SecurityEvents.ps1                # default: 24h, 1000 events
.\scripts\Generate-SecurityEvents.ps1 -Hours 6 -EventCount 2500

Detect-BruteForce.ps1

Scans security_events.csv for failed logon bursts per (User, SourceIP)

Outputs to data\reports\BruteForce_*.csv/.txt

Example

.\scripts\Detect-BruteForce.ps1 -WindowMinutes 10 -Threshold 5

Detect-Malware.ps1

Scans network_events.csv for repetitive OUTBOUND beacons / odd ports / small keep-alives

Optional poor-man’s TI: drop IOC text files in data\threat-intel\ (one IP/domain per line)

Outputs to data\reports\Malware_*.csv/.txt

Example

.\scripts\Detect-Malware.ps1 -WindowMinutes 15 -MinBursts 8 -SmallPktMax 15

📊 The Dashboard

Open automatically via the one-touch script, or manually:

Double-click dashboard\index.html, or

Serve locally to avoid any file:// CORS edge-cases:

cd .\dashboard
python -m http.server 8080
# browse to http://localhost:8080


What it shows

Live-styled metrics, alert feed, threat breakdown, and an investigation queue

Reads the rolling CSVs from data\sample-logs\
(Detections are reflected indirectly; you can extend the UI to read data\reports\ for explicit alert counts)

Branding note
Header shows a generic “Analyst” label (not a personal name) for portfolio use.

🧭 Typical Flow (manual)
# 1) Generate
.\scripts\Generate-SecurityEvents.ps1 -Hours 6 -EventCount 2000

# 2) Detect
.\scripts\Detect-BruteForce.ps1 -WindowMinutes 10 -Threshold 5
.\scripts\Detect-Malware.ps1   -WindowMinutes 15 -MinBursts 8

# 3) View
start .\dashboard\index.html

🛠️ Troubleshooting

“running scripts is disabled”

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser


Dashboard doesn’t update: Regenerate → Ctrl+F5 hard refresh (disable cache in DevTools if needed).

No detections: Lower thresholds (e.g., -Threshold 3 or -MinBursts 3) or increase -EventCount.

Encoding/parsing issues: Scripts are ASCII/UTF-8 clean and PS 5.1–safe. If you edited files in another editor, resave as UTF-8 (without BOM).

🧩 Extending the Demo (optional)

Add data\reports\*_latest.json summaries (already scaffolded in scripts) and a tiny JS fetch to show live alert counts in the header.

Swap in your own CSVs to visualize real data (schemas documented in the generator script).

Schedule the generator with Task Scheduler to refresh data periodically.

📜 License & Attribution

This demo is intended for portfolio and interview evaluation use.


Quickstart for Reviewers

# In repo root
.\Start-SOCDashboard.ps1
# Browser opens with fresh data & detections