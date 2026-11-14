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
        [ValidateNotNullOrEmpty()]
        [System.String] $OutFile,

        [Parameter(Mandatory = $false)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential] $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UserAgent,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $AllowedHosts,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 86400)]
        [System.Int32] $TimeoutSec = 60,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $ShowProgress
    )

    $ParsedUri = $null
    if (-not [System.Uri]::TryCreate($Uri, [System.UriKind]::Absolute, [ref] $ParsedUri) -or
        -not $ParsedUri.IsWellFormedOriginalString() -or
        $ParsedUri.Scheme -ne "https" -or
        [System.String]::IsNullOrWhiteSpace($ParsedUri.Host) -or
        -not [System.String]::IsNullOrEmpty($ParsedUri.UserInfo)) {
        throw [System.ArgumentException]::New("Only absolute HTTPS URIs are supported: '$Uri'.")
    }

    if ($PSBoundParameters.ContainsKey("Proxy")) {
        $ParsedProxy = $null
        if ([System.String]::IsNullOrWhiteSpace($Proxy) -or
            -not [System.Uri]::TryCreate($Proxy, [System.UriKind]::Absolute, [ref] $ParsedProxy) -or
            @("http", "https") -notcontains $ParsedProxy.Scheme -or
            [System.String]::IsNullOrWhiteSpace($ParsedProxy.Host) -or
            -not [System.String]::IsNullOrEmpty($ParsedProxy.UserInfo)) {
            throw [System.ArgumentException]::New("Proxy must be an absolute HTTP or HTTPS URI without embedded credentials.")
        }
    }
    elseif ($PSBoundParameters.ContainsKey("ProxyCredential") -and $ProxyCredential -ne [System.Management.Automation.PSCredential]::Empty) {
        throw [System.ArgumentException]::New("ProxyCredential cannot be specified without Proxy.")
    }

    $EffectiveAllowedHosts = if ($PSBoundParameters.ContainsKey("AllowedHosts")) { $AllowedHosts } else { @($ParsedUri.Host) }
    if ($EffectiveAllowedHosts -notcontains $ParsedUri.Host) {
        throw [System.ArgumentException]::New("The URI host '$($ParsedUri.Host)' is not in the allowed host list.")
    }

    $params = @{
        Uri             = $Uri
        Method          = $Method
        UseBasicParsing = $true
        MaximumRedirection = 0
        TimeoutSec      = $TimeoutSec
        ErrorAction     = "Stop"
    }
    if ($PSBoundParameters.ContainsKey("OutFile")) { $params.OutFile = $OutFile }
    $params.UserAgent = if ($PSBoundParameters.ContainsKey("UserAgent")) { $UserAgent } else { Get-VcUserAgent }
    if ($PSBoundParameters.ContainsKey("Proxy") -and -not [System.String]::IsNullOrEmpty($Proxy)) {
        $params.Proxy = $Proxy
        if ($PSBoundParameters.ContainsKey("ProxyCredential") -and $ProxyCredential -ne [System.Management.Automation.PSCredential]::Empty) {
            $params.ProxyCredential = $ProxyCredential
        }
        else {
            $params.ProxyUseDefaultCredentials = $true
        }
    }

    $WebRequestCommand = Get-Command -Name "Invoke-WebRequest" -ErrorAction "Stop"
    $SupportsSslProtocol = $WebRequestCommand.Parameters.ContainsKey("SslProtocol")
    if ($SupportsSslProtocol) {
        $SslProtocols = [System.Security.Authentication.SslProtocols]::Tls12
        if ([System.Enum]::GetNames([System.Security.Authentication.SslProtocols]) -contains "Tls13") {
            $SslProtocols = $SslProtocols -bor [System.Security.Authentication.SslProtocols]::Tls13
        }
        $params.SslProtocol = $SslProtocols
    }

    $CurrentUri = $ParsedUri
    $MaximumRedirects = 5
    for ($RedirectCount = 0; $RedirectCount -le $MaximumRedirects; $RedirectCount++) {
        $params.Uri = $CurrentUri.AbsoluteUri
        $Response = $null
        $RequestException = $null
        $OriginalProtocol = $null
        $OriginalProgress = $ProgressPreference
        $TlsLockEntered = $false
        try {
            if (-not $SupportsSslProtocol) {
                [System.Threading.Monitor]::Enter([System.Net.ServicePointManager])
                $TlsLockEntered = $true
                $OriginalProtocol = [System.Net.ServicePointManager]::SecurityProtocol
                [System.Net.ServicePointManager]::SecurityProtocol = $OriginalProtocol -bor [System.Net.SecurityProtocolType]::Tls12
            }
            $ProgressPreference = if ($ShowProgress) { "Continue" } else { "SilentlyContinue" }
            try {
                $Response = Invoke-WebRequest @params
            }
            catch {
                $RequestException = $_.Exception
                $Response = $RequestException.Response
                if ($null -eq $Response -and
                    $PSVersionTable.PSEdition -eq "Desktop" -and
                    $RequestException -is [System.InvalidOperationException]) {
                    $LegacyParams = @{
                        Uri          = $CurrentUri.AbsoluteUri
                        Method       = $Method
                        UserAgent    = $params.UserAgent
                        TimeoutSec   = $TimeoutSec
                        ShowProgress = $ShowProgressBar
                    }
                    if ($PSBoundParameters.ContainsKey("OutFile")) { $LegacyParams.OutFile = $OutFile }
                    if ($PSBoundParameters.ContainsKey("Proxy")) { $LegacyParams.Proxy = $Proxy }
                    if ($PSBoundParameters.ContainsKey("ProxyCredential")) { $LegacyParams.ProxyCredential = $ProxyCredential }
                    $LegacyResponse = Invoke-VcWebRequestLegacy @LegacyParams
                    $Response = $LegacyResponse.Response
                    $RequestException = $LegacyResponse.Exception
                }
                if ($null -eq $Response) { throw }
            }
        }
        finally {
            if ($null -ne $OriginalProtocol) {
                [System.Net.ServicePointManager]::SecurityProtocol = $OriginalProtocol
            }
            if ($TlsLockEntered) {
                [System.Threading.Monitor]::Exit([System.Net.ServicePointManager])
            }
            $ProgressPreference = $OriginalProgress
        }

        $StatusCode = $null
        if ($null -ne $Response -and $null -ne $Response.StatusCode) {
            $StatusCode = [System.Int32]$Response.StatusCode
        }
        elseif ($null -ne $RequestException -and $null -ne $RequestException.StatusCode) {
            $StatusCode = [System.Int32]$RequestException.StatusCode
        }

        if (@(301, 302, 303, 307, 308) -notcontains $StatusCode) {
            if ($null -ne $RequestException) { throw $RequestException }
            if ($null -ne $StatusCode -and $StatusCode -ge 400) {
                throw [System.Net.WebException]::New("The HTTPS request failed with status code $StatusCode.")
            }
            Write-Output -InputObject $Response
            return
        }

        if ($RedirectCount -ge $MaximumRedirects) {
            throw [System.Net.WebException]::New("The request exceeded the maximum of $MaximumRedirects redirects.")
        }

        $RedirectLocation = $null
        if ($null -ne $Response.Headers) {
            $LocationProperty = $Response.Headers.PSObject.Properties["Location"]
            if ($null -ne $LocationProperty) { $RedirectLocation = $LocationProperty.Value }
            if ($null -eq $RedirectLocation) {
                try { $RedirectLocation = $Response.Headers["Location"] }
                catch { $RedirectLocation = $null }
            }
        }
        if ([System.String]::IsNullOrWhiteSpace([System.String]$RedirectLocation)) {
            throw [System.Net.WebException]::New("The server returned a redirect without a Location header.")
        }

        $RedirectUri = $null
        if (-not [System.Uri]::TryCreate($CurrentUri, [System.String]$RedirectLocation, [ref] $RedirectUri) -or
            -not $RedirectUri.IsWellFormedOriginalString() -or
            $RedirectUri.Scheme -ne "https" -or
            [System.String]::IsNullOrWhiteSpace($RedirectUri.Host) -or
            -not [System.String]::IsNullOrEmpty($RedirectUri.UserInfo)) {
            throw [System.Net.WebException]::New("The server redirected to a URI that is not an absolute HTTPS URI.")
        }
        if ($EffectiveAllowedHosts -notcontains $RedirectUri.Host) {
            throw [System.Net.WebException]::New("The redirect host '$($RedirectUri.Host)' is not in the allowed host list.")
        }
        $CurrentUri = $RedirectUri
    }
}
