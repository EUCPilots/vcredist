<#
	.SYNOPSIS
		Private Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
    Describe -Name "Get-IntuneRequirementArchitecture" {
        It "Maps <Label> to <Expected>" -ForEach @(
            @{ Label = "x86"; Supported = @("x86"); Expected = "x86" }
            @{ Label = "AMD64"; Supported = @("AMD64"); Expected = "x64" }
            @{ Label = "ARM64"; Supported = @("ARM64"); Expected = "arm64" }
            @{ Label = "x86 and AMD64"; Supported = @("x86", "AMD64"); Expected = "x64x86" }
            @{ Label = "all"; Supported = @("ARM64", "AMD64", "x86"); Expected = "AllWithARM64" }
        ) {
            Get-IntuneRequirementArchitecture -SupportedArchitecture $Supported | Should -Be $Expected
        }

        It "Rejects combinations IntuneWin32App cannot represent" -ForEach @(
            @{ Supported = @("x86", "ARM64") }
            @{ Supported = @("AMD64", "ARM64") }
        ) {
            { Get-IntuneRequirementArchitecture -SupportedArchitecture $Supported } | Should -Throw "*cannot represent*"
        }

        It "Throws for an unsupported architecture" {
            { Get-IntuneRequirementArchitecture -SupportedArchitecture @("ia64") } | Should -Throw
        }
    }
}
