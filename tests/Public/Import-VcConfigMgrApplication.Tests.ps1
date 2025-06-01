<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$SupportedReleases = @("2022")
}

Describe -Name "Validate Import-VcConfigMgrApplication" -ForEach $SupportedReleases {
	BeforeAll {
		if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
			$Skip = $false

			$Release = $_
			$Path = $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads"))
			New-Item -Path $Path -ItemType "Directory" -ErrorAction "SilentlyContinue" | Out-Null
			$VcList = Save-VcRedist -Path $Path -VcList (Get-VcList -Release $Release)
		}
		else {
			$Skip = $true
		}
	}

	Context "ConfigMgr is not installed" -Skip:$Skip {
		It "Should throw when the ConfigMgr module is not installed" {
			$params = @{
				VcList      = $VcList
				CMPath      = $env:RUNNER_TEMP
				SMSSiteCode = "LAB"
				AppFolder   = "VcRedists"
				Silent      = $true
				NoCopy      = $true
				Publisher   = "Microsoft"
				Keyword     = "Visual C++ Redistributable"
			}
			{ Import-VcConfigMgrApplication @params } | Should -Throw
		}
	}

	Context "ConfigMgr is not installed but env:SMS_ADMIN_UI_PATH set to a valid path" -Skip:$Skip {
		BeforeAll {
			[Environment]::SetEnvironmentVariable("SMS_ADMIN_UI_PATH", "$env:RUNNER_TEMP")
		}

		It "Should throw when env:SMS_ADMIN_UI_PATH is valid but module does not exist" {
			$params = @{
				VcList      = $VcList
				CMPath      = $env:RUNNER_TEMP
				SMSSiteCode = "LAB"
				AppFolder   = "VcRedists"
				Silent      = $true
				NoCopy      = $true
				Publisher   = "Microsoft"
				Keyword     = "Visual C++ Redistributable"
			}
			{ Import-VcConfigMgrApplication @params } | Should -Throw
		}
	}

	Context "ConfigMgr is not installed but env:SMS_ADMIN_UI_PATH set to an invalid path" -Skip:$Skip {
		BeforeAll {
			[Environment]::SetEnvironmentVariable("SMS_ADMIN_UI_PATH", "$env:RUNNER_TEMP\Test")
		}

		It "Should throw when env:SMS_ADMIN_UI_PATH is invalid" {
			$params = @{
				VcList      = $VcList
				CMPath      = $env:RUNNER_TEMP
				SMSSiteCode = "LAB"
				AppFolder   = "VcRedists"
				Silent      = $true
				NoCopy      = $true
				Publisher   = "Microsoft"
				Keyword     = "Visual C++ Redistributable"
			}
			{ Import-VcConfigMgrApplication @params } | Should -Throw
		}
	}
}
