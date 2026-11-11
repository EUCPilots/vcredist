<#
	.SYNOPSIS
		Private Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
	BeforeAll {
		function New-TestManifestJson ([System.String] $Updated, [System.String] $SchemaVersion = "1.0", [System.String] $Uri = "https://download.microsoft.com/vc_redist.x64.exe") {
			[ordered]@{
				SchemaVersion = $SchemaVersion
				Updated       = $Updated
				Entries       = @([ordered]@{
						Name            = "Test"
						ProductCode     = "{d992c12e-cab2-426f-bde3-fb8c53950b0d}"
						Version         = "14.0.1.0"
						URI             = $Uri
						Release         = "14"
						Architecture    = "x64"
						Install         = "/install"
						SilentInstall   = "/install /quiet"
						SilentUninstall = "uninstall"
						UninstallKey    = "64"
						PackageId       = "id"
						DetectionFile   = "file"
						Supported       = $true
					})
			} | ConvertTo-Json -Depth 5
		}
		$BundledUpdated = ([System.DateTime](Get-VcManifest -Source "Bundled").Updated).ToUniversalTime()
		$Newer = New-TestManifestJson -Updated $BundledUpdated.AddDays(1).ToString("yyyy-MM-ddTHH:mm:ssZ")
		$Older = New-TestManifestJson -Updated $BundledUpdated.AddDays(-1).ToString("yyyy-MM-ddTHH:mm:ssZ")
		$Future = New-TestManifestJson -Updated "2099-01-01T00:00:00Z" -SchemaVersion "2.0"
		$BadHost = New-TestManifestJson -Updated "2099-01-01T00:00:00Z" -Uri "https://evil.example.com/a.exe"
	}

	Describe -Name "Get-VcManifest" {
		Context "Bundled source" {
			It "Returns the bundled manifest without making a network call" {
				Mock Invoke-VcWebRequest { throw "should not be called" }
				$Manifest = Get-VcManifest -Source "Bundled"
				$Manifest.Source | Should -BeExactly "Bundled"
				@($Manifest.Entries).Count | Should -BeGreaterThan 0
				Should -Invoke Invoke-VcWebRequest -Times 0 -Exactly
			}
		}

		Context "Remote source" {
			It "Uses a remote manifest that is newer than the bundled manifest" {
				Mock Invoke-VcWebRequest { [PSCustomObject]@{ Content = $Newer } }
				$Manifest = Get-VcManifest
				$Manifest.Source | Should -BeExactly "Remote"
				@($Manifest.Entries).Count | Should -Be 1
			}

			It "Uses the bundled manifest when the remote manifest is older" {
				Mock Invoke-VcWebRequest { [PSCustomObject]@{ Content = $Older } }
				(Get-VcManifest).Source | Should -BeExactly "Bundled"
			}

			It "Passes proxy parameters to the web request" {
				Mock Invoke-VcWebRequest { [PSCustomObject]@{ Content = $Newer } }
				$Credential = [System.Management.Automation.PSCredential]::New("user", (ConvertTo-SecureString "x" -AsPlainText -Force))
				Get-VcManifest -Proxy "http://proxy:8080" -ProxyCredential $Credential | Out-Null
				Should -Invoke Invoke-VcWebRequest -Times 1 -Exactly -ParameterFilter { $Proxy -eq "http://proxy:8080" -and $ProxyCredential.UserName -eq "user" }
			}
		}

		Context "Fallback to the bundled manifest" {
			It "Falls back with a warning on a network failure" {
				Mock Invoke-VcWebRequest { throw "network down" }
				$Manifest = Get-VcManifest -WarningVariable Warn -WarningAction SilentlyContinue
				$Manifest.Source | Should -BeExactly "Bundled"
				$Warn | Should -Not -BeNullOrEmpty
			}

			It "Falls back on invalid JSON" {
				Mock Invoke-VcWebRequest { [PSCustomObject]@{ Content = "not json" } }
				(Get-VcManifest -WarningAction SilentlyContinue).Source | Should -BeExactly "Bundled"
			}

			It "Falls back on an unsupported schema version" {
				Mock Invoke-VcWebRequest { [PSCustomObject]@{ Content = $Future } }
				(Get-VcManifest -WarningAction SilentlyContinue).Source | Should -BeExactly "Bundled"
			}

			It "Falls back when an entry URI is not on the allowed host list" {
				Mock Invoke-VcWebRequest { [PSCustomObject]@{ Content = $BadHost } }
				(Get-VcManifest -WarningAction SilentlyContinue).Source | Should -BeExactly "Bundled"
			}

			It "Throws instead of falling back when -Source Remote is used" {
				Mock Invoke-VcWebRequest { throw "network down" }
				{ Get-VcManifest -Source "Remote" } | Should -Throw
			}
		}
	}
}
