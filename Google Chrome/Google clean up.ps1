<#
.SYNOPSIS
    Automated cleanup and uninstallation script for Google Chrome.

.DESCRIPTION
    This script detects Google Chrome installations via ARP entries and setup.exe,
    then attempts to uninstall or remove orphaned entries and leftover folders.
    It handles multiple scenarios:
        1. ARP entry present with setup.exe available
        2. setup.exe present but ARP entry missing
        3. ARP entry present but setup.exe missing
        4. Neither ARP entry nor setup.exe found

    The script uses only native PowerShell commands (Start-Process, Remove-Item, etc.)
    for uninstall and cleanup operations.

.PARAMETER TargetVersion
    Specify the target version string to compare against installed versions.
    Default is "Enter Version".

.NOTES
    Author: Brajesh
    Source : https://github.com/brajesh61
    Date:   September 2026
    Tested on: Windows 10/11
    Requirements: Run with elevated privileges (Administrator)

.EXAMPLE
    .\Uninstall-Chrome.ps1
    Runs the script with default TargetVersion.

.EXAMPLE
    .\Uninstall-Chrome.ps1 -TargetVersion "118.0.5993.90"
    Uninstalls Chrome versions less than or equal to 118.0.5993.90.
#>


# Define target version (replace with actual version string if needed)
$TargetVersion = "Enter Version"

# Detect Chrome ARP entry
$ChromeARP = Get-ItemProperty `
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", `
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*Google Chrome*" }

# Detect setup.exe
$SetupExe = Get-ChildItem `
    "C:\Program Files\Google\Chrome\Application", `
    "C:\Program Files (x86)\Google\Chrome\Application" `
    -Filter "setup.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

# ------------------------------------------------------------
# Case 1: Uninstall lower version if exist
# ------------------------------------------------------------
if ($ChromeARP) {
    foreach ($Chrome in $ChromeARP) {
        $Version = $Chrome.DisplayVersion
        $PSChild = $Chrome.PSChildName

        $UninstallString = "$env:ProgramFiles\Google\Chrome\Application\$Version\Installer\setup.exe"
        $UninstallStringX86 = "$env:ProgramFiles(x86)\Google\Chrome\Application\$Version\Installer\setup.exe"

        if ($Version -le $TargetVersion) {##Comment this if version not required
            if ($PSChild -like "*Google Chrome*") {
                if (Test-Path $UninstallString) {
                    Start-Process -FilePath $UninstallString -ArgumentList "--uninstall --channel=stable --system-level --verbose-logging --force-uninstall" -Wait
                    Remove-Item "$env:ProgramFiles\Google\Chrome\Application\$Version" -Recurse -Force -ErrorAction SilentlyContinue
                }
                if (Test-Path $UninstallStringX86) {
                    Start-Process -FilePath $UninstallStringX86 -ArgumentList "--uninstall --channel=stable --system-level --verbose-logging --force-uninstall" -Wait
                    Remove-Item "$env:ProgramFiles(x86)\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
                    Remove-Item "$env:ProgramFiles(x86)\Google" -Recurse -Force -ErrorAction SilentlyContinue
                }
                Write-Host "Google Chrome $Version uninstalled successfully." -ForegroundColor Green
            }
            else {
                # Generic MSI uninstall
                $UninstallCmd = "msiexec.exe /x $PSChild /qn /norestart"
                Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $PSChild /qn /norestart" -Wait
                Write-Host "Google Chrome $Version uninstalled successfully." -ForegroundColor Green

                Remove-Item "$env:ProgramFiles(x86)\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item "$env:ProgramFiles(x86)\Google" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item "$env:ProgramFiles\Google" -Recurse -Force -ErrorAction SilentlyContinue
            }
        }##Comment this if version not required
    }
}

# ------------------------------------------------------------
# Case 2: setup.exe present BUT ARP entry missing 
# ------------------------------------------------------------
elseif ($SetupExe -and (-not $ChromeARP)) {
    Write-Host "setup.exe found but ARP entry missing. Running Chrome cleanup." -ForegroundColor Green

     # Remove MSI Product Entries
            Get-ChildItem "HKLM:\SOFTWARE\Classes\Installer\Products" -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {
                    $Props = Get-ItemProperty $_.PSPath -ErrorAction Stop

                    if ($Props.ProductName -like "*Google Chrome*" -or
                        $Props.ProductName -like "*Chrome*") {

                        Write-Host "Removing MSI Product: $($Props.ProductName)" -ForegroundColor Green

                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                catch {
                    Write-Host "Failed processing MSI Product Key: $($_.PSChildName)" -ForegroundColor Green
                }
            }

            # Remove MSI UserData Entries
            Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products" -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {

                    $InstallProperties = Join-Path $_.PSPath "InstallProperties"
                    $Props = Get-ItemProperty $InstallProperties -ErrorAction SilentlyContinue

                    if ($Props.DisplayName -like "*Google Chrome*" -or
                        $Props.DisplayName -like "*Chrome*") {

                        Write-Host "Removing MSI UserData: $($Props.DisplayName)" -ForegroundColor Green

                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                catch {
                    Write-Host "Failed processing MSI UserData Key: $($_.PSChildName)" -ForegroundColor Red
                }
            }
    Start-Process -FilePath $SetupExe -ArgumentList "--uninstall --force-uninstall --system-level" -Wait
    Start-Sleep -Seconds 10

    # Cleanup folders
    Remove-Item "$env:ProgramFiles\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles\Google" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles(x86)\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles(x86)\Google" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Google" -Recurse -Force -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------
# Case 3: ARP entry present BUT setup.exe missing
# ------------------------------------------------------------
elseif ($ChromeARP -and (-not $SetupExe)) {
    Write-Host "ARP entry found but setup.exe missing. Cleaning orphaned Chrome registration." -ForegroundColor Green


     # Remove MSI Product Entries
            Get-ChildItem "HKLM:\SOFTWARE\Classes\Installer\Products" -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {
                    $Props = Get-ItemProperty $_.PSPath -ErrorAction Stop

                    if ($Props.ProductName -like "*Google Chrome*" -or
                        $Props.ProductName -like "*Chrome*") {

                        Write-Host "Removing MSI Product: $($Props.ProductName)" -ForegroundColor Green

                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                catch {
                    Write-Host "Failed processing MSI Product Key: $($_.PSChildName)" -ForegroundColor Red
                }
            }

            # Remove MSI UserData Entries
            Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products" -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {

                    $InstallProperties = Join-Path $_.PSPath "InstallProperties"
                    $Props = Get-ItemProperty $InstallProperties -ErrorAction SilentlyContinue

                    if ($Props.DisplayName -like "*Google Chrome*" -or
                        $Props.DisplayName -like "*Chrome*") {

                        Write-Host "Removing MSI UserData: $($Props.DisplayName)" -ForegroundColor Green

                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                catch {
                    Write-Host "Failed processing MSI UserData Key: $($_.PSChildName)" -ForegroundColor Red
                }
            }

    # Remove ARP entries
    Get-ItemProperty `
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", `
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
        -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.DisplayName -like "*Google Chrome*") {
                Write-Host "Removing ARP Entry: $($Props.DisplayName)" -ForegroundColor Green
                Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

    # Cleanup folders
    Remove-Item "$env:ProgramFiles\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles\Google" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles(x86)\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles(x86)\Google" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Google" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "Google Chrome cleanup completed."
}
# Case 4: Neither setup.exe nor ARP entry found
else {
    Write-Host "Google Chrome not detected." -ForegroundColor Yellow
}
