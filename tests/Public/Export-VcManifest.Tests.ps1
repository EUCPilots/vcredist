<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

Describe -Name "Export-VcManifest" {
    BeforeAll {
        $Temp = if ($env:RUNNER_TEMP) { $env:RUNNER_TEMP } elseif ($env:TMPDIR) { $env:TMPDIR } else { [System.IO.Path]::GetTempPath() }
        $Path = Join-Path -Path $Temp -ChildPath "VcExport-$([System.Guid]::NewGuid())"
        New-Item -Path $Path -ItemType "Directory" -Force | Out-Null
    }

    It "Writes a valid flat manifest from the bundled source" {
        Export-VcManifest -Path $Path -Source "Bundled" | Out-Null
        $File = Get-ChildItem -Path $Path -Filter "*.json" | Select-Object -First 1
        $File | Should -Not -BeNullOrEmpty
        $Json = Get-Content -LiteralPath $File.FullName -Raw | ConvertFrom-Json
        $Json.SchemaVersion | Should -Not -BeNullOrEmpty
        $Json.Entries.Count | Should -BeGreaterThan 0
    }

    It "Does not write with -WhatIf" {
        $Empty = Join-Path -Path $Path -ChildPath "WhatIf"
        New-Item -Path $Empty -ItemType "Directory" -Force | Out-Null
        Export-VcManifest -Path $Empty -Source "Bundled" -WhatIf | Out-Null
        Get-ChildItem -Path $Empty | Should -BeNullOrEmpty
    }

    AfterAll {
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction "SilentlyContinue"
    }
}
