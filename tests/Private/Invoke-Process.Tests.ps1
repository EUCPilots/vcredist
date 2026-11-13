<#
	.SYNOPSIS
		Private process invocation tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
		$Skip = $false
	}
	else {
		$Skip = $true
	}
}

InModuleScope VcRedist {
	BeforeAll {
		$script:PowerShellExe = Join-Path -Path $PSHOME -ChildPath "$((Get-Process -Id $PID).ProcessName).exe"
	}

	Describe -Name "Invoke-Process" -Skip:$Skip {
		Context "Process execution" {
			It "Returns standard output as a string" {
				$params = @{
					FilePath     = $script:PowerShellExe
					ArgumentList = @("-NoProfile", "-Command", "[Console]::Write('process output')")
				}

				Invoke-Process @params | Should -Be "process output"
			}

			It "Preserves arguments containing spaces" {
				$params = @{
					FilePath     = $script:PowerShellExe
					ArgumentList = @("-NoProfile", "-Command", "[Console]::Write('value with spaces')")
				}

				Invoke-Process @params | Should -Be "value with spaces"
			}

			It "Writes successful process standard error to the error stream" {
				$params = @{
					FilePath     = $script:PowerShellExe
					ArgumentList = @("-NoProfile", "-Command", "[Console]::Error.WriteLine('warning text')")
				}
				$errors = @()

				Invoke-Process @params -ErrorVariable errors -ErrorAction "Continue" | Out-Null

				($errors -join " ") | Should -Match "warning text"
			}

			It "Throws when the process exits with an unapproved code" {
				$params = @{
					FilePath     = $script:PowerShellExe
					ArgumentList = @("-NoProfile", "-Command", "[Environment]::Exit(5)")
				}

				{ Invoke-Process @params } | Should -Throw "*exited with code 5*"
			}

			It "Accepts configured nonzero success exit codes" {
				$params = @{
					FilePath         = $script:PowerShellExe
					ArgumentList     = @("-NoProfile", "-Command", "[Environment]::Exit(5)")
					SuccessExitCodes = @(0, 5)
				}

				{ Invoke-Process @params } | Should -Not -Throw
			}

			It "Retains exit code <ExitCode> for a short-lived process" -TestCases @(
				@{ ExitCode = 0; ArgumentList = @("/?") }
				@{ ExitCode = 1; ArgumentList = @("/q", "VcRedist-Nonexistent-Executable-93F11FA9.exe") }
			) {
				param (
					[System.Int32] $ExitCode,
					[System.String[]] $ArgumentList
				)

				$params = @{
					FilePath         = "$env:SystemRoot\System32\where.exe"
					ArgumentList     = $ArgumentList
					SuccessExitCodes = @($ExitCode)
				}

				{ Invoke-Process @params } | Should -Not -Throw
			}

			It "Stops a process that exceeds its timeout" {
				$params = @{
					FilePath       = $script:PowerShellExe
					ArgumentList   = @("-NoProfile", "-Command", "Start-Sleep -Seconds 5")
					TimeoutSeconds = 1
				}

				{ Invoke-Process @params } | Should -Throw "*exceeded the timeout*"
			}

			It "Stops a process that exceeds the captured output limit" {
				$params = @{
					FilePath            = $script:PowerShellExe
					ArgumentList        = @("-NoProfile", "-Command", "[Console]::Write('0123456789')")
					MaximumOutputBytes  = 5
				}

				{ Invoke-Process @params } | Should -Throw "*exceeded the output limit*"
			}

			It "Does not start a process when WhatIf is specified" {
				Mock Start-Process { throw "Process should not have started." }
				$params = @{
					FilePath     = $script:PowerShellExe
					ArgumentList = @("-NoProfile", "-Command", "[Console]::Write('unexpected')")
				}

				Invoke-Process @params -WhatIf

				Should -Invoke Start-Process -Times 0
			}

			It "Throws when passed an executable that does not exist" {
				$params = @{
					FilePath     = "$env:SystemRoot\System32\cmd1.exe"
					ArgumentList = @("/c", "dir")
				}

				{ Invoke-Process @params } | Should -Throw
			}
		}
	}
}
