<#
	.SYNOPSIS
		Private Pester function tests. MDT cmdlets are stubbed; no MDT installation is required.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
    Describe -Name "New-MdtDrive" {
        BeforeAll {
            function Add-MDTPersistentDrive { param ([Parameter(ValueFromPipeline)] $InputObject) process { $InputObject } }
            function Get-MdtPersistentDrive { }
        }

        BeforeEach {
            Mock New-PSDrive { [PSCustomObject]@{ Name = "DS020" } }
            Mock Add-MDTPersistentDrive { }
            Mock Get-MdtPersistentDrive { [PSCustomObject]@{ Name = "DS020"; Path = "/deploy" } }
        }

        It "Returns the expected MDT drive name" {
            New-MdtDrive -Drive "DS020" -Path "/deploy" | Should -Be "DS020"
        }

        It "Does not map a drive with -WhatIf" {
            New-MdtDrive -Drive "DS020" -Path "/deploy" -WhatIf | Should -BeNullOrEmpty
            Should -Invoke New-PSDrive -Times 0
        }
    }
}
