// SOC Analyst Dashboard JavaScript
// Interactive functionality for threat monitoring simulation
// Author: Artez Chapman

class SOCDashboard {
    constructor() {
        this.initializeComponents();
        this.startRealTimeUpdates();
        this.populateAlertFeed();
        this.populateInvestigationQueue();
        this.bindEventListeners();
    }

    initializeComponents() {
        // Initialize timestamp display
        this.updateTimestamp();
        setInterval(() => this.updateTimestamp(), 1000);

        // Initialize metrics animation
        this.animateMetrics();
    }

    updateTimestamp() {
        const now = new Date();
        const timestamp = now.toLocaleString('en-US', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        });
        
        const currentTimeElement = document.getElementById('currentTime');
        if (currentTimeElement) {
            currentTimeElement.textContent = timestamp;
        }

        const lastAnalysisElement = document.getElementById('lastAnalysis');
        if (lastAnalysisElement) {
            lastAnalysisElement.textContent = timestamp;
        }
    }

    animateMetrics() {
        // Animate metric values on load
        const metricValues = document.querySelectorAll('.metric-value');
        metricValues.forEach((element, index) => {
            const targetValue = element.textContent;
            const numericValue = parseInt(targetValue.replace(/,/g, ''));
            
            if (!isNaN(numericValue)) {
                element.textContent = '0';
                this.animateNumber(element, 0, numericValue, 2000, targetValue.includes(','));
            }
        });
    }

    animateNumber(element, start, end, duration, useCommas = false) {
        const startTime = Date.now();
        const animate = () => {
            const elapsed = Date.now() - startTime;
            const progress = Math.min(elapsed / duration, 1);
            
            // Easing function
            const easeOutCubic = 1 - Math.pow(1 - progress, 3);
            const current = Math.floor(start + (end - start) * easeOutCubic);
            
            element.textContent = useCommas ? current.toLocaleString() : current.toString();
            
            if (progress < 1) {
                requestAnimationFrame(animate);
            }
        };
        animate();
    }

    populateAlertFeed() {
        const alertFeed = document.getElementById('alertFeed');
        if (!alertFeed) return;

        const alerts = [
            {
                severity: 'critical',
                title: 'Data Exfiltration Detected',
                details: '192.168.1.150 → 203.0.113.195 | 847MB transferred',
                time: '14:32:15'
            },
            {
                severity: 'high',
                title: 'Brute Force Attack',
                details: '203.0.113.15 → admin account | 47 attempts',
                time: '14:28:42'
            },
            {
                severity: 'high',
                title: 'Malware Communication',
                details: '10.0.0.25 → 185.220.101.42 | Botnet C2',
                time: '14:25:18'
            },
            {
                severity: 'medium',
                title: 'Suspicious Port Activity',
                details: '172.16.1.10 → Port 31337 | Unusual traffic',
                time: '14:22:07'
            },
            {
                severity: 'high',
                title: 'Failed Login Spike',
                details: '198.51.100.25 → Multiple accounts | 23 attempts',
                time: '14:19:33'
            },
            {
                severity: 'critical',
                title: 'APT Communication',
                details: '192.168.1.102 → 203.0.113.195 | Command & Control',
                time: '14:15:22'
            },
            {
                severity: 'medium',
                title: 'Off-Hours File Access',
                details: 'finance_data.xlsx accessed | User: jsmith',
                time: '14:12:45'
            }
        ];

        alertFeed.innerHTML = '';
        alerts.forEach((alert, index) => {
            const alertElement = document.createElement('div');
            alertElement.className = `alert-item ${alert.severity}`;
            alertElement.style.animationDelay = `${index * 0.1}s`;
            alertElement.style.opacity = '0';
            alertElement.style.animation = 'slideInLeft 0.5s ease forwards';
            
            alertElement.innerHTML = `
                <div class="alert-severity ${alert.severity}">${alert.severity}</div>
                <div class="alert-content">
                    <div class="alert-title">${alert.title}</div>
                    <div class="alert-details">${alert.details}</div>
                </div>
                <div class="alert-time">${alert.time}</div>
            `;
            
            alertFeed.appendChild(alertElement);
        });

        // Add CSS animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideInLeft {
                from {
                    opacity: 0;
                    transform: translateX(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }
        `;
        document.head.appendChild(style);
    }

    populateInvestigationQueue() {
        const tableBody = document.querySelector('#investigationQueue tbody');
        if (!tableBody) return;

        const incidents = [
            {
                id: 'BF-20250826-143215-2030113015',
                type: 'Brute Force Attack',
                severity: 'critical',
                source: '203.0.113.15',
                time: '14:32:15',
                status: 'investigating'
            },
            {
                id: 'MW-20250826-142818-18522010142',
                type: 'Malware Communication',
                severity: 'high',
                source: '10.0.0.25',
                time: '14:28:18',
                status: 'blocked'
            },
            {
                id: 'DE-20250826-141522-2030113195',
                type: 'Data Exfiltration',
                severity: 'critical',
                source: '192.168.1.150',
                time: '14:15:22',
                status: 'investigating'
            },
            {
                id: 'BF-20250826-141933-19851100025',
                type: 'Brute Force Attack',
                severity: 'high',
                source: '198.51.100.25',
                time: '14:19:33',
                status: 'blocked'
            },
            {
                id: 'SA-20250826-141245-17216110',
                type: 'Suspicious Activity',
                severity: 'medium',
                source: '172.16.1.10',
                time: '14:12:45',
                status: 'monitoring'
            }
        ];

        tableBody.innerHTML = '';
        incidents.forEach(incident => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td><span class="incident-id">${incident.id}</span></td>
                <td>${incident.type}</td>
                <td><span class="severity-badge ${incident.severity}">${incident.severity}</span></td>
                <td><code>${incident.source}</code></td>
                <td>${incident.time}</td>
                <td><span class="status-badge ${incident.status}">${incident.status}</span></td>
                <td>
                    <button class="action-btn" onclick="dashboard.viewIncident('${incident.id}')">View</button>
                    <button class="action-btn" onclick="dashboard.blockSource('${incident.source}')">Block</button>
                </td>
            `;
            tableBody.appendChild(row);
        });
    }

    startRealTimeUpdates() {
        // Simulate real-time metric updates
        setInterval(() => {
            this.updateMetrics();
        }, 5000);

        // Simulate new alerts
        setInterval(() => {
            this.addNewAlert();
        }, 15000);
    }

    updateMetrics() {
        const totalEvents = document.getElementById('totalEvents');
        const activeThreats = document.getElementById('activeThreats');
        const mttd = document.getElementById('mttd');
        const accuracy = document.getElementById('accuracy');

        if (totalEvents) {
            const current = parseInt(totalEvents.textContent.replace(/,/g, ''));
            const newValue = current + Math.floor(Math.random() * 50) + 10;
            totalEvents.textContent = newValue.toLocaleString();
        }

        if (activeThreats) {
            const threats = ['5', '6', '7', '8', '9'];
            activeThreats.textContent = threats[Math.floor(Math.random() * threats.length)];
        }

        if (mttd) {
            const values = ['4.2', '3.8', '4.5', '3.9', '4.1'];
            mttd.textContent = values[Math.floor(Math.random() * values.length)];
        }

        if (accuracy) {
            const values = ['97.8%', '97.6%', '98.1%', '97.9%', '98.0%'];
            accuracy.textContent = values[Math.floor(Math.random() * values.length)];
        }
    }

    addNewAlert() {
        const alertFeed = document.getElementById('alertFeed');
        if (!alertFeed) return;

        const newAlerts = [
            {
                severity: 'medium',
                title: 'Unusual Network Activity',
                details: '10.0.0.15 → Port scanning detected',
                time: new Date().toLocaleTimeString('en-US', { hour12: false })
            },
            {
                severity: 'high',
                title: 'Login from New Location',
                details: 'admin account → Suspicious geolocation',
                time: new Date().toLocaleTimeString('en-US', { hour12: false })
            },
            {
                severity: 'medium',
                title: 'Antivirus Alert',
                details: 'Potential malware → Quarantined',
                time: new Date().toLocaleTimeString('en-US', { hour12: false })
            }
        ];

        const randomAlert = newAlerts[Math.floor(Math.random() * newAlerts.length)];
        
        const alertElement = document.createElement('div');
        alertElement.className = `alert-item ${randomAlert.severity}`;
        alertElement.style.opacity = '0';
        alertElement.style.transform = 'translateY(-20px)';
        alertElement.style.transition = 'all 0.5s ease';
        
        alertElement.innerHTML = `
            <div class="alert-severity ${randomAlert.severity}">${randomAlert.severity}</div>
            <div class="alert-content">
                <div class="alert-title">${randomAlert.title}</div>
                <div class="alert-details">${randomAlert.details}</div>
            </div>
            <div class="alert-time">${randomAlert.time}</div>
        `;
        
        // Insert at the top of the feed
        alertFeed.insertBefore(alertElement, alertFeed.firstChild);
        
        // Animate in
        setTimeout(() => {
            alertElement.style.opacity = '1';
            alertElement.style.transform = 'translateY(0)';
        }, 100);
        
        // Remove oldest alert if more than 10
        const alerts = alertFeed.querySelectorAll('.alert-item');
        if (alerts.length > 10) {
            alerts[alerts.length - 1].remove();
        }
    }

    bindEventListeners() {
        // Auto refresh toggle
        const autoRefreshBtn = document.getElementById('autoRefresh');
        if (autoRefreshBtn) {
            autoRefreshBtn.addEventListener('click', () => {
                this.toggleAutoRefresh(autoRefreshBtn);
            });
        }

        // Export incidents button
        const exportBtn = document.getElementById('exportIncidents');
        if (exportBtn) {
            exportBtn.addEventListener('click', () => {
                this.exportIncidents();
            });
        }

        // Run analysis button
        const runAnalysisBtn = document.getElementById('runAnalysis');
        if (runAnalysisBtn) {
            runAnalysisBtn.addEventListener('click', () => {
                this.runFullAnalysis(runAnalysisBtn);
            });
        }

        // Timeframe selector
        const timeframeSelect = document.getElementById('timeframe');
        if (timeframeSelect) {
            timeframeSelect.addEventListener('change', (e) => {
                this.updateTimeframe(e.target.value);
            });
        }
    }

    toggleAutoRefresh(button) {
        if (button.classList.contains('active')) {
            button.classList.remove('active');
            button.textContent = 'Auto Refresh (Off)';
            // Stop auto refresh
            if (this.refreshInterval) {
                clearInterval(this.refreshInterval);
            }
        } else {
            button.classList.add('active');
            button.textContent = 'Auto Refresh';
            // Start auto refresh
            this.refreshInterval = setInterval(() => {
                this.addNewAlert();
            }, 10000);
        }
    }

    exportIncidents() {
        // Simulate export functionality
        const incidents = document.querySelectorAll('#investigationQueue tbody tr');
        const csvContent = 'Incident ID,Threat Type,Severity,Source,Time,Status\n' +
            Array.from(incidents).map(row => {
                const cells = row.querySelectorAll('td');
                return Array.from(cells).slice(0, 6).map(cell => 
                    cell.textContent.replace(/,/g, ';')
                ).join(',');
            }).join('\n');

        const blob = new Blob([csvContent], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `soc_incidents_${new Date().toISOString().slice(0, 10)}.csv`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
        
        // Show feedback
        this.showNotification('Incident report exported successfully', 'success');
    }

    runFullAnalysis(button) {
        const originalText = button.textContent;
        button.textContent = 'Running Analysis...';
        button.disabled = true;
        
        // Simulate analysis process
        setTimeout(() => {
            // Update metrics to show analysis results
            document.getElementById('totalEvents').textContent = '12,483';
            document.getElementById('activeThreats').textContent = '9';
            document.getElementById('mttd').textContent = '3.7';
            document.getElementById('accuracy').textContent = '98.2%';
            
            // Add new critical alert
            const alertFeed = document.getElementById('alertFeed');
            const newAlert = document.createElement('div');
            newAlert.className = 'alert-item critical';
            newAlert.innerHTML = `
                <div class="alert-severity critical">CRITICAL</div>
                <div class="alert-content">
                    <div class="alert-title">Full Analysis Complete</div>
                    <div class="alert-details">2 new critical threats identified | Immediate action required</div>
                </div>
                <div class="alert-time">${new Date().toLocaleTimeString('en-US', { hour12: false })}</div>
            `;
            alertFeed.insertBefore(newAlert, alertFeed.firstChild);
            
            button.textContent = originalText;
            button.disabled = false;
            
            this.showNotification('Full analysis completed - 2 new critical threats detected', 'warning');
        }, 3000);
    }

    updateTimeframe(timeframe) {
        // Simulate updating threat analysis based on timeframe
        const threatBars = document.querySelectorAll('.category-bar');
        const threatCounts = document.querySelectorAll('.category-count');
        
        const timeframeData = {
            '1h': { critical: 1, high: 2, medium: 1 },
            '24h': { critical: 2, high: 3, medium: 2 },
            '7d': { critical: 5, high: 8, medium: 12 }
        };
        
        const data = timeframeData[timeframe];
        const total = data.critical + data.high + data.medium;
        
        // Update bars and counts
        if (threatBars.length >= 3 && threatCounts.length >= 3) {
            // Critical
            threatBars[0].style.width = `${(data.critical / total) * 100}%`;
            threatCounts[0].textContent = data.critical;
            
            // High
            threatBars[1].style.width = `${(data.high / total) * 100}%`;
            threatCounts[1].textContent = data.high;
            
            // Medium
            threatBars[2].style.width = `${(data.medium / total) * 100}%`;
            threatCounts[2].textContent = data.medium;
        }
    }

    viewIncident(incidentId) {
        this.showNotification(`Opening incident ${incidentId} for detailed analysis`, 'info');
        // In a real implementation, this would open a detailed incident view
    }

    blockSource(sourceIP) {
        this.showNotification(`Blocked source IP: ${sourceIP}`, 'success');
        // In a real implementation, this would trigger firewall blocking
    }

    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: var(--bg-secondary);
            color: var(--text-primary);
            border: 1px solid var(--border);
            border-left: 4px solid var(--${type === 'success' ? 'success' : type === 'warning' ? 'warning' : type === 'error' ? 'danger' : 'accent-primary'});
            padding: 1rem;
            border-radius: 8px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            z-index: 1000;
            max-width: 300px;
            animation: slideInRight 0.3s ease;
        `;
        
        document.body.appendChild(notification);
        
        // Auto remove after 3 seconds
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }
}

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.dashboard = new SOCDashboard();
});

// Add notification animations
const notificationStyles = document.createElement('style');
notificationStyles.textContent = `
    @keyframes slideInRight {
        from {
            opacity: 0;
            transform: translateX(100%);
        }
        to {
            opacity: 1;
            transform: translateX(0);
        }
    }
    
    @keyframes slideOutRight {
        from {
            opacity: 1;
            transform: translateX(0);
        }
        to {
            opacity: 0;
            transform: translateX(100%);
        }
    }
`;
document.head.appendChild(notificationStyles);