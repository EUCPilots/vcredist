<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$SupportedReleasesAmd64 = @("2017", "2019", "14")
	$SupportedReleasesArm64 = @("14")
	$UnsupportedReleases = @("2008", "2010", "2012", "2013", "2015")
	# $UnsupportedReleases = Get-VcList -Unsupported

	if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
		$SkipAmd = $false
	}
	else {
		$SkipAmd = $true
	}
	if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
		$SkipArm = $false
	}
	else {
		$SkipArm = $true
	}

	# Elevation tests only apply on Windows and only when NOT running as admin
	$SkipElevationTest = -not $IsWindows
	if ($IsWindows) {
		$IsElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
		$SkipElevationTest = $IsElevated
	}
}

Describe -Name "Install-VcRedist elevation requirement" -Skip:$SkipElevationTest {
	Context "When the session is not elevated" {
		It "Throws when called without elevation" {
			{ Install-VcRedist -VcList (Get-VcList) } | Should -Throw
		}

		It "Throws a ScriptRequiresException when called without elevation" {
			{ Install-VcRedist -VcList (Get-VcList) } | Should -Throw -ExceptionType ([System.Management.Automation.ScriptRequiresException])
		}
	}
}

Describe -Name "AMD64 specific tests" -Skip:$SkipAmd {
	Describe -Name "Install-VcRedist with unsupported Redistributables" -ForEach $UnsupportedReleases {
		BeforeAll {
			$Release = $_

			# Create download path
			if ($env:Temp) {
				$Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
			}
			elseif ($env:TMPDIR) {
				$Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
			}
			elseif ($env:RUNNER_TEMP) {
				$Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
			}
			New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null
		}

		Context "Install <Release> x64 Redistributable" {
			BeforeAll {
				# $VcRedist = $Release | Save-VcRedist -Path $Path
				$VcRedist = Get-VcList -Unsupported | `
					Where-Object { $_.Release -eq $Release -and $_.Architecture -eq "x64" } | `
					Save-VcRedist -Path $Path
			}

			It "Installs OK via parameters" {
				{ Install-VcRedist -VcList $VcRedist -Silent } | Should -Not -Throw
			}
		}

		Context "Install <Release> x86 Redistributable" {
			BeforeAll {
				$VcRedist = Get-VcList -Unsupported | `
					Where-Object { $_.Release -eq $Release -and $_.Architecture -eq "x86" } | `
					Save-VcRedist -Path $Path
			}

			It "Installs OK via parameters" {
				{ Install-VcRedist -VcList $VcRedist -Silent } | Should -Not -Throw
			}
		}
	}

	Describe -Name "Install-VcRedist with supported Redistributables" -ForEach $SupportedReleasesAmd64 {
		BeforeAll {
			$Release = $_

			# Create download path
			if ($env:Temp) {
				$Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
			}
			elseif ($env:TMPDIR) {
				$Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
			}
			elseif ($env:RUNNER_TEMP) {
				$Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
			}
			New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null
		}

		Context "Install <Release> x64 Redistributable" {
			BeforeAll {
				$VcRedist = Get-VcList -Release $Release -Architecture "x64" | Save-VcRedist -Path $Path
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via parameters" {
				{ Install-VcRedist -VcList $VcRedist -Silent } | Should -Not -Throw
			}

			It "Returns the list of installed VcRedists after install" {
				Install-VcRedist -VcList $VcRedist -Silent | Should -BeOfType "System.Management.Automation.PSObject"
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via the pipeline" {
				{ Get-VcList -Release $Release -Architecture "x64" | `
						Save-VcRedist -Path $Path | `
						Install-VcRedist -Silent } | Should -Not -Throw
			}
		}

		Context "Install <Release> x86 Redistributable" {
			BeforeAll {
				$VcRedist = Get-VcList -Release $Release -Architecture "x86" | Save-VcRedist -Path $Path
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via parameters" {
				{ Install-VcRedist -VcList $VcRedist -Silent } | Should -Not -Throw
			}

			It "Returns the list of installed VcRedists after install" {
				Install-VcRedist -VcList $VcRedist -Silent | Should -BeOfType "System.Management.Automation.PSObject"
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via the pipeline" {
				{ Get-VcList -Release $Release -Architecture "x86" | `
						Save-VcRedist -Path $Path | `
						Install-VcRedist -Silent } | Should -Not -Throw
			}
		}
	}
}

Describe -Name "ARM64 specific tests" -Skip:$SkipArm {
	Describe -Name "Install-VcRedist with supported Redistributables" -ForEach $SupportedReleasesArm64 {
		BeforeAll {
			$Release = $_

			# Create download path
			if ($env:Temp) {
				$Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
			}
			elseif ($env:TMPDIR) {
				$Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
			}
			elseif ($env:RUNNER_TEMP) {
				$Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
			}
			New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null
		}

		Context "Install <Release> arm64 Redistributable" {
			BeforeAll {
				$VcRedist = Get-VcList -Release $Release -Architecture "arm64" | Save-VcRedist -Path $Path
				$VcRedist | Uninstall-VcRedist -Confirm:$false -ErrorAction "SilentlyContinue"
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via parameters" {
				{ Install-VcRedist -VcList $VcRedist -Silent } | Should -Not -Throw
			}

			It "Returns the list of installed VcRedists after install" {
				Install-VcRedist -VcList $VcRedist -Silent | Should -BeOfType "System.Management.Automation.PSObject"
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via the pipeline" {
				{ Get-VcList -Release $Release -Architecture "arm64" | `
						Save-VcRedist -Path $Path | `
						Install-VcRedist -Silent } | Should -Not -Throw
			}
		}
	}
}
