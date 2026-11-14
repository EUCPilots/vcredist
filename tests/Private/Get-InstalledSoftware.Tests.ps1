<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
}

InModuleScope VcRedist {
	Describe -Name "Get-InstalledSoftware" {
		BeforeAll {
			function New-TestUninstallEntry {
				param (
					[System.String] $KeyName,
					[System.Collections.Hashtable] $Values
				)

				$Entry = [PSCustomObject]@{
					PSChildName = $KeyName
					Values      = $Values
				}
				Add-Member -InputObject $Entry -MemberType "ScriptMethod" -Name "GetValue" -Value {
					param ([System.String] $ValueName)
					$this.Values[$ValueName]
				}
				$Entry
			}
		}

		Context "Registry enumeration" {
			BeforeEach {
				Mock Test-Path { $true }
				Mock Get-ChildItem {
					if ($LiteralPath -eq "Registry::HKEY_USERS") {
						return @()
					}
					@()
				}
				Mock New-PSDrive { }
				Mock Remove-PSDrive { }
			}

			It "Does not create or remove a shared registry drive" {
				Get-InstalledSoftware | Out-Null

				Should -Invoke New-PSDrive -Times 0 -Exactly
				Should -Invoke Remove-PSDrive -Times 0 -Exactly
			}

			It "Scans registry locations once per invocation" {
				Get-InstalledSoftware -ErrorAction "Stop" | Out-Null

				Should -Invoke Get-ChildItem -Times 1 -Exactly -ParameterFilter {
					$LiteralPath -eq "Registry::HKEY_USERS"
				}
				Should -Invoke Test-Path -Times 2 -Exactly
			}

			It "Scans only loaded user hives" {
				Mock Get-ChildItem {
					if ($LiteralPath -eq "Registry::HKEY_USERS") {
						return @(
							[PSCustomObject]@{ PSChildName = "S-1-5-21-100-200-300-1001" }
							[PSCustomObject]@{ PSChildName = ".DEFAULT" }
						)
					}
					@()
				}

				Get-InstalledSoftware | Out-Null

				Should -Invoke Test-Path -Times 1 -Exactly -ParameterFilter {
					$LiteralPath -eq "Registry::HKEY_USERS\S-1-5-21-100-200-300-1001\Software\Microsoft\Windows\CurrentVersion\Uninstall"
				}
				Should -Invoke Test-Path -Times 0 -Exactly -ParameterFilter {
					$LiteralPath -like "*\.DEFAULT\*"
				}
			}

			It "Reports registry enumeration failures and continues" {
				Mock Get-ChildItem {
					if ($LiteralPath -eq "Registry::HKEY_USERS") {
						return @()
					}
					if ($LiteralPath -like "*Wow6432Node*") {
						throw "Registry access denied"
					}
					@()
				}

				$null = Get-InstalledSoftware -ErrorVariable RegistryErrors -ErrorAction "Continue"

				$RegistryErrors.Exception.Message | Should -Contain "Registry access denied"
			}
		}

		Context "Installed software entries" {
			BeforeEach {
				Mock Test-Path { $true }
				Mock Get-ChildItem {
					if ($LiteralPath -eq "Registry::HKEY_USERS") {
						return @()
					}
					if ($LiteralPath -like "*HKEY_LOCAL_MACHINE\Software\Microsoft*") {
						return $Entries
					}
					@()
				}
			}

			It "Includes non-GUID uninstall entries and treats Name wildcards literally" {
				$Entries = @(
					(New-TestUninstallEntry -KeyName "VendorApp" -Values @{
						DisplayName = "Tool A[1]"
						Publisher   = "Vendor"
					})
					(New-TestUninstallEntry -KeyName "AnotherApp" -Values @{
						DisplayName = "Tool A1"
						Publisher   = "Vendor"
					})
				)

				$Result = @(Get-InstalledSoftware -Name "Tool A[1]")

				$Result.Count | Should -Be 1
				$Result[0].Name | Should -BeExactly "Tool A[1]"
				$Result[0].ProductCode | Should -BeNullOrEmpty
				$Result[0].Architecture | Should -BeNullOrEmpty
			}

			It "Identifies ARM64, x64, and x86 without defaulting unknown names to x86" {
				$Entries = @(
					(New-TestUninstallEntry -KeyName "ArmApp" -Values @{ DisplayName = "Runtime ARM64" })
					(New-TestUninstallEntry -KeyName "AmdApp" -Values @{ DisplayName = "Runtime AMD64" })
					(New-TestUninstallEntry -KeyName "X86App" -Values @{ DisplayName = "Runtime x86" })
					(New-TestUninstallEntry -KeyName "UnknownApp" -Values @{ DisplayName = "Runtime" })
				)

				$Result = @(Get-InstalledSoftware)

				$Result.Architecture | Should -Be @("arm64", "x64", "x86", $null)
			}
		}

		Context "Get-InstalledSoftware returns the expected output" {
			It "Returns null for software that is not installed" {
				Get-InstalledSoftware -Name "SoftwareThatIsNotInstalled" | Should -BeNullOrEmpty
			}

			It "Returns an object of the expected type" {
				Get-InstalledSoftware | Should -BeOfType [System.Management.Automation.PSObject]
			}

			It "Returns details for installed software" {
				(Get-InstalledSoftware).Count | Should -BeGreaterThan 0
			}

			It "Returns details for GitHub CLI" {
				(Get-InstalledSoftware -Name "Github CLI").Publisher | Should -BeExactly "GitHub, Inc."
			}
		}
	}
}
