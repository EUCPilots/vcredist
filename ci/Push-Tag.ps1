<#
    .SYNOPSIS
        Requests the gated publishing workflow instead of pushing unvalidated tags.
#>
[CmdletBinding()]
param ()

$ErrorActionPreference = "Stop"
$Metadata = & (Join-Path -Path $PSScriptRoot -ChildPath "Get-ReleaseMetadata.ps1") -RequireDocumentation
$Sha = git rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw "Could not determine the release commit." }
gh workflow run publish-module.yml --ref main -f "tag=$($Metadata.Tag)" -f "commit=$Sha"
if ($LASTEXITCODE -ne 0) { throw "Could not dispatch the gated publishing workflow." }
