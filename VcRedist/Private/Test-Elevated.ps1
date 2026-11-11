function Test-Elevated {
    <#
        .SYNOPSIS
            Returns True when the current session is running with administrator rights.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    $Principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    Write-Output -InputObject $Principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}
