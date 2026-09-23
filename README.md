# PowerShell Automation Enterprise 🚀

[![Language](https://img.shields.io/badge/Language-PowerShell-blue.svg)](https://github.com/brajesh61/PowerShell-Automation-Enterprise)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/brajesh61/PowerShell-Automation-Enterprise/blob/main/LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/brajesh61/PowerShell-Automation-Enterprise/graphs/commit-activity)

A collection of enterprise-grade PowerShell automation scripts designed to streamline IT administration, software deployment troubleshooting, and system management across enterprise environments.

---

## 📌 Repository Overview

This repository houses production-ready PowerShell scripts intended to solve common Enterprise IT operational issues, automated remediation tasks, and system configurations.

### Available Automation Scripts

| Category | Script Name | Description | Link |
| :--- | :--- | :--- | :--- |
| **Google Chrome** | `Google chrome clean up.ps1` | Automated cleanup and uninstallation script that handles broken ARP entries, missing setup files, and leftover directories. | [View Script](https://github.com/brajesh61/PowerShell-Automation-Enterprise/blob/main/Google%20Chrome/Google%20chrome%20clean%20up.ps1) |
| **Google Chrome** | `Fix-Chrome1603.ps1` | Resolves MSI installation/update Error Code 1603 during Chrome enterprise deployments. | [View Script](https://github.com/brajesh61/PowerShell-Automation-Enterprise/blob/main/Google%20Chrome/Fix-Chrome1603.ps1) |

---

## 🔧 Featured Script Details

### 🧹 Google Chrome Cleanup & Uninstall (`Google chrome clean up.ps1`)

* **Problem Solved:** Detects and completely removes Google Chrome installations, orphaned registry entries, and leftover files across multiple failure scenarios.
* **Scenarios Handled:**
  1. **Standard Uninstall:** Uninstalling target version using `setup.exe` or native MSI parameters.
  2. **Corrupted Install (setup.exe present, ARP missing):** Removes stale MSI product keys and triggers clean setup uninstallation.
  3. **Orphaned Registration (ARP present, setup.exe missing):** Cleans up stale registry entries from `HKLM:\SOFTWARE\Classes\Installer` and uninstall keys.
  4. **Post-Cleanup:** Sweeps leftover directories in `Program Files`, `Program Files (x86)`, and `%LOCALAPPDATA%`.
* **Direct Path:** [`/Google Chrome/Google chrome clean up.ps1`](https://github.com/brajesh61/PowerShell-Automation-Enterprise/blob/main/Google%20Chrome/Google%20chrome%20clean%20up.ps1)

---

### 🛠️ Chrome Installation Remediation (`Fix-Chrome1603.ps1`)

* **Problem Solved:** MSI Error 1603 (Fatal error during installation) when deploying or updating Google Chrome via SCCM, Intune, or manual deployment.
* **Key Features:**
  * Cleanly terminates hanging Google Chrome processes.
  * Cleans orphaned registry keys causing installer lockups.
  * Ensures a clean slate before retrying the deployment process.
* **Direct Path:** [`/Google Chrome/Fix-Chrome1603.ps1`](https://github.com/brajesh61/PowerShell-Automation-Enterprise/blob/main/Google%20Chrome/Fix-Chrome1603.ps1)

---

## 🚀 Getting Started

### Prerequisites

* PowerShell 5.1 or PowerShell 7+
* Administrator privileges on target Windows endpoints (Windows 10 / 11 / Server)

### Execution Examples

To run scripts from this repository locally:

```powershell
# Unblock downloaded script if needed
Unblock-File -Path ".\Google chrome clean up.ps1"

# Run Chrome cleanup with elevated privileges
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\'Google chrome clean up.ps1' -TargetVersion "118.0.5993.90"
