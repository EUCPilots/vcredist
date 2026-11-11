<#
    .SYNOPSIS
        Installs and imports the pinned dependencies used by Intune tests.
#>
[CmdletBinding()]
param ()

$ErrorActionPreference = "Stop"
$Dependencies = @{ "MSAL.PS" = "4.37.0.0"; "IntuneWin32App" = "1.5.0" }
foreach ($Name in $Dependencies.Keys) {
    if (-not (Get-Module -ListAvailable -Name $Name | Where-Object Version -EQ $Dependencies[$Name])) {
        Install-Module -Name $Name -RequiredVersion $Dependencies[$Name] -Scope "CurrentUser" -Repository "PSGallery" -Force
    }
    Import-Module -Name $Name -RequiredVersion $Dependencies[$Name] -Force
}
