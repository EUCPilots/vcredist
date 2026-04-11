function Get-ProxyParam {
    <#
        .SYNOPSIS
            Returns a hashtable of proxy-related parameters for splatting into Invoke-WebRequest.

        .DESCRIPTION
            If -Proxy is specified, uses it directly. Otherwise detects the system proxy for the given URI.
            Always respects -ProxyCredential when provided; falls back to default credentials for system proxies.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String] $Uri,

        [Parameter(Mandatory = $false)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false)]
        [System.Collections.IDictionary] $BoundParameters = @{}
    )

    $params = @{}

    if ($BoundParameters.ContainsKey("Proxy")) {
        $params.Proxy = $Proxy
        if ($BoundParameters.ContainsKey("ProxyCredential")) {
            $params.ProxyCredential = $ProxyCredential
        }
    }
    else {
        $RequestUri = [System.Uri]::new($Uri)
        $SystemProxy = [System.Net.WebRequest]::DefaultWebProxy
        if ($null -ne $SystemProxy) {
            $ProxyUri = $SystemProxy.GetProxy($RequestUri)
            if (($null -ne $ProxyUri) -and ($ProxyUri.AbsoluteUri -ne $RequestUri.AbsoluteUri)) {
                Write-Verbose -Message "Using system proxy '$($ProxyUri.AbsoluteUri)' for '$Uri'."
                $params.Proxy = $ProxyUri.AbsoluteUri
                if ($BoundParameters.ContainsKey("ProxyCredential")) {
                    $params.ProxyCredential = $ProxyCredential
                }
                else {
                    $params.ProxyUseDefaultCredentials = $true
                }
            }
        }
    }

    return $params
}
