<#
    .SYNOPSIS
        Main Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
    $ModulePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "VcRedist"
    $ScriptCases = Get-ChildItem -Path $ModulePath -Recurse -Include "*.ps1", "*.psm1", "*.psd1" |
        ForEach-Object { @{ File = $_ } }
    $FunctionCases = Get-ChildItem -Path $ModulePath -Recurse -Filter "*.ps1" |
        ForEach-Object { @{ File = $_ } }
}

Describe -Name "General module validation" {
    Context "Validation" {
        It "Script <file> should exist" -TestCases $ScriptCases {
            param($file)
            $file.FullName | Should -Exist
        }

        It "Script <file> should be valid PowerShell" -TestCases $ScriptCases {
            param($file)
            $contents = Get-Content -Path $file.FullName -ErrorAction "Stop"
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should -Be 0
        }
    }
}

Describe -Name "function validation" {
    Context "Validation" {
        It "Script <file> should only contain one function" -TestCases $FunctionCases {
            param($file)
            $contents = Get-Content -Path $file.FullName -ErrorAction "Stop"
            $describes = [Management.Automation.Language.Parser]::ParseInput($contents, [ref]$null, [ref]$null)
            $test = @($describes.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] })
            $test.Count | Should -Be 1
        }

        It "<file> should match function name" -TestCases $FunctionCases {
            param($file)
            $contents = Get-Content -Path $file.FullName -ErrorAction "Stop"
            $describes = [Management.Automation.Language.Parser]::ParseInput($contents, [ref]$null, [ref]$null)
            $test = @($describes.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] })
            $test[0].name | Should -BeExactly $file.BaseName
        }

        It "<file> should not run statements while importing" -TestCases $FunctionCases {
            param($file)
            $contents = Get-Content -Path $file.FullName -Raw -ErrorAction "Stop"
            $describes = [Management.Automation.Language.Parser]::ParseInput($contents, [ref]$null, [ref]$null)
            $statements = @($describes.EndBlock.Statements | Where-Object { $_ -isnot [System.Management.Automation.Language.FunctionDefinitionAst] })
            $statements | Should -BeNullOrEmpty
        }
    }
}

# Test module and manifest
Describe -Name "Module Metadata validation" {
    Context "File info" {
        BeforeAll {
            $ModulePath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "VcRedist"
        }

        It "Script fileinfo should be OK" {
            { Test-ModuleManifest -Path (Join-Path $ModulePath "VcRedist.psd1") -ErrorAction "Stop" } | Should -Not -Throw
        }

        It "Import module should be OK" {
            { Import-Module $ModulePath -Force -ErrorAction "Stop" } | Should -Not -Throw
        }

        It "Should have unique function file names across public and private directories" {
            $FunctionFiles = @(
                foreach ($Directory in @("Public", "Private")) {
                    Get-ChildItem -LiteralPath (Join-Path $ModulePath $Directory) -Filter "*.ps1" -File
                }
            )
            $Duplicates = @($FunctionFiles | Group-Object -Property "BaseName" | Where-Object { $_.Count -gt 1 })
            $Duplicates | Should -BeNullOrEmpty
        }

        It "Should export only functions and aliases declared in the manifest" {
            $Manifest = Test-ModuleManifest -Path (Join-Path $ModulePath "VcRedist.psd1") -ErrorAction "Stop"
            $ImportedModule = Import-Module -Name (Join-Path $ModulePath "VcRedist.psm1") -Force -PassThru -ErrorAction "Stop"

            $FunctionDifferences = Compare-Object `
                -ReferenceObject @($Manifest.ExportedFunctions.Keys | Sort-Object) `
                -DifferenceObject @($ImportedModule.ExportedFunctions.Keys | Sort-Object)
            $AliasDifferences = Compare-Object `
                -ReferenceObject @($Manifest.ExportedAliases.Keys | Sort-Object) `
                -DifferenceObject @($ImportedModule.ExportedAliases.Keys | Sort-Object)

            $FunctionDifferences | Should -BeNullOrEmpty
            $AliasDifferences | Should -BeNullOrEmpty
        }
    }
}
