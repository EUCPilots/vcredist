function Get-VcManifest {
    <#
        .SYNOPSIS
            Resolves the VcRedist manifest: remote first, falling back to the manifest bundled with the module.
        .PARAMETER Source
            Auto uses the remote manifest and falls back to the bundled manifest on any failure.
            Remote fails if the remote manifest cannot be used. Bundled never touches the network.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Auto", "Remote", "Bundled")]
        [System.String] $Source = "Auto",

        [Parameter(Mandatory = $false)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential] $ProxyCredential = [System.Management.Automation.PSCredential]::Empty
    )

    $Config = Get-VcConfig
    $Major = [System.Int32]$Config.Manifest.SupportedSchemaMajor
    $Hosts = @($Config.Download.AllowedHosts)

    function Read-Manifest ([System.String] $Json) {
        $Manifest = $Json | ConvertFrom-Json -ErrorAction "Stop"
        Test-VcManifest -Manifest $Manifest -SupportedSchemaMajor $Major -AllowedHosts $Hosts | Out-Null
        $Manifest
    }

    $BundledPath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "VisualCRedistributables.json"
    $Bundled = $null
    if ($Source -ne "Remote") {
        try {
            Write-Verbose -Message "Reading bundled manifest: '$BundledPath'."
            $Bundled = Read-Manifest -Json (Get-Content -LiteralPath $BundledPath -Raw -ErrorAction "Stop")
        }
        catch {
            throw "Unable to read the bundled manifest '$BundledPath'. $($_.Exception.Message)"
        }
    }

    $Selected = $Bundled
    $SelectedSource = "Bundled"
    if ($Source -ne "Bundled") {
        try {
            Write-Verbose -Message "Reading remote manifest: '$($Config.Manifest.Uri)'."
            $params = @{
                Uri        = $Config.Manifest.Uri
                TimeoutSec = [System.Int32]$Config.Manifest.TimeoutSeconds
            }
            if ($PSBoundParameters.ContainsKey("Proxy")) { $params.Proxy = $Proxy }
            if ($PSBoundParameters.ContainsKey("ProxyCredential")) { $params.ProxyCredential = $ProxyCredential }
            $Response = Invoke-VcWebRequest @params
            $Remote = Read-Manifest -Json ([System.String]$Response.Content)

            if ($null -ne $Bundled -and ([System.DateTime]$Remote.Updated).ToUniversalTime() -lt ([System.DateTime]$Bundled.Updated).ToUniversalTime()) {
                Write-Verbose -Message "Remote manifest ($($Remote.Updated)) is older than the bundled manifest ($($Bundled.Updated)). Using bundled manifest."
            }
            else {
                $Selected = $Remote
                $SelectedSource = "Remote"
            }
        }
        catch {
            if ($Source -eq "Remote") { throw }
            Write-Warning -Message "Unable to use the remote manifest, using the bundled manifest. $($_.Exception.Message)"
        }
    }

    Write-Verbose -Message "Using $SelectedSource manifest, updated $($Selected.Updated)."
    $Selected | Add-Member -MemberType "NoteProperty" -Name "Source" -Value $SelectedSource -Force
    Write-Output -InputObject $Selected
}
