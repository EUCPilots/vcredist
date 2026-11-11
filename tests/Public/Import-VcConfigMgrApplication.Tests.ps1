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
            function Add-CMScriptDeploymentType { param ($ApplicationName, $InstallCommand, $ContentLocation, $AddDetectionClause, $DeploymentTypeName, $UserInteractionMode, $UninstallCommand, $LogonRequirementType, $InstallationBehaviorType, $Comment) }

            $Item = Get-VcList -Source "Bundled" | Select-Object -First 1
            $Item | Add-Member -MemberType "NoteProperty" -Name "Path" -Value (Join-Path -Path $TestDrive -ChildPath "vc_redist.exe") -Force
            $Params = @{ VcList = $Item; CMPath = $TestDrive; SMSSiteCode = "LAB"; NoCopy = $true; Silent = $true }
        }

        BeforeEach {
            $env:SMS_ADMIN_UI_PATH = Join-Path -Path $TestDrive -ChildPath "bin"
            Mock Get-ChildItem { [PSCustomObject]@{ FullName = "ConfigurationManager.psd1" } }
            Mock Import-Module { }
            Mock New-Item { }
            Mock Get-Item { [PSCustomObject]@{ PSDrive = [PSCustomObject]@{ Name = "LAB" } } }
            Mock Set-Location { }
            Mock New-CMApplication { [PSCustomObject]@{ Name = "App" } }
            Mock Move-CMObject { $InputObject }
            Mock New-CMDetectionClauseRegistryKey { "clause" }
            Mock Add-CMScriptDeploymentType { }
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

        It "Creates the application and deployment type and returns the application" {
            Import-VcConfigMgrApplication @Params | Should -Not -BeNullOrEmpty
            Should -Invoke New-CMApplication -Times 1
            Should -Invoke Add-CMScriptDeploymentType -Times 1
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
        }

        It "Copies content with robocopy success codes when NoCopy is not set" {
            Mock Invoke-Process { }
            $Copy = $Params.Clone()
            $Copy.Remove("NoCopy")
            Import-VcConfigMgrApplication @Copy | Out-Null
            Should -Invoke Invoke-Process -Times 1 -ParameterFilter { $SuccessExitCodes -contains 7 }
        }
    }
}
