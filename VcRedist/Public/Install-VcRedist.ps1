function Install-VcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/install-vcredist/")]
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

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    begin {
        # Get script elevation status
        [System.Boolean] $Elevated = Test-Elevated
        if ($Elevated -eq $false) {
            $Msg = "Installing the Visual C++ Redistributables requires elevation. The current Windows PowerShell session is not running as Administrator. Start Windows PowerShell by using the Run as Administrator option, and then try running the script again"
            throw [System.Management.Automation.ScriptRequiresException]::New($Msg)
        }

        # Get currently installed VcRedist versions
        $currentInstalled = Get-InstalledVcRedist
        $OperatingSystemArchitecture = Get-VcOperatingSystemArchitecture
    }

    process {

        # Make sure that $VcList has the required properties
        if ((Test-VcListObject -VcList $VcList) -ne $true) {
            $Msg = "Required properties not found. Please ensure the output from Save-VcRedist is sent to this function. "
            throw [System.Management.Automation.PropertyNotFoundException]::New($Msg)
        }

        # Sort $VcList by version number from oldest to newest
        foreach ($VcRedist in ($VcList | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $false })) {

            $SupportedArchitecture = @(Get-VcSupportedArchitecture -SupportedArchitecture $VcRedist.SupportedArchitecture)

            # If already installed or the -Force parameter is not specified, skip
            if (($currentInstalled | Where-Object { $VcRedist.ProductCode -contains $_.ProductCode }) -and !($PSBoundParameters.ContainsKey("Force"))) {
                Write-Information -MessageData "VcRedist already installed: '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)'" -InformationAction "Continue"
            }
            else {

                if ($SupportedArchitecture -notcontains $OperatingSystemArchitecture) {
                    Write-Warning -Message "Incompatible architecture: '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)' is not supported on '$OperatingSystemArchitecture'."
                }
                else {

                    if (Test-Path -LiteralPath $VcRedist.Path -PathType "Leaf") {
                        Write-Verbose -Message "Install VcRedist: '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)'"
                        if ($PSCmdlet.ShouldProcess("$($VcRedist.Path) $($VcRedist.Install)", "Install")) {

                            # Only run installers with a valid Microsoft signature
                            Assert-VcSignature -Path $VcRedist.Path | Out-Null

                            # Create parameters with -ArgumentList set based on Install/SilentInstall properties in the manifest
                            $params = @{
                                FilePath     = $VcRedist.Path
                                ArgumentList = if ($Silent) { $VcRedist.SilentInstall } else { $VcRedist.Install }
                                PassThru     = $true
                                Wait         = $true
                                NoNewWindow  = $true
                                ErrorAction  = "Stop"
                            }
                            $Result = Start-Process @params

                            # 3010: reboot required; 1641: reboot initiated; 1638: another version already installed
                            if (@(0, 1638, 1641, 3010) -contains $Result.ExitCode) {
                                Write-Verbose -Message "Installed: '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)'; ExitCode: $($Result.ExitCode)"
                                if (@(1641, 3010) -contains $Result.ExitCode) {
                                    Write-Warning -Message "A restart is required to complete installation of '$($VcRedist.Name) $($VcRedist.Architecture)'."
                                }
                            }
                            else {
                                Write-Error -Message "Installation of '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)' failed with exit code $($Result.ExitCode)."
                            }
                        }
                    }
                    else {
                        Write-Warning -Message "Cannot find: '$($VcRedist.Path)'. Download with Save-VcRedist."
                    }
                }
            }
        }
    }

    end {
        # Get the installed Visual C++ Redistributables applications to return on the pipeline
        Write-Output -InputObject (Get-InstalledVcRedist)
    }
}
