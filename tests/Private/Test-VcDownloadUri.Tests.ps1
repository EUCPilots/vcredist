<#
	.SYNOPSIS
		Private Pester function tests.
#>
[CmdletBinding()]
param ()

InModuleScope VcRedist {
	Describe -Name "Test-VcDownloadUri" {
		It "Returns <Expected> for '<Uri>'" -ForEach @(
			@{ Uri = "https://download.microsoft.com/a.exe"; Expected = $true }
			@{ Uri = "https://aka.ms/vs/17/release/vc_redist.x64.exe"; Expected = $true }
			@{ Uri = "https://DOWNLOAD.MICROSOFT.COM/a.exe"; Expected = $true }
			@{ Uri = "http://download.microsoft.com/a.exe"; Expected = $false }
			@{ Uri = "https://download.microsoft.com.evil.example/a.exe"; Expected = $false }
			@{ Uri = "https://example.com/a.exe"; Expected = $false }
			@{ Uri = "not a uri"; Expected = $false }
			@{ Uri = ""; Expected = $false }
		) {
			Test-VcDownloadUri -Uri $Uri | Should -Be $Expected
		}
	}
}
