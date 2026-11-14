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
	Describe 'New-TemporaryFolder' {
		Context "Test New-TemporaryFolder" {
			It "Creates and returns a unique temporary directory" {
				$TemporaryFolders = @()
				try {
					$TemporaryFolders += New-TemporaryFolder
					$TemporaryFolders += New-TemporaryFolder

					$TemporaryFolders[0] | Should -Not -Be $TemporaryFolders[1]
					foreach ($TemporaryFolder in $TemporaryFolders) {
						Test-Path -LiteralPath $TemporaryFolder -PathType "Container" | Should -BeTrue
					}
				}
				finally {
					foreach ($TemporaryFolder in $TemporaryFolders) {
						if (Test-Path -LiteralPath $TemporaryFolder -PathType "Container") {
							Remove-Item -LiteralPath $TemporaryFolder -Recurse -Force
						}
					}
				}
			}

			It "Surfaces directory creation errors" {
				Mock New-Item {
					throw [System.IO.IOException]::New("Unable to create the directory.")
				}

				{ New-TemporaryFolder } | Should -Throw "Unable to create the directory."
			}
		}
	}
}
