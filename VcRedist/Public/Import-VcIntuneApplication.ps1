function Import-VcIntuneApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpURI = "https://vcredist.com/import-vcintuneapplication/")]
    [OutputType([System.String])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Pass a VcList object from Save-VcRedist.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList
    )

    begin {
        # IntuneWin32App currently supports Windows PowerShell only
        if (Test-PSCore) {
            $Msg = "The IntuneWin32App module requires Windows PowerShell 5.1 and cannot be loaded on PowerShell Core. Run this function in a Windows PowerShell 5.1 session. See https://github.com/MSEndpointMgr/IntuneWin32App for details."
            throw [System.TypeLoadException]::New($Msg)
        }

        # Test for required variables
        $Modules = "IntuneWin32App"
        foreach ($Module in $Modules) {
            if (Get-Module -Name $Module -ListAvailable -ErrorAction "SilentlyContinue") {
                Write-Verbose -Message "Support module installed: $Module."
            }
            else {
                $Msg = "Required module missing: '$Module'. Install it with: Install-Module -Name $Module. Note: $Module requires Windows PowerShell 5.1. See https://github.com/MSEndpointMgr/IntuneWin32App for details."
                throw [System.TypeLoadException]::New($Msg)
            }
        }

        # Test for authentication token
        if ($null -eq $Global:AccessToken) {
            $Msg = "Microsoft Graph API access token missing. Authenticate to the Graph API with Connect-MSIntuneGraph."
            throw [System.UnauthorizedAccessException]::New($Msg)
        }

        # Get the Intune app manifest
        $IntuneManifest = Get-Content -Path $(Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "Intune.json") | ConvertFrom-Json -ErrorAction "Stop"
        Write-Verbose -Message "Loaded Intune app manifest."

        # Create the icon object for the app
        $IconPath = [System.IO.Path]::Combine($MyInvocation.MyCommand.Module.ModuleBase, "img", "vcredist.png")
        if (Test-Path -Path $IconPath) {
            Write-Verbose -Message "Using icon image from path: $IconPath."
            $Icon = New-IntuneWin32AppIcon -FilePath $IconPath
        }
        else {
            Write-Error -Message "Unable to find icon image in path: $IconPath."
        }
    }

    process {
        # Make sure that $VcList has the required properties
        Test-VcListObject -VcList $VcList | Out-Null

        foreach ($VcRedist in $VcList) {

            # Check if the package already exists in Intune
            $AppDetails = Get-RequiredVcRedistUpdatesFromIntune -VcList $VcRedist
            if ($null -eq $AppDetails -or $AppDetails.UpdateRequired -eq $true) {

                # Package MSI as .intunewin file
                $OutputFolder = New-TemporaryFolder
                $params = @{
                    SourceFolder = $(Split-Path -Path $VcRedist.Path -Parent)
                    SetupFile    = $(Split-Path -Path $VcRedist.Path -Leaf)
                    OutputFolder = $OutputFolder
                }
                $Package = New-IntuneWin32AppPackage @params
                Write-Verbose -Message "Created IntuneWin package: $($Package.Path)."

                # Requirement rule
                # Assuming here that no one is managing an x86 machine with Intune in 2026
                switch ($VcRedist.Architecture) {
                    "x86" { $Architecture = "AllWithARM64" }
                    "x64" { $Architecture = "AllWithARM64" }
                    "ARM64" { $Architecture = "arm64" }
                    default {
                        $Architecture = "x64x86"
                        continue
                    }
                }
                $params = @{
                    Architecture                   = $Architecture
                    MinimumSupportedWindowsRelease = $IntuneManifest.RequirementRule.MinimumRequiredOperatingSystem
                    MinimumFreeDiskSpaceInMB       = $IntuneManifest.RequirementRule.SizeInMBValue
                }
                $RequirementRule = New-IntuneWin32AppRequirementRule @params

                # Create the detection rules for the Win32 app
                $DetectionRules = New-IntuneWin32AppDetectionRule -VcList $VcRedist -IntuneManifest $IntuneManifest

                # Construct a table of default parameters for Win32 app
                $DisplayName = "$($IntuneManifest.Information.Publisher) $($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)"
                Write-Verbose -Message "Creating Win32 app for $DisplayName."

                # Create a Notes property with identifying information
                $Notes = [PSCustomObject] @{
                    "CreatedBy" = "VcRedist"
                    "Guid"      = $VcRedist.PackageId
                    "Date"      = $(Get-Date -Format "yyyy-MM-dd")
                } | ConvertTo-Json -Compress

                $Win32AppArgs = @{
                    "FilePath"                 = $Package.Path
                    "DisplayName"              = $DisplayName
                    "Description"              = "$($IntuneManifest.Information.Description). $DisplayName"
                    "AppVersion"               = $VcRedist.Version
                    "Notes"                    = $Notes
                    "Publisher"                = $IntuneManifest.Information.Publisher
                    "InformationURL"           = $IntuneManifest.Information.InformationURL
                    "PrivacyURL"               = $IntuneManifest.Information.PrivacyURL
                    "CompanyPortalFeaturedApp" = $false
                    "InstallExperience"        = $IntuneManifest.Program.InstallExperience
                    "RestartBehavior"          = $IntuneManifest.Program.DeviceRestartBehavior
                    "DetectionRule"            = $DetectionRules
                    "RequirementRule"          = $RequirementRule
                    "InstallCommandLine"       = "$(Split-Path -Path $VcRedist.URI -Leaf) $($VcRedist.SilentInstall)"
                    "UninstallCommandLine"     = $VcRedist.SilentUninstall
                }
                if ($null -ne $Icon) {
                    $Win32AppArgs.Add("Icon", $Icon)
                }
                $Application = Add-IntuneWin32App @Win32AppArgs
                if ($null -ne $Application) {
                    # Exclude the largeIcon property from the output
                    $Application | Select-Object -Property * -ExcludeProperty "largeIcon" | Write-Output
                }

                # Clean up the temporary intunewin package
                Write-Verbose -Message "Removing temporary output folder: $OutputFolder."
                Remove-Item -Path $OutputFolder -Recurse -Force -ErrorAction "SilentlyContinue"
            }
            else {
                Write-Verbose -Message "No update required for $($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)."
            }
        }
    }
}
