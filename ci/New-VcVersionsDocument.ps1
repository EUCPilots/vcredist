<#
    .SYNOPSIS
        Generates version documentation from the bundled redistributable manifest.
    .PARAMETER Root
        Repository or staged release directory.
    .PARAMETER Version
        Full Gallery version, including the optional prerelease label.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [System.String] $Root,
    [Parameter(Mandatory = $true)]
    [System.String] $Version
)

$ErrorActionPreference = "Stop"
$Manifest = Get-Content -LiteralPath (Join-Path -Path $Root -ChildPath "VcRedist/VisualCRedistributables.json") -Raw |
    ConvertFrom-Json -ErrorAction "Stop"
if ($Manifest.PSObject.Properties.Name -contains "Entries") {
    $Entries = @($Manifest.Entries)
}
elseif ($Manifest.PSObject.Properties.Name -contains "Supported" -and $Manifest.PSObject.Properties.Name -contains "Unsupported") {
    $Entries = @($Manifest.Supported) + @($Manifest.Unsupported)
}
else {
    throw "Unrecognized bundled redistributable manifest schema."
}
if ($Entries.Count -eq 0) { throw "The bundled redistributable manifest is empty." }
$Lines = @(
    "# Included Redistributables"
    ""
    ('VcRedist `{0}` includes the following Redistributables (supported and unsupported):' -f $Version)
    ""
    "| Version | Architecture | Name |"
    "| --- | --- | --- |"
)
foreach ($Entry in ($Entries | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true }, Architecture, Name)) {
    foreach ($Property in @("Version", "Architecture", "Name")) {
        if (-not $Entry.$Property) { throw "A bundled manifest entry is missing $Property." }
    }
    $Lines += "| $($Entry.Version) | $($Entry.Architecture) | $($Entry.Name -replace '\|', '\|') |"
}
($Lines -join "`n") + "`n"
