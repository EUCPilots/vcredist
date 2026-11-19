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
                Name = "VC"; Release = "14"; Version = "14.0.0.1"; Architecture = "x64"; SupportedArchitecture = @("AMD64"); ProductCode = "{11111111-1111-1111-1111-111111111111}"
                URI = "https://download.microsoft.com/vc.exe"; Install = "/install"; SilentInstall = "/quiet"; SilentUninstall = "x"
                UninstallKey = "64"; PackageId = "x"; DetectionFile = "x"; Path = $Installer
            }
        }

        BeforeEach {
            Mock Test-Elevated { $true }
            Mock Get-InstalledVcRedist { @() }
            Mock Get-VcOperatingSystemArchitecture { "AMD64" }
            Mock Assert-VcSignature { $true }
            Mock Test-VcListObject { $true }
        }

        It "Treats exit code <Code> as success" -ForEach @(@{ Code = 0 }, @{ Code = 1638 }) {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = $Code } }
            { $Item | Install-VcRedist -Silent -ErrorAction "Stop" | Out-Null } | Should -Not -Throw
            Should -Invoke Start-Process -Times 1
        }

        It "Uses the expected install arguments when Silent is <Silent>" -ForEach @(
            @{ Silent = $true; Arguments = "/quiet" }
            @{ Silent = $false; Arguments = "/install" }
        ) {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            if ($Silent) { $Item | Install-VcRedist -Silent | Out-Null }
            else { $Item | Install-VcRedist | Out-Null }

            Should -Invoke Start-Process -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq $Item.Path -and
                $ArgumentList -eq $Arguments -and
                $PassThru -and $Wait -and $NoNewWindow
            }
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

        It "Warns and skips an installer file that is missing" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Missing = $Item.PSObject.Copy()
            $Missing.Path = Join-Path -Path $TestDrive -ChildPath "missing.exe"

            $Missing | Install-VcRedist -WarningVariable "W" -WarningAction "SilentlyContinue" | Out-Null

            ($W -join " ") | Should -Match "Cannot find"
            Should -Invoke Start-Process -Times 0 -Exactly
        }

        It "Throws when not elevated" {
            Mock Test-Elevated { $false }
            { $Item | Install-VcRedist | Out-Null } | Should -Throw
        }

        It "Installs releases in manifest order for <InputMode>, then by version" -ForEach @(
            @{ InputMode = "pipeline" }
            @{ InputMode = "parameter" }
        ) {
            $script:InstallSequence = [System.Collections.Generic.List[System.String]]::new()
            Mock Start-Process {
                $script:InstallSequence.Add([System.IO.Path]::GetFileName($FilePath))
                [PSCustomObject]@{ ExitCode = 0 }
            }
            $Candidates = foreach ($Release in @("14", "2019", "2017", "2015", "2013", "2012", "2010", "2008", "2005")) {
                $Candidate = $Item.PSObject.Copy()
                $Candidate.Release = $Release
                $Candidate.Version = "14.0.0.1"
                $Candidate.Path = Join-Path $TestDrive "$Release.exe"
                Set-Content -LiteralPath $Candidate.Path -Value "x"
                $Candidate
            }
            $Older = $Candidates[0].PSObject.Copy()
            $Older.Version = "14.0.0.0"
            $Older.Path = Join-Path $TestDrive "14-older.exe"
            Set-Content -LiteralPath $Older.Path -Value "x"
            $Candidates = @($Candidates) + @($Older)

            if ($InputMode -eq "pipeline") { $Candidates | Install-VcRedist -Silent | Out-Null }
            else { Install-VcRedist -VcList $Candidates -Silent | Out-Null }

            $script:InstallSequence -join "," | Should -BeExactly "2005.exe,2008.exe,2010.exe,2012.exe,2013.exe,2015.exe,2017.exe,2019.exe,14-older.exe,14.exe"
        }

        It "Rejects an unknown release before starting any installer" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Unknown = $Item.PSObject.Copy()
            $Unknown.Release = "2099"
            { @($Item, $Unknown) | Install-VcRedist } | Should -Throw "*2099*InstallOrder*"
            Should -Invoke Start-Process -Times 0 -Exactly
        }

        It "Uses the bundled manifest order rather than a hard-coded order" {
            Mock Get-VcManifest { [PSCustomObject]@{ InstallOrder = @("14", "2005") } }
            $script:InstallSequence = [System.Collections.Generic.List[System.String]]::new()
            Mock Start-Process {
                $script:InstallSequence.Add([System.IO.Path]::GetFileName($FilePath))
                [PSCustomObject]@{ ExitCode = 0 }
            }
            $First = $Item.PSObject.Copy()
            $First.Release = "2005"
            $First.Path = Join-Path $TestDrive "2005.exe"
            Set-Content -LiteralPath $First.Path -Value "x"
            @($First, $Item) | Install-VcRedist | Out-Null
            $script:InstallSequence -join "," | Should -BeExactly "vc_redist.exe,2005.exe"
            Should -Invoke Get-VcManifest -Times 1 -Exactly -ParameterFilter { $Source -eq "Bundled" }
        }

        It "Rejects a bundled manifest with no installation order" {
            Mock Get-VcManifest { [PSCustomObject]@{} }
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            { $Item | Install-VcRedist } | Should -Throw "*InstallOrder*"
            Should -Invoke Start-Process -Times 0 -Exactly
        }

        It "Does not start installers with WhatIf" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Item | Install-VcRedist -WhatIf | Out-Null
            Should -Invoke Start-Process -Times 0 -Exactly
        }

        It "Re-installs an already installed VcRedist when Force is specified" {
            Mock Get-InstalledVcRedist { @($Item) }
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }

            $Item | Install-VcRedist -Force | Out-Null

            Should -Invoke Start-Process -Times 1 -Exactly
        }

        It "Skips an already installed VcRedist unless Force is specified" {
            Mock Get-InstalledVcRedist { @($Item) }
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }

            $Item | Install-VcRedist -InformationVariable "Information" -InformationAction "Continue" | Out-Null

            Should -Invoke Start-Process -Times 0 -Exactly
            ($Information.MessageData -join " ") | Should -Match "already installed"
        }

        It "Uses manifest support for <Package> on <System>" -ForEach @(
            @{ Package = "arm64"; System = "AMD64"; Supported = @("ARM64"); Installs = 0 }
            @{ Package = "x64"; System = "x86"; Supported = @("AMD64"); Installs = 0 }
            @{ Package = "x64"; System = "AMD64"; Supported = @("AMD64"); Installs = 1 }
            @{ Package = "x64"; System = "ARM64"; Supported = @("AMD64", "ARM64"); Installs = 1 }
            @{ Package = "x64"; System = "ARM64"; Supported = @("AMD64"); Installs = 1 }
            @{ Package = "x86"; System = "ARM64"; Supported = @("x86", "AMD64", "ARM64"); Installs = 1 }
            @{ Package = "arm64"; System = "ARM64"; Supported = @("ARM64"); Installs = 1 }
            @{ Package = "x86"; System = "x86"; Supported = @("x86", "AMD64", "ARM64"); Installs = 1 }
        ) {
            Mock Get-VcOperatingSystemArchitecture { $System }
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Candidate = $Item.PSObject.Copy()
            $Candidate.Architecture = $Package
            $Candidate.SupportedArchitecture = $Supported
            $Candidate | Install-VcRedist -Force -WarningVariable "W" -WarningAction "SilentlyContinue" | Out-Null
            Should -Invoke Start-Process -Times $Installs -Exactly
            if ($Installs -eq 0) {
                ($W -join " ") | Should -Match "not recommended"
            }
        }

        It "Does not bypass the architecture check for x64 on ARM64 without Force" {
            Mock Get-VcOperatingSystemArchitecture { "ARM64" }
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Candidate = $Item.PSObject.Copy()
            $Candidate.SupportedArchitecture = @("AMD64")

            $Candidate | Install-VcRedist -WarningVariable "W" -WarningAction "SilentlyContinue"

            Should -Invoke Start-Process -Times 0 -Exactly
            ($W -join " ") | Should -Match "not recommended"
        }

        It "Does not bypass the architecture check for non-x64 on ARM64 with Force" {
            Mock Get-VcOperatingSystemArchitecture { "ARM64" }
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Candidate = $Item.PSObject.Copy()
            $Candidate.Architecture = "x86"
            $Candidate.SupportedArchitecture = @("AMD64")

            $Candidate | Install-VcRedist -Force -WarningVariable "W" -WarningAction "SilentlyContinue"

            Should -Invoke Start-Process -Times 0 -Exactly
            ($W -join " ") | Should -Match "not recommended"
        }

        It "Rejects missing or empty supported architecture metadata" -ForEach @(
            @{ Supported = $null }
            @{ Supported = @() }
            @{ Supported = @("") }
        ) {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Candidate = $Item.PSObject.Copy()
            $Candidate.SupportedArchitecture = $Supported
            { $Candidate | Install-VcRedist } | Should -Throw "*SupportedArchitecture*"
            Should -Invoke Start-Process -Times 0
        }

        It "Continues the pipeline after skipping an incompatible manifest entry" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Candidates = @(Get-VcList -Release "14" -Source "Bundled" | Where-Object { $_.Architecture -in @("arm64", "x86") })
            $Candidates.Count | Should -Be 2
            foreach ($Candidate in $Candidates) {
                $Candidate | Add-Member -NotePropertyName "Path" -NotePropertyValue $Installer
            }
            $Candidates | Install-VcRedist -WarningVariable "W" -WarningAction "SilentlyContinue" | Out-Null
            Should -Invoke Start-Process -Times 1 -Exactly
            ($W -join " ") | Should -Match "not recommended"
        }

        It "Rejects an object with no SupportedArchitecture property" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }
            $Candidate = $Item.PSObject.Copy()
            $Candidate.PSObject.Properties.Remove("SupportedArchitecture")
            { $Candidate | Install-VcRedist } | Should -Throw "*SupportedArchitecture*"
            Should -Invoke Start-Process -Times 0
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

        It "Reports Uninstalled for exit code <Code>" -ForEach @(@{ Code = 0 }, @{ Code = 1605 }, @{ Code = 1641 }, @{ Code = 3010 }) {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = $Code } }
            $Result = Uninstall-VcRedist -VcList $Item -Confirm:$false
            $Result.State | Should -Be "Uninstalled"
            $Result.ExitCode | Should -Be $Code
        }

        It "Builds the expected msiexec command for a valid product code" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }

            $Result = Uninstall-VcRedist -VcList $Item -Confirm:$false

            $Result.State | Should -Be "Uninstalled"
            Should -Invoke Start-Process -Times 1 -Exactly -ParameterFilter {
                $FilePath -like "*\System32\msiexec.exe" -and
                $ArgumentList -eq "/uninstall {11111111-1111-1111-1111-111111111111} /quiet /norestart" -and
                $PassThru -and $Wait -and $NoNewWindow
            }
        }

        It "Builds the expected command for a quoted executable uninstall string" {
            $Executable = Join-Path -Path $TestDrive -ChildPath "vendor uninstaller.exe"
            Set-Content -LiteralPath $Executable -Value "x"
            $ExeItem = $Item.PSObject.Copy()
            $ExeItem | Add-Member -NotePropertyName "UninstallString" -NotePropertyValue "`"$Executable`" /custom"
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }

            $Result = Uninstall-VcRedist -VcList $ExeItem -Confirm:$false

            $Result.State | Should -Be "Uninstalled"
            Should -Invoke Start-Process -Times 1 -Exactly -ParameterFilter {
                $FilePath -eq $Executable -and
                $ArgumentList -eq "/uninstall /quiet /norestart"
            }
        }

        It "Filters manually selected installed redistributables by release and architecture" {
            $Selected = $Item.PSObject.Copy()
            $Selected.Name = "Selected"
            $Selected.Release = "2019"
            $Selected.Architecture = "x86"
            $Selected.ProductCode = "{22222222-2222-2222-2222-222222222222}"
            $Selected.SilentUninstall = "msiexec.exe /X$($Selected.ProductCode) /quiet"
            $WrongArchitecture = $Selected.PSObject.Copy()
            $WrongArchitecture.Name = "Wrong architecture"
            $WrongArchitecture.Architecture = "x64"
            $WrongRelease = $Selected.PSObject.Copy()
            $WrongRelease.Name = "Wrong release"
            $WrongRelease.Release = "14"
            Mock Get-InstalledVcRedist { @($Selected, $WrongArchitecture, $WrongRelease) }
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }

            $Results = @(Uninstall-VcRedist -Release "2019" -Architecture "x86" -Confirm:$false)

            $Results.Count | Should -Be 1
            $Results[0].Name | Should -Be "Selected"
            Should -Invoke Start-Process -Times 1 -Exactly -ParameterFilter {
                $ArgumentList -eq "/uninstall {22222222-2222-2222-2222-222222222222} /quiet /norestart"
            }
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

        It "Does not start an uninstaller with WhatIf" {
            Mock Start-Process { [PSCustomObject]@{ ExitCode = 0 } }

            $Result = @(Uninstall-VcRedist -VcList $Item -Confirm:$false -WhatIf)

            $Result | Should -BeNullOrEmpty
            Should -Invoke Start-Process -Times 0 -Exactly
        }

        It "Throws when the input object has no uninstall command" {
            $Invalid = $Item.PSObject.Copy()
            $Invalid.PSObject.Properties.Remove("SilentUninstall")

            { Uninstall-VcRedist -VcList $Invalid -Confirm:$false } |
                Should -Throw "*Cannot find uninstall string*"
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
