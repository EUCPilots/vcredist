<#
    .SYNOPSIS
        Prepares the manifest and documentation for one explicit release.
    .PARAMETER Version
        Three-component module version.
    .PARAMETER Prerelease
        Optional lowercase prerelease label, such as beta1.
    .PARAMETER Root
        Repository directory to update.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$")]
    [System.String] $Version,
    [ValidatePattern("^$|^[a-z][a-z0-9]*$")]
    [System.String] $Prerelease = "",
    [System.String] $Root = (Split-Path -Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = "Stop"
$Current = & (Join-Path -Path $PSScriptRoot -ChildPath "Get-ReleaseMetadata.ps1") -Root $Root
$Comparison = ([System.Version]$Version).CompareTo([System.Version]$Current.Version)
if ($Comparison -lt 0 -or ($Comparison -eq 0 -and (-not $Current.Prerelease -or
    ($Prerelease -and [System.String]::CompareOrdinal($Prerelease, $Current.Prerelease) -le 0)))) {
    throw "The requested release must be newer than $($Current.FullVersion)."
}
$FullVersion = $Version
if ($Prerelease) { $FullVersion += "-$Prerelease" }
$ChangelogPath = Join-Path -Path $Root -ChildPath "docs/changelog.md"
$Changelog = Get-Content -LiteralPath $ChangelogPath -Raw
$Headings = [System.Text.RegularExpressions.Regex]::Matches($Changelog, "(?m)^## ([^\r\n]+)\r?$")
if ($Headings.Count -eq 0 -or $Headings[0].Groups[1].Value -cne "VERSION" -or
    @($Headings | Where-Object { $_.Groups[1].Value -eq "VERSION" }).Count -ne 1) {
    throw "Prepare exactly one '## VERSION' section at the top of the changelog before releasing."
}
$Start = $Headings[0].Index + $Headings[0].Length
$End = $Changelog.Length
if ($Headings.Count -gt 1) { $End = $Headings[1].Index }
if (-not $Changelog.Substring($Start, $End - $Start).Trim()) { throw "The VERSION release notes are empty." }
$Document = & (Join-Path -Path $PSScriptRoot -ChildPath "New-VcVersionsDocument.ps1") -Root $Root -Version $FullVersion
$ManifestPath = Join-Path -Path $Root -ChildPath "VcRedist/VcRedist.psd1"
$Functions = @(Get-ChildItem -LiteralPath (Join-Path -Path $Root -ChildPath "VcRedist/Public") -Filter "*.ps1" | Select-Object -ExpandProperty BaseName)
Update-ModuleManifest -Path $ManifestPath -ModuleVersion $Version -Prerelease $Prerelease -FunctionsToExport $Functions -ErrorAction "Stop"
$Encoding = New-Object -TypeName "System.Text.UTF8Encoding" -ArgumentList $false
if (-not $Prerelease) {
    # Update-ModuleManifest ignores an empty prerelease value, so remove any previous label for stable releases.
    $ManifestContent = [System.IO.File]::ReadAllText($ManifestPath)
    $ManifestContent = [System.Text.RegularExpressions.Regex]::Replace(
        $ManifestContent,
        '(?m)^[ \t]*Prerelease[ \t]*=[ \t]*(?:''[^'']*''|"[^"]*")[ \t]*\r?\n',
        ""
    )
    [System.IO.File]::WriteAllText($ManifestPath, $ManifestContent, $Encoding)
}
[System.IO.File]::WriteAllText($ChangelogPath, ($Changelog -replace "(?m)^## VERSION\r?$", "## $FullVersion"), $Encoding)
[System.IO.File]::WriteAllText((Join-Path -Path $Root -ChildPath "docs/versions.md"), $Document, $Encoding)
& (Join-Path -Path $PSScriptRoot -ChildPath "Get-ReleaseMetadata.ps1") -Root $Root -RequireDocumentation
