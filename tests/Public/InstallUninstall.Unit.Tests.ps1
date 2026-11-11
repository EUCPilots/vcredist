<#
	.SYNOPSIS
		Mocked exit-code tests for Install-VcRedist and Uninstall-VcRedist. No installers are run.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
    Describe -Name "Install-VcRedist exit codes" {
        BeforeAll {
            $Installer = Join-Path -Path $TestDrive -ChildPath "vc_redist.exe"
            Set-Content -LiteralPath $Installer -Value "x"
            $Item = [PSCustomObject]@{
                Name = "VC"; Release = "14"; Version = "14.0.0.1"; Architecture = "x64"; ProductCode = "{11111111-1111-1111-1111-111111111111}"
                URI = "https://download.microsoft.com/vc.exe"; Install = "/install"; SilentInstall = "/quiet"; SilentUninstall = "x"
                UninstallKey = "64"; PackageId = "x"; DetectionFile = "x"; Path = $Installer
            }
        }

        BeforeEach {
            Mock Test-Elevated { $true }
            Mock Get-InstalledVcRedist { @() }
            Mock Get-Bitness { "x64" }
            Mock Assert-VcSignature { $true }
            Mock Test-VcListObject { $true }
        }

        It "Treats exit code <Code> as success" -ForEach @(@{ Code = 0 }, @{ Code = 1638 }) {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = $Code } }
            { $Item | Install-VcRedist -Silent -ErrorAction "Stop" | Out-Null } | Should -Not -Throw
            Should -Invoke Start-Process -Times 1
        }

        It "Warns that a restart is required for exit code <Code>" -ForEach @(@{ Code = 3010 }, @{ Code = 1641 }) {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = $Code } }
            $Item | Install-VcRedist -Silent -WarningVariable "W" -WarningAction "SilentlyContinue" | Out-Null
            ($W -join " ") | Should -Match "restart"
        }

        It "Writes an error for a failing exit code" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 1603 } }
            { $Item | Install-VcRedist -Silent -ErrorAction "Stop" | Out-Null } | Should -Throw "*1603*"
        }

        It "Does not start the installer when the signature is invalid" {
            Mock Assert-VcSignature { throw "Invalid signature" }
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            { $Item | Install-VcRedist -Silent | Out-Null } | Should -Throw
            Should -Invoke Start-Process -Times 0
        }

        It "Throws when not elevated" {
            Mock Test-Elevated { $false }
            { $Item | Install-VcRedist | Out-Null } | Should -Throw
        }
    }

    Describe -Name "Uninstall-VcRedist exit codes" {
        BeforeAll {
            $Item = [PSCustomObject]@{
                Name = "VC"; Release = "14"; Version = "14.0.0.1"; Architecture = "x64"; ProductCode = "{11111111-1111-1111-1111-111111111111}"
                SilentUninstall = "msiexec.exe /X{11111111-1111-1111-1111-111111111111} /quiet"
            }
        }

        BeforeEach {
            Mock Test-Elevated { $true }
        }

        It "Reports Uninstalled for exit code <Code>" -ForEach @(@{ Code = 0 }, @{ Code = 1605 }, @{ Code = 3010 }) {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = $Code } }
            $Result = Uninstall-VcRedist -VcList $Item -Confirm:$false
            $Result.State | Should -Be "Uninstalled"
            $Result.ExitCode | Should -Be $Code
        }

        It "Reports Failed for a failing exit code" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 1603 } }
            $Result = Uninstall-VcRedist -VcList $Item -WarningAction "SilentlyContinue" -Confirm:$false
            $Result.State | Should -Be "Failed"
        }

        It "Reports Failed when Start-Process throws" {
            Mock Start-Process { throw "boom" }
            (Uninstall-VcRedist -VcList $Item -WarningAction "SilentlyContinue" -Confirm:$false).State | Should -Be "Failed"
        }

        It "Does not carry a previous exit code into the next item" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Missing = [PSCustomObject]@{ Name = "Gone"; Release = "14"; Version = "1"; Architecture = "x64"; ProductCode = "x"; SilentUninstall = "`"$TestDrive/missing.exe`" /x" }
            $Results = Uninstall-VcRedist -VcList @($Item, $Missing) -WarningAction "SilentlyContinue" -Confirm:$false
            ($Results | Where-Object { $_.Name -eq "Gone" }).State | Should -Be "Failed"
            ($Results | Where-Object { $_.Name -eq "Gone" }).ExitCode | Should -BeNullOrEmpty
        }

        It "Skips msiexec uninstall with an invalid product code" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Bad = $Item.PSObject.Copy()
            $Bad.ProductCode = "not-a-guid"
            Uninstall-VcRedist -VcList $Bad -WarningAction "SilentlyContinue" -Confirm:$false | Should -BeNullOrEmpty
            Should -Invoke Start-Process -Times 0
        }
    }
}
