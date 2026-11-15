Describe "Update-Manifest architecture handling" {
    BeforeAll {
        $ScriptPath = Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) "ci/Update-Manifest.ps1"
        $Entries = @(Get-VcList -Release @("14", "2019", "2017") -Source "Bundled")
    }
    BeforeEach {
        $ManifestPath = Join-Path $TestDrive "manifest.json"
        @{ SchemaVersion = "1.0"; Updated = "2026-01-01T00:00:00Z"; InstallOrder = @("2017", "2019", "14"); Entries = $Entries } |
            ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ManifestPath
        Mock Get-VcOperatingSystemArchitecture -ModuleName VcRedist { "AMD64" }
        Mock Get-VcList {
            $Entries | Where-Object { $Release -contains $_.Release -and $_.Architecture -eq $Architecture }
        }
        Mock Save-VcRedist { $VcList }
        Mock Install-VcRedist { $VcList }
        Mock Get-InstalledVcRedist {
            $Entries | Where-Object { $_.Architecture -eq "x64" }
        }
    }
    It "Skips incompatible entries before downloading and installing" {
        & $ScriptPath -Release "14" -Architecture @("x64", "arm64") -Path $TestDrive -VcManifest $ManifestPath
        Should -Invoke Get-VcList -Times 1 -Exactly -ParameterFilter { $Architecture -eq "x64" }
        Should -Invoke Save-VcRedist -Times 1 -Exactly
        Should -Invoke Install-VcRedist -Times 1 -Exactly
    }
    It "Fails if a compatible package has no matching installed entry" {
        Mock Get-InstalledVcRedist { }
        { & $ScriptPath -Release "14" -Architecture @("x64") -Path $TestDrive -VcManifest $ManifestPath } |
            Should -Throw "*No installed VcRedist found*"
    }
    It "Matches the unified 2022 redistributable for all supported releases on ARM64" {
        Mock Get-VcOperatingSystemArchitecture -ModuleName VcRedist { "ARM64" }
        Mock Get-InstalledVcRedist {
            $Item = ($Entries | Where-Object { $_.Architecture -eq "arm64" -and $_.Release -eq "14" } | Select-Object -First 1).PSObject.Copy()
            $Item.Release = "2022"
            $Item
        }
        & $ScriptPath -Release @("14", "2019", "2017") -Architecture @("x64", "arm64") -Path $TestDrive -VcManifest $ManifestPath
        Should -Invoke Get-VcList -Times 3 -Exactly -ParameterFilter { $Architecture -eq "arm64" }
    }
    It "Rejects a manifest with missing architecture metadata rather than skipping it" {
        $Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
        $Manifest.Entries[0].PSObject.Properties.Remove("SupportedArchitecture")
        $Manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ManifestPath
        { & $ScriptPath -Release "14" -Architecture @("x64") -Path $TestDrive -VcManifest $ManifestPath } |
            Should -Throw "*SupportedArchitecture*"
        Should -Invoke Get-VcList -Times 0
    }
    It "Preserves installation order when updating the manifest" {
        Mock Get-InstalledVcRedist {
            $Item = ($Entries | Where-Object { $_.Architecture -eq "x64" -and $_.Release -eq "14" } | Select-Object -First 1).PSObject.Copy()
            $Item.Version = "99.0.0.0"
            $Item
        }
        & $ScriptPath -Release "14" -Architecture "x64" -Path $TestDrive -VcManifest $ManifestPath
        $UpdatedManifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
        $UpdatedManifest.InstallOrder -join "," | Should -BeExactly "2017,2019,14"
    }
}
