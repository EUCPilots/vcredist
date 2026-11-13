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

		It "Rejects URIs containing embedded credentials" {
			{ Invoke-VcWebRequest -Uri "https://user:password@example.com/a" } | Should -Throw "*HTTPS*"
			Should -Invoke Invoke-WebRequest -Times 0 -Exactly
		}

		It "Uses basic parsing, a timeout and stops on error" {
			Invoke-VcWebRequest -Uri "https://example.com/a" -TimeoutSec 5 | Out-Null
			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter { $UseBasicParsing -and $MaximumRedirection -eq 0 -and $TimeoutSec -eq 5 -and $ErrorAction -eq "Stop" }
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

		It "Rejects proxy credentials without a proxy" {
			$Credential = [System.Management.Automation.PSCredential]::New("user", (ConvertTo-SecureString "x" -AsPlainText -Force))
			{ Invoke-VcWebRequest -Uri "https://example.com/a" -ProxyCredential $Credential } | Should -Throw "*without Proxy*"
			Should -Invoke Invoke-WebRequest -Times 0 -Exactly
		}

		It "Rejects invalid proxy URIs" {
			{ Invoke-VcWebRequest -Uri "https://example.com/a" -Proxy "ftp://proxy.example:21" } | Should -Throw "*Proxy must be*"
			Should -Invoke Invoke-WebRequest -Times 0 -Exactly
		}

		It "Follows HTTPS redirects only to allowed hosts" {
			Mock Invoke-WebRequest {
				if ($Uri -eq "https://example.com/a") {
					[PSCustomObject]@{ StatusCode = 302; Headers = @{ Location = "https://cdn.example.com/a" } }
				}
				else {
					[PSCustomObject]@{ StatusCode = 200; Content = "ok" }
				}
			}
			$Response = Invoke-VcWebRequest -Uri "https://example.com/a" -AllowedHosts @("example.com", "cdn.example.com")
			$Response.Content | Should -Be "ok"
			Should -Invoke Invoke-WebRequest -Times 2 -Exactly
		}

		It "Handles redirects returned through an exception response" {
			Mock Invoke-WebRequest {
				if ($Uri -eq "https://example.com/a") {
					$Response = [PSCustomObject]@{ StatusCode = 302; Headers = @{ Location = "https://example.com/final" } }
					$Exception = [System.Exception]::New("redirect")
					$Exception | Add-Member -MemberType "NoteProperty" -Name "Response" -Value $Response
					$Exception | Add-Member -MemberType "NoteProperty" -Name "StatusCode" -Value 302
					throw $Exception
				}
				[PSCustomObject]@{ StatusCode = 200; Content = "ok" }
			}
			$Response = Invoke-VcWebRequest -Uri "https://example.com/a"
			$Response.Content | Should -Be "ok"
			Should -Invoke Invoke-WebRequest -Times 2 -Exactly
		}

		It "Rejects redirects to HTTP or unapproved hosts" {
			Mock Invoke-WebRequest { [PSCustomObject]@{ StatusCode = 302; Headers = @{ Location = "http://example.com/a" } } }
			{ Invoke-VcWebRequest -Uri "https://example.com/a" } | Should -Throw "*HTTPS*"
			Should -Invoke Invoke-WebRequest -Times 1 -Exactly

			Mock Invoke-WebRequest { [PSCustomObject]@{ StatusCode = 302; Headers = @{ Location = "https://other.example/a" } } }
			{ Invoke-VcWebRequest -Uri "https://example.com/a" } | Should -Throw "*allowed host list*"
			Should -Invoke Invoke-WebRequest -Times 2 -Exactly
		}

		It "Restores the TLS protocol" {
			$Before = [System.Net.ServicePointManager]::SecurityProtocol
			Invoke-VcWebRequest -Uri "https://example.com/a" | Out-Null
			[System.Net.ServicePointManager]::SecurityProtocol | Should -Be $Before
		}

		It "Restores the TLS protocol when a request fails" {
			Mock Invoke-WebRequest { throw "network down" }
			$Before = [System.Net.ServicePointManager]::SecurityProtocol
			{ Invoke-VcWebRequest -Uri "https://example.com/a" } | Should -Throw "*network down*"
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
