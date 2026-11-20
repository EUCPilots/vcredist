<#
	.SYNOPSIS
		Manifest tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
    $ValidateCasesAmd64 = @(
        foreach ($Release in @("2017", "2019", "14")) {
            foreach ($Architecture in @("x86", "x64")) {
                @{ Release = $Release; Architecture = $Architecture }
            }
        }
    )
    $ValidateCasesArm64 = @(
        @{ Release = "14"; Architecture = "arm64" }
    )

    $SkipAmd = $env:PROCESSOR_ARCHITECTURE -ne "AMD64"
    $SkipArm = $env:PROCESSOR_ARCHITECTURE -ne "ARM64"
}

Describe -Name "AMD64 manifest tests" -Skip:$SkipAmd {
    Describe -Name "Manifest entry <Release> <Architecture>" -ForEach $ValidateCasesAmd64 {
        BeforeAll {
            Get-InstalledVcRedist | Uninstall-VcRedist -Confirm:$false

            $VcManifest = Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath "VcRedist/VisualCRedistributables.json"
            $CurrentManifest = Get-Content -Path $VcManifest -Raw | ConvertFrom-Json
            $ManifestVcRedist = @($CurrentManifest.Entries | Where-Object {
                $_.Supported -and $_.Release -eq $Release -and $_.Architecture -eq $Architecture
            })
            if ($ManifestVcRedist.Count -ne 1) {
                throw "Expected one supported manifest entry for release $Release, architecture $Architecture; found $($ManifestVcRedist.Count)."
            }
            $ManifestVcRedist = $ManifestVcRedist[0]

            $Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
            New-Item -Path $Path -ItemType "Directory" -Force | Out-Null
            Get-VcList -Release $Release -Architecture $Architecture -Source "Bundled" |
                Where-Object { $_.Supported } |
                Save-VcRedist -Path $Path |
                Install-VcRedist -Silent | Out-Null

            $InstalledItem = Get-InstalledVcRedist |
                    Where-Object { $_.ProductCode -eq $ManifestVcRedist.ProductCode -and $_.Architecture -eq $Architecture } |
                Sort-Object -Property { [System.Version]$_.Version } -Descending |
                Select-Object -First 1
        }

        It "installs a current redistributable matching the manifest" {
            $InstalledItem | Should -Not -BeNullOrEmpty
            ([System.Version]$InstalledItem.Version -gt [System.Version]$ManifestVcRedist.Version) | Should -BeFalse
            $InstalledItem.ProductCode | Should -Be $ManifestVcRedist.ProductCode
        }
    }
}

Describe -Name "ARM64 manifest tests" -Skip:$SkipArm {
    Describe -Name "Manifest entry <Release> <Architecture>" -ForEach $ValidateCasesArm64 {
        BeforeAll {
            Get-InstalledVcRedist | Uninstall-VcRedist -Confirm:$false

            $VcManifest = Join-Path -Path $env:GITHUB_WORKSPACE -ChildPath "VcRedist/VisualCRedistributables.json"
            $CurrentManifest = Get-Content -Path $VcManifest -Raw | ConvertFrom-Json
            $ManifestVcRedist = @($CurrentManifest.Entries | Where-Object {
                $_.Supported -and $_.Release -eq $Release -and $_.Architecture -eq $Architecture
            })
            if ($ManifestVcRedist.Count -ne 1) {
                throw "Expected one supported manifest entry for release $Release, architecture $Architecture; found $($ManifestVcRedist.Count)."
            }
            $ManifestVcRedist = $ManifestVcRedist[0]

            $Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
            New-Item -Path $Path -ItemType "Directory" -Force | Out-Null
            Get-VcList -Release $Release -Architecture $Architecture -Source "Bundled" |
                Where-Object { $_.Supported } |
                Save-VcRedist -Path $Path |
                Install-VcRedist -Silent | Out-Null

            $InstalledItem = Get-InstalledVcRedist |
                    Where-Object { $_.ProductCode -eq $ManifestVcRedist.ProductCode -and $_.Architecture -eq $Architecture } |
                Sort-Object -Property { [System.Version]$_.Version } -Descending |
                Select-Object -First 1
        }

        It "installs a current redistributable matching the manifest" {
            $InstalledItem | Should -Not -BeNullOrEmpty
            ([System.Version]$InstalledItem.Version -gt [System.Version]$ManifestVcRedist.Version) | Should -BeFalse
            $InstalledItem.ProductCode | Should -Be $ManifestVcRedist.ProductCode
        }
    }
}
