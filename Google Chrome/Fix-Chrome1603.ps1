<#
.SYNOPSIS
    Resolve Google Chrome installation error 1603.

.DESCRIPTION
    This script is intended to fix cases where:
        - Neither ARP entry nor setup.exe is found, OR
        - Chrome was uninstalled using setup.exe,
          but attempting to install a new version results in MSI error 1603.

    The script cleans up orphaned registry entries and leftover Chrome folders
    to ensure a fresh installation can proceed without error.

.NOTES
    .NOTES
    This PowerShell script was developed and optimized specifically for brajesh61. 
    Usage of this script is intended within the brajesh61 environment. 
    Customers and users are permitted to copy the script from the repository 
    and apply it in brajesh61 solutions.

    Please note: The general terms of use for brajesh61 do not apply to this script. 
    brajesh61 Software GmbH assumes no responsibility or liability for its functionality, 
    usage, or any consequences arising from its use. This script is provided freely 
    and without warranty.

    PowerShell is a product of Microsoft Corporation. 
    brajesh61 is a product of brajesh61 Software GmbH. 
    © brajesh61 Software GmbH. All rights reserved.

    .LINK
        https://github.com/brajesh61/PowerShell-Automation/tree/MasterList/ActiveDirectory/Computers


.EXAMPLE
    .\Fix-Chrome1603.ps1
    Executes the cleanup routine to resolve Chrome installation error 1603.
#>

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

 # Cleanup folders
    Remove-Item "$env:ProgramFiles\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles\Google" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles(x86)\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramFiles(x86)\Google" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Google\Chrome" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LOCALAPPDATA\Google" -Recurse -Force -ErrorAction SilentlyContinue
