<#
    .SYNOPSIS
        Pester tests for Get-RequiredVcRedistUpdatesFromIntune
#>
[CmdletBinding()]
param ()

InModuleScope VcRedist {
    Describe "Get-RequiredVcRedistUpdatesFromIntune" -Tag "Intune" {
        Context "Basic Functionality" {
            It "Should not throw when called with no parameters" {
                { Get-RequiredVcRedistUpdatesFromIntune -VcList (Get-VcList) } | Should -Not -Throw
            }
            It "Should return an array or $null" {
                $result = Get-RequiredVcRedistUpdatesFromIntune -VcList (Get-VcList)
                ($result -is [System.Array] -or $null -eq $result) | Should -BeTrue
            }
        }
        Context "Parameter validation" {
            It "Should throw when VcList is missing" {
                { Get-RequiredVcRedistUpdatesFromIntune } | Should -Throw
            }
        }
    }
}
