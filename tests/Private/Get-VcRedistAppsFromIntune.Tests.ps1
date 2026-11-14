<#
    .SYNOPSIS
        Pester tests for Intune application matching and pipeline handling.
#>
[CmdletBinding()]
param ()

InModuleScope VcRedist {
    Describe "Get-VcRedistAppsFromIntune" -Tag "Intune" {
        BeforeAll {
            function Get-IntuneWin32App { }
            $Redist = Get-VcList -Source "Bundled" -Release "14" -Architecture "x64" -WarningAction "SilentlyContinue" |
                Select-Object -First 1
        }

        BeforeEach {
            $script:IntuneApps = @()
            Mock Get-IntuneWin32App { $script:IntuneApps }
        }

        It "Matches VcRedist metadata regardless of JSON property order" {
            $Notes = [PSCustomObject]@{
                "Guid"      = $Redist.PackageId
                "Date"      = "2026-01-01"
                "CreatedBy" = "VcRedist"
            } | ConvertTo-Json -Compress
            $script:IntuneApps = @([PSCustomObject]@{
                    Id             = "app-id"
                    Publisher      = "Microsoft"
                    displayName    = "Microsoft $($Redist.Name) $($Redist.Version) $($Redist.Architecture)"
                    displayVersion = $Redist.Version
                    notes          = $Notes
                })

            $Result = @(Get-VcRedistAppsFromIntune -VcList $Redist)

            $Result.Count | Should -Be 1
            $Result[0].packageId | Should -Be $Redist.PackageId
        }

        It "Warns and skips malformed notes instead of aborting the lookup" {
            $script:IntuneApps = @([PSCustomObject]@{
                    Id             = "app-id"
                    Publisher      = "Microsoft"
                    displayName    = "Microsoft $($Redist.Name) $($Redist.Version) $($Redist.Architecture)"
                    displayVersion = $Redist.Version
                    notes          = "{"
                })

            { Get-VcRedistAppsFromIntune -VcList $Redist -WarningAction "SilentlyContinue" } | Should -Not -Throw
            @(Get-VcRedistAppsFromIntune -VcList $Redist -WarningAction "SilentlyContinue").Count | Should -Be 0
        }

        It "Does not match an app with the right notes but the wrong publisher or product identity" {
            $Notes = [PSCustomObject]@{
                "CreatedBy" = "VcRedist"
                "Guid"      = $Redist.PackageId
                "Date"      = "2026-01-01"
            } | ConvertTo-Json -Compress
            $script:IntuneApps = @(
                [PSCustomObject]@{
                    Id             = "wrong-publisher"
                    Publisher      = "Other"
                    displayName    = "Microsoft $($Redist.Name) $($Redist.Version) $($Redist.Architecture)"
                    displayVersion = $Redist.Version
                    notes          = $Notes
                }
                [PSCustomObject]@{
                    Id             = "wrong-name"
                    Publisher      = "Microsoft"
                    displayName    = "Microsoft Unrelated Product $($Redist.Version) $($Redist.Architecture)"
                    displayVersion = $Redist.Version
                    notes          = $Notes
                }
            )

            @(Get-VcRedistAppsFromIntune -VcList $Redist).Count | Should -Be 0
        }
    }

    Describe "Intune functions with pipeline input" -Tag "Intune" {
        BeforeAll {
            function Remove-IntuneWin32App { param ($Id) }
            $Redist = Get-VcList -Source "Bundled" -Release "14" -Architecture "x64" -WarningAction "SilentlyContinue" |
                Select-Object -First 1
        }

        BeforeEach {
            $script:RedistA = $Redist.PSObject.Copy()
            $script:RedistB = $Redist.PSObject.Copy()
            $script:RedistB.PackageId = [System.Guid]::NewGuid().Guid
            $script:RemovedIds = @()
            Mock Get-VcRedistAppsFromIntune {
                [PSCustomObject]@{
                    Id             = "app-$($VcList.PackageId)"
                    packageId      = $VcList.PackageId
                    displayName    = "VcRedist application"
                    displayVersion = $VcList.Version
                }
            }
            Mock Remove-IntuneWin32App { $script:RemovedIds += $Id }
        }

        It "Looks up and removes each piped package" {
            @($RedistA, $RedistB) | Remove-VcIntuneApplication -Confirm:$false

            Should -Invoke Get-VcRedistAppsFromIntune -Times 2
            Should -Invoke Remove-IntuneWin32App -Times 2
            $script:RemovedIds.Count | Should -Be 2
            $script:RemovedIds | Should -Contain "app-$($RedistA.PackageId)"
            $script:RemovedIds | Should -Contain "app-$($RedistB.PackageId)"
        }

        It "Does not remove Intune apps with WhatIf" {
            @($RedistA, $RedistB) | Remove-VcIntuneApplication -WhatIf

            Should -Invoke Get-VcRedistAppsFromIntune -Times 2
            Should -Invoke Remove-IntuneWin32App -Times 0
        }

        It "Checks each piped package for required updates" {
            $Results = @($RedistA, $RedistB) | Get-RequiredVcRedistUpdatesFromIntune

            $Results.Count | Should -Be 2
            Should -Invoke Get-VcRedistAppsFromIntune -Times 2
        }
    }
}
