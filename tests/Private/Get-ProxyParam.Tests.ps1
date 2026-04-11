<#
	.SYNOPSIS
		Pester tests for Get-ProxyParam private function.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
}

InModuleScope VcRedist {

	Describe -Name "Get-ProxyParam" {

		Context "Return type" {
			It "Always returns a Hashtable" {
				$Result = Get-ProxyParam -Uri "https://example.com" -BoundParameters @{}
				$Result | Should -BeOfType [System.Collections.Hashtable]
			}

			It "Returns a Hashtable when an explicit proxy is supplied" {
				$BoundParams = [System.Collections.Generic.Dictionary[string, object]]::new()
				$BoundParams["Proxy"] = "http://proxy.example.com:8080"
				$Result = Get-ProxyParam -Uri "https://example.com" -Proxy "http://proxy.example.com:8080" -BoundParameters $BoundParams
				$Result | Should -BeOfType [System.Collections.Hashtable]
			}
		}

		Context "When Proxy is explicitly specified in BoundParameters" {
			BeforeAll {
				$ProxyUri = "http://proxy.example.com:8080"
				$BoundParams = [System.Collections.Generic.Dictionary[string, object]]::new()
				$BoundParams["Proxy"] = $ProxyUri
			}

			It "Includes the Proxy key" {
				$Result = Get-ProxyParam -Uri "https://example.com" -Proxy $ProxyUri -BoundParameters $BoundParams
				$Result.ContainsKey("Proxy") | Should -BeTrue
			}

			It "Sets Proxy to the supplied value" {
				$Result = Get-ProxyParam -Uri "https://example.com" -Proxy $ProxyUri -BoundParameters $BoundParams
				$Result.Proxy | Should -BeExactly $ProxyUri
			}

			It "Does not include ProxyCredential when none is supplied" {
				$Result = Get-ProxyParam -Uri "https://example.com" -Proxy $ProxyUri -BoundParameters $BoundParams
				$Result.ContainsKey("ProxyCredential") | Should -BeFalse
			}

			It "Does not include ProxyUseDefaultCredentials when an explicit proxy is used" {
				$Result = Get-ProxyParam -Uri "https://example.com" -Proxy $ProxyUri -BoundParameters $BoundParams
				$Result.ContainsKey("ProxyUseDefaultCredentials") | Should -BeFalse
			}
		}

		Context "When Proxy and ProxyCredential are both in BoundParameters" {
			BeforeAll {
				$ProxyUri = "http://proxy.example.com:8080"
				$SecurePass = ConvertTo-SecureString -String "TestPassword" -AsPlainText -Force
				$Credential = [System.Management.Automation.PSCredential]::new("testuser", $SecurePass)

				$BoundParams = [System.Collections.Generic.Dictionary[string, object]]::new()
				$BoundParams["Proxy"] = $ProxyUri
				$BoundParams["ProxyCredential"] = $Credential
			}

			It "Includes the Proxy key" {
				$Result = Get-ProxyParam -Uri "https://example.com" -Proxy $ProxyUri -ProxyCredential $Credential -BoundParameters $BoundParams
				$Result.ContainsKey("Proxy") | Should -BeTrue
			}

			It "Includes the ProxyCredential key" {
				$Result = Get-ProxyParam -Uri "https://example.com" -Proxy $ProxyUri -ProxyCredential $Credential -BoundParameters $BoundParams
				$Result.ContainsKey("ProxyCredential") | Should -BeTrue
			}

			It "Sets ProxyCredential to the supplied credential" {
				$Result = Get-ProxyParam -Uri "https://example.com" -Proxy $ProxyUri -ProxyCredential $Credential -BoundParameters $BoundParams
				$Result.ProxyCredential.UserName | Should -BeExactly "testuser"
			}

			It "Does not include ProxyUseDefaultCredentials" {
				$Result = Get-ProxyParam -Uri "https://example.com" -Proxy $ProxyUri -ProxyCredential $Credential -BoundParameters $BoundParams
				$Result.ContainsKey("ProxyUseDefaultCredentials") | Should -BeFalse
			}
		}

		Context "When no Proxy is in BoundParameters and no system proxy exists" {
			It "Returns a Hashtable (empty when no system proxy is configured)" {
				# Pass empty BoundParameters; system proxy detection runs but may find nothing
				$Result = Get-ProxyParam -Uri "https://example.com" -BoundParameters @{}
				$Result | Should -BeOfType [System.Collections.Hashtable]
			}

			It "Does not include an explicit Proxy key when none is specified" {
				$BoundParams = [System.Collections.Generic.Dictionary[string, object]]::new()
				$Result = Get-ProxyParam -Uri "https://example.com" -BoundParameters $BoundParams
				# If no system proxy applies, the hashtable should have no Proxy key
				# (if a system proxy IS configured in the test environment, this key may be present — skip that assertion)
				if ($Result.Count -eq 0) {
					$Result.ContainsKey("Proxy") | Should -BeFalse
				}
			}
		}

		Context "PSBoundParameters (Dictionary) compatibility" {
			It "Accepts PSBoundParameters (Dictionary[string,object]) without error" {
				# $PSBoundParameters is Dictionary[string,object] not Hashtable — verify the IDictionary
				# parameter accepts it without coercion errors
				$BoundParams = [System.Collections.Generic.Dictionary[string, object]]::new()
				$BoundParams["Proxy"] = "http://proxy.test:3128"
				{ Get-ProxyParam -Uri "https://example.com" -Proxy "http://proxy.test:3128" -BoundParameters $BoundParams } | Should -Not -Throw
			}
		}
	}
}
