function Assert-Elevation {
    <#
        .SYNOPSIS
            Throws if the current session is not running as Administrator.
    #>
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $false)]
        [System.String] $Activity = "This operation"
    )

    [System.Boolean] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if ($Elevated -eq $false) {
        $Msg = "$Activity requires elevation. The current Windows PowerShell session is not running as Administrator. Start Windows PowerShell by using the Run as Administrator option, and then try running the script again"
        throw [System.Management.Automation.ScriptRequiresException]::New($Msg)
    }
}
