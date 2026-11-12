<#
    .SYNOPSIS
        Prepares the manifest and documentation for one explicit release.
    .PARAMETER Version
        Three-component module version.
    .PARAMETER Prerelease
        Optional lowercase prerelease label, such as beta1.
    .PARAMETER Root
        Repository directory to update.
    .EXAMPLE
        ./ci/Update-Release.ps1 -Version 5.1.0 -Prerelease beta1 -Verbose
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
Write-Verbose -Message "Reading current release metadata from '$Root'."
$Current = & (Join-Path -Path $PSScriptRoot -ChildPath "Get-ReleaseMetadata.ps1") -Root $Root
$FullVersion = $Version
if ($Prerelease) { $FullVersion += "-$Prerelease" }
Write-Verbose -Message "Comparing requested release '$FullVersion' with current release '$($Current.FullVersion)'."
$Comparison = ([System.Version]$Version).CompareTo([System.Version]$Current.Version)
if ($Comparison -lt 0 -or ($Comparison -eq 0 -and (-not $Current.Prerelease -or
    ($Prerelease -and [System.String]::CompareOrdinal($Prerelease, $Current.Prerelease) -le 0)))) {
    throw "The requested release must be newer than $($Current.FullVersion)."
}
$ChangelogPath = Join-Path -Path $Root -ChildPath "docs/changelog.md"
Write-Verbose -Message "Validating release notes in '$ChangelogPath'."
$Changelog = Get-Content -LiteralPath $ChangelogPath -Raw
$Headings = [System.Text.RegularExpressions.Regex]::Matches($Changelog, "(?m)^## ([^\r\n]+)\r?$")
if ($Headings.Count -eq 0 -or
    ($Headings[0].Groups[1].Value -cne "VERSION" -and $Headings[0].Groups[1].Value -cne $FullVersion) -or
    @($Headings | Where-Object { $_.Groups[1].Value -eq "VERSION" -or $_.Groups[1].Value -eq $FullVersion }).Count -ne 1) {
    throw "Prepare exactly one '## VERSION' or '## $FullVersion' section at the top of the changelog before releasing."
}
$Start = $Headings[0].Index + $Headings[0].Length
$End = $Changelog.Length
if ($Headings.Count -gt 1) { $End = $Headings[1].Index }
if (-not $Changelog.Substring($Start, $End - $Start).Trim()) { throw "The release notes for $FullVersion are empty." }
Write-Verbose -Message "Changelog heading '$($Headings[0].Groups[1].Value)' has nonempty release notes."
Write-Verbose -Message "Generating bundled version documentation for '$FullVersion'."
$Document = & (Join-Path -Path $PSScriptRoot -ChildPath "New-VcVersionsDocument.ps1") -Root $Root -Version $FullVersion
$ManifestPath = Join-Path -Path $Root -ChildPath "VcRedist/VcRedist.psd1"
$Functions = @(Get-ChildItem -LiteralPath (Join-Path -Path $Root -ChildPath "VcRedist/Public") -Filter "*.ps1" | Select-Object -ExpandProperty BaseName)
Write-Verbose -Message "Updating '$ManifestPath' for '$FullVersion' with $($Functions.Count) public function exports."
Update-ModuleManifest -Path $ManifestPath -ModuleVersion $Version -Prerelease $Prerelease -FunctionsToExport $Functions -ErrorAction "Stop"
$Encoding = New-Object -TypeName "System.Text.UTF8Encoding" -ArgumentList $false
if (-not $Prerelease) {
    Write-Verbose -Message "Removing any prerelease label for the stable release."
    # Update-ModuleManifest ignores an empty prerelease value, so remove any previous label for stable releases.
    $ManifestContent = [System.IO.File]::ReadAllText($ManifestPath)
    $ManifestContent = [System.Text.RegularExpressions.Regex]::Replace(
        $ManifestContent,
        '(?m)^[ \t]*Prerelease[ \t]*=[ \t]*(?:''[^'']*''|"[^"]*")[ \t]*\r?\n',
        ""
    )
    [System.IO.File]::WriteAllText($ManifestPath, $ManifestContent, $Encoding)
}
Write-Verbose -Message "Writing changelog and bundled version documentation for '$FullVersion'."
[System.IO.File]::WriteAllText($ChangelogPath, ($Changelog -replace "(?m)^## VERSION\r?$", "## $FullVersion"), $Encoding)
[System.IO.File]::WriteAllText((Join-Path -Path $Root -ChildPath "docs/versions.md"), $Document, $Encoding)
Write-Verbose -Message "Validating prepared release '$FullVersion'."
& (Join-Path -Path $PSScriptRoot -ChildPath "Get-ReleaseMetadata.ps1") -Root $Root -RequireDocumentation
