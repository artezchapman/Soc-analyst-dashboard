# SOC Analyst Dashboard - Setup Guide

## 🚀 Quick Start Instructions

### Prerequisites
- **Windows PowerShell 5.1+** or **PowerShell Core 7+**
- **Modern web browser** (Chrome, Firefox, Edge, Safari)
- **Administrative privileges** for event log access (optional for demo)

### Installation Steps

#### 1. Clone or Download Repository
```bash
# If using git
git clone https://github.com/artezchapman/soc-analyst-dashboard.git
cd soc-analyst-dashboard

# Or download and extract ZIP file
```

#### 2. Generate Sample Security Data
```powershell
# Navigate to project directory
cd soc-analyst-dashboard

# Generate 24 hours of realistic security events
.\scripts\Generate-SecurityEvents.ps1 -Hours 24 -EventCount 10000

# This creates sample log files in data/sample-logs/
```

#### 3. Run Threat Detection Analysis
```powershell
# Detect brute force attacks
.\scripts\Detect-BruteForce.ps1 -Threshold 10

# Detect malware communications
.\scripts\Detect-Malware.ps1

# View generated reports in docs/incident-reports/
```

#### 4. Launch SOC Dashboard
```bash
# Open dashboard in browser
start dashboard\index.html

# Or manually navigate to dashboard/index.html in your browser
```

## 📋 Project Structure Overview

```
soc-analyst-dashboard/
├── README.md                           # Project overview and documentation
├── docs/
│   ├── SETUP.md                       # This setup guide
│   └── incident-reports/              # Generated incident reports
├── data/
│   ├── sample-logs/                   # Generated security event logs
│   └── threat-intel/                  # Threat intelligence feeds
├── scripts/
│   ├── Generate-SecurityEvents.ps1    # Creates realistic security data
│   ├── Detect-BruteForce.ps1         # Brute force attack detection
│   └── Detect-Malware.ps1            # Malware communication detection
└── dashboard/
    ├── index.html                     # Main dashboard interface
    ├── css/styles.css                 # Dashboard styling
    └── js/dashboard.js                # Interactive functionality
```

## 🔧 Configuration Options

### Event Generation Parameters
```powershell
# Customize event generation
.\scripts\Generate-SecurityEvents.ps1 -Hours 48 -EventCount 20000 -OutputPath ".\custom-logs\"

# Parameters:
# -Hours: Time span to simulate (default: 24)
# -EventCount: Number of events to generate (default: 10000)
# -OutputPath: Where to save log files (default: .\data\sample-logs\)
```

### Detection Thresholds
```powershell
# Adjust brute force detection sensitivity
.\scripts\Detect-BruteForce.ps1 -FailureThreshold 5 -TimeWindowMinutes 30

# Parameters:
# -FailureThreshold: Failed attempts to trigger alert (default: 10)
# -TimeWindowMinutes: Time window for analysis (default: 60)
# -LogPath: Path to security events CSV
# -OutputPath: Where to save incident reports
```

### Threat Intelligence
```powershell
# Custom threat intelligence sources
.\scripts\Detect-Malware.ps1 -ThreatIntelPath ".\custom-iocs\"

# The script automatically creates sample IOC files:
# - malicious_ips.csv
# - malicious_domains.csv
```

## 📊 Understanding the Output

### Generated Files
After running the scripts, you'll have:

**Data Files:**
- `data/sample-logs/security_events.csv` - Windows security events
- `data/sample-logs/network_events.csv` - Network traffic data  
- `data/sample-logs/file_events.csv` - File access events
- `data/sample-logs/generation_summary.txt` - Event generation report

**Analysis Results:**
- `docs/incident-reports/BF-*.txt` - Brute force incident reports
- `docs/incident-reports/MW-*.txt` - Malware communication reports
- `docs/incident-reports/*_summary.csv` - Summary data for dashboard

### Dashboard Features
The web dashboard provides:
- **Real-time Metrics** - Event counts, threat levels, detection times
- **Live Alert Feed** - Streaming security alerts with severity levels
- **Threat Analysis** - Visual breakdown of threats by category
- **Investigation Queue** - Incident management and response actions
- **Interactive Terminal** - Shows analysis commands and results

## 🔍 Demonstration Scenarios

### Scenario 1: Brute Force Attack Investigation
```powershell
# 1. Generate events with planted brute force attack
.\scripts\Generate-SecurityEvents.ps1

# 2. Run detection analysis
.\scripts\Detect-BruteForce.ps1

# 3. Review incident report
# Check docs/incident-reports/BF-*.txt for detailed findings

# 4. View dashboard
# Open dashboard/index.html to see real-time metrics
```

