<#
	.SYNOPSIS
		Verifies the MDT functions emit a deprecation warning. MDT is mocked.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

Describe -Name "MDT functions deprecation" {
    It "<Name> warns that it is deprecated" -ForEach @(
        @{ Name = "Import-VcMdtApplication" }
        @{ Name = "New-VcMdtBundle" }
        @{ Name = "Update-VcMdtApplication" }
        @{ Name = "Update-VcMdtBundle" }
    ) {
        $Function = $Name
        InModuleScope VcRedist -Parameters @{ Function = $Function; Temp = $TestDrive } {
            Mock Test-PSCore { $true }
            $List = Get-VcList -Source "Bundled" | Select-Object -First 1
            $Warnings = @()
            try {
                $params = @{ MdtPath = $Temp; WarningVariable = "Warnings"; WarningAction = "SilentlyContinue"; ErrorAction = "SilentlyContinue" }
                if ($Function -notlike "*Bundle") { $params.VcList = $List }
                & $Function @params
            }
            catch { $null = $_ }
            ($Warnings -join " ") | Should -Match "deprecated"
        }
    }
}
