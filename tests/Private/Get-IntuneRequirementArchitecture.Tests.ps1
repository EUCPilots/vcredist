<#
	.SYNOPSIS
		Private Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
    Describe -Name "Get-IntuneRequirementArchitecture" {
        It "Maps <Architecture> to <Expected>" -ForEach @(
            @{ Architecture = "x86"; Expected = "x64x86" }
            @{ Architecture = "x64"; Expected = "x64" }
            @{ Architecture = "ARM64"; Expected = "arm64" }
        ) {
            Get-IntuneRequirementArchitecture -Architecture $Architecture | Should -Be $Expected
        }

        It "Throws for an unsupported architecture" {
            { Get-IntuneRequirementArchitecture -Architecture "ia64" } | Should -Throw
        }

        It "Never returns the invalid value All" {
            foreach ($Architecture in "x86", "x64", "ARM64") {
                Get-IntuneRequirementArchitecture -Architecture $Architecture | Should -Not -Be "All"
            }
        }
    }
}
