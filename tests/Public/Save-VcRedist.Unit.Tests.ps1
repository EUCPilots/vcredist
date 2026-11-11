<#
	.SYNOPSIS
		Mocked unit tests for Save-VcRedist. No network access or Windows APIs are required.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
param ()

Describe -Name "Save-VcRedist unit tests" {
    BeforeAll {
        $Item = [PSCustomObject]@{
            Name         = "Test"
            Release      = "2022"
            Version      = "14.0.0.1"
            Architecture = "x64"
            URI          = "https://download.microsoft.com/download/test/vc_redist.x64.exe"
        }
    }

    It "Downloads, verifies the signature and returns the object with a Path" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = $TestDrive } {
            Mock Invoke-VcWebRequest { Set-Content -LiteralPath $OutFile -Value "x" }
            Mock Assert-VcSignature { $true }
            $Result = $Item | Save-VcRedist -Path $Dir
            $Result.Path | Should -Exist
            Should -Invoke Assert-VcSignature -Times 1
        }
    }

    It "Passes the proxy to the download" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (New-Item -Path "$TestDrive/p" -ItemType "Directory").FullName } {
            Mock Invoke-VcWebRequest { Set-Content -LiteralPath $OutFile -Value "x" }
            Mock Assert-VcSignature { $true }
            $Item | Save-VcRedist -Path $Dir -Proxy "http://proxy:8080" | Out-Null
            Should -Invoke Invoke-VcWebRequest -ParameterFilter { $Proxy -eq "http://proxy:8080" } -Times 1
        }
    }

    It "Removes the temporary file and leaves no installer when the signature is invalid" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (New-Item -Path "$TestDrive/s" -ItemType "Directory").FullName } {
            Mock Invoke-VcWebRequest { Set-Content -LiteralPath $OutFile -Value "x" }
            Mock Assert-VcSignature { throw "Invalid signature" }
            { $Item | Save-VcRedist -Path $Dir } | Should -Throw
            Get-ChildItem -Path $Dir -Recurse -File | Should -BeNullOrEmpty
        }
    }

    It "Creates a missing target path before downloading" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (Join-Path -Path $TestDrive -ChildPath "new/nested") } {
            Mock Invoke-VcWebRequest { Set-Content -LiteralPath $OutFile -Value "x" }
            Mock Assert-VcSignature { $true }
            $Dir | Should -Not -Exist
            ($Item | Save-VcRedist -Path $Dir).Path | Should -Exist
        }
    }

    It "Throws before downloading when the path cannot be created" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = $TestDrive } {
            Mock Invoke-VcWebRequest { }
            Mock New-Item { throw "denied" }
            { $Item | Save-VcRedist -Path (Join-Path -Path $Dir -ChildPath "nope") } | Should -Throw "*Unable to create*"
            Should -Invoke Invoke-VcWebRequest -Times 0
        }
    }

    It "Throws when the path is an existing file" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = $TestDrive } {
            $File = Join-Path -Path $Dir -ChildPath "file.txt"
            Set-Content -LiteralPath $File -Value "x"
            { $Item | Save-VcRedist -Path $File } | Should -Throw "*is a file*"
        }
    }

    It "Rejects a URI that is not on the allowed host list" {
        InModuleScope VcRedist -Parameters @{ Dir = (New-Item -Path "$TestDrive/h" -ItemType "Directory").FullName } {
            Mock Invoke-VcWebRequest { }
            $Bad = [PSCustomObject]@{ Name = "x"; Release = "2022"; Version = "1.0.0.0"; Architecture = "x64"; URI = "https://example.com/vc.exe" }
            { $Bad | Save-VcRedist -Path $Dir } | Should -Throw
            Should -Invoke Invoke-VcWebRequest -Times 0
        }
    }
}
