<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

BeforeDiscovery {
	# Uninstall all currently installed Visual C++ Redistributables to ensure a clean test environment.
	Get-InstalledVcRedist | Uninstall-VcRedist -Confirm:$false

	$ModuleRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
	$ManifestPath = Join-Path -Path $ModuleRoot -ChildPath "VcRedist/VisualCRedistributables.json"
	$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
	$TestReleases = @("2015", "2017", "2019", "14")
	$SupportedReleasesAmd64 = @(
		$Manifest.Entries |
			Where-Object { $_.Release -in $TestReleases -and $_.Supported -eq $true -and $_.Architecture -in @("x86", "x64") } |
			Select-Object -ExpandProperty Release -Unique |
			Sort-Object
	)
	$SupportedReleasesArm64 = @(
		$Manifest.Entries |
			Where-Object { $_.Release -in $TestReleases -and $_.Supported -eq $true -and $_.Architecture -eq "arm64" } |
			Select-Object -ExpandProperty Release -Unique |
			Sort-Object
	)
	$UnsupportedReleases = @(
		$Manifest.Entries |
			Where-Object { $_.Release -in $TestReleases -and $_.Supported -eq $false -and $_.Architecture -in @("x86", "x64") } |
			Select-Object -ExpandProperty Release -Unique |
			Sort-Object
	)

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
				$VcRedist = Get-VcList -Export Unsupported -Source "Bundled" -WarningAction "SilentlyContinue" | `
					Where-Object { $_.Release -eq $Release -and $_.Architecture -eq "x64" } | `
					Save-VcRedist -Path $Path
			}

			It "Installs OK via parameters" {
				$Installed = @(Install-VcRedist -VcList $VcRedist -Silent -Force -ErrorAction "Stop")
				$Installed | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode } | Should -Not -BeNullOrEmpty
			}
		}

		Context "Install <Release> x86 Redistributable" {
			BeforeAll {
				$VcRedist = Get-VcList -Export Unsupported -Source "Bundled" -WarningAction "SilentlyContinue" | `
					Where-Object { $_.Release -eq $Release -and $_.Architecture -eq "x86" } | `
					Save-VcRedist -Path $Path
			}

			It "Installs OK via parameters" {
				$Installed = @(Install-VcRedist -VcList $VcRedist -Silent -Force -ErrorAction "Stop")
				$Installed | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode } | Should -Not -BeNullOrEmpty
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
			New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null
		}

		Context "Install <Release> x64 Redistributable" {
			BeforeAll {
				$VcRedist = Get-VcList -Release $Release -Architecture "x64" -Source "Bundled" | Save-VcRedist -Path $Path
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via parameters" {
				{ Install-VcRedist -VcList $VcRedist -Silent -Force -ErrorAction "Stop" | Out-Null } | Should -Not -Throw
			}

			It "Returns the list of installed VcRedists after install" {
				$Installed = @(Install-VcRedist -VcList $VcRedist -Silent -ErrorAction "Stop")
				$Installed | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode } | Should -Not -BeNullOrEmpty
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via the pipeline" {
				$Installed = @(Get-VcList -Release $Release -Architecture "x64" -Source "Bundled" | `
						Save-VcRedist -Path $Path | `
						Install-VcRedist -Silent -ErrorAction "Stop")
				$Installed | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode } | Should -Not -BeNullOrEmpty
			}
		}

		Context "Install <Release> x86 Redistributable" {
			BeforeAll {
				$VcRedist = Get-VcList -Release $Release -Architecture "x86" -Source "Bundled" | Save-VcRedist -Path $Path
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via parameters" {
				{ Install-VcRedist -VcList $VcRedist -Silent -Force -ErrorAction "Stop" | Out-Null } | Should -Not -Throw
			}

			It "Returns the list of installed VcRedists after install" {
				$Installed = @(Install-VcRedist -VcList $VcRedist -Silent -ErrorAction "Stop")
				$Installed | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode } | Should -Not -BeNullOrEmpty
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via the pipeline" {
				$Installed = @(Get-VcList -Release $Release -Architecture "x86" -Source "Bundled" | `
						Save-VcRedist -Path $Path | `
						Install-VcRedist -Silent -ErrorAction "Stop")
				$Installed | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode } | Should -Not -BeNullOrEmpty
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
			New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null
		}

		Context "Install <Release> arm64 Redistributable" {
			BeforeAll {
				$VcRedist = Get-VcList -Release $Release -Architecture "arm64" -Source "Bundled" | Save-VcRedist -Path $Path
				$VcRedist | Uninstall-VcRedist -Confirm:$false -ErrorAction "SilentlyContinue"
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via parameters" {
				{ Install-VcRedist -VcList $VcRedist -Silent -ErrorAction "Stop" | Out-Null } | Should -Not -Throw
			}

			It "Returns the list of installed VcRedists after install" {
				$Installed = @(Install-VcRedist -VcList $VcRedist -Silent -ErrorAction "Stop")
				$Installed | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode } | Should -Not -BeNullOrEmpty
			}

			It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via the pipeline" {
				$Installed = @(Get-VcList -Release $Release -Architecture "arm64" -Source "Bundled" | `
						Save-VcRedist -Path $Path | `
						Install-VcRedist -Silent -ErrorAction "Stop")
				$Installed | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode } | Should -Not -BeNullOrEmpty
			}
		}
	}
}
