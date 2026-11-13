<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$VcList = Get-InstalledVcRedist
	$AllVcList = Get-InstalledVcRedist -Export All
}

Describe -Name "Get-InstalledVcRedist" {
	Context "Validate Get-InstalledVcRedist" {
		It "Should not throw" {
			{ Get-InstalledVcRedist } | Should -Not -Throw
		}

		It "Should not throw with -Export All" {
			{ Get-InstalledVcRedist -Export All } | Should -Not -Throw
		}
	}
}

InModuleScope VcRedist {
	Describe -Name "Get-InstalledVcRedist export filtering" {
		BeforeEach {
			Mock Get-InstalledSoftware {
				@(
					[PSCustomObject]@{
						Publisher = "Microsoft Corporation"
						Name = "Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.40664"
						Architecture = "x86"
					}
					[PSCustomObject]@{
						Publisher = "Microsoft"
						Name = "Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40664"
						Architecture = "x86"
					}
					[PSCustomObject]@{
						Publisher = "Microsoft Corporation"
						Name = "Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40664"
						Architecture = "x64"
					}
					[PSCustomObject]@{
						Publisher = "Microsoft Corporation"
						Name = "Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40664"
						Architecture = "x64"
					}
					[PSCustomObject]@{
						Publisher = "Microsoft Corporation"
						Name = "Microsoft Visual C++ Build Tools"
						Architecture = "x64"
					}
					[PSCustomObject]@{
						Publisher = "Other Publisher"
						Name = "Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40664"
						Architecture = "x86"
					}
				)
			}
		}

		It "Returns only Microsoft Redistributables by default" {
			$Result = @(Get-InstalledVcRedist)

			$Result.Count | Should -Be 2
			@($Result.Name) | Should -Contain "Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.40664"
			@($Result.Name) | Should -Contain "Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40664"
		}

		It "Includes Microsoft Additional and Minimum runtimes with -Export All" {
			$Result = @(Get-InstalledVcRedist -Export All)

			$Result.Count | Should -Be 4
			@($Result.Name) | Should -Contain "Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.40664"
			@($Result.Name) | Should -Contain "Microsoft Visual C++ 2013 x64 Additional Runtime - 12.0.40664"
			@($Result.Name) | Should -Contain "Microsoft Visual C++ 2013 x64 Minimum Runtime - 12.0.40664"
		}

		It "Rejects unsupported -Export values" {
			{ Get-InstalledVcRedist -Export Unsupported } | Should -Throw
		}
	}
}

Describe -Name "Get-InstalledVcRedist with default VcRedists" -ForEach $VcList {
	Context "Validate Get-InstalledVcRedist array properties" {
		It "VcRedist <_.Name> has expected Name property" {
			[System.Boolean]$_.Name | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected Version property" {
			[System.Boolean]$_.Version | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected ProductCode property" {
			[System.Boolean]$_.ProductCode | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected UninstallString property" {
			[System.Boolean]$_.UninstallString | Should -BeTrue
		}
	}
}

Describe -Name "Get-InstalledVcRedist with all VcRedists" -ForEach $AllVcList {
	Context "Validate Get-InstalledVcRedist array properties" {
		It "VcRedist <_.Name> has expected Name property" {
			[System.Boolean]$_.Name | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected Version property" {
			[System.Boolean]$_.Version | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected ProductCode property" {
			[System.Boolean]$_.ProductCode | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected UninstallString property" {
			[System.Boolean]$_.UninstallString | Should -BeTrue
		}
	}
}
