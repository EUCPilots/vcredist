<#
    .SYNOPSIS
        Pester tests for Intune Win32 app detection rule creation.
#>
[CmdletBinding()]
param ()

BeforeDiscovery {
    $ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    Import-Module (Join-Path $ProjectRoot "VcRedist\VcRedist.psd1") -Force
}

InModuleScope VcRedist {
    Describe "New-IntuneWin32AppDetectionRule" -Tag "Intune" {
        BeforeAll {
            Mock -CommandName New-IntuneWin32AppDetectionRuleMSI -MockWith { return @{ Type = "MSI" } }
            Mock -CommandName New-IntuneWin32AppDetectionRuleScript -MockWith { return @{ Type = "Script" } }
            Mock -CommandName New-IntuneWin32AppDetectionRuleRegistry -MockWith { return @{ Type = "Registry" } }
            Mock -CommandName New-IntuneWin32AppDetectionRuleFile -MockWith { return @{ Type = "File" } }

            $TestVcList = @(
                @{
                    Architecture  = "x64"
                    Version       = "14.32.31332.0"
                    ProductCode   = "{12345678-1234-1234-1234-123456789012}"
                    DetectionFile = "C:\Windows\System32\vcruntime140.dll"
                    UninstallKey  = "64"
                }
            )

            $TestIntuneManifest = @{
                DetectionRule = @(
                    @{
                        Type                   = "MSI"
                        ProductCode            = "{12345678-1234-1234-1234-123456789012}"
                        ProductVersionOperator = "greaterThanOrEqual"
                        ProductVersion         = "14.32.31332.0"
                    }
                    @{
                        Type            = "Registry"
                        DetectionMethod = "Existence"
                        KeyPath         = "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64\{guid}"
                        ValueName       = "Version"
                        DetectionType   = "exists"
                    }
                    @{
                        Type            = "File"
                        DetectionMethod = "Version"
                        Operator        = "greaterThanOrEqual"
                    }
                )
            }
        }

        Context "Parameter validation" {
            It "Should throw when VcList is null" {
                { New-IntuneWin32AppDetectionRule -VcList $null -IntuneManifest $TestIntuneManifest } |
                    Should -Throw
            }

            It "Should throw when IntuneManifest is null" {
                { New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $null } |
                    Should -Throw
            }
        }

        Context "Detection rule creation" {
            It "Should create an MSI detection rule" {
                $Result = New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $TestIntuneManifest

                Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleMSI -Times 1
                $Result | Should -Not -BeNullOrEmpty
                $Result[0].Type | Should -Be "MSI"
            }

            It "Should create a registry detection rule" {
                $Result = New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $TestIntuneManifest

                Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleRegistry -Times 1
                $Result | Should -Not -BeNullOrEmpty
                $Result[1].Type | Should -Be "Registry"
            }

            It "Should create a file detection rule" {
                $Result = New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $TestIntuneManifest

                Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleFile -Times 1
                $Result | Should -Not -BeNullOrEmpty
                $Result[2].Type | Should -Be "File"
            }

            It "Should handle multiple VcRedist items" {
                $MultipleVcList = @($TestVcList[0], $TestVcList[0])
                $Result = New-IntuneWin32AppDetectionRule -VcList $MultipleVcList -IntuneManifest $TestIntuneManifest

                Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleMSI -Times 2
                $Result.Count | Should -Be 6
            }
        }

        Context "Registry detection rules" {
            BeforeAll {
                $RegistryManifest = @{
                    DetectionRule = @(
                        @{
                            Type            = "Registry"
                            DetectionMethod = "Existence"
                            KeyPath         = "HKLM:\SOFTWARE\Test\{guid}"
                            ValueName       = "Version"
                            DetectionType   = "exists"
                        }
                        @{
                            Type            = "Registry"
                            DetectionMethod = "VersionComparison"
                            KeyPath         = "HKLM:\SOFTWARE\Test"
                            ValueName       = "Version"
                            Operator        = "greaterThanOrEqual"
                            Value           = "14.0"
                        }
                        @{
                            Type            = "Registry"
                            DetectionMethod = "StringComparison"
                            KeyPath         = "HKLM:\SOFTWARE\Test"
                            ValueName       = "Edition"
                            Operator        = "equal"
                            Value           = "Enterprise"
                        }
                        @{
                            Type            = "Registry"
                            DetectionMethod = "IntegerComparison"
                            KeyPath         = "HKLM:\SOFTWARE\Test"
                            ValueName       = "BuildNumber"
                            Operator        = "greaterThan"
                            Value           = "10000"
                        }
                    )
                }
            }

            It "Should create all supported types of registry detection rules" {
                $Result = New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $RegistryManifest

                Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleRegistry -Times 4
                $Result.Count | Should -Be 4
            }
        }

        Context "File detection rules" {
            BeforeAll {
                $FileManifest = @{
                    DetectionRule = @(
                        @{
                            Type            = "File"
                            DetectionMethod = "Existence"
                            Path            = "C:\Test"
                            FileOrFolder    = "test.dll"
                            DetectionType   = "exists"
                        }
                        @{
                            Type            = "File"
                            DetectionMethod = "DateModified"
                            Path            = "C:\Test"
                            FileOrFolder    = "test.dll"
                            Operator        = "greaterThan"
                            DateTimeValue   = "2025-01-01"
                        }
                        @{
                            Type            = "File"
                            DetectionMethod = "DateCreated"
                            Path            = "C:\Test"
                            FileOrFolder    = "test.dll"
                            Operator        = "lessThan"
                            DateTimeValue   = "2025-12-31"
                        }
                        @{
                            Type            = "File"
                            DetectionMethod = "Size"
                            Path            = "C:\Test"
                            FileOrFolder    = "test.dll"
                            Operator        = "greaterThan"
                            SizeInMBValue   = "1"
                        }
                    )
                }
            }

            It "Should create all supported types of file detection rules" {
                $Result = New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $FileManifest

                Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleFile -Times 4
                $Result.Count | Should -Be 4
            }
        }
    }
}
