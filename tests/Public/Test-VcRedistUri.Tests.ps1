<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

Describe -Name "Test-VcRedistUri" {
    It "Passes a Microsoft HTTPS URI when the request succeeds" {
        InModuleScope VcRedist {
            Mock Invoke-VcWebRequest { [PSCustomObject]@{ StatusCode = 200 } }
            $List = Get-VcList -Source "Bundled" | Select-Object -First 1
            { $List | Test-VcRedistUri } | Should -Not -Throw
            Should -Invoke Invoke-VcWebRequest -Times 1
        }
    }

    It "Returns a false Result when the request fails" {
        InModuleScope VcRedist {
            Mock Invoke-VcWebRequest { throw "404" }
            $List = Get-VcList -Source "Bundled" | Select-Object -First 1
            ($List | Test-VcRedistUri).Result | Should -BeFalse
        }
    }
}
