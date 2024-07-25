<#
    .SYNOPSIS
        Update manifest for newer VcRedist versions.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUserDeclaredVarsMoreThanAssignments", "")]
[CmdletBinding()]
param (
    [System.String] $Path,
    [System.String] $VcManifest
)

process {

    # Get an array of VcRedists from the current manifest and the installed VcRedists
    Write-Host -ForegroundColor "Cyan" "`tGetting manifest from: $VcManifest."
    $CurrentManifest = Get-Content -Path $VcManifest | ConvertFrom-Json
    $InstalledVcRedists = Get-InstalledVcRedist

    $Output = @()
    $FoundNewVersion = $false

    Write-Host "`tInstalling VcRedist $Item." -ForegroundColor "Cyan"
    Get-VcList -Release "2022" -Architecture "ARM64" | Save-VcRedist -Path $Path | Install-VcRedist -Silent
    $InstalledVcRedists = Get-InstalledVcRedist | Where-Object { $_.Name -notmatch "Debug Runtime" }

    # Filter the VcRedists for the target version and compare against what has been installed
    foreach ($ManifestVcRedist in ($CurrentManifest.Supported | Where-Object { $_.Release -eq "2022" -and $_.Architecture -eq "ARM64" })) {
        $InstalledItem = $InstalledVcRedists | Where-Object { ($_.Release -eq $ManifestVcRedist.Release) -and ($_.Architecture -eq $ManifestVcRedist.Architecture) }

        # If the manifest version of the VcRedist is lower than the installed version, the manifest is out of date
        if ([System.Version]$InstalledItem.Version -gt [System.Version]$ManifestVcRedist.Version) {
            Write-Host -ForegroundColor "Cyan" "`tVcRedist manifest is out of date."
            Write-Host -ForegroundColor "Cyan" "`tInstalled version:`t$($InstalledItem.Version)"
            Write-Host -ForegroundColor "Cyan" "`tManifest version:`t$($ManifestVcRedist.Version)"

            # Find the index of the VcRedist in the manifest and update it's properties
            $Index = $CurrentManifest.Supported::IndexOf($CurrentManifest.Supported.ProductCode, $ManifestVcRedist.ProductCode)
            $CurrentManifest.Supported[$Index].ProductCode = $InstalledItem.ProductCode
            $CurrentManifest.Supported[$Index].Version = $InstalledItem.Version

            # Create output variable
            # $NewVersion = $InstalledItem.Version
            $FoundNewVersion = $true
            $Output += $Item
        }
    }

    # If a version was found and were aren't in the main branch
    Write-Host -ForegroundColor "Cyan" "`tFound new version $FoundNewVersion."
    if ($FoundNewVersion -eq $true) {

        # Convert to JSON and export to the module manifest
        try {
            Write-Host -ForegroundColor "Cyan" "`tUpdating module manifest for VcRedist $($Output -join ", ")."
            $CurrentManifest | ConvertTo-Json | Set-Content -Path $VcManifest -Force
        }
        catch {
            throw "Failed to convert to JSON and write back to the manifest."
        }
    }
    else {
        Write-Host -ForegroundColor "Cyan" "`tInstalled VcRedist matches manifest."
    }
}
