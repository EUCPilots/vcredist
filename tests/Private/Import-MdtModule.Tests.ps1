<#
	.SYNOPSIS
		Private Pester function tests. MDT is mocked; no MDT installation is required.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
    Describe -Name "Import-MdtModule" {
        It "Throws when the MDT registry key is missing" {
            Mock Test-Path { $false }
            { Import-MdtModule } | Should -Throw
        }

        It "Throws when the MDT module file is missing" {
            Mock Test-Path { $true } -ParameterFilter { $Path -like "HKLM:*" }
            Mock Test-Path { $false } -ParameterFilter { $Path -notlike "HKLM:*" }
            Mock Get-ItemProperty { [PSCustomObject]@{ Install_Dir = "/mdt" } }
            Mock Resolve-Path { "/mdt" }
            { Import-MdtModule } | Should -Throw
        }

        It "Returns true when the module imports" {
            Mock Test-Path { $true }
            Mock Get-ItemProperty { [PSCustomObject]@{ Install_Dir = "/mdt" } }
            Mock Resolve-Path { "/mdt" }
            Mock Import-Module { }
            Import-MdtModule -Force | Should -BeTrue
            Should -Invoke Import-Module -Times 1
        }
    }
}
