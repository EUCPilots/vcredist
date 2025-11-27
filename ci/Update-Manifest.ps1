<#
    .SYNOPSIS
        Update manifest for newer VcRedist versions.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUserDeclaredVarsMoreThanAssignments", "")]
[CmdletBinding()]
param (
    [System.String[]] $Release,
    [System.String[]] $Architecture = @("x64", "x86"),
    [System.String] $Path,
    [System.String] $VcManifest
)

begin {
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    $InformationPreference = [System.Management.Automation.ActionPreference]::Continue
    $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
}

process {

    # Get an array of VcRedists from the current manifest and the installed VcRedists
    Write-Information -MessageData "$($PSStyle.Foreground.Cyan)`tGetting manifest from: $VcManifest."
    $CurrentManifest = Get-Content -Path $VcManifest | ConvertFrom-Json
    $InstalledVcRedists = Get-InstalledVcRedist

    $Output = @()
    $FoundNewVersion = $false
    foreach ($Arch in $Architecture) {
        foreach ($Rls in $Release) {

            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)`tInstalling VcRedist $Rls."
            Get-VcList -Release $Rls -Architecture $Arch | Save-VcRedist -Path $Path | Install-VcRedist -Silent
            $InstalledVcRedists = Get-InstalledVcRedist | Where-Object { $_.Name -notmatch "Debug Runtime" }

            # Filter the VcRedists for the target version and compare against what has been installed
            foreach ($ManifestVcRedist in ($CurrentManifest.Supported | Where-Object { $_.Release -eq $Rls -and $_.Architecture -eq $Arch })) {
                $InstalledItem = $InstalledVcRedists | Where-Object { ($_.Release -eq $ManifestVcRedist.Release) -and ($_.Architecture -eq $ManifestVcRedist.Architecture) }

                # If the manifest version of the VcRedist is lower than the installed version, the manifest is out of date
                if ([System.Version]$InstalledItem.Version -gt [System.Version]$ManifestVcRedist.Version) {
                    Write-Information -MessageData "$($PSStyle.Foreground.Cyan)`tVcRedist manifest is out of date."
                    Write-Information -MessageData "$($PSStyle.Foreground.Cyan)`tInstalled version:`t$($InstalledItem.Version)"
                    Write-Information -MessageData "$($PSStyle.Foreground.Cyan)`tManifest version:`t$($ManifestVcRedist.Version)"

                    # Find the index of the VcRedist in the manifest and update it's properties
                    $Index = $CurrentManifest.Supported::IndexOf($CurrentManifest.Supported.ProductCode, $ManifestVcRedist.ProductCode)
                    $CurrentManifest.Supported[$Index].ProductCode = $InstalledItem.ProductCode
                    $CurrentManifest.Supported[$Index].Version = $InstalledItem.Version

                    # Create output variable
                    # $NewVersion = $InstalledItem.Version
                    $FoundNewVersion = $true
                    $Output += $Rls
                }
            }
        }
    }

    # If a version was found and were aren't in the main branch
    Write-Information -MessageData "$($PSStyle.Foreground.Cyan)`tFound new version $FoundNewVersion."
    if ($FoundNewVersion -eq $true) {

        # Convert to JSON and export to the module manifest
        try {
            Write-Information -MessageData "$($PSStyle.Foreground.Cyan)`tUpdating module manifest for VcRedist $($Output -join ", ")."
            $CurrentManifest | ConvertTo-Json | Set-Content -Path $VcManifest -Force
        }
        catch {
            throw "Failed to convert to JSON and write back to the manifest."
        }
    }
    else {
        Write-Information -MessageData "$($PSStyle.Foreground.Cyan)`tInstalled VcRedist matches manifest."
    }
}
