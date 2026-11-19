<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$SupportedReleases = @("2017", "2019", "14")
}

Describe -Name "Save-VcRedist" -ForEach $SupportedReleases {
	BeforeAll {
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

		#region Functions used in tests
		function Test-VcDownload {
			<#
		.SYNOPSIS
			Tests downloads from Get-VcList are successful.
		#>
			[CmdletBinding()]
			param (
				[Parameter()]
				[PSCustomObject] $VcList,

				[Parameter()]
				[string] $Path
			)
			$VcList = @($VcList)
			if ($VcList.Count -eq 0) { return $false }
			$Output = $true
			foreach ($VcRedist in $VcList) {
				$Folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path).Path, $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
				$InstallerName = [System.IO.Path]::GetFileName(([System.Uri]$VcRedist.URI).LocalPath)
				$Target = [System.IO.Path]::Combine($Folder, $InstallerName)
				if (Test-Path -Path $Target -PathType Leaf) {
					Write-Verbose "$($Target) - exists."
				}
				else {
					Write-Warning "$($Target) - not found."
					$Output = $false
					break
				}
			}
			Write-Output $Output
		}
		#endregion
	}

	Context "Download Redistributables" {
        It "Downloads the release <_> x64 and returns the expected object" {
            $VcList = @(Get-VcList -Release $_ -Architecture "x64")
            $Saved = @(Save-VcRedist -VcList $VcList -Path $Path)

            $Saved.Count | Should -Be $VcList.Count
            $Saved | ForEach-Object {
                $ExpectedPath = [System.IO.Path]::Combine(
                    (Resolve-Path -Path $Path).Path,
                    $_.Release,
                    $_.Version,
                    $_.Architecture,
                    [System.IO.Path]::GetFileName(([System.Uri]$_.URI).LocalPath)
                )
                $_ | Should -BeOfType "PSCustomObject"
                $_.Path | Should -Be $ExpectedPath
                $_.Path | Should -Exist
            }
        }

		It "Downloads the release <_> x86 and returns the expected object" {
            $VcList = @(Get-VcList -Release $_ -Architecture "x86")
            $Saved = @(Save-VcRedist -VcList $VcList -Path $Path)

            $Saved.Count | Should -Be $VcList.Count
            $Saved | ForEach-Object {
                $ExpectedPath = [System.IO.Path]::Combine(
                    (Resolve-Path -Path $Path).Path,
                    $_.Release,
                    $_.Version,
                    $_.Architecture,
                    [System.IO.Path]::GetFileName(([System.Uri]$_.URI).LocalPath)
                )
                $_ | Should -BeOfType "PSCustomObject"
                $_.Path | Should -Be $ExpectedPath
                $_.Path | Should -Exist
            }
        }
	}

	Context "Test downloaded Redistributables" {
		It "Downloaded Visual C++ Redistributables <_> x64 OK" {
			Test-VcDownload -VcList (Get-VcList -Release $_ -Architecture "x64") -Path $Path | Should -BeTrue
		}

		It "Downloaded Visual C++ Redistributables <_> x86 OK" {
			Test-VcDownload -VcList (Get-VcList -Release $_ -Architecture "x86") -Path $Path | Should -BeTrue
		}
	}
}

Describe -Name "Save-VcRedist pipeline" -ForEach $SupportedReleases {
	BeforeAll {
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
		Push-Location -Path $Path
	}

	Context "Test pipeline support" {
		It "Should not throw when passed <_> x64 via pipeline with no parameters" {
			$VcList = @(Get-VcList -Release $_ -Architecture "x64")
			$Saved = @($VcList | Save-VcRedist)

			$Saved.Count | Should -Be $VcList.Count
			$Saved | ForEach-Object {
				$ExpectedPath = [System.IO.Path]::Combine(
					(Resolve-Path -Path $Path).Path,
					$_.Release,
					$_.Version,
					$_.Architecture,
					[System.IO.Path]::GetFileName(([System.Uri]$_.URI).LocalPath)
				)
				$_.Path | Should -Be $ExpectedPath
				$_.Path | Should -Exist
			}
		}

		It "Should not throw when passed <_> x86 via pipeline with no parameters" {
			$VcList = @(Get-VcList -Release $_ -Architecture "x86")
			$Saved = @($VcList | Save-VcRedist)

			$Saved.Count | Should -Be $VcList.Count
			$Saved | ForEach-Object {
				$ExpectedPath = [System.IO.Path]::Combine(
					(Resolve-Path -Path $Path).Path,
					$_.Release,
					$_.Version,
					$_.Architecture,
					[System.IO.Path]::GetFileName(([System.Uri]$_.URI).LocalPath)
				)
				$_.Path | Should -Be $ExpectedPath
				$_.Path | Should -Exist
			}
		}
	}

	AfterAll {
		Pop-Location
	}
}
