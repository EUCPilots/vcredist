function Import-VcConfigMgrApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Import-VcCmApp")]
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/import-vcconfigmgrapplication/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Pass a VcList object from Save-VcRedist.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $CMPath,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateScript( { if ($_ -match "^[a-zA-Z0-9]{3}$") { $true } else { throw "$_ is not a valid ConfigMgr site code." } })]
        [System.String] $SMSSiteCode,

        [Parameter(Mandatory = $false, Position = 4)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $NoCopy,

        [Parameter(Mandatory = $false, Position = 5)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $false, Position = 6)]
        [ValidatePattern("^[a-zA-Z0-9\+ ]+$")]
        [System.String] $Keyword = "Visual C++ Redistributable"
    )

    begin {
        #region If the ConfigMgr console is installed, load the PowerShell module; Requires PowerShell module to be installed
        if (Test-Path -Path env:SMS_ADMIN_UI_PATH) {
            try {
                # Import the ConfigurationManager.psd1 module
                $params = @{
                    Path        = $(Split-Path -Path $env:SMS_ADMIN_UI_PATH -Parent)
                    Filter      = "ConfigurationManager.psd1"
                    ErrorAction = "SilentlyContinue"
                }
                $ModuleFile = Get-ChildItem @params
                if (-not[System.String]::IsNullOrEmpty($ModuleFile)) {
                    Write-Verbose -Message "Importing module: $($ModuleFile.FullName)"
                    Import-Module -Name $ModuleFile.FullName -Verbose:$false
                }
                else {
                    $Msg = "Could not load ConfigurationManager.psd1 from $(Split-Path -Path $env:SMS_ADMIN_UI_PATH -Parent). Please make sure that the Configuration Manager console is installed."
                    throw [System.IO.FileNotFoundException]::New($Msg)
                }
            }
            catch {
                throw $_
            }
        }
        else {
            $Msg = "Cannot find environment variable SMS_ADMIN_UI_PATH. Is the ConfigMgr console and PowerShell module installed?"
            throw [System.Exception]::New($Msg)
        }
        #endregion

        #region Validate $CMPath
        if ($CMPath -notmatch "^\\\\[^\\]+\\[^\\]+(?:\\.*)?$") {
            $Msg = "'$CMPath' must be a UNC path to an existing FileSystem directory."
            throw [System.ArgumentException]::New($Msg)
        }
        $ResolvedCMPath = Resolve-Path -LiteralPath $CMPath -ErrorAction "SilentlyContinue"
        if ($null -ne $ResolvedCMPath) {
            $CMPathItem = Get-Item -LiteralPath $ResolvedCMPath.ProviderPath -ErrorAction "Stop"
            if ($CMPathItem.Provider.Name -ne "FileSystem" -or -not $CMPathItem.PSIsContainer) {
                $Msg = "'$CMPath' must be an existing FileSystem directory."
                throw [System.ArgumentException]::New($Msg)
            }
            $CMPath = $ResolvedCMPath.ProviderPath.TrimEnd("\")

            # Create the folder for importing the Redistributables into
            if ($AppFolder.Length -gt 0) {
                $DestCmFolder = "$($SMSSiteCode):\Application\$($AppFolder)"
                if ($PSCmdlet.ShouldProcess($DestCmFolder, "Creating")) {
                    Write-Verbose -Message "Creating: $DestCmFolder."
                    New-Item -Path $DestCmFolder -ErrorAction "SilentlyContinue" | Out-Null
                }
            }
            else {
                Write-Verbose -Message "Importing into: $($SMSSiteCode):\Application."
                $DestCmFolder = "$($SMSSiteCode):\Application"
            }
        }
        else {
            $Msg = "Unable to confirm '$CMPath' exists. Please check that '$CMPath' is valid."
            throw [System.IO.DirectoryNotFoundException]::New($Msg)
        }
        #endregion
    }

    process {

        # Make sure that $VcList has the required properties
        if ((Test-VcListObject -VcList $VcList) -ne $true) {
            $Msg = "Required properties not found. Please ensure the output from Save-VcRedist is sent to this function. "
            throw [System.Management.Automation.PropertyNotFoundException]::New($Msg)
        }

        $OriginalLocation = Get-Location
        try {
            foreach ($VcRedist in $VcList) {
                Write-Verbose -Message "Importing VcRedist app: 'Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)'"
                $SupportedArchitecture = @(Get-VcSupportedArchitecture -SupportedArchitecture $VcRedist.SupportedArchitecture)
                $app = $null

                # Import as an application into ConfigMgr
                if ($PSCmdlet.ShouldProcess("'$($VcRedist.Name)' in $CMPath", "Import ConfigMgr app")) {

                    # Create the ConfigMgr application with properties from the manifest
                    if ((Get-Item -Path $DestCmFolder).PSDrive.Name -eq $SMSSiteCode) {
                        if ($PSCmdlet.ShouldProcess($VcRedist.Name + " $($VcRedist.Architecture)", "Creating ConfigMgr application")) {
                            Set-Location -Path $DestCmFolder -ErrorAction "Stop"
                            $ArchitectureRequirement = New-VcConfigMgrArchitectureRequirement -SupportedArchitecture $SupportedArchitecture

                            # Build paths
                            $SourceFolder = $(Split-Path -Path $VcRedist.Path -Parent)
                            $ContentLocation = [System.IO.Path]::Combine($CMPath, $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)

                            #region Copy VcRedists to the network location. Use robocopy for robustness
                            $InstallerName = Split-Path -Path $VcRedist.Path -Leaf
                            $Target = Join-Path -Path $ContentLocation -ChildPath $InstallerName
                            $ContentReady = $false
                            if ($NoCopy.IsPresent) {
                                Write-Warning -Message "NoCopy specified, skipping copy to $ContentLocation. Ensure VcRedists exist in the target."
                                if (-not (Test-Path -LiteralPath $Target -PathType "Leaf")) {
                                    $Msg = "The installer '$Target' is missing. Remove -NoCopy or place the installer in the target location."
                                    throw [System.IO.FileNotFoundException]::New($Msg)
                                }
                                $ContentReady = $true
                            }
                            else {
                                if ($PSCmdlet.ShouldProcess("'$($VcRedist.Path)' to '$($ContentLocation)'", "Copy")) {
                                    if (-not (Test-Path -LiteralPath $VcRedist.Path -PathType "Leaf")) {
                                        $Msg = "The source installer '$($VcRedist.Path)' does not exist or is not a file."
                                        throw [System.IO.FileNotFoundException]::New($Msg)
                                    }
                                    if (-not (Test-Path -LiteralPath $ContentLocation -PathType "Container")) {
                                        New-Item -Path $ContentLocation -ItemType "Directory" -Force -ErrorAction "Stop" | Out-Null
                                    }
                                    if (-not (Test-Path -LiteralPath $ContentLocation -PathType "Container")) {
                                        $Msg = "Unable to create the content directory '$ContentLocation'."
                                        throw [System.IO.DirectoryNotFoundException]::New($Msg)
                                    }

                                    try {
                                        $invokeProcessParams = @{
                                            FilePath         = "$env:SystemRoot\System32\robocopy.exe"
                                            ArgumentList     = "`"$SourceFolder`" `"$ContentLocation`" `"$InstallerName`" /S /XJ /R:1 /W:1 /NP /NJH /NJS /NFL /NDL"
                                            SuccessExitCodes = 0..7
                                        }
                                        Invoke-Process @invokeProcessParams | Out-Null
                                    }
                                    catch [System.Exception] {
                                        $Msg = "Failed to copy Redistributable '$($VcRedist.Path)' to '$ContentLocation': $($_.Exception.Message)"
                                        throw [System.IO.IOException]::New($Msg, $_.Exception)
                                    }
                                    if (-not (Test-Path -LiteralPath $Target -PathType "Leaf")) {
                                        $Msg = "Robocopy completed without creating the expected installer '$Target'."
                                        throw [System.IO.IOException]::New($Msg)
                                    }
                                    $ContentReady = $true
                                }
                            }
                            #endregion

                            if (-not $ContentReady -and -not $WhatIfPreference) {
                                continue
                            }

                            try {
                                # Change to the SMS Application folder before importing the applications
                                Write-Verbose -Message "Setting location to: $DestCmFolder"
                                Set-Location -Path $DestCmFolder -ErrorAction "Stop"

                                # Splat New-CMApplication parameters, add the application and move into the target folder
                                $ApplicationName = "Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)"
                                $cmAppParams = @{
                                    Name              = $ApplicationName
                                    Description       = "$Publisher $ApplicationName imported by $($MyInvocation.MyCommand). https://vcredist.com"
                                    SoftwareVersion   = $VcRedist.Version
                                    LinkText          = $VcRedist.URL
                                    Publisher         = $Publisher
                                    Keyword           = $Keyword
                                    ReleaseDate       = [System.DateTime]::Today
                                    PrivacyUrl        = "https://go.microsoft.com/fwlink/?LinkId=521839"
                                    UserDocumentation = "https://visualstudio.microsoft.com/vs/support/"
                                }
                                $app = New-CMApplication @cmAppParams
                                if ($AppFolder) {
                                    $app | Move-CMObject -FolderPath $DestCmFolder -ErrorAction "SilentlyContinue" | Out-Null
                                }
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "Failed to create application $($VcRedist.Name) $($VcRedist.Architecture)."
                                Write-Warning -Message $_.Exception.Message
                            }
                        }

                        # Add a deployment type to the application
                        if ((($null -ne $app) -or $WhatIfPreference) -and $PSCmdlet.ShouldProcess($("$($VcRedist.Name) $($VcRedist.Architecture) $($VcRedist.Version)"), "Adding deployment type")) {

                            try {
                                # Change to the SMS Application folder before importing the applications
                                Write-Verbose -Message "Set location to: $DestCmFolder"
                                Set-Location -Path $DestCmFolder -ErrorAction "Stop"

                                # Create the detection method
                                $params = @{
                                    Hive    = "LocalMachine"
                                    Is64Bit = if ($VcRedist.UninstallKey -eq "64") { $true } else { $false }
                                    KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$($VcRedist.ProductCode)"
                                }
                                $detectionClause = New-CMDetectionClauseRegistryKey @params

                                # Splat Add-CMScriptDeploymentType parameters and add the application deployment type
                                $cmScriptParams = @{
                                    ApplicationName          = $ApplicationName
                                    InstallCommand           = "$(Split-Path -Path $VcRedist.Path -Leaf) $(if ($Silent) { $VcRedist.SilentInstall } else { $VcRedist.Install })"
                                    ContentLocation          = $ContentLocation
                                    AddDetectionClause       = $detectionClause
                                    AddRequirement           = $ArchitectureRequirement
                                    DeploymentTypeName       = "SCRIPT_$($VcRedist.Name)"
                                    UserInteractionMode      = "Hidden"
                                    UninstallCommand         = $VcRedist.SilentUninstall
                                    LogonRequirementType     = "WhetherOrNotUserLoggedOn"
                                    InstallationBehaviorType = "InstallForSystem"
                                    Comment                  = "Generated by $($MyInvocation.MyCommand). https://vcredist.com"
                                }
                                Add-CMScriptDeploymentType @cmScriptParams -ErrorAction "Stop" | Out-Null
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "Failed to add script deployment type."
                                Write-Warning -Message $_.Exception.Message
                                throw
                            }
                        }
                        if ($null -ne $app) { Write-Output -InputObject $app }
                    }
                }
            }
        }
        finally {
            Set-Location -Path $OriginalLocation
        }
    }

    end { }
}
