<#
    .SYNOPSIS
        Mocked tests for Intune update requirements.
#>
[CmdletBinding()]
param ()

InModuleScope VcRedist {
    Describe "Import-VcIntuneApplication update requirements" {
        BeforeAll {
            function New-IntuneWin32AppIcon { param ($FilePath) }
            function New-IntuneWin32AppPackage { param ($SourceFolder, $SetupFile, $OutputFolder) }
            function New-IntuneWin32AppRequirementRule { param ($Architecture, $MinimumSupportedWindowsRelease, $MinimumFreeDiskSpaceInMB) }
            function New-IntuneWin32AppRequirementRuleFile { param ($Version, $Path, $FileOrFolder, $Operator, $VersionValue, $Check32BitOn64System) }
            function Add-IntuneWin32App {
                param ($FilePath, $DisplayName, $Description, $AppVersion, $Notes, $Publisher, $InformationURL, $PrivacyURL,
                    $CompanyPortalFeaturedApp, $InstallExperience, $RestartBehavior, $DetectionRule, $RequirementRule,
                    $InstallCommandLine, $UninstallCommandLine, $Icon,
                    [System.Collections.Specialized.OrderedDictionary[]] $AdditionalRequirementRule)
            }

            $OriginalToken = Get-Variable -Name "AccessToken" -Scope "Global" -ErrorAction "SilentlyContinue"
            $OriginalTokenValue = if ($null -ne $OriginalToken) { $OriginalToken.Value }
            $Global:AccessToken = "test-token"
            $Item = Get-VcList -Source "Bundled" -Release "14" -Architecture "x64" | Select-Object -First 1
            $Item | Add-Member -MemberType "NoteProperty" -Name "Path" -Value (Join-Path -Path $TestDrive -ChildPath "vc_redist.exe") -Force
        }

        BeforeEach {
            $script:ImportedArguments = $null
            Mock Test-PSCore { $false }
            Mock Get-Module { [PSCustomObject]@{ Name = "IntuneWin32App" } } -ParameterFilter { $Name -eq "IntuneWin32App" }
            Mock Get-RequiredVcRedistUpdatesFromIntune { $null }
            Mock New-TemporaryFolder { Join-Path -Path $TestDrive -ChildPath "package" }
            Mock New-IntuneWin32AppIcon { "icon" }
            Mock New-IntuneWin32AppPackage { [PSCustomObject]@{ Path = "package.intunewin" } }
            Mock New-IntuneWin32AppRequirementRule { [ordered]@{ architecture = $Architecture } }
            Mock New-IntuneWin32AppDetectionRule { "detection" }
            Mock New-IntuneWin32AppRequirementRuleFile {
                [ordered]@{
                    path = $Path
                    fileOrFolderName = $FileOrFolder
                    operator = $Operator
                    detectionValue = $VersionValue
                    check32BitOn64System = $Check32BitOn64System
                }
            }
            Mock Add-IntuneWin32App {
                $script:ImportedArguments = @{
                    AdditionalRequirementRule = $AdditionalRequirementRule
                    DetectionRule = $DetectionRule
                    RequirementRule = $RequirementRule
                }
                [PSCustomObject]@{ id = "app" }
            }
            Mock Remove-Item { }
        }

        AfterAll {
            if ($null -ne $OriginalToken) {
                $Global:AccessToken = $OriginalTokenValue
            }
            else {
                Remove-Variable -Name "AccessToken" -Scope "Global" -ErrorAction "SilentlyContinue"
            }
        }

        It "Does not add an update requirement by default" {
            Import-VcIntuneApplication -VcList $Item | Out-Null
            Should -Invoke New-IntuneWin32AppRequirementRuleFile -Times 0
            $script:ImportedArguments.AdditionalRequirementRule | Should -BeNullOrEmpty
        }

        It "Does not add a requirement when the switch is explicitly false" {
            Import-VcIntuneApplication -VcList $Item -ImportAsUpdate:$false | Out-Null
            Should -Invoke New-IntuneWin32AppRequirementRuleFile -Times 0
        }

        It "Adds the older-version file requirement for <Architecture>" -ForEach @(
            @{ Architecture = "x86"; Redirect = $true }
            @{ Architecture = "x64"; Redirect = $false }
            @{ Architecture = "arm64"; Redirect = $false }
        ) {
            $Redist = $Item.PSObject.Copy()
            $Redist.Architecture = $Architecture
            Import-VcIntuneApplication -VcList $Redist -ImportAsUpdate | Out-Null

            Should -Invoke New-IntuneWin32AppRequirementRuleFile -Times 1 -ParameterFilter {
                $Version -eq $true -and $Operator -eq "lessThan" -and
                $VersionValue -eq $Redist.Version -and $FileOrFolder -eq "vcruntime140.dll" -and
                $Check32BitOn64System -eq $Redirect
            }
            $Rules = @($script:ImportedArguments.AdditionalRequirementRule)
            $Rules.Count | Should -Be 1
            ($Rules[0].path -replace "/", "\") | Should -Be "%SystemRoot%\System32"
            $Rules[0].operator | Should -Be "lessThan"
            $Rules[0].detectionValue | Should -Be $Redist.Version
            $Rules[0].check32BitOn64System | Should -Be $Redirect
            $script:ImportedArguments.DetectionRule | Should -Be "detection"
            $script:ImportedArguments.RequirementRule.architecture | Should -Be (Get-IntuneRequirementArchitecture -Architecture $Architecture)
        }

        It "Uses each bundled package's detection file and version for its update requirement" {
            $Entries = @(Get-VcList -Source "Bundled" -Export "All" -WarningAction "SilentlyContinue")
            $Entries.Count | Should -BeGreaterThan 0
            foreach ($Redist in $Entries) {
                $Redist | Add-Member -MemberType "NoteProperty" -Name "Path" -Value $Item.Path -Force
                Import-VcIntuneApplication -VcList $Redist -ImportAsUpdate | Out-Null
                $Rule = $script:ImportedArguments.AdditionalRequirementRule[0]
                ($Rule.path -replace "/", "\") | Should -Be ((Split-Path -Path $Redist.DetectionFile -Parent) -replace "/", "\")
                $Rule.fileOrFolderName | Should -Be (Split-Path -Path $Redist.DetectionFile -Leaf)
                $Rule.detectionValue | Should -Be $Redist.Version
                $Rule.operator | Should -Be "lessThan"
                $Rule.check32BitOn64System | Should -Be ($Redist.Architecture -eq "x86")
            }
        }

        It "Uses the supplied detection file rather than a fixed runtime filename" {
            $Redist = $Item.PSObject.Copy()
            $Redist.DetectionFile = "%SystemRoot%\Custom\other.dll"
            Import-VcIntuneApplication -VcList $Redist -ImportAsUpdate | Out-Null
            $Rule = $script:ImportedArguments.AdditionalRequirementRule[0]
            ($Rule.path -replace "/", "\") | Should -Be "%SystemRoot%\Custom"
            $Rule.fileOrFolderName | Should -Be "other.dll"
        }

        It "Uses the correct bundled runtime filename for release <Release>" -ForEach @(
            @{ Release = "2012"; File = "msvcr110.dll" }
            @{ Release = "2013"; File = "msvcr120.dll" }
        ) {
            $Entries = @(Get-VcList -Source "Bundled" -Export "All" -WarningAction "SilentlyContinue" | Where-Object { $_.Release -eq $Release })
            $Entries.Count | Should -BeGreaterThan 0
            foreach ($Entry in $Entries) {
                (Split-Path -Path $Entry.DetectionFile -Leaf) | Should -Be $File
            }
        }

        It "Keeps older releases importable without the switch" {
            $Redist = $Item.PSObject.Copy()
            $Redist.Version = "12.0.40664.0"
            $Redist.Release = "2013"
            Import-VcIntuneApplication -VcList $Redist | Out-Null
            Should -Invoke Add-IntuneWin32App -Times 1
            Should -Invoke New-IntuneWin32AppRequirementRuleFile -Times 0
        }

        It "Creates a requirement for each piped package" {
            $Other = $Item.PSObject.Copy()
            $Other.Architecture = "x86"
            @($Item, $Other) | Import-VcIntuneApplication -ImportAsUpdate | Out-Null
            Should -Invoke New-IntuneWin32AppRequirementRuleFile -Times 2
            Should -Invoke Add-IntuneWin32App -Times 2
        }

        It "Surfaces errors creating the requirement without importing the app" {
            Mock New-IntuneWin32AppRequirementRuleFile { throw "Rule creation failed" }
            { Import-VcIntuneApplication -VcList $Item -ImportAsUpdate } | Should -Throw "*Rule creation failed*"
            Should -Invoke Add-IntuneWin32App -Times 0
            Should -Invoke New-TemporaryFolder -Times 0
        }

        It "Does not create an app or rule with WhatIf" {
            Import-VcIntuneApplication -VcList $Item -ImportAsUpdate -WhatIf | Out-Null
            Should -Invoke New-IntuneWin32AppRequirementRuleFile -Times 0
            Should -Invoke Add-IntuneWin32App -Times 0
        }

        It "Does not create an app when the existing Intune app is current" {
            Mock Get-RequiredVcRedistUpdatesFromIntune { [PSCustomObject]@{ UpdateRequired = $false } }
            Import-VcIntuneApplication -VcList $Item -ImportAsUpdate | Out-Null
            Should -Invoke New-IntuneWin32AppRequirementRuleFile -Times 0
            Should -Invoke Add-IntuneWin32App -Times 0
        }
    }
}
