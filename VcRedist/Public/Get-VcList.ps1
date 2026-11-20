function Get-VcList {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Get-VcRedist")]
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(DefaultParameterSetName = "Manifest", HelpURI = "https://vcredist.com/get-vclist/")]
    param (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Manifest")]
        [ValidatePattern("^[0-9]{2,4}$")]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Release = @("14"),

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "Manifest")]
        [ValidateSet("x86", "x64", "arm64")]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Architecture = @("x86", "x64", "arm64"),

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Export")]
        [ValidateSet("Supported", "All", "Unsupported")]
        [System.String] $Export = "Supported",

        [Parameter(Mandatory = $false)]
        [ValidateSet("Auto", "Remote", "Bundled")]
        [System.String] $Source = "Auto",

        [Parameter(Mandatory = $false)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty
    )

    process {
        # Messages
        $WarningMessage = "This list includes unsupported Visual C++ Redistributables."

        $params = @{ Source = $Source }
        if ($PSBoundParameters.ContainsKey("Proxy")) { $params.Proxy = $Proxy }
        if ($PSBoundParameters.ContainsKey("ProxyCredential")) { $params.ProxyCredential = $ProxyCredential }
        $Manifest = Get-VcManifest @params
        $Entries = @($Manifest.Entries)

        if ($PSCmdlet.ParameterSetName -eq "Export") {
            Write-Verbose -Message "Selecting Visual C++ Redistributables with export mode '$Export'."
            switch ($Export) {
                "All" {
                    Write-Warning -Message $WarningMessage
                    $Output = $Entries
                }
                "Supported" { $Output = $Entries | Where-Object { $_.Supported -eq $true } }
                "Unsupported" {
                    Write-Warning -Message $WarningMessage
                    $Output = $Entries | Where-Object { $_.Supported -eq $false }
                }
            }
        }
        else {
            Write-Verbose -Message "Filtering Visual C++ Redistributables by release '$($Release -join ", ")' and architecture '$($Architecture -join ", ")'."
            $Output = $Entries | `
                Where-Object { $Release -contains $_.Release } | `
                Where-Object { $Architecture -contains $_.Architecture }
            if ($Output | Where-Object { $_.Supported -eq $false }) {
                Write-Warning -Message $WarningMessage
            }
        }

        Write-Verbose -Message "Selected $(@($Output).Count) Visual C++ Redistributables."

        # Replace the placeholder tokens in the uninstall command
        foreach ($Item in @($Output)) {
            Write-Verbose -Message "Preparing: '$($Item.Name) $($Item.Version) $($Item.Architecture)' (release $($Item.Release))."
            $ParsedUri = $null
            if (-not [System.Uri]::TryCreate([System.String]$Item.URI, [System.UriKind]::Absolute, [ref] $ParsedUri)) {
                throw [System.InvalidOperationException]::New("Manifest entry '$($Item.Name)' has an invalid URI: '$($Item.URI)'.")
            }
            $InstallerName = [System.IO.Path]::GetFileName($ParsedUri.LocalPath)
            if ([System.String]::IsNullOrWhiteSpace($InstallerName)) {
                throw [System.InvalidOperationException]::New("Manifest entry '$($Item.Name)' URI does not contain an installer filename: '$($Item.URI)'.")
            }
            $SilentUninstall = [System.String]$Item.SilentUninstall
            $SilentUninstall = $SilentUninstall.Replace("#Installer", $InstallerName)
            $Item.SilentUninstall = $SilentUninstall.Replace("#ProductCode", [System.String]$Item.ProductCode)
            Write-Output -InputObject $Item
        }
    }
}
