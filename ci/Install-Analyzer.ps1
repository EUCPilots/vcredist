<#
    .SYNOPSIS
        Installs and imports the pinned script analyzer used by CI.
#>
[CmdletBinding()]
param ()

$ErrorActionPreference = "Stop"
if (-not (Get-Module -ListAvailable -Name "PSScriptAnalyzer" | Where-Object Version -EQ "1.25.0")) {
    Install-Module -Name "PSScriptAnalyzer" -RequiredVersion "1.25.0" -Scope "CurrentUser" -Force -Repository "PSGallery"
}
Import-Module -Name "PSScriptAnalyzer" -RequiredVersion "1.25.0"
