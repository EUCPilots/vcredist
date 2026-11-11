function Test-VcDownloadUri {
    <#
        .SYNOPSIS
            Returns $true when a URI is an absolute HTTPS URI on an allowed host.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [System.String] $Uri,

        [Parameter(Mandatory = $false)]
        [System.String[]] $AllowedHosts = (Get-VcConfig).Download.AllowedHosts
    )

    $ParsedUri = $null
    if (-not [System.Uri]::TryCreate($Uri, [System.UriKind]::Absolute, [ref] $ParsedUri)) { return $false }
    if ($ParsedUri.Scheme -ne "https") { return $false }
    return [System.Boolean]($AllowedHosts -contains $ParsedUri.Host.ToLower())
}
