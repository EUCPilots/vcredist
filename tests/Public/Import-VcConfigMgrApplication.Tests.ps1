<#
	.SYNOPSIS
		Mocked tests for Import-VcConfigMgrApplication. ConfigMgr cmdlets are stubbed; no site is required.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
    Describe -Name "Import-VcConfigMgrApplication" {
        BeforeAll {
            function New-CMApplication { param ($Name, $Description, $SoftwareVersion, $LinkText, $Publisher, $Keyword, $ReleaseDate, $PrivacyUrl, $UserDocumentation) }
            function Move-CMObject { param ([Parameter(ValueFromPipeline)] $InputObject, $FolderPath) process { $InputObject } }
            function New-CMDetectionClauseRegistryKey { param ($Hive, $Is64Bit, $KeyName) }
            function Add-CMScriptDeploymentType { param ($ApplicationName, $InstallCommand, $ContentLocation, $AddDetectionClause, $AddRequirement, $DeploymentTypeName, $UserInteractionMode, $UninstallCommand, $LogonRequirementType, $InstallationBehaviorType, $Comment) }

            $Item = Get-VcList -Source "Bundled" | Select-Object -First 1
            $Item | Add-Member -MemberType "NoteProperty" -Name "Path" -Value (Join-Path -Path $TestDrive -ChildPath "vc_redist.exe") -Force
            $Params = @{ VcList = $Item; CMPath = "\\server\share"; SMSSiteCode = "LAB"; NoCopy = $true; Silent = $true }
        }

        BeforeEach {
            $env:SMS_ADMIN_UI_PATH = Join-Path -Path $TestDrive -ChildPath "bin"
            Mock Get-ChildItem { [PSCustomObject]@{ FullName = "ConfigurationManager.psd1" } }
            Mock Import-Module { }
            Mock Resolve-Path { [PSCustomObject]@{ ProviderPath = $TestDrive } }
            Mock New-Item { }
            Mock Get-Item {
                [PSCustomObject]@{
                    PSDrive     = [PSCustomObject]@{ Name = "LAB" }
                    PSIsContainer = $true
                    Provider    = [PSCustomObject]@{ Name = "FileSystem" }
                }
            }
            Mock Set-Location { }
            Mock New-CMApplication { [PSCustomObject]@{ Name = "App" } }
            Mock Move-CMObject { $InputObject }
            Mock New-CMDetectionClauseRegistryKey { "clause" }
            Mock New-VcConfigMgrArchitectureRequirement { "architecture-rule" }
            Mock Add-CMScriptDeploymentType { }
            [System.IO.File]::WriteAllText($Item.Path, "installer")
            $ContentLocation = [System.IO.Path]::Combine($TestDrive, $Item.Release, $Item.Version, $Item.Architecture)
            [System.IO.Directory]::CreateDirectory($ContentLocation) | Out-Null
            $script:TargetInstaller = Join-Path -Path $ContentLocation -ChildPath (Split-Path -Path $Item.Path -Leaf)
            [System.IO.File]::WriteAllText($script:TargetInstaller, "installer")
        }

        AfterAll {
            Remove-Item -Path "env:SMS_ADMIN_UI_PATH" -ErrorAction "SilentlyContinue"
        }

        It "Throws when SMS_ADMIN_UI_PATH is not set" {
            Remove-Item -Path "env:SMS_ADMIN_UI_PATH" -ErrorAction "SilentlyContinue"
            { Import-VcConfigMgrApplication @Params } | Should -Throw
        }

        It "Throws when the ConfigurationManager module cannot be found" {
            Mock Get-ChildItem { $null }
            { Import-VcConfigMgrApplication @Params } | Should -Throw
        }

        It "Rejects a CMPath that is not a directory" {
            $InvalidPath = $Params.Clone()
            Mock Get-Item {
                [PSCustomObject]@{
                    Provider = [PSCustomObject]@{ Name = "FileSystem" }
                    PSIsContainer = $false
                }
            }
            { Import-VcConfigMgrApplication @InvalidPath } | Should -Throw "*FileSystem directory*"
        }

        It "Rejects a CMPath that is not a UNC path" {
            $InvalidPath = $Params.Clone()
            $InvalidPath.CMPath = $TestDrive
            { Import-VcConfigMgrApplication @InvalidPath } | Should -Throw "*must be a UNC path*"
        }

        It "Creates the application and deployment type and returns the application" {
            Import-VcConfigMgrApplication @Params | Should -Not -BeNullOrEmpty
            Should -Invoke New-CMApplication -Times 1
            Should -Invoke Add-CMScriptDeploymentType -Times 1
            Should -Invoke Add-CMScriptDeploymentType -Times 1 -ParameterFilter { $AddRequirement -eq "architecture-rule" }
            Should -Invoke New-VcConfigMgrArchitectureRequirement -Times 1 -ParameterFilter {
                ($SupportedArchitecture -join ",") -eq ($Item.SupportedArchitecture -join ",")
            }
        }

        It "Passes ReleaseDate to ConfigMgr as a DateTime value" {
            Import-VcConfigMgrApplication @Params | Out-Null
            Should -Invoke New-CMApplication -Times 1 -ParameterFilter { $ReleaseDate -is [System.DateTime] }
        }

        It "Restores the original location" {
            $Before = Get-Location
            Import-VcConfigMgrApplication @Params | Out-Null
            Should -Invoke Set-Location -Times 1 -ParameterFilter { "$Path" -eq $Before.Path }
        }

        It "Restores the location and skips the deployment type when application creation fails" {
            Mock New-CMApplication { throw "boom" }
            $Before = Get-Location
            Import-VcConfigMgrApplication @Params -WarningAction "SilentlyContinue" | Should -BeNullOrEmpty
            Should -Invoke Add-CMScriptDeploymentType -Times 0
            Should -Invoke Set-Location -Times 1 -ParameterFilter { "$Path" -eq $Before.Path }
        }

        It "Does not call ConfigMgr with -WhatIf" {
            Import-VcConfigMgrApplication @Params -WhatIf | Out-Null
            Should -Invoke New-CMApplication -Times 0
            Should -Invoke New-VcConfigMgrArchitectureRequirement -Times 0
        }

        It "Does not create an application when requirement creation fails" {
            Mock New-VcConfigMgrArchitectureRequirement { throw "Cannot create requirement" }
            { Import-VcConfigMgrApplication @Params } | Should -Throw "*Cannot create requirement*"
            Should -Invoke New-CMApplication -Times 0
            Should -Invoke Add-CMScriptDeploymentType -Times 0
        }

        It "Does not report an application when deployment type creation fails" {
            Mock Add-CMScriptDeploymentType { throw "Deployment type failed" }
            $Output = @()
            { $Output = @(Import-VcConfigMgrApplication @Params -WarningAction "SilentlyContinue") } |
                Should -Throw "*Deployment type failed*"
            $Output | Should -BeNullOrEmpty
        }

        It "Copies content with robocopy success codes when NoCopy is false" {
            Mock Invoke-Process { [System.IO.File]::WriteAllText($script:TargetInstaller, "copied") }
            $Copy = $Params.Clone()
            $Copy.NoCopy = $false
            Remove-Item -LiteralPath $script:TargetInstaller
            Import-VcConfigMgrApplication @Copy | Out-Null
            Should -Invoke Invoke-Process -Times 1 -ParameterFilter { $SuccessExitCodes -contains 7 }
        }

        It "Fails the import when robocopy fails even if stale content exists" {
            Mock Invoke-Process { throw "robocopy failed" }
            $Copy = $Params.Clone()
            $Copy.NoCopy = $false
            { Import-VcConfigMgrApplication @Copy } | Should -Throw "*Failed to copy Redistributable*robocopy failed*"
            Should -Invoke New-CMApplication -Times 0
        }

        It "Fails the import when robocopy does not create the expected installer" {
            Mock Invoke-Process { }
            $Copy = $Params.Clone()
            $Copy.NoCopy = $false
            Remove-Item -LiteralPath $script:TargetInstaller
            { Import-VcConfigMgrApplication @Copy } | Should -Throw "*without creating the expected installer*"
            Should -Invoke New-CMApplication -Times 0
        }

        It "Fails when NoCopy is set and the destination installer is missing" {
            Remove-Item -LiteralPath $script:TargetInstaller
            { Import-VcConfigMgrApplication @Params } | Should -Throw "*installer*is missing*"
            Should -Invoke New-CMApplication -Times 0
        }
    }
}
