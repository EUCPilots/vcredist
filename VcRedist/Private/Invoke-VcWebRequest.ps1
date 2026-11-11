function Invoke-VcWebRequest {
    <#
        .SYNOPSIS
            Wraps Invoke-WebRequest so that all network calls use the same HTTPS, TLS, timeout and proxy handling.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Get", "Head")]
        [System.String] $Method = "Get",

        [Parameter(Mandatory = $false)]
        [System.String] $OutFile,

        [Parameter(Mandatory = $false)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential] $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false)]
        [System.String] $UserAgent,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 86400)]
        [System.Int32] $TimeoutSec = 60,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $ShowProgress
    )

    $ParsedUri = $null
    if (-not [System.Uri]::TryCreate($Uri, [System.UriKind]::Absolute, [ref] $ParsedUri) -or $ParsedUri.Scheme -ne "https") {
        throw [System.ArgumentException]::New("Only absolute HTTPS URIs are supported: '$Uri'.")
    }

    $params = @{
        Uri             = $Uri
        Method          = $Method
        UseBasicParsing = $true
        TimeoutSec      = $TimeoutSec
        ErrorAction     = "Stop"
    }
    if ($PSBoundParameters.ContainsKey("OutFile")) { $params.OutFile = $OutFile }
    if ($PSBoundParameters.ContainsKey("UserAgent")) { $params.UserAgent = $UserAgent }
    if ($PSBoundParameters.ContainsKey("Proxy") -and -not [System.String]::IsNullOrEmpty($Proxy)) {
        $params.Proxy = $Proxy
        if ($PSBoundParameters.ContainsKey("ProxyCredential") -and $ProxyCredential -ne [System.Management.Automation.PSCredential]::Empty) {
            $params.ProxyCredential = $ProxyCredential
        }
        else {
            $params.ProxyUseDefaultCredentials = $true
        }
    }

    # TLS and progress changes are restored so the caller's session is not altered
    $OriginalProtocol = [System.Net.ServicePointManager]::SecurityProtocol
    $OriginalProgress = $ProgressPreference
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = $OriginalProtocol -bor [System.Net.SecurityProtocolType]::Tls12
        $ProgressPreference = if ($ShowProgress) { "Continue" } else { "SilentlyContinue" }
        Invoke-WebRequest @params
    }
    finally {
        [System.Net.ServicePointManager]::SecurityProtocol = $OriginalProtocol
        $ProgressPreference = $OriginalProgress
    }
}
