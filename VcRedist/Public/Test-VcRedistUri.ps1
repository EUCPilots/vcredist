function Test-VcRedistUri {
    <#
        .EXTERNALHELP Vcredist-help.xml
    #>
    [Alias("Test-VcRedistDownload")]
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(HelpURI = "https://stealthpuppy.com/vcredist/test/")]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Pass a VcList object from Get-VcList.")]
            [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $false, Position = 1)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false, Position = 2)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $ShowProgress
    )

    begin {
        $AllowedHosts = [System.String[]](Get-VcConfig).Download.AllowedHosts
        $ShowProgressBar = $PSBoundParameters.ContainsKey("Verbose") -or $PSBoundParameters.ContainsKey("ShowProgress")
    }

    process {
        foreach ($Object in $VcList) {

            # Validate the URI property
            if ([System.String]::IsNullOrEmpty($Object.URI)) {
                $Msg = "Object does not have valid URI property."
                throw [System.Management.Automation.PropertyNotFoundException]::New($Msg)
            }

            $Result = $false
            if (Test-VcDownloadUri -Uri $Object.URI -AllowedHosts $AllowedHosts) {
                try {
                    $params = @{
                        Uri          = $Object.URI
                        Method       = "Head"
                        AllowedHosts = $AllowedHosts
                        TimeoutSec   = 30
                        ShowProgress = $ShowProgressBar
                    }
                    if ($PSBoundParameters.ContainsKey("Proxy")) { $params.Proxy = $Proxy }
                    if ($PSBoundParameters.ContainsKey("ProxyCredential")) { $params.ProxyCredential = $ProxyCredential }
                    Invoke-VcWebRequest @params | Out-Null
                    $Result = $true
                }
                catch [System.Exception] {
                    Write-Verbose -Message "Request failed for '$($Object.URI)': $($_.Exception.Message)"
                }
            }
            else {
                Write-Warning -Message "URI is not HTTPS or not on the allowed host list: '$($Object.URI)'."
            }

            $PSObject = [PSCustomObject] @{
                Result       = $Result
                Release      = $Object.Release
                Architecture = $Object.Architecture
                Version      = $Object.Version
                URI          = $Object.URI
            }
            Write-Output -InputObject $PSObject
        }
    }

    end { }
}
