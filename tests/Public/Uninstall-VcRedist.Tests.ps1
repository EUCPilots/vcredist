<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

BeforeDiscovery {
    $SupportedReleases = @("14")

    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
        $SkipAmd = $false
    }
    else {
        $SkipAmd = $true
    }
    if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
        $SkipArm = $false
    }
    else {
        $SkipArm = $true
    }
}

Describe -Name "AMD64 specific tests" -Skip:$SkipAmd {
    Describe -Name "Uninstall-VcRedist" -ForEach $SupportedReleases {
        BeforeAll {
            $Release = $_

            # Create download path
            if ($env:Temp) {
                $Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
            }
            elseif ($env:TMPDIR) {
                $Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
            }
            elseif ($env:RUNNER_TEMP) {
                $Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
            }
            New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null

            $VcList = Get-VcList -Release $Release -Architecture @("x86", "x64") | Save-VcRedist -Path $Path
            Install-VcRedist -VcList $VcList -Silent | Out-Null
        }

        Context "Uninstall VcRedist <Release>" {
            It "Uninstalls the VcRedist <Release> x86" {
                $Results = @(Uninstall-VcRedist -Release $Release -Architecture "x86" -Confirm:$false)

                $Results | Should -Not -BeNullOrEmpty
                $Results | ForEach-Object {
                    $_.Release | Should -Be $Release
                    $_.Architecture | Should -Be "x86"
                    $_.State | Should -Be "Uninstalled"
                }
            }

            It "Uninstalls the VcRedist <Release> x64" {
                $Results = @(Uninstall-VcRedist -Release $Release -Architecture "x64" -Confirm:$false)

                $Results | Should -Not -BeNullOrEmpty
                $Results | ForEach-Object {
                    $_.Release | Should -Be $Release
                    $_.Architecture | Should -Be "x64"
                    $_.State | Should -Be "Uninstalled"
                }
            }
        }
    }

    Describe -Name "Uninstall VcRedist via the pipeline" -ForEach $SupportedReleases {
        BeforeAll {
            $Release = $_

            # Create download path
            if ($env:Temp) {
                $Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
            }
            elseif ($env:TMPDIR) {
                $Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
            }
            elseif ($env:RUNNER_TEMP) {
                $Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
            }
            New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null

            $VcList = Get-VcList -Release $Release -Architecture @("x86", "x64") | Save-VcRedist -Path $Path
            Install-VcRedist -VcList $VcList -Silent | Out-Null
        }

        Context "Test uninstall via the pipeline" {
            It "Reports the state of each Redistributable passed via the pipeline" {
                $InstalledProductCodes = @(Get-InstalledVcRedist | ForEach-Object { $_.ProductCode })
                $Results = @($VcList | Uninstall-VcRedist -Confirm:$false)

                $Results.Count | Should -Be @($VcList).Count
                foreach ($VcRedist in $VcList) {
                    $MatchingResults = @($Results | Where-Object {
                            $_.Release -eq $VcRedist.Release -and $_.Architecture -eq $VcRedist.Architecture
                        })
                    $MatchingResults.Count | Should -Be 1
                    if ($InstalledProductCodes -contains $VcRedist.ProductCode) {
                        $MatchingResults[0].State | Should -Be "Uninstalled"
                    }
                    else {
                        $MatchingResults[0].State | Should -Be "Not installed"
                    }
                }
            }
        }
    }
}

Describe -Name "ARM64 specific tests" -Skip:$SkipArm {
    Describe -Name "Uninstall-VcRedist" -ForEach $SupportedReleases {
        BeforeAll {
            $Release = $_

            # Create download path
            if ($env:Temp) {
                $Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
            }
            elseif ($env:TMPDIR) {
                $Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
            }
            elseif ($env:RUNNER_TEMP) {
                $Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
            }
            New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null

            $VcList = Get-VcList -Release $Release -Architecture @("x86", "arm64") | Save-VcRedist -Path $Path
            Install-VcRedist -VcList $VcList -Silent | Out-Null
        }

        Context "Uninstall VcRedist <Release>" {
            It "Uninstalls the VcRedist <Release> x86" {
                $Results = @(Uninstall-VcRedist -Release $Release -Architecture "x86" -Confirm:$false)

                $Results | Should -Not -BeNullOrEmpty
                $Results | ForEach-Object {
                    $_.Release | Should -Be $Release
                    $_.Architecture | Should -Be "x86"
                    $_.State | Should -Be "Uninstalled"
                }
            }

            It "Uninstalls the VcRedist 2022 arm64" {
                $Results = @(Uninstall-VcRedist -Release "2022" -Architecture "arm64" -Confirm:$false)

                $Results | Should -Not -BeNullOrEmpty
                $Results | ForEach-Object {
                    $_.Release | Should -Be "2022"
                    $_.Architecture | Should -Be "arm64"
                    $_.State | Should -Be "Uninstalled"
                }
            }
        }
    }

    Describe -Name "Uninstall VcRedist via the pipeline" -ForEach $SupportedReleases {
        BeforeAll {
            $Release = $_

            # Create download path
            if ($env:Temp) {
                $Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
            }
            elseif ($env:TMPDIR) {
                $Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
            }
            elseif ($env:RUNNER_TEMP) {
                $Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
            }
            New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null

            $VcList = Get-VcList -Release $Release -Architecture @("x86") | Save-VcRedist -Path $Path
            Install-VcRedist -VcList $VcList -Silent | Out-Null
        }

        Context "Test uninstall via the pipeline" {
            It "Reports the state of each Redistributable passed via the pipeline" {
                $InstalledProductCodes = @(Get-InstalledVcRedist | ForEach-Object { $_.ProductCode })
                $Results = @($VcList | Uninstall-VcRedist -Confirm:$false)

                $Results.Count | Should -Be @($VcList).Count
                foreach ($VcRedist in $VcList) {
                    $MatchingResults = @($Results | Where-Object {
                            $_.Release -eq $VcRedist.Release -and $_.Architecture -eq $VcRedist.Architecture
                        })
                    $MatchingResults.Count | Should -Be 1
                    if ($InstalledProductCodes -contains $VcRedist.ProductCode) {
                        $MatchingResults[0].State | Should -Be "Uninstalled"
                    }
                    else {
                        $MatchingResults[0].State | Should -Be "Not installed"
                    }
                }
            }
        }
    }
}