### Scenario 2: Malware Communication Detection
```powershell
# 1. Analyze network events for IOC matches
.\scripts\Detect-Malware.ps1

# 2. Review malware communication reports
# Check docs/incident-reports/MW-*.txt

# 3. Examine threat intelligence
# Review data/threat-intel/ for IOC feeds used
```

### Scenario 3: Full SOC Workflow
```powershell
# Complete analysis workflow
.\scripts\Generate-SecurityEvents.ps1 -Hours 24 -EventCount 15000
.\scripts\Detect-BruteForce.ps1
.\scripts\Detect-Malware.ps1

# Dashboard shows comprehensive threat landscape
# Multiple incident types with varying severity levels
# Demonstrates end-to-end SOC analyst capabilities
```

## 🛠️ Troubleshooting

### Common Issues

**1. PowerShell Execution Policy**
```powershell
# If scripts won't run due to execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run individual scripts with bypass
powershell -ExecutionPolicy Bypass -File .\scripts\Generate-SecurityEvents.ps1
```

**2. File Path Issues**
```powershell
# Ensure you're in the correct directory
Get-Location  # Should show soc-analyst-dashboard folder

# Use absolute paths if needed
.\scripts\Generate-SecurityEvents.ps1 -OutputPath "C:\Full\Path\To\Output"
```

**3. Dashboard Not Loading**
- Ensure `dashboard/index.html` exists
- Check browser console for JavaScript errors
- Verify all CSS and JS files are present in dashboard/css/ and dashboard/js/
- Try different browser if issues persist

**4. No Threats Detected**
```powershell
# Increase event count for more planted threats
.\scripts\Generate-SecurityEvents.ps1 -EventCount 20000

# Lower detection thresholds
.\scripts\Detect-BruteForce.ps1 -FailureThreshold 5
```

### Performance Optimization

**For Large Datasets:**
- Use smaller EventCount values for faster generation
- Process logs in batches for very large datasets
- Consider using PowerShell Core 7+ for better performance

**For Slow Browsers:**
- Reduce dashboard auto-refresh frequency
- Use Chrome or Edge for best performance
- Close unnecessary browser tabs during demonstration

## 📈 Extending the Project

### Adding New Threat Types
1. Create new detection script following existing patterns
2. Add threat scenarios to `Generate-SecurityEvents.ps1`
3. Update dashboard to display new threat categories
4. Create corresponding incident report templates

### Custom Threat Intelligence
1. Replace sample IOCs in `data/threat-intel/` with real feeds
2. Modify `Detect-Malware.ps1` to use additional IOC sources
3. Add new IOC types (URLs, file hashes, etc.)

### Integration with Real Systems
- Modify scripts to read from actual log sources
- Connect to SIEM platforms for live data
- Implement real firewall blocking via APIs
- Add email notifications for critical incidents

## 🎯 Professional Use Cases

### Job Interview Demonstrations
1. **Technical Interview** - Walk through detection logic and PowerShell code
2. **Management Presentation** - Show dashboard and explain SOC metrics
3. **Hands-on Assessment** - Generate new scenarios and analyze results

### Portfolio Showcasing
- **GitHub Repository** - Professional code organization and documentation
- **LinkedIn Projects** - Screenshots and metrics demonstrating impact
- **Professional Website** - Integration with portfolio showcasing SOC skills

### Skill Development
- **PowerShell Automation** - Advanced scripting for security operations
- **Threat Hunting** - Pattern recognition and IOC matching
- **Incident Response** - Structured investigation methodology
- **SIEM Concepts** - Log correlation and alert management

---

## ✅ Verification Checklist

Before considering setup complete:

- [ ] **Scripts Execute Successfully** - All PowerShell scripts run without errors
- [ ] **Data Generation Works** - Sample logs created in data/sample-logs/
- [ ] **Threats Detected** - Incident reports generated in docs/incident-reports/
- [ ] **Dashboard Loads** - Web interface displays correctly in browser
- [ ] **Interactive Features Work** - Buttons, alerts, and updates function properly
- [ ] **Professional Presentation** - Clean, organized output suitable for demonstrations

**Next Steps:** You're ready to demonstrate professional SOC analyst capabilities!

---

*For additional support or questions, review the main README.md or examine the PowerShell script comments for detailed implementation notes.*