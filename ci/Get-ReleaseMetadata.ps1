<#
    .SYNOPSIS
        Validates release metadata and optionally its documentation and tag.
    .PARAMETER Root
        Repository or staged release directory.
    .PARAMETER RequireDocumentation
        Requires current, nonempty release notes and matching bundled-manifest documentation.
    .PARAMETER Tag
        Expected tag; must equal the full manifest version prefixed with v.
#>
[CmdletBinding()]
param (
    [System.String] $Root = (Split-Path -Path $PSScriptRoot -Parent),
    [System.Management.Automation.SwitchParameter] $RequireDocumentation,
    [System.String] $Tag
)

$ErrorActionPreference = "Stop"
$Manifest = Import-PowerShellDataFile -LiteralPath (Join-Path -Path $Root -ChildPath "VcRedist/VcRedist.psd1")
$Version = [System.String]$Manifest.ModuleVersion
if ($Version -notmatch "^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$") {
    throw "ModuleVersion must be a three-component version without leading zeros."
}
$null = [System.Version]$Version
$Prerelease = [System.String]$Manifest.PrivateData.PSData.Prerelease
if ($Prerelease -and $Prerelease -cnotmatch "^[a-z][a-z0-9]*$") {
    throw "Prerelease must contain lowercase letters and digits, starting with a letter (for example beta1)."
}
$FullVersion = $Version
if ($Prerelease) { $FullVersion += "-$Prerelease" }
$ExpectedTag = "v$FullVersion"
if ($Tag -and $Tag -cne $ExpectedTag) { throw "Tag '$Tag' does not match manifest tag '$ExpectedTag'." }
$Functions = @(Get-ChildItem -LiteralPath (Join-Path -Path $Root -ChildPath "VcRedist/Public") -Filter "*.ps1" | Select-Object -ExpandProperty BaseName)
$Difference = @(Compare-Object -ReferenceObject $Functions -DifferenceObject @($Manifest.FunctionsToExport))
if ($Difference.Count -gt 0) { throw "FunctionsToExport does not match the public function files." }
Test-ModuleManifest -Path (Join-Path -Path $Root -ChildPath "VcRedist/VcRedist.psd1") -ErrorAction "Stop" | Out-Null
$Notes = ""
if ($RequireDocumentation) {
    $Changelog = Get-Content -LiteralPath (Join-Path -Path $Root -ChildPath "docs/changelog.md") -Raw
    $Sections = [System.Text.RegularExpressions.Regex]::Matches($Changelog, "(?m)^## ([^\r\n]+)\r?$")
    if ($Sections.Count -eq 0 -or $Sections[0].Groups[1].Value -cne $FullVersion) {
        throw "The first changelog release must be '## $FullVersion'."
    }
    $Start = $Sections[0].Index + $Sections[0].Length
    $End = $Changelog.Length
    if ($Sections.Count -gt 1) { $End = $Sections[1].Index }
    $Notes = $Changelog.Substring($Start, $End - $Start).Trim()
    if (-not $Notes) { throw "Release notes for $FullVersion are empty." }
    $Expected = & (Join-Path -Path $PSScriptRoot -ChildPath "New-VcVersionsDocument.ps1") -Root $Root -Version $FullVersion
    $Actual = Get-Content -LiteralPath (Join-Path -Path $Root -ChildPath "docs/versions.md") -Raw
    if (($Actual -replace "`r`n", "`n").Trim() -cne $Expected.Trim()) {
        throw "Version documentation does not match the release version and bundled manifest."
    }
}
[PSCustomObject]@{
    Version = $Version
    Prerelease = $Prerelease
    FullVersion = $FullVersion
    Tag = $ExpectedTag
    Notes = $Notes
}
