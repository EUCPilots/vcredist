function Import-VcMdtApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Import-VcMdtApp")]
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/import-vcmdtapplication/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Pass a VcList object from Save-VcRedist.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $false)]
        [System.ObsoleteAttribute("This parameter is not longer supported. The Path property must be on the object passed to -VcList.")]
        [System.String] $Path,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType "Container") { $true } else { throw "Cannot find path $_" } })]
        [ValidateNotNullOrEmpty()]
        [System.String] $MdtPath,

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [ValidateNotNullOrEmpty()]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $DontHide,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Force,

        [Parameter(Mandatory = $false, Position = 4)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [System.String] $MdtDrive = "DS099",

        [Parameter(Mandatory = $false, Position = 5)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $false, Position = 6)]
        [ValidatePattern("^[a-zA-Z0-9-]+$")]
        [System.String] $Language = "en-US"
    )

    begin {
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
                    $Msg = "Failed to map drive to: $MdtPath. Error: $($_.Exception.Message)"
                    throw $Msg
                }
            }
        }
        else {
            $Msg = "Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again."
            throw [System.Management.Automation.InvalidPowerShellStateException]::New($Msg)
        }

        # Create the Application folder
        if ($AppFolder.Length -gt 0) {
            if ($PSCmdlet.ShouldProcess($AppFolder, "Create")) {
                try {
                    $params = @{
                        Drive       = $(Edit-MdtDrive -Drive $MdtDrive)
                        Name        = $AppFolder
                    }
                    New-MdtApplicationFolder @params > $null
                }
                catch [System.Exception] {
                    Write-Warning -Message "Failed to create folder: $AppFolder, with: $($_.Exception.Message)"
                    throw $_
                }
            }
            $MdtTargetFolder = "$(Edit-MdtDrive -Drive $MdtDrive)\Applications\$AppFolder"
        }
        else {
            $MdtTargetFolder = "$(Edit-MdtDrive -Drive $MdtDrive)\Applications"
        }
        Write-Verbose -Message "VcRedists will be imported into: $MdtTargetFolder"
        Write-Verbose -Message "Retrieving existing Visual C++ Redistributables from the deployment share"
        $existingVcRedists = Get-ChildItem -Path $MdtTargetFolder -ErrorAction "SilentlyContinue" | Where-Object { $_.Name -like "*Visual C++*" }
    }

    process {

        # Make sure that $VcList has the required properties
        if ((Test-VcListObject -VcList $VcList) -ne $true) {
            $Msg = "Required properties not found. Please ensure the output from Save-VcRedist is sent to this function. "
            throw [System.Management.Automation.PropertyNotFoundException]::New($Msg)
        }

        foreach ($VcRedist in $VcList) {

            # Set variables
            Write-Verbose -Message "processing: '$($VcRedist.Name) $($VcRedist.Architecture)'."
            $supportedPlatform = if ($VcRedist.Architecture -eq "x86") {
                $null
            }
            else {
                @("All x64 Windows 10 Client", "All x64 Windows Server 10")
            }

            # Check for existing application by matching current VcRedist
            $ApplicationName = "Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)"
            $VcMatched = $existingVcRedists | Where-Object { $_.Name -eq $ApplicationName }

            # Remove the matched VcRedist application
            if ($PSBoundParameters.ContainsKey("Force")) {
                if ($VcMatched.UninstallKey -eq $VcRedist.ProductCode) {
                    if ($PSCmdlet.ShouldProcess($VcMatched.Name, "Remove")) {
                        Remove-Item -Path $("$MdtTargetFolder\$($VcMatched.Name)") -Force
                    }
                }
            }

            # Import as an application into the MDT deployment share
            if (Test-Path -Path "$MdtTargetFolder\$($VcMatched.Name)") {
                Write-Verbose -Message "'$("$MdtTargetFolder\$($VcMatched.Name)")' exists. Use -Force to overwrite the existing application."
            }
            else {
                if ($PSCmdlet.ShouldProcess("$($VcRedist.Name) in $MdtPath", "Import")) {
                    try {

                        # Splat the Import-MDTApplication arguments
                        $importMDTAppParams = @{
                            Path                  = $MdtTargetFolder
                            Name                  = $ApplicationName
                            Enable                = $true
                            Reboot                = $false
                            Hide                  = $(if ($DontHide.IsPresent) { "False" } else { "True" })
                            Comments              = "Generated by $($MyInvocation.MyCommand), https://vcredist.com/"
                            ShortName             = "$($VcRedist.Name) $($VcRedist.Architecture)"
                            Version               = $VcRedist.Version
                            Publisher             = $Publisher
                            Language              = $Language
                            CommandLine           = ".\$(Split-Path -Path $VcRedist.URI -Leaf) $(if ($Silent.IsPresent) { $VcRedist.SilentInstall } else { $VcRedist.Install })"
                            ApplicationSourcePath = $(Split-Path -Path $VcRedist.Path -Parent)
                            DestinationFolder     = "$Publisher VcRedist\$($VcRedist.Release)\$($VcRedist.Version)\$($VcRedist.Architecture)"
                            WorkingDirectory      = ".\Applications\$Publisher VcRedist\$($VcRedist.Release)\$($VcRedist.Version)\$($VcRedist.Architecture)"
                            UninstallKey          = $VcRedist.ProductCode
                            SupportedPlatform     = $supportedPlatform
                        }
                        Import-MDTApplication @importMDTAppParams > $null
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "Error encountered importing the application: '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)'."
                        throw $_
                    }
                }
            }
        }
    }

    end {
        # Get the imported Visual C++ Redistributables applications to return on the pipeline
        Write-Verbose -Message "Retrieving Visual C++ Redistributables imported into the deployment share"
        Write-Output -InputObject (Get-ChildItem -Path $MdtTargetFolder | Where-Object { $_.Name -like "*Visual C++*" } | Select-Object -Property *)
    }
}
