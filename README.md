# SOC Analyst Dashboard

**Professional cybersecurity monitoring solution demonstrating SOC analyst capabilities through PowerShell automation and real-time threat visualization.**

---

## 🎯 **Project Overview**

This project showcases end-to-end Security Operations Center (SOC) workflows, featuring automated threat detection, security event analysis, and interactive dashboard visualization. Built specifically to demonstrate skills required for SOC Analyst positions.

**Key Capabilities:**
- **Automated Security Event Generation**: Creates realistic security events for testing
- **Threat Detection Algorithms**: Brute force and malware communication detection
- **Real-time Dashboard**: Interactive web-based security monitoring interface
- **Professional Reporting**: Enterprise-ready security analysis output

---

## 🚀 **Quick Start**

### Prerequisites
- Windows PowerShell 5.1 or later
- Modern web browser (Chrome, Firefox, Edge)
- Administrator privileges for PowerShell execution

### Installation
```powershell
# Clone the repository
git clone https://github.com/YOUR_USERNAME/soc-analyst-dashboard.git
cd soc-analyst-dashboard

# Set execution policy (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Usage Workflow
```powershell
# 1. Generate realistic security events (24 hours, 10,000 events)
.\scripts\Generate-SecurityEvents.ps1 -Hours 24 -EventCount 10000

# 2. Run brute force attack detection
.\scripts\Detect-BruteForce.ps1

# 3. Run malware communication detection
.\scripts\Detect-Malware.ps1

# 4. Open the dashboard
start .\dashboard\index.html
```

---

## 📁 **Project Structure**

```
soc-analyst-dashboard/
├── README.md                           # Project documentation
├── scripts/                           # PowerShell automation scripts
│   ├── Generate-SecurityEvents.ps1    # Security event generation
│   ├── Detect-BruteForce.ps1         # Brute force attack detection
│   └── Detect-Malware.ps1            # Malware communication detection
├── dashboard/                         # Web dashboard interface
│   ├── index.html                     # Main dashboard page
│   ├── css/styles.css                 # Cybersecurity-themed styling
│   └── js/dashboard.js                # Interactive functionality
├── docs/                              # Additional documentation
│   └── SETUP.md                       # Detailed setup instructions
└── data/                              # Data directories (created at runtime)
    ├── logs/                          # Timestamped security event logs
    ├── sample-logs/                   # Sample data for detection scripts
    ├── reports/                       # Threat detection reports
    └── threat-intel/                  # Threat intelligence data
```

---

## 🔧 **Component Details**

### PowerShell Scripts

#### `Generate-SecurityEvents.ps1`
Creates realistic security events for testing and demonstration:
- **Parameters**: `-Hours` (time range), `-EventCount` (number of events)
- **Output**: Creates files in both `data/logs/` and `data/sample-logs/`
- **Features**: Realistic IP addresses, usernames, timestamps, and event types
- **Creates**: security_events.csv and network_events.csv for detection scripts

#### `Detect-BruteForce.ps1`
Analyzes security events for brute force attack patterns:
- **Input**: `data/sample-logs/security_events.csv` (created by Generate-SecurityEvents.ps1)
- **Output**: Detailed brute force detection reports in `data/reports/`
- **Capabilities**: Pattern recognition, risk scoring, IOC identification
- **Detection**: Failed login attempts (Event ID 4625) with configurable thresholds

#### `Detect-Malware.ps1`
Identifies malware communication patterns in network logs:
- **Input**: `data/sample-logs/network_events.csv` (created by Generate-SecurityEvents.ps1)
- **Output**: Malware communication analysis reports in `data/reports/`
- **Features**: C2 detection, suspicious domain identification, threat classification
- **Intelligence**: Creates and uses threat intelligence feeds automatically

### Web Dashboard

**Interactive Features:**
- **Real-time Metrics**: Security event statistics and threat counts
- **Visual Analytics**: Charts and graphs for threat visualization
- **Alert Management**: Prioritized security alerts with severity levels
- **System Status**: Infrastructure health monitoring
- **Responsive Design**: Professional cybersecurity aesthetic

---

## 📊 **Expected Output**

### After Running Generate-SecurityEvents.ps1
```
✅ SUCCESS: Generated 10,000 security events
📁 Main file: .\data\logs\SecurityEvents_20250829_143022.csv
📁 Sample files created for detection scripts

📊 Event Summary:
   Info Events: 6,847
   Warning Events: 2,306
   High/Critical Events: 847
```

### After Running Detect-BruteForce.ps1
```
🚨 BRUTE FORCE ATTACKS DETECTED: 3
📄 Generating incident reports...
   ✅ Report saved: BF-20250829-143045-18522010024.txt
📈 Threats Detected: 3 (Critical: 1 | High: 1 | Medium: 1)
```

### After Running Detect-Malware.ps1
```
🦠 MALWARE COMMUNICATIONS DETECTED: 7
📄 Generating detailed incident reports...
   ✅ Report saved: MW-20250829-143067-18522010142.txt
📈 Affected Internal Hosts: 4
```

---

## 🎯 **Professional Applications**

### SOC Analyst Skills Demonstrated
- **Security Event Analysis**: Pattern recognition and threat identification
- **PowerShell Automation**: Enterprise-level scripting for security operations
- **Data Visualization**: Converting security data into actionable insights
- **Incident Response**: Systematic approach to threat detection and reporting
- **Documentation**: Professional reporting for stakeholder communication

### Enterprise Integration Ready
- **SIEM Compatible**: Outputs integrate with Splunk, QRadar, or similar platforms
- **Scalable Architecture**: Designed for high-volume security event processing
- **Compliance Reporting**: Structured output for audit and compliance requirements
- **Threat Intelligence**: Automated IOC matching and threat categorization

---

## 🔍 **Testing & Validation**

### Quick Test (1-minute demo)
```powershell
# Generate smaller dataset for quick testing
.\scripts\Generate-SecurityEvents.ps1 -Hours 1 -EventCount 1000
.\scripts\Detect-BruteForce.ps1
.\scripts\Detect-Malware.ps1

# Verify dashboard functionality
start .\dashboard\index.html
```

### Troubleshooting
If you encounter PowerShell execution errors:
```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# If scripts fail, ensure you're running as Administrator
# Right-click PowerShell → "Run as Administrator"
```

### Common Issues
- **"File not found"**: Run Generate-SecurityEvents.ps1 first to create sample data
- **"Access denied"**: Run PowerShell as Administrator
- **"Execution policy"**: Use the Set-ExecutionPolicy command above

---

## 📈 **Technical Highlights**

### Technologies Used
- **Backend**: PowerShell 5.1+ for security automation
- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Data Processing**: CSV parsing and analysis
- **Visualization**: Interactive security metrics and charts
- **Styling**: Modern cybersecurity-themed dark UI

### Security Considerations
- **Synthetic Data**: All generated events are synthetic for demonstration
- **No Sensitive Information**: No real credentials or system data used
- **Safe Testing**: Designed for isolated testing environments
- **Threat Intelligence**: Simulated IOCs for demonstration purposes

---

## 🚀 **Future Enhancements**

- **Machine Learning Integration**: AI-powered threat detection algorithms
- **Real-time Streaming**: Live security event processing
- **API Development**: RESTful API for enterprise integration
- **Advanced Analytics**: Behavioral analysis and anomaly detection
- **SIEM Integration**: Direct integration with enterprise security platforms

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 **Author**

**Artez Chapman** - Cybersecurity Professional  
*Built to demonstrate SOC analyst capabilities and cybersecurity automation skills.*

---

**⚡ Ready for Enterprise SOC Deployment ⚡**
