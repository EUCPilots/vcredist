<#
	.SYNOPSIS
		Private Pester function tests. MDT is mocked; no MDT installation is required.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
    Describe -Name "Import-MdtModule" -Tag "MDT" {
        It "Throws when the MDT registry key is missing" {
            Mock Test-Path { $false }
            { Import-MdtModule } | Should -Throw
        }

        It "Surfaces MDT registry read failures" {
            Mock Test-Path { $true }
            Mock Get-ItemProperty { throw [System.UnauthorizedAccessException]::New("Registry access denied") }
            { Import-MdtModule } | Should -Throw
        }

        It "Throws when the MDT registry key returns no properties" {
            Mock Test-Path { $true }
            Mock Get-ItemProperty { $null }
            { Import-MdtModule } | Should -Throw "*Unable to read MDT Registry path properties*"
        }

        It "Throws when the registry key has no Install_Dir property" {
            Mock Test-Path { $true }
            Mock Get-ItemProperty { [PSCustomObject]@{} }
            { Import-MdtModule } | Should -Throw "*Install_Dir*"
        }

        It "Throws when the Install_Dir property is empty" {
            Mock Test-Path { $true }
            Mock Get-ItemProperty { [PSCustomObject]@{ Install_Dir = "" } }
            { Import-MdtModule } | Should -Throw "*Install_Dir*"
        }

        It "Throws when the MDT module file is missing" {
            Mock Test-Path { $true } -ParameterFilter { $LiteralPath -like "HKLM:*" }
            Mock Test-Path { $false } -ParameterFilter { $LiteralPath -notlike "HKLM:*" }
            Mock Get-ItemProperty { [PSCustomObject]@{ Install_Dir = "/mdt" } }
            Mock Resolve-Path { [PSCustomObject]@{ ProviderPath = "/mdt" } }
            { Import-MdtModule } | Should -Throw
            Should -Invoke Test-Path -Times 1 -ParameterFilter {
                $LiteralPath -like "*MicrosoftDeploymentToolkit.psd1" -and $PathType -eq "Leaf"
            }
        }

        It "Returns true when the module imports" {
            Mock Test-Path { $true }
            Mock Get-ItemProperty { [PSCustomObject]@{ Install_Dir = "/mdt" } }
            Mock Resolve-Path { [PSCustomObject]@{ ProviderPath = "/mdt" } }
            Mock Import-Module { }
            Import-MdtModule -Force | Should -BeTrue
            Should -Invoke Import-Module -Times 1 -ParameterFilter { $Force }
        }

        It "Surfaces module import failures" {
            Mock Test-Path { $true }
            Mock Get-ItemProperty { [PSCustomObject]@{ Install_Dir = "/mdt" } }
            Mock Resolve-Path { [PSCustomObject]@{ ProviderPath = "/mdt" } }
            Mock Import-Module { throw [System.InvalidOperationException]::New("Module import failed") }
            { Import-MdtModule } | Should -Throw "*Module import failed*"
        }
    }
}
