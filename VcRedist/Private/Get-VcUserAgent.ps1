function Get-VcUserAgent {
    <#
        .SYNOPSIS
            Returns the user agent string VcRedist uses for web requests.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $Version = $MyInvocation.MyCommand.Module.Version
    if ($null -eq $Version) { $Version = "0.0.0" }
    $Os = [System.Environment]::OSVersion
    Write-Output -InputObject "VcRedist/$Version (https://github.com/EUCPilots/vcredist; PowerShell $($PSVersionTable.PSVersion); $($Os.Platform) $($Os.Version))"
}
