function Export-VcManifest {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpURI = "https://vcredist.com/export-vcmanifest/")]
    [OutputType([System.IO.FileSystemInfo])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { if (Test-Path -Path $_ -PathType "Container") { $true } else { throw [System.IO.DirectoryNotFoundException]::New("Cannot find path: $_") } })]
        [System.String] $Path
    )

    process {
        [System.String] $DestinationFile = Join-Path -Path $Path -ChildPath "VisualCRedistributables.json"

        # If Get-VcList has fetched a remote manifest this session, export that; otherwise copy the bundled file
        if ($null -ne $script:VcManifestCache) {
            Write-Verbose -Message "Exporting cached manifest to '$DestinationFile'."
            try {
                $script:VcManifestCache | ConvertTo-Json -Depth 10 | Set-Content -Path $DestinationFile -Encoding "UTF8" -ErrorAction "Stop"
                Get-Item -Path $DestinationFile -ErrorAction "Stop"
            }
            catch {
                throw $_
            }
        }
        else {
            [System.String] $Manifest = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VisualCRedistributables.json"
            Write-Verbose -Message "Exporting bundled manifest to '$Path'."
            try {
                $params = @{
                    Path        = $Manifest
                    Destination = $Path
                    PassThru    = $true
                    ErrorAction = "Stop"
                }
                Copy-Item @params
            }
            catch {
                throw $_
            }
        }
    }
}
