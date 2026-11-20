<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

Describe -Name "Get-VcList" {
    Context "Bundled manifest" {
        It "Returns supported entries by default" {
            $List = @(Get-VcList -Source "Bundled")
            $List | Should -Not -BeNullOrEmpty
            $List.Count | Should -BeGreaterThan 0
            $List | ForEach-Object { $_.Supported | Should -BeTrue }
        }

        InModuleScope VcRedist {
            Describe "Get-VcList unsupported release warnings" {
                BeforeEach {
                    Mock Get-VcManifest {
                        [PSCustomObject]@{
                            Entries = @(
                                [PSCustomObject]@{ Name = "Supported"; Release = "2013"; Architecture = "x86"; Supported = $true; URI = "https://example.com/a.exe"; SilentUninstall = "#Installer"; ProductCode = "a" }
                                [PSCustomObject]@{ Name = "Unsupported 1"; Release = "2015"; Architecture = "x86"; Supported = $false; URI = "https://example.com/b.exe"; SilentUninstall = "#Installer"; ProductCode = "b" }
                                [PSCustomObject]@{ Name = "Unsupported 2"; Release = "2015"; Architecture = "x86"; Supported = $false; URI = "https://example.com/c.exe"; SilentUninstall = "#Installer"; ProductCode = "c" }
                                [PSCustomObject]@{ Name = "Supported x64"; Release = "2015"; Architecture = "x64"; Supported = $true; URI = "https://example.com/d.exe"; SilentUninstall = "#Installer"; ProductCode = "d" }
                            )
                        }
                    }
                }

                It "Warns once while returning supported and unsupported matches" {
                    $Results = @(Get-VcList -Release @("2013", "2015") -Architecture "x86" -Source "Bundled" -WarningVariable "Warnings" -WarningAction "SilentlyContinue")

                    $Results.Count | Should -Be 3
                    @($Results | Where-Object { $_.Supported -eq $false }).Count | Should -Be 2
                    @($Warnings).Count | Should -Be 1
                    $Warnings[0].Message | Should -Be "This list includes unsupported Visual C++ Redistributables."
                }

                It "Does not warn for supported matches when unsupported entries are filtered out" {
                    $Results = @(Get-VcList -Release "2015" -Architecture "x64" -Source "Bundled" -WarningVariable "Warnings" -WarningAction "SilentlyContinue")

                    $Results.Count | Should -Be 1
                    $Results[0].Supported | Should -BeTrue
                    $Warnings | Should -BeNullOrEmpty
                }

                It "Does not warn when there are no matches" {
                    $Results = @(Get-VcList -Release "2099" -Source "Bundled" -WarningVariable "Warnings" -WarningAction "SilentlyContinue")

                    $Results.Count | Should -Be 0
                    $Warnings | Should -BeNullOrEmpty
                }
            }
        }

        It "Returns more entries for All than for Supported or Unsupported" {
            $All = @(Get-VcList -Export "All" -Source "Bundled" -WarningAction "SilentlyContinue")
            $Supported = @(Get-VcList -Export "Supported" -Source "Bundled")
            $Unsupported = @(Get-VcList -Export "Unsupported" -Source "Bundled" -WarningAction "SilentlyContinue")
            $All.Count | Should -Be ($Supported.Count + $Unsupported.Count)
            $Supported | ForEach-Object { $_.Supported | Should -BeTrue }
            $Unsupported | ForEach-Object { $_.Supported | Should -BeFalse }
        }

        It "Filters by release and architecture" {
            $List = @(Get-VcList -Release "2019" -Architecture "x64" -Source "Bundled")
            $List | Should -Not -BeNullOrEmpty
            $List | ForEach-Object {
                $_.Release | Should -Be "2019"
                $_.Architecture | Should -Be "x64"
                $_.Supported | Should -BeTrue
            }
        }

        It "Reports the active filters and selected entries with Verbose" {
            $Records = @(Get-VcList -Release "14" -Architecture "x64" -Source "Bundled" -Verbose 4>&1)
            $List = @($Records | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] })
            $Messages = @($Records | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] })

            ($Messages.Message -join "`n") | Should -Match "release '14' and architecture 'x64'"
            ($Messages.Message -join "`n") | Should -Match "Selected $($List.Count) Visual C\+\+ Redistributables\."
            foreach ($Item in $List) {
                ($Messages.Message -join "`n") | Should -Match ([System.Text.RegularExpressions.Regex]::Escape("Preparing: '$($Item.Name) $($Item.Version) $($Item.Architecture)' (release $($Item.Release))."))
            }
        }

        It "Reports zero selected entries with Verbose" {
            $Records = @(Get-VcList -Release "2099" -Source "Bundled" -Verbose 4>&1)
            $List = @($Records | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] })
            $Messages = @($Records | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] })

            $List.Count | Should -Be 0
            ($Messages.Message -join "`n") | Should -Match "Selected 0 Visual C\+\+ Redistributables\."
        }

        It "Reports the selected export mode with Verbose" {
            $Records = @(Get-VcList -Export "Unsupported" -Source "Bundled" -WarningAction "SilentlyContinue" -Verbose 4>&1)
            $List = @($Records | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] })
            $Messages = @($Records | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] })

            ($Messages.Message -join "`n") | Should -Match "export mode 'Unsupported'"
            ($Messages.Message -join "`n") | Should -Match "Selected $($List.Count) Visual C\+\+ Redistributables\."
        }

        It "Returns objects with the required properties" {
            $Item = Get-VcList -Export "All" -Source "Bundled" -WarningAction "SilentlyContinue" | Select-Object -First 1
            foreach ($Property in "Name", "ProductCode", "Version", "URI", "Release", "Architecture",
                "Install", "SilentInstall", "SilentUninstall", "SupportedArchitecture", "UninstallKey",
                "PackageId", "DetectionFile", "Supported") {
                $Item.PSObject.Properties.Name | Should -Contain $Property
            }
        }

        It "Replaces the placeholder tokens" {
            Get-VcList -Export "All" -Source "Bundled" -WarningAction "SilentlyContinue" | ForEach-Object {
                $_.SilentUninstall | Should -Not -Match "#ProductCode|#Installer"
            }
        }

        It "Uses the URI filename literally and ignores its query string" {
            InModuleScope VcRedist {
                Mock Get-VcManifest {
                    [PSCustomObject]@{
                        Entries = @(
                            [PSCustomObject]@{
                                Name            = "Test"
                                Supported       = $true
                                Release         = "2022"
                                Architecture    = "x64"
                                URI             = 'https://download.microsoft.com/vc_redist%241.exe?token=$1'
                                SilentUninstall = "start #Installer code #ProductCode"
                                ProductCode     = '$2'
                            }
                        )
                    }
                }

                $Item = Get-VcList -Release "2022" -Architecture "x64" -Source "Bundled"
                $Item.SilentUninstall | Should -Be 'start vc_redist$1.exe code $2'
            }
        }

        It "Rejects an invalid release" {
            { Get-VcList -Release "abc" -Source "Bundled" } | Should -Throw
        }

        It "Rejects empty release and architecture filters" {
            { Get-VcList -Release @() -Source "Bundled" } | Should -Throw
            { Get-VcList -Architecture @() -Source "Bundled" } | Should -Throw
        }

        It "Rejects an invalid architecture" {
            { Get-VcList -Architecture "invalid" -Source "Bundled" } | Should -Throw
        }
    }

    Context "Remote manifest" {
        It "Returns entries from the selected remote manifest" {
            InModuleScope VcRedist {
                Mock Invoke-VcWebRequest {
                    $Content = [ordered]@{
                        SchemaVersion = "1.0"
                        Updated       = "2099-01-01T00:00:00Z"
                        Entries       = @(
                            [ordered]@{
                                Name                  = "Remote test"
                                ProductCode           = "{00000000-0000-0000-0000-000000000001}"
                                Version               = "14.0.1.0"
                                URI                   = "https://download.microsoft.com/vc_redist.x64.exe"
                                Release               = "2022"
                                Architecture          = "x64"
                                Install               = "/install"
                                SilentInstall         = "/install /quiet"
                                SilentUninstall       = "uninstall"
                                SupportedArchitecture = @("AMD64")
                                UninstallKey          = "64"
                                PackageId             = "remote-test"
                                DetectionFile         = "vc_redist.x64.exe"
                                Supported             = $true
                            }
                        )
                    } | ConvertTo-Json -Depth 5
                    [PSCustomObject]@{ Content = $Content }
                }

                $List = @(Get-VcList -Release "2022" -Architecture "x64" -Source "Remote")
                $List.Count | Should -Be 1
                $List[0].Name | Should -Be "Remote test"
                Should -Invoke Invoke-VcWebRequest -Times 1 -Exactly
            }
        }

        It "Falls back to the bundled manifest when Auto cannot retrieve the remote manifest" {
            InModuleScope VcRedist {
                Mock Invoke-VcWebRequest { throw "network down" }

                $Expected = @(Get-VcList -Source "Bundled")
                $Actual = @(Get-VcList -WarningAction "SilentlyContinue")

                $Actual.Count | Should -Be $Expected.Count
                (Compare-Object -ReferenceObject $Expected.Name -DifferenceObject $Actual.Name) |
                    Should -BeNullOrEmpty
                Should -Invoke Invoke-VcWebRequest -Times 1 -Exactly
            }
        }

        It "Throws when the explicitly selected remote manifest is invalid" {
            InModuleScope VcRedist {
                Mock Invoke-VcWebRequest {
                    [PSCustomObject]@{ Content = "not json" }
                }

                { Get-VcList -Source "Remote" } | Should -Throw
                Should -Invoke Invoke-VcWebRequest -Times 1 -Exactly
            }
        }
    }
}
