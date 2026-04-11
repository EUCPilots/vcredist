<#
	.SYNOPSIS
		Pester tests for Assert-Elevation private function.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	# Assert-Elevation wraps Windows security APIs; skip on non-Windows platforms
	$SkipNonWindows = -not $IsWindows

	# Detect the elevation state of the current test process so tests can
	# self-select: elevated sessions skip the "should throw" tests and vice versa
	if ($IsWindows) {
		$IsElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
	}
	else {
		$IsElevated = $false
	}
}

InModuleScope VcRedist {

	Describe -Name "Assert-Elevation" -Skip:$SkipNonWindows {

		Context "When the session is elevated" -Skip:(-not $IsElevated) {
			It "Does not throw" {
				{ Assert-Elevation } | Should -Not -Throw
			}

			It "Does not throw with a custom Activity message" {
				{ Assert-Elevation -Activity "Running tests" } | Should -Not -Throw
			}
		}

		Context "When the session is not elevated" -Skip:$IsElevated {
			It "Throws" {
				{ Assert-Elevation } | Should -Throw
			}

			It "Throws a ScriptRequiresException" {
				{ Assert-Elevation } | Should -Throw -ExceptionType ([System.Management.Automation.ScriptRequiresException])
			}

			It "Error message contains the default Activity text" {
				{ Assert-Elevation } | Should -Throw -ExpectedMessage "*This operation*"
			}

			It "Error message contains the custom Activity text" {
				{ Assert-Elevation -Activity "Installing VcRedists" } | Should -Throw -ExpectedMessage "*Installing VcRedists*"
			}
		}
	}
}
