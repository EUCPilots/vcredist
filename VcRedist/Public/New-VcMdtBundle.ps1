function New-VcMdtBundle {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/import-vcmdtapplication/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType "Container") { $true } else { throw "Cannot find path $_" } })]
        [System.String] $MdtPath,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [ValidateNotNullOrEmpty()]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Force,

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [System.String] $MdtDrive = "DS099",

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $false, Position = 4)]
        [ValidatePattern("^[a-zA-Z0-9\+ ]+$")]
        [System.String] $BundleName = "Visual C++ Redistributables",

        [Parameter(Mandatory = $false, Position = 5)]
        [ValidatePattern("^[a-zA-Z0-9-]+$")]
        [System.String] $Language = "en-US"
    )

    begin {
        Write-Warning -Message "MDT is no longer supported by Microsoft. This function is deprecated and may be removed in a future release of VcRedist."

        # If running on PowerShell Core, error and exit.
        if (Test-PSCore) {
            $Msg = "We can't load the MicrosoftDeploymentToolkit module on PowerShell Core. Please use PowerShell 5.1."
            throw [System.TypeLoadException]::New($Msg)
        }

        # Import the MDT module and create a PS drive to MdtPath
        if (Import-MdtModule) {
            if ($PSCmdlet.ShouldProcess($MdtPath, "Mapping")) {
                try {
                    $params = @{
                        Drive       = $MdtDrive
                        Path        = $MdtPath
                        ErrorAction = "Continue"
                    }
                    New-MdtDrive @params > $null
                    Restore-MDTPersistentDrive -Force > $null
                }
                catch [System.Exception] {
                    Write-Warning -Message "Failed to map drive to: $MdtPath, with: $($_.Exception.Message)"
                    throw $_
                }
            }
        }
        else {
            $Msg = "Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again."
            throw [System.Management.Automation.InvalidPowerShellStateException]::New($Msg)
        }
    }

    process {
        Write-Verbose -Message "Getting existing Visual C++ Redistributables the deployment share"
        $TargetMdtFolder = "$($MdtDrive):\Applications\$AppFolder"
        $BundlePath = "$TargetMdtFolder\$Publisher $BundleName"
        $existingVcRedists = @(Get-ChildItem -Path $TargetMdtFolder -ErrorAction "SilentlyContinue" |
            Where-Object { $_.Name -like "*Visual C++*" -and $_.Name -ne "$Publisher $BundleName" })
        if ($existingVcRedists.Count -eq 0) {
            Write-Warning -Message "Failed to find existing VcRedist applications in the MDT share. Please import the VcRedists with Import-VcMdtApplication."
        }

        if ($existingVcRedists.Count -gt 0 -and (Test-Path -Path $TargetMdtFolder)) {
            $BundleExists = Test-Path -Path $BundlePath
            if ($BundleExists -and -not $Force.IsPresent) {
                Write-Verbose "'$($Publisher) $($BundleName)' exists. Use -Force to overwrite the existing bundle."
            }
            elseif ($PSCmdlet.ShouldProcess($BundlePath, $(if ($BundleExists) { "Replace bundle" } else { "Create bundle" }))) {
                Write-Verbose -Message "Gathering VcRedist applications in: $TargetMdtFolder"
                $VersionedVcRedists = foreach ($App in $existingVcRedists) {
                    $ParsedVersion = $null
                    if (-not [System.Version]::TryParse([System.String]$App.Version, [ref]$ParsedVersion)) {
                        throw [System.FormatException]::New("Invalid version '$($App.Version)' on MDT application '$($App.Name)'.")
                    }
                    if ([System.String]::IsNullOrWhiteSpace([System.String]$App.guid)) {
                        throw [System.Management.Automation.ValidationMetadataException]::New("Missing application GUID on MDT application '$($App.Name)'.")
                    }
                    [PSCustomObject]@{
                        Version = $ParsedVersion
                        Guid    = $App.guid
                    }
                }
                $dependencies = @($VersionedVcRedists | Sort-Object -Property Version | ForEach-Object { $_.Guid })
                $importMDTAppParams = @{
                    Path       = $TargetMdtFolder
                    Name       = "$($Publisher) $($BundleName)"
                    Enable     = $true
                    Reboot     = $false
                    Hide       = $false
                    Comments   = "Application bundle for installing Visual C++ Redistributables. Generated by $($MyInvocation.MyCommand)"
                    ShortName  = $BundleName
                    Version    = $(Get-Date -Format (([System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat).ShortDatePattern))
                    Publisher  = $Publisher
                    Language   = $Language
                    Dependency = $dependencies
                    Bundle     = $true
                    ErrorAction = "Stop"
                }

                $BackupName = $null
                $BackupPath = $null
                $BackupCreated = $false
                try {
                    if ($BundleExists) {
                        $BackupName = "VcRedistBundleBackup_$([System.Guid]::NewGuid().ToString('N'))"
                        $BackupPath = "$TargetMdtFolder\$BackupName"
                        Rename-Item -Path $BundlePath -NewName $BackupName -ErrorAction "Stop"
                        $BackupCreated = $true
                    }
                    Import-MDTApplication @importMDTAppParams > $null
                }
                catch {
                    $ImportError = $_
                    if ($BackupCreated) {
                        try {
                            if (Test-Path -Path $BundlePath) {
                                Remove-Item -Path $BundlePath -Force -Recurse -ErrorAction "Stop"
                            }
                            Rename-Item -Path $BackupPath -NewName "$Publisher $BundleName" -ErrorAction "Stop"
                        }
                        catch {
                            throw [System.InvalidOperationException]::New(
                                "Failed to create the replacement bundle and restore the original bundle from '$BackupPath'. Import error: $($ImportError.Exception.Message) Rollback error: $($_.Exception.Message)",
                                $ImportError.Exception
                            )
                        }
                    }
                    Write-Warning -Message "Error encountered importing the VcRedist bundle."
                    throw $ImportError
                }

                if ($BackupCreated) {
                    try {
                        Remove-Item -Path $BackupPath -Force -Recurse -ErrorAction "Stop"
                    }
                    catch {
                        Write-Warning -Message "The replacement bundle was created, but the previous bundle backup could not be removed from '$BackupPath': $($_.Exception.Message)"
                    }
                }
            }
        }
        else {
            Write-Error -Message "Failed to find path $TargetMdtFolder."
        }

        if (Test-Path -Path $BundlePath) {
            # Return list of apps to the pipeline
            Write-Output -InputObject (Get-ChildItem -Path $BundlePath | Select-Object -Property *)
        }
    }
}
