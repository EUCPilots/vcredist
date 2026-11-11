<#
	.SYNOPSIS
		Private Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

InModuleScope VcRedist {
	Describe -Name "Invoke-VcWebRequest" {
		BeforeEach {
			Mock Invoke-WebRequest { "ok" }
		}

		It "Rejects non-HTTPS URIs" {
			{ Invoke-VcWebRequest -Uri "http://example.com/a" } | Should -Throw "*HTTPS*"
			Should -Invoke Invoke-WebRequest -Times 0 -Exactly
		}

		It "Uses basic parsing, a timeout and stops on error" {
			Invoke-VcWebRequest -Uri "https://example.com/a" -TimeoutSec 5 | Out-Null
			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $UseBasicParsing -and $TimeoutSec -eq 5 -and $ErrorAction -eq "Stop" }
		}

		It "Does not set proxy parameters by default" {
			Invoke-VcWebRequest -Uri "https://example.com/a" | Out-Null
			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { -not $Proxy -and -not $ProxyCredential }
		}

		It "Passes the proxy and credential" {
			$Credential = [System.Management.Automation.PSCredential]::New("user", (ConvertTo-SecureString "x" -AsPlainText -Force))
			Invoke-VcWebRequest -Uri "https://example.com/a" -Proxy "http://proxy:8080" -ProxyCredential $Credential | Out-Null
			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $Proxy -eq "http://proxy:8080" -and $ProxyCredential.UserName -eq "user" }
		}

		It "Uses default proxy credentials when only a proxy is specified" {
			Invoke-VcWebRequest -Uri "https://example.com/a" -Proxy "http://proxy:8080" | Out-Null
			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $Proxy -eq "http://proxy:8080" -and $ProxyUseDefaultCredentials }
		}

		It "Restores the TLS protocol" {
			$Before = [System.Net.ServicePointManager]::SecurityProtocol
			Invoke-VcWebRequest -Uri "https://example.com/a" | Out-Null
			[System.Net.ServicePointManager]::SecurityProtocol | Should -Be $Before
		}

		It "Sends the VcRedist user agent by default" {
			Invoke-VcWebRequest -Uri "https://example.com/a" | Out-Null
			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $UserAgent -like "VcRedist/* (https://github.com/EUCPilots/vcredist; PowerShell *" }
		}

		It "Uses a caller-supplied user agent" {
			Invoke-VcWebRequest -Uri "https://example.com/a" -UserAgent "Custom/1.0" | Out-Null
			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $UserAgent -eq "Custom/1.0" }
		}
	}
}
