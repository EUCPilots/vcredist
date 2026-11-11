function Uninstall-VcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(DefaultParameterSetName = "Manual", SupportsShouldProcess = $true, ConfirmImpact = "High", HelpURI = "https://vcredist.com/uninstall-vcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    param (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Manual")]
        [ValidateSet("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019", "14")]
        [System.String[]] $Release = @("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019", "14"),

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "Manual")]
        [ValidateSet("x86", "x64", "ARM64")]
        [System.String[]] $Architecture = @("x86", "x64"),

        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = "Pipeline",
            HelpMessage = "Pass a VcList object from Get-VcList.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList
    )

    begin {
        # Get script elevation status
        [System.Boolean] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        if ($Elevated -eq $false) {
            $Msg = "Uninstalling the Visual C++ Redistributables requires elevation. The current Windows PowerShell session is not running as Administrator. Start Windows PowerShell by using the Run as Administrator option, and then try running the script again"
            throw [System.Management.Automation.ScriptRequiresException]::New($Msg)
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Manual" {
                # Get the installed VcRedists and filter
                Write-Verbose -Message "Getting locally installed Visual C++ Redistributables"
                $VcRedistsToRemove = Get-InstalledVcRedist | Where-Object { $Release -contains $_.Release } | Where-Object { $Architecture -contains $_.Architecture }
            }
            "Pipeline" {
                Write-Verbose -Message "Removing installed Visual C++ Redistributables passed via the pipeline"
                $VcRedistsToRemove = $VcList
            }
        }

        # Walk through each VcRedist and uninstall
        foreach ($VcRedist in $VcRedistsToRemove) {
            $UninstallString = $null
            $Result = $null
            $State = $null
            $params = $null

            # We could be passed an object from Get-VcList or Get InstalledVcRedist
            if ([System.String]::IsNullOrEmpty($VcRedist.UninstallString) -eq $false) {
                $UninstallString = $VcRedist.UninstallString
            }
            elseif ([System.String]::IsNullOrEmpty($VcRedist.SilentUninstall) -eq $false) {
                $UninstallString = $VcRedist.SilentUninstall
            }

            if ([System.String]::IsNullOrEmpty($UninstallString)) {
                $Msg = "Cannot find uninstall string. Please check object passed to this function."
                throw [System.Management.Automation.PropertyNotFoundException]::New($Msg)
            }

            # Build the uninstall command
            if ($UninstallString -match "^\s*`"?msiexec(\.exe)?`"?\s") {
                if ($VcRedist.ProductCode -notmatch "^\{[0-9A-Fa-f]{8}(-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}\}$") {
                    Write-Warning -Message "Invalid product code for '$($VcRedist.Name)': '$($VcRedist.ProductCode)'."
                    continue
                }
                Write-Verbose -Message "VcRedist uninstall uses Msiexec."
                $params = @{
                    FilePath     = "$Env:SystemRoot\System32\msiexec.exe"
                    ArgumentList = "/uninstall $($VcRedist.ProductCode) /quiet /norestart"
                }
            }
            else {
                # Split the command into the executable (quoted or not), expanding environment variables
                $FilePath = $null
                if ($UninstallString -match "^\s*`"([^`"]+)`"") { $FilePath = $Matches[1] }
                elseif ($UninstallString -match "^\s*(\S+)") { $FilePath = $Matches[1] }
                $FilePath = [System.Environment]::ExpandEnvironmentVariables([System.String]$FilePath)

                if (-not (Test-Path -LiteralPath $FilePath -PathType "Leaf")) {
                    Write-Warning -Message "Cannot find uninstaller '$FilePath' for $($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)."
                    $State = "Failed"
                }
                else {
                    Write-Verbose -Message "VcRedist uninstall uses '$FilePath'."
                    $params = @{
                        FilePath     = $FilePath
                        ArgumentList = "/uninstall /quiet /norestart"
                    }
                }
            }

            if ($null -ne $params -and $PSCmdlet.ShouldProcess($VcRedist.Name, "Uninstall")) {
                try {
                    $params.PassThru = $true
                    $params.Wait = $true
                    $params.NoNewWindow = $true
                    $params.ErrorAction = "Stop"
                    $Result = Start-Process @params

                    # 3010: reboot required; 1641: reboot initiated; 1605: product not installed
                    if (@(0, 1605, 1641, 3010) -contains $Result.ExitCode) {
                        $State = "Uninstalled"
                    }
                    else {
                        Write-Warning -Message "Uninstall of $($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture) returned exit code $($Result.ExitCode)."
                        $State = "Failed"
                    }
                }
                catch [System.Exception] {
                    Write-Warning -Message "Failure in uninstalling $($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture): $($_.Exception.Message)"
                    $State = "Failed"
                }
            }

            if ($null -ne $State) {
                [PSCustomObject] @{
                    Name         = $VcRedist.Name
                    Version      = $VcRedist.Version
                    Release      = $VcRedist.Release
                    Architecture = $VcRedist.Architecture
                    State        = $State
                    ExitCode     = $Result.ExitCode
                }
            }
        }
    }

    end {
    }
}
