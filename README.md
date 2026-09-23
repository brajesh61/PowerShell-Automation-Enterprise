# PowerShell Automation Enterprise 🚀

[![Language](https://img.shields.io/badge/Language-PowerShell-blue.svg)](https://github.com/brajesh61/PowerShell-Automation-Enterprise)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/brajesh61/PowerShell-Automation-Enterprise/graphs/commit-activity)

A collection of enterprise-grade PowerShell automation scripts designed to streamline IT administration, software deployment troubleshooting, and system management across enterprise environments.

---

## 📌 Repository Overview

This repository houses production-ready PowerShell scripts intended to solve common Enterprise IT operational issues, automated remediation tasks, and system configurations.

### Available Automation Scripts

| Category | Script Name | Description | Link |
| :--- | :--- | :--- | :--- |
| **Google Chrome** | `Fix-Chrome1603.ps1` | Resolves MSI installation/update Error Code 1603 during Chrome enterprise deployments. | [View Script](https://github.com/brajesh61/PowerShell-Automation-Enterprise/tree/main/Google%20Chrome) |

---

## 🔧 Featured Script Details

### 🛠️ Chrome Installation Remediation (`Fix-Chrome1603.ps1`)

* **Problem Solved:** MSI Error 1603 (Fatal error during installation) when deploying or updating Google Chrome via SCCM, Intune, or manual deployment.
* **Key Features:**
  * Cleanly terminates hanging Google Chrome processes.
  * Cleans orphaned registry keys causing installer lockups.
  * Ensures a clean slate before retrying the deployment process.
* **Direct Path:** [`/Google Chrome/Fix-Chrome1603.ps1`](https://github.com/brajesh61/PowerShell-Automation-Enterprise/tree/main/Google%20Chrome)

---

## 🚀 Getting Started

### Prerequisites

* PowerShell 5.1 or PowerShell 7+
* Administrator privileges on target Windows endpoints

### Execution Example

To run scripts from this repository locally:

```powershell
# Unblock downloaded script if needed
Unblock-File -Path ".\Fix-Chrome1603.ps1"

# Run with Administrator privileges
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Fix-Chrome1603.ps1
