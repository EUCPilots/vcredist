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
    }
}

# Test module and manifest
Describe -Name "Module Metadata validation" {
    Context "File info" {
        BeforeAll {
        }

        It "Script fileinfo should be OK" {
            { Test-ModuleManifest -Path "$env:GITHUB_WORKSPACE\VcRedist\VcRedist.psd1" -ErrorAction "Stop" } | Should -Not -Throw
        }

        It "Import module should be OK" {
            { Import-Module "$env:GITHUB_WORKSPACE\VcRedist" -Force -ErrorAction "Stop" } | Should -Not -Throw
        }
    }
}
