function Export-VcManifest {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Export-VcXml")]
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/export-vcmanifest/")]
    [OutputType([System.IO.FileSystemInfo])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { if (Test-Path -LiteralPath $_ -PathType "Container") { $true } else { throw [System.IO.DirectoryNotFoundException]::New("Cannot find path: $_") } })]
        [System.String] $Path,

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

        # Write only the manifest schema, without the Source property added by the resolver
        $Output = [ordered]@{
            SchemaVersion = $Manifest.SchemaVersion
            Updated       = ([System.DateTime]$Manifest.Updated).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            Entries       = @($Manifest.Entries)
        }
        $Target = Join-Path -Path (Resolve-Path -LiteralPath $Path).Path -ChildPath "VisualCRedistributables.json"
        if ($PSCmdlet.ShouldProcess($Target, "Export $($Manifest.Source) manifest")) {
            Write-Verbose -Message "Writing $($Manifest.Source) manifest to: '$Target'."
            $Output | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $Target -Encoding "UTF8" -Force -ErrorAction "Stop"
            Get-Item -LiteralPath $Target
        }
    }
}
