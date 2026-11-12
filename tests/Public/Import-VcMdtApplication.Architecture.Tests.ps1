InModuleScope VcRedist {
    Describe "Import-VcMdtApplication architecture requirements" {
        BeforeAll {
            function Restore-MDTPersistentDrive { param ([switch] $Force) }
            function Import-MDTApplication {
                param ($Path, $Name, $Enable, $Reboot, $Hide, $Comments, $ShortName, $Version, $Publisher,
                    $Language, $CommandLine, $ApplicationSourcePath, $DestinationFolder, $WorkingDirectory,
                    $UninstallKey, $SupportedPlatform)
            }
            $Items = @(Get-VcList -Release "14" -Source "Bundled")
            foreach ($Item in $Items) {
                $Item | Add-Member -NotePropertyName "Path" -NotePropertyValue (Join-Path $TestDrive "vc.exe")
            }
        }
        BeforeEach {
            Mock Test-PSCore { $false }
            Mock Import-MdtModule { $true }
            Mock New-MdtDrive { }
            Mock Restore-MDTPersistentDrive { }
            Mock New-MdtApplicationFolder { }
            Mock Get-ChildItem { }
            Mock Test-Path { $false } -ParameterFilter { $Path -like "*Visual C++*" }
            Mock Import-MDTApplication { }
        }
        It "Uses AMD64 platform restrictions from the manifest" {
            $Item = $Items | Where-Object { $_.Architecture -eq "x64" }
            Import-VcMdtApplication -VcList $Item -MdtPath $TestDrive -WarningAction "SilentlyContinue" | Out-Null
            Should -Invoke Import-MDTApplication -Times 1 -ParameterFilter {
                $SupportedPlatform -contains "All x64 Windows 10 Client" -and $SupportedPlatform -contains "All x64 Windows Server 10"
            }
        }
        It "Leaves x86 and AMD64 compatible applications unrestricted" {
            $Item = $Items | Where-Object { $_.Architecture -eq "x86" }
            Import-VcMdtApplication -VcList $Item -MdtPath $TestDrive -WarningAction "SilentlyContinue" | Out-Null
            Should -Invoke Import-MDTApplication -Times 1 -ParameterFilter { $null -eq $SupportedPlatform }
        }
        It "Skips ARM64-only packages with a warning" {
            $Item = $Items | Where-Object { $_.Architecture -eq "arm64" }
            Import-VcMdtApplication -VcList $Item -MdtPath $TestDrive -WarningVariable "W" -WarningAction "SilentlyContinue" | Out-Null
            ($W -join " ") | Should -Match "Skipping.*ARM64"
            Should -Invoke Import-MDTApplication -Times 0
        }
    }
}
