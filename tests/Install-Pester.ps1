<#
    .SYNOPSIS
        Installs the pinned Pester version used in CI.
#>
[CmdletBinding()]
param ()

$ErrorActionPreference = "Stop"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
if ($PSVersionTable.PSVersion.Major -le 5) {
    Install-PackageProvider -Name "NuGet" -MinimumVersion "2.8.5.208" -Force -Scope "CurrentUser" | Out-Null
}
if (-not (Get-Module -Name "Pester" -ListAvailable | Where-Object Version -EQ "5.7.1")) {
    Install-Module -Name "Pester" -RequiredVersion "5.7.1" -Repository "PSGallery" -Scope "CurrentUser" -Force -SkipPublisherCheck
}
Import-Module -Name "Pester" -RequiredVersion "5.7.1" -Force
