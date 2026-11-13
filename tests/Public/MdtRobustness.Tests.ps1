<#
    .SYNOPSIS
        Mocked regression tests for MDT function failure and replacement behavior.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This is OK for test files.")]
param ()

InModuleScope VcRedist {
    Describe -Name "Update-VcMdtApplication robustness" {
        BeforeAll {
            function Restore-MDTPersistentDrive { param ([switch] $Force) }
            $VcRedist = Get-VcList -Release "14" -Architecture "x64" -Source "Bundled" | Select-Object -First 1
            $Installer = Join-Path -Path $TestDrive -ChildPath "vc_redist.x64.exe"
            Set-Content -LiteralPath $Installer -Value "installer"
            $VcRedist | Add-Member -MemberType "NoteProperty" -Name "Path" -Value $Installer -Force
            $ExistingApplication = [PSCustomObject]@{
                Name          = "Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) 1.0.0.0"
                ShortName     = "$($VcRedist.Name) $($VcRedist.Architecture)"
                Version       = "1.0.0.0"
                UninstallKey  = "old-product-code"
                CommandLine   = "old-command"
                Source        = "old-source"
                WorkingDirectory = "old-working-directory"
                PSPath        = "DS099:\Applications\VcRedists\existing"
            }
        }

        BeforeEach {
            Mock Test-PSCore { $false }
            Mock Import-MdtModule { $true }
            Mock New-MdtDrive { }
            Mock Restore-MDTPersistentDrive { }
            Mock Get-ChildItem { $ExistingApplication }
            Mock Test-Path { $true } -ParameterFilter { $Path -like "*\Applications\VcRedists" }
            Mock Set-ItemProperty { }
        }

        It "Finds the imported application by its exact short name and uses robocopy's argument order" {
            Mock Invoke-Process { }

            Update-VcMdtApplication -VcList $VcRedist -MdtPath $TestDrive -WarningAction "SilentlyContinue"

            Should -Invoke Invoke-Process -Times 1 -ParameterFilter {
                $ArgumentList.Count -ge 4 -and
                    $ArgumentList[0] -and
                    $ArgumentList[1] -and
                    $ArgumentList[2] -eq "*.exe" -and
                    $ArgumentList[3] -eq "/S"
            }
            Should -Invoke Set-ItemProperty -Times 1
        }

        It "Propagates a copy failure even if a destination installer already exists" {
            Mock Invoke-Process { throw "robocopy failed" }
            Mock Test-Path { $true }

            { Update-VcMdtApplication -VcList $VcRedist -MdtPath $TestDrive -WarningAction "SilentlyContinue" } |
                Should -Throw "*robocopy failed*"
        }
    }

    Describe -Name "Import-VcMdtApplication force replacement" {
        BeforeAll {
            function Restore-MDTPersistentDrive { param ([switch] $Force) }
            function Import-MDTApplication {
                param ($Path, $Name, $Enable, $Reboot, $Hide, $Comments, $ShortName, $Version, $Publisher,
                    $Language, $CommandLine, $ApplicationSourcePath, $DestinationFolder, $WorkingDirectory,
                    $UninstallKey, $SupportedPlatform)
            }
            $VcRedist = Get-VcList -Release "14" -Architecture "x64" -Source "Bundled" | Select-Object -First 1
            $Installer = Join-Path -Path $TestDrive -ChildPath "vc_redist.x64.exe"
            Set-Content -LiteralPath $Installer -Value "installer"
            $VcRedist | Add-Member -MemberType "NoteProperty" -Name "Path" -Value $Installer -Force
            $ApplicationName = "Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)"
            $ExistingApplication = [PSCustomObject]@{
                Name         = $ApplicationName
                UninstallKey = "different-product-code"
            }
            $State = [PSCustomObject]@{ ApplicationExists = $true }
        }

        BeforeEach {
            Mock Test-PSCore { $false }
            Mock Import-MdtModule { $true }
            Mock New-MdtDrive { }
            Mock Restore-MDTPersistentDrive { }
            Mock New-MdtApplicationFolder { }
            Mock Get-ChildItem { $ExistingApplication }
            Mock Test-Path {
                if ($Path -eq $TestDrive) { return $true }
                if ($Path -like "*Visual C++*") { return $State.ApplicationExists }
                return $false
            }
            Mock Remove-Item { $State.ApplicationExists = $false }
            Mock Import-MDTApplication { }
        }

        It "Replaces an exact-name application when its uninstall key has changed" {
            Import-VcMdtApplication -VcList $VcRedist -MdtPath $TestDrive -Force -WarningAction "SilentlyContinue" |
                Out-Null

            Should -Invoke Remove-Item -Times 1
            Should -Invoke Import-MDTApplication -Times 1
        }
    }

    Describe -Name "New-VcMdtBundle robustness" {
        BeforeAll {
            function Restore-MDTPersistentDrive { param ([switch] $Force) }
            function Import-MDTApplication {
                param ($Path, $Name, $Enable, $Reboot, $Hide, $Comments, $ShortName, $Version, $Publisher,
                    $Language, $Dependency, $Bundle, $ErrorAction)
            }
            $Application = [PSCustomObject]@{
                Name    = "Visual C++ Redistributable 2019 x64"
                Version = "14.0.1.0"
                guid    = "app-guid"
            }
            $OldBundle = [PSCustomObject]@{
                Name    = "Microsoft Visual C++ Redistributables"
                Version = "11/13/2026"
                guid    = "old-bundle-guid"
            }
            $State = [PSCustomObject]@{
                BundleExists = $true
                BackupExists = $false
                ThrowOnImport = $false
            }
        }

        BeforeEach {
            $Apps = @($Application, $OldBundle)
            $State.BundleExists = $true
            $State.BackupExists = $false
            $State.ThrowOnImport = $false

            Mock Test-PSCore { $false }
            Mock Import-MdtModule { $true }
            Mock New-MdtDrive { }
            Mock Restore-MDTPersistentDrive { }
            Mock Get-ChildItem {
                if ($Path -like "*\Applications\VcRedists") { return $Apps }
                return @()
            }
            Mock Test-Path {
                if ($Path -eq $TestDrive) { return $true }
                if ($Path -like "*\Applications\VcRedists") { return $true }
                if ($Path -like "*\Microsoft Visual C++ Redistributables") { return $State.BundleExists }
                return $false
            }
            Mock Rename-Item {
                if ($NewName -like "VcRedistBundleBackup_*") {
                    $State.BundleExists = $false
                    $State.BackupExists = $true
                }
                else {
                    $State.BundleExists = $true
                    $State.BackupExists = $false
                }
            }
            Mock Remove-Item {
                if ($Path -like "*VcRedistBundleBackup_*") { $State.BackupExists = $false }
                else { $State.BundleExists = $false }
            }
            Mock Import-MDTApplication {
                if ($State.ThrowOnImport) { throw "bundle import failed" }
                $State.BundleExists = $true
            }
        }

        It "Excludes the old bundle from dependencies and keeps it until replacement import succeeds" {
            New-VcMdtBundle -MdtPath $TestDrive -Force -WarningAction "SilentlyContinue" | Out-Null

            Should -Invoke Import-MDTApplication -Times 1 -ParameterFilter {
                $Dependency.Count -eq 1 -and $Dependency[0] -eq "app-guid"
            }
            Should -Invoke Rename-Item -Times 1
            Should -Invoke Remove-Item -Times 1
            $State.BackupExists | Should -BeFalse
        }

        It "Restores the existing bundle if replacement import fails" {
            $State.ThrowOnImport = $true

            { New-VcMdtBundle -MdtPath $TestDrive -Force -WarningAction "SilentlyContinue" } |
                Should -Throw "*bundle import failed*"

            Should -Invoke Rename-Item -Times 2
            $State.BundleExists | Should -BeTrue
            $State.BackupExists | Should -BeFalse
        }

        It "Does not enumerate a bundle path that was not created" {
            $State.BundleExists = $false

            { New-VcMdtBundle -MdtPath $TestDrive -WarningAction "SilentlyContinue" | Out-Null } |
                Should -Not -Throw

            Should -Invoke Get-ChildItem -Times 1
        }
    }
}
