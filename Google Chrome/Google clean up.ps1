       $Version = "Enter Version"
       # Detect Chrme ARP Entry
        $ChromeARP = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*Google Chrome*" }



        # Detect setup.exe
        $SetupExe = Get-ChildItem "C:\Program Files\Google\Chrome\Application", "C:\Program Files (x86)\Google\Chrome\Application" -Filter "setup.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
        # ------------------------------------------------------------
        # Case 1: Uninstall lower version if exist
        # ------------------------------------------------------------
        If($ChromeARP)
        {
        Foreach($Chrome in $ChromeARP){
         $Version = $Chrome.DisplayVersion
       $PSChild = $Chrome.PSChildName
         $UninstallString = "$envProgramFiles\Google\Chrome\Application\$Version\Installer\setup.exe"
         $UninstallStringX86 = "$envProgramFilesX86\Google\Chrome\Application\$Version\Installer\setup.exe"
        If($Version -le "$Version")
        {
             If($PSChild -like "*Google Chrome*"){
             If(Test-Path -Path $UninstallString){ 
                Execute-Process -Path $UninstallString -Parameters "--uninstall --channel=stable --system-level --verbose-logging --force-uninstall" -ContinueOnError $true
                If(Test-Path -Path "$envProgramFiles\Google\Chrome\Application\$Version"){
                 Remove-Folder -Path "$envProgramFiles\Google\Chrome\Application\$Version" -ContinueOnError $true}
                }
                If(Test-Path -Path $UninstallStringX86){
                    Execute-Process -Path $UninstallStringX86 -Parameters "--uninstall --channel=stable --system-level --verbose-logging --force-uninstall" -ContinueOnError $true
                If(Test-Path -Path "$envProgramFilesX86\Google\Chrome"){
                 Remove-Folder -Path "$envProgramFilesX86\Google\Chrome" -ContinueOnError $true}
                 Remove-Folder -Path "$envProgramFilesX86\Google" -ContinueOnError $true
                }
                Write-Log -Message "Google chrome $Version is uninstalled successfully...." -Source ${CmdletName}
              }
              Else
                {
                If($PSChild -notlike "*Google Chrome*")
                   {
                     Execute-MSI -Action 'Uninstall' -Path "$PSChild" -Parameters "/qn /norestart" -ContinueOnError $true
                     Write-Log -Message "Google chrome $Version is uninstalled successfully...." -Source ${CmdletName}
                   }
                   If(Test-Path -Path "$envProgramFilesX86\Google\Chrome"){
                   Remove-Folder -Path "$envProgramFilesX86\Google\Chrome" -ContinueOnError $true}
                   Remove-Folder -Path "$envProgramFilesX86\Google" -ContinueOnError $true
                   Remove-Folder -Path "$envProgramFiles\Google" -ContinueOnError $true
                }
              }
           }
        }
        
        
        # ------------------------------------------------------------
        # Case 2: setup.exe present BUT ARP entry missing Exid code 1603 solution
        # ------------------------------------------------------------
        if ($SetupExe -and (-not $ChromeARP)) {
             
            # Remove MSI Product Entries
            Get-ChildItem "HKLM:\SOFTWARE\Classes\Installer\Products" -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {
                    $Props = Get-ItemProperty $_.PSPath -ErrorAction Stop

                    if ($Props.ProductName -like "*Google Chrome*" -or
                        $Props.ProductName -like "*Chrome*") {

                        Write-Log "Removing MSI Product: $($Props.ProductName)" -Source ${CmdletName}

                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                catch {
                    Write-Log "Failed processing MSI Product Key: $($_.PSChildName)" -Source ${CmdletName}
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

                        Write-Log "Removing MSI UserData: $($Props.DisplayName)" -Source ${CmdletName}

                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                catch {
                    Write-Log "Failed processing MSI UserData Key: $($_.PSChildName)" -Source ${CmdletName}
                }
            }
            Write-Log "setup.exe found but ARP entry missing. Running Chrome cleanup." -Source ${CmdletName}

            Execute-Process -Path $SetupExe -Parameters "--uninstall --force-uninstall --system-level"

            Start-Sleep -Seconds 10
                
             # ------------------------------------------------------------
             # Common Cleanup (Runs for all cases)
             # ------------------------------------------------------------
 
                Write-Log "Removing remaining Chrome folders." -Source ${CmdletName}

                Remove-Folder -Path "$envProgramFiles\Google\Chrome" -ErrorAction SilentlyContinue
                Remove-Folder -Path "$envProgramFiles\Google" -ErrorAction SilentlyContinue

                Remove-Folder -Path "$envProgramFilesX86\Google\Chrome" -ErrorAction SilentlyContinue
                Remove-Folder -Path "$envProgramFilesX86\Google" -ErrorAction SilentlyContinue

                Remove-Folder -Path "$env:LOCALAPPDATA\Google\Chrome" -ErrorAction SilentlyContinue
                Remove-Folder -Path "$env:LOCALAPPDATA\Google" -ErrorAction SilentlyContinue
        }
        # ------------------------------------------------------------
        # Case 3: ARP entry present BUT setup.exe missing
        # ------------------------------------------------------------
        elseif ($ChromeARP -and (-not $SetupExe)) {

            Write-Log "ARP entry found but setup.exe missing. Cleaning orphaned Chrome registration." -Source ${CmdletName}

            # Remove MSI Product Entries
            Get-ChildItem "HKLM:\SOFTWARE\Classes\Installer\Products" -ErrorAction SilentlyContinue |
            ForEach-Object {

                try {
                    $Props = Get-ItemProperty $_.PSPath -ErrorAction Stop

                    if ($Props.ProductName -like "*Google Chrome*" -or
                        $Props.ProductName -like "*Chrome*") {

                        Write-Log "Removing MSI Product: $($Props.ProductName)" -Source ${CmdletName}

                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                catch {
                    Write-Log "Failed processing MSI Product Key: $($_.PSChildName)" -Source ${CmdletName}
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

                        Write-Log "Removing MSI UserData: $($Props.DisplayName)" -Source ${CmdletName}

                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                catch {
                    Write-Log "Failed processing MSI UserData Key: $($_.PSChildName)" -Source ${CmdletName}
                }
            }

            # Remove ARP Entries
            Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {

                    $Props = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue

                    if ($Props.DisplayName -like "*Google Chrome*") {

                        Write-Log "Removing ARP Entry: $($Props.DisplayName)" -Source ${CmdletName}

                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                catch {
                    Write-Log "Failed processing ARP Key: $($_.PSChildName)" -Source ${CmdletName}
                }
            }

             # ------------------------------------------------------------
             # Common Cleanup (Runs for all cases)
             # ------------------------------------------------------------

                Write-Log "Removing remaining Chrome folders." -Source ${CmdletName}

                Remove-Folder -Path "$envProgramFiles\Google\Chrome" -ErrorAction SilentlyContinue
                Remove-Folder -Path "$envProgramFiles\Google" -ErrorAction SilentlyContinue

                Remove-Folder -Path "$envProgramFilesX86\Google\Chrome" -ErrorAction SilentlyContinue
                Remove-Folder -Path "$envProgramFilesX86\Google" -ErrorAction SilentlyContinue

                Remove-Folder -Path "$env:LOCALAPPDATA\Google\Chrome" -ErrorAction SilentlyContinue
                Remove-Folder -Path "$env:LOCALAPPDATA\Google" -ErrorAction SilentlyContinue

                Write-Log "Google Chrome cleanup completed." -Source ${CmdletName}
        }
        # ------------------------------------------------------------
        # Case 4: Neither setup.exe nor ARP entry found
        # ------------------------------------------------------------
        else {
            Write-Log "Google Chrome not detected." -Source ${CmdletName}
        }