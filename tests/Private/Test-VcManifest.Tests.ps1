<#
	.SYNOPSIS
		Private Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
	BeforeAll {
		function New-TestManifest {
			[PSCustomObject]@{
				SchemaVersion = "1.0"
				Updated       = "2026-01-01T00:00:00Z"
				Entries       = @([PSCustomObject]@{
						Name            = "Test"
						ProductCode     = "{d992c12e-cab2-426f-bde3-fb8c53950b0d}"
						Version         = "14.0.1.0"
						URI             = "https://download.microsoft.com/vc_redist.x64.exe"
						Release         = "14"
						Architecture    = "x64"
						SupportedArchitecture = @("AMD64")
						Install         = "/install"
						SilentInstall   = "/install /quiet"
						SilentUninstall = "uninstall"
						UninstallKey    = "64"
						PackageId       = "id"
						DetectionFile   = "file"
						Supported       = $true
					})
			}
		}
	}

	Describe -Name "Test-VcManifest" {
		It "Returns true for a valid manifest" {
			Test-VcManifest -Manifest (New-TestManifest) | Should -BeTrue
		}
		It "Validates the bundled manifest, including allowed hosts" {
			$Bundled = Get-VcManifest -Source "Bundled"
			Test-VcManifest -Manifest $Bundled -AllowedHosts (Get-VcConfig).Download.AllowedHosts | Should -BeTrue
		}
		It "Throws for a null manifest" {
			{ Test-VcManifest -Manifest $null } | Should -Throw
		}
		It "Throws for a missing top-level property" {
			$M = New-TestManifest; $M.PSObject.Properties.Remove("Entries")
			{ Test-VcManifest -Manifest $M } | Should -Throw "*Entries*"
		}
		It "Throws for an unsupported schema major version" {
			$M = New-TestManifest; $M.SchemaVersion = "2.0"
			{ Test-VcManifest -Manifest $M } | Should -Throw "*SchemaVersion*"
		}
		It "Throws when an entry property is empty" {
			$M = New-TestManifest; $M.Entries[0].URI = ""
			{ Test-VcManifest -Manifest $M } | Should -Throw "*URI*"
		}
		It "Throws when Supported is not a boolean" {
			$M = New-TestManifest; $M.Entries[0].Supported = "true"
			{ Test-VcManifest -Manifest $M } | Should -Throw "*Supported*"
		}
		It "Rejects invalid supported architectures" -ForEach @(
			@{ Value = $null }
			@{ Value = @() }
			@{ Value = @("") }
			@{ Value = @("AMD64", "unknown") }
			@{ Value = "AMD64" }
		) {
			$M = New-TestManifest; $M.Entries[0].SupportedArchitecture = $Value
			{ Test-VcManifest -Manifest $M } | Should -Throw "*SupportedArchitecture*"
		}
		It "Throws for an invalid version" {
			$M = New-TestManifest; $M.Entries[0].Version = "abc"
			{ Test-VcManifest -Manifest $M } | Should -Throw "*Version*"
		}
		It "Throws for a URI that is not HTTPS" {
			$M = New-TestManifest; $M.Entries[0].URI = "http://download.microsoft.com/a.exe"
			{ Test-VcManifest -Manifest $M -AllowedHosts @("download.microsoft.com") } | Should -Throw "*allowed host*"
		}
	}
}
