function Invoke-VcWebRequestLegacy {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String] $Uri,

        [Parameter(Mandatory = $true)]
        [System.String] $Method,

        [Parameter(Mandatory = $false)]
        [System.String] $OutFile,

        [Parameter(Mandatory = $false)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential] $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $true)]
        [System.String] $UserAgent,

        [Parameter(Mandatory = $true)]
        [System.Int32] $TimeoutSec,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $ShowProgress
    )

    $Request = [System.Net.HttpWebRequest]::Create($Uri)
    $Request.Method = $Method
    $Request.AllowAutoRedirect = $false
    $Request.Timeout = $TimeoutSec * 1000
    $Request.ReadWriteTimeout = $TimeoutSec * 1000
    $Request.UserAgent = $UserAgent

    if (-not [System.String]::IsNullOrEmpty($Proxy)) {
        $WebProxy = [System.Net.WebProxy]::new($Proxy)
        if ($ProxyCredential -ne [System.Management.Automation.PSCredential]::Empty) {
            $WebProxy.Credentials = $ProxyCredential.GetNetworkCredential()
        }
        else {
            $WebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials
        }
        $Request.Proxy = $WebProxy
    }

    $Response = $null
    $RequestException = $null
    try {
        $Response = $Request.GetResponse()
    }
    catch [System.Net.WebException] {
        $RequestException = $_.Exception
        $Response = $RequestException.Response
        if ($null -eq $Response) { throw }
    }

    $StatusCode = [System.Int32]$Response.StatusCode
    $Headers = $Response.Headers
    $Content = $null
    $RedirectStatusCodes = @(301, 302, 303, 307, 308)
    try {
        if ($RedirectStatusCodes -notcontains $StatusCode -and $StatusCode -lt 400) {
            $ResponseStream = $Response.GetResponseStream()
            if ($null -ne $ResponseStream) {
                if (-not [System.String]::IsNullOrEmpty($OutFile)) {
                    $FileStream = [System.IO.File]::Open(
                        $OutFile,
                        [System.IO.FileMode]::Create,
                        [System.IO.FileAccess]::Write,
                        [System.IO.FileShare]::None
                    )
                    try {
                        $Buffer = New-Object -TypeName "System.Byte[]" -ArgumentList 81920
                        $BytesRead = 0
                        $TotalBytes = $Response.ContentLength
                        while (($Count = $ResponseStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {
                            $FileStream.Write($Buffer, 0, $Count)
                            $BytesRead += $Count
                            if ($ShowProgress -and $TotalBytes -gt 0) {
                                $PercentComplete = [System.Int32](100 * $BytesRead / $TotalBytes)
                                Write-Progress -Activity "Downloading $Uri" -Status "$BytesRead of $TotalBytes bytes" -PercentComplete $PercentComplete
                            }
                        }
                    }
                    finally {
                        $FileStream.Dispose()
                        if ($ShowProgress) {
                            Write-Progress -Activity "Downloading $Uri" -Completed
                        }
                    }
                }
                elseif ($Method -ne "Head") {
                    $Reader = [System.IO.StreamReader]::new($ResponseStream)
                    try {
                        $Content = $Reader.ReadToEnd()
                    }
                    finally {
                        $Reader.Dispose()
                    }
                }
                else {
                    $ResponseStream.Dispose()
                }
            }
        }
    }
    finally {
        $Response.Close()
    }

    [PSCustomObject]@{
        Response  = [PSCustomObject]@{
            StatusCode = $StatusCode
            Headers    = $Headers
            Content    = $Content
        }
        Exception = $RequestException
    }
}
