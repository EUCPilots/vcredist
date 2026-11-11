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
        [System.String[]] $Release = @("14"),

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "Manifest")]
        [ValidateSet("x86", "x64", "arm64")]
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
        $params = @{ Source = $Source }
        if ($PSBoundParameters.ContainsKey("Proxy")) { $params.Proxy = $Proxy }
        if ($PSBoundParameters.ContainsKey("ProxyCredential")) { $params.ProxyCredential = $ProxyCredential }
        $Manifest = Get-VcManifest @params
        $Entries = @($Manifest.Entries)

        if ($PSCmdlet.ParameterSetName -eq "Export") {
            switch ($Export) {
                "All" {
                    Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                    $Output = $Entries
                }
                "Supported" { $Output = $Entries | Where-Object { $_.Supported -eq $true } }
                "Unsupported" {
                    Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                    $Output = $Entries | Where-Object { $_.Supported -eq $false }
                }
            }
        }
        else {
            $Output = $Entries | Where-Object { $_.Supported -eq $true } | `
                Where-Object { $Release -contains $_.Release } | `
                Where-Object { $Architecture -contains $_.Architecture }
        }

        # Replace the placeholder tokens in the uninstall command
        foreach ($Item in @($Output)) {
            $Item.SilentUninstall = $Item.SilentUninstall `
                -replace "#Installer", (Split-Path -Path $Item.URI -Leaf) `
                -replace "#ProductCode", $Item.ProductCode
            Write-Output -InputObject $Item
        }
    }
}
