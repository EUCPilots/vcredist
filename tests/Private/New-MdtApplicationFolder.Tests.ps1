<#
	.SYNOPSIS
		Private Pester function tests. File system calls are mocked; no MDT installation is required.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
    Describe -Name "New-MdtApplicationFolder" {
        It "Returns true without creating a folder that exists" {
            Mock Test-Path { $true }
            Mock New-Item { }
            New-MdtApplicationFolder -Drive "DS020" -Name "VcRedists" | Should -BeTrue
            Should -Invoke New-Item -Times 0
        }

        It "Creates a folder that does not exist" {
            # MDT provider parameters such as -Enable come from the provider.
            function New-Item { param ($Path, $Enable, $Name, $ItemType) }
            Mock Test-Path { $false }
            Mock New-Item { }
            New-MdtApplicationFolder -Drive "DS020" -Name "VcRedists" | Should -BeTrue
            Should -Invoke New-Item -Times 1
        }
    }
}
