<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

Describe -Name "Get-VcList" {
    Context "Bundled manifest" {
        It "Returns supported entries by default" {
            $List = Get-VcList -Source "Bundled"
            $List | Should -Not -BeNullOrEmpty
            $List.Count | Should -BeGreaterThan 0
        }

        It "Returns more entries for All than for Supported or Unsupported" {
            $All = @(Get-VcList -Export "All" -Source "Bundled")
            $Supported = @(Get-VcList -Export "Supported" -Source "Bundled")
            $Unsupported = @(Get-VcList -Export "Unsupported" -Source "Bundled")
            $All.Count | Should -Be ($Supported.Count + $Unsupported.Count)
        }

        It "Filters by release and architecture" {
            $List = @(Get-VcList -Release "2022" -Architecture "x64" -Source "Bundled")
            $List | ForEach-Object { $_.Architecture | Should -Be "x64" }
        }

        It "Returns objects with the required properties" {
            $Item = Get-VcList -Export "All" -Source "Bundled" | Select-Object -First 1
            foreach ($Property in "Name", "Version", "URI", "Release", "Architecture", "SilentInstall") {
                $Item.PSObject.Properties.Name | Should -Contain $Property
            }
        }

        It "Replaces the placeholder tokens" {
            Get-VcList -Export "All" -Source "Bundled" | ForEach-Object {
                $_.SilentUninstall | Should -Not -Match "#ProductCode|#Installer"
            }
        }

        It "Rejects an invalid release" {
            { Get-VcList -Release "abc" -Source "Bundled" } | Should -Throw
        }
    }
}
