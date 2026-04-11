function Get-VcList {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Get-VcRedist")]
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(HelpURI = "https://vcredist.com/get-vclist/")]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateSet("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019", "14")]
        [System.String[]] $Release = @("14"),

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet("x86", "x64", "ARM64")]
        [System.String[]] $Architecture,

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Source,

        [Parameter(Mandatory = $false, Position = 3)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false, Position = 4)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Alias("Xml")]
        [System.String] $Path,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $NoCache,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Unsupported
    )

    begin {
        [System.String] $RemoteManifestUrl = "https://vcredist.com/manifest.json"
        [System.String] $BundledManifestPath = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VisualCRedistributables.json"

        # Map deprecated -Path to -Source
        if ($PSBoundParameters.ContainsKey("Path") -and -not $PSBoundParameters.ContainsKey("Source")) {
            $Source = $Path
        }

        # Determine the effective source: explicit > remote > fallback
        if (-not [System.String]::IsNullOrEmpty($Source)) {
            [System.String] $ResolvedSource = $Source
        }
        else {
            [System.String] $ResolvedSource = $RemoteManifestUrl
        }
    }

    process {
        # Attempt to use the session cache
        if (-not $NoCache -and $null -ne $script:VcManifestCache -and $script:VcManifestCacheSource -eq $ResolvedSource) {
            Write-Verbose -Message "Using cached manifest from '$ResolvedSource'."
            $JsonManifest = $script:VcManifestCache
        }
        else {
            try {
                if ($ResolvedSource -match "^https?://") {
                    Write-Verbose -Message "Fetching remote manifest from '$ResolvedSource'."
                    $iwrParams = @{
                        Uri              = $ResolvedSource
                        UseBasicParsing  = $true
                        TimeoutSec       = 10
                        ErrorAction      = "Stop"
                    }
                    $iwrParams += Get-ProxyParam -Uri $ResolvedSource -Proxy $Proxy -ProxyCredential $ProxyCredential -BoundParameters $PSBoundParameters
                    $Content = (Invoke-WebRequest @iwrParams).Content
                }
                else {
                    Write-Verbose -Message "Reading manifest from '$ResolvedSource'."
                    $Content = Get-Content -Path $ResolvedSource -Raw -ErrorAction "Stop"
                }

                Write-Verbose -Message "Converting JSON."
                $JsonManifest = $Content | ConvertFrom-Json -ErrorAction "Stop"
                $script:VcManifestCache = $JsonManifest
                $script:VcManifestCacheSource = $ResolvedSource
            }
            catch {
                if ($ResolvedSource -eq $RemoteManifestUrl) {
                    Write-Warning -Message "Remote manifest unavailable ('$ResolvedSource'). Falling back to bundled manifest. Error: $($_.Exception.Message)"
                    try {
                        $Content = Get-Content -Path $BundledManifestPath -Raw -ErrorAction "Stop"
                        $JsonManifest = $Content | ConvertFrom-Json -ErrorAction "Stop"
                    }
                    catch {
                        Write-Warning -Message "Unable to read bundled manifest. Please validate the module installation."
                        throw $_
                    }
                }
                else {
                    Write-Warning -Message "Unable to read manifest from '$ResolvedSource'."
                    throw $_
                }
            }
        }

        if ($null -ne $JsonManifest) {
            # Filter by supported/unsupported status
            if ($Unsupported) {
                Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                [System.Management.Automation.PSObject] $Output = $JsonManifest | Where-Object { $_.Supported -eq $false }
            }
            else {
                [System.Management.Automation.PSObject] $Output = $JsonManifest | Where-Object { $_.Supported -eq $true }
            }

            # Apply Release filter when explicitly specified, or by default for supported output.
            if ($PSBoundParameters.ContainsKey("Release") -or -not $Unsupported) {
                $Output = $Output | Where-Object { $Release -contains $_.Release }
            }

            # Apply Architecture filter if specified
            if ($PSBoundParameters.ContainsKey("Architecture")) {
                $Output = $Output | Where-Object { $Architecture -contains $_.Architecture }
            }

            # Replace strings in the manifest
            $Count = @($Output).Count - 1
            Write-Verbose -Message "Object count is: $($Count + 1)."
            for ($i = 0; $i -le $Count; $i++) {
                try {
                    $Output[$i].SilentUninstall = $Output[$i].SilentUninstall `
                        -replace "#Installer", $(Split-Path -Path $Output[$i].URI -Leaf) `
                        -replace "#ProductCode", $Output[$i].ProductCode
                }
                catch {
                    Write-Verbose -Message "Failed to replace strings in: $($JsonManifest[$i].Name)."
                }
            }
            Write-Output -InputObject $Output
        }
    }
}
