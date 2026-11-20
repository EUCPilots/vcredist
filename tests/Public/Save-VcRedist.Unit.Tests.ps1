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

    It "Downloads without signature validation when explicitly requested" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (Join-Path -Path $TestDrive -ChildPath "skip-download") } {
            Mock Invoke-VcWebRequest { Set-Content -LiteralPath $OutFile -Value "x" }
            Mock Assert-VcSignature { throw "Signature validation should not run" }
            $Result = $Item | Save-VcRedist -Path $Dir -SkipAuthenticodeValidation
            $Result.Path | Should -Exist
            Should -Invoke Invoke-VcWebRequest -Times 1 -Exactly
            Should -Invoke Assert-VcSignature -Times 0 -Exactly
        }
    }

    It "Validates an explicitly false skip switch" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (Join-Path -Path $TestDrive -ChildPath "skip-false") } {
            Mock Invoke-VcWebRequest { Set-Content -LiteralPath $OutFile -Value "x" }
            Mock Assert-VcSignature { throw "Invalid signature" }
            { $Item | Save-VcRedist -Path $Dir -SkipAuthenticodeValidation:$false } | Should -Throw "*Invalid signature*"
            Should -Invoke Assert-VcSignature -Times 1 -Exactly
            Get-ChildItem -Path $Dir -Recurse -File | Should -BeNullOrEmpty
        }
    }

    It "Validates an existing installer by default" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (Join-Path -Path $TestDrive -ChildPath "existing-default") } {
            $TargetDir = Join-Path -Path $Dir -ChildPath "2022/14.0.0.1/x64"
            New-Item -Path $TargetDir -ItemType "Directory" -Force | Out-Null
            $Target = Join-Path -Path $TargetDir -ChildPath "vc_redist.x64.exe"
            Set-Content -LiteralPath $Target -Value "x"
            Mock Get-Item { [PSCustomObject]@{ VersionInfo = [PSCustomObject]@{ ProductVersion = "14.0.0.1" } } } -ParameterFilter { $LiteralPath -eq $Target }
            Mock Invoke-VcWebRequest { throw "Download should not run" }
            Mock Assert-VcSignature { throw "Invalid signature" }
            { $Item | Save-VcRedist -Path $Dir } | Should -Throw "*Invalid signature*"
            Should -Invoke Assert-VcSignature -Times 1 -Exactly -ParameterFilter { $Path -eq $Target }
            Should -Invoke Invoke-VcWebRequest -Times 0 -Exactly
        }
    }

    It "Reuses an existing installer when its version is newer" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (Join-Path -Path $TestDrive -ChildPath "existing-newer") } {
            $TargetDir = Join-Path -Path $Dir -ChildPath "2022/14.0.0.1/x64"
            New-Item -Path $TargetDir -ItemType "Directory" -Force | Out-Null
            $Target = Join-Path -Path $TargetDir -ChildPath "vc_redist.x64.exe"
            Set-Content -LiteralPath $Target -Value "x"
            Mock Get-Item { [PSCustomObject]@{ VersionInfo = [PSCustomObject]@{ ProductVersion = "14.0.0.2" } } } -ParameterFilter { $LiteralPath -eq $Target }
            Mock Invoke-VcWebRequest { throw "Download should not run" }
            Mock Assert-VcSignature { $true }

            $Result = $Item | Save-VcRedist -Path $Dir

            $Result.Path | Should -Be $Target
            Should -Invoke Invoke-VcWebRequest -Times 0 -Exactly
            Should -Invoke Assert-VcSignature -Times 1 -Exactly -ParameterFilter { $Path -eq $Target }
        }
    }

    It "Redownloads an existing installer when its version is older" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (Join-Path -Path $TestDrive -ChildPath "existing-older") } {
            $TargetDir = Join-Path -Path $Dir -ChildPath "2022/14.0.0.1/x64"
            New-Item -Path $TargetDir -ItemType "Directory" -Force | Out-Null
            $Target = Join-Path -Path $TargetDir -ChildPath "vc_redist.x64.exe"
            Set-Content -LiteralPath $Target -Value "old"
            Mock Get-Item { [PSCustomObject]@{ VersionInfo = [PSCustomObject]@{ ProductVersion = "14.0.0.0" } } } -ParameterFilter { $LiteralPath -eq $Target }
            Mock Invoke-VcWebRequest { Set-Content -LiteralPath $OutFile -Value "new" }
            Mock Assert-VcSignature { $true }

            $Result = $Item | Save-VcRedist -Path $Dir

            $Result.Path | Should -Be $Target
            Get-Content -LiteralPath $Target | Should -Be "new"
            Should -Invoke Invoke-VcWebRequest -Times 1 -Exactly
            Should -Invoke Assert-VcSignature -Times 1 -Exactly
        }
    }

    It "Reuses an existing installer without signature validation when explicitly requested" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (Join-Path -Path $TestDrive -ChildPath "existing-skip") } {
            $TargetDir = Join-Path -Path $Dir -ChildPath "2022/14.0.0.1/x64"
            New-Item -Path $TargetDir -ItemType "Directory" -Force | Out-Null
            $Target = Join-Path -Path $TargetDir -ChildPath "vc_redist.x64.exe"
            Set-Content -LiteralPath $Target -Value "x"
            Mock Get-Item { [PSCustomObject]@{ VersionInfo = [PSCustomObject]@{ ProductVersion = "14.0.0.1" } } } -ParameterFilter { $LiteralPath -eq $Target }
            Mock Invoke-VcWebRequest { throw "Download should not run" }
            Mock Assert-VcSignature { throw "Signature validation should not run" }
            $Result = $Item | Save-VcRedist -Path $Dir -SkipAuthenticodeValidation
            $Result.Path | Should -Be $Target
            Should -Invoke Invoke-VcWebRequest -Times 0 -Exactly
            Should -Invoke Assert-VcSignature -Times 0 -Exactly
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

    It "Passes proxy credentials and a custom user agent to the download" {
        $Credential = [System.Management.Automation.PSCredential]::New(
            "proxy-user",
            (ConvertTo-SecureString "secret" -AsPlainText -Force)
        )
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (New-Item -Path "$TestDrive/credentials" -ItemType "Directory").FullName; Credential = $Credential } {
            Mock Invoke-VcWebRequest { Set-Content -LiteralPath $OutFile -Value "x" }
            Mock Assert-VcSignature { $true }

            $Item | Save-VcRedist -Path $Dir -Proxy "http://proxy:8080" -ProxyCredential $Credential -UserAgent "VcRedist.Tests/1.0" | Out-Null

            Should -Invoke Invoke-VcWebRequest -Times 1 -Exactly -ParameterFilter {
                $Proxy -eq "http://proxy:8080" -and
                $ProxyCredential.UserName -eq "proxy-user" -and
                $UserAgent -eq "VcRedist.Tests/1.0"
            }
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

    It "Removes a partial temporary file when the download fails" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (New-Item -Path "$TestDrive/download-failure" -ItemType "Directory").FullName } {
            Mock Invoke-VcWebRequest {
                Set-Content -LiteralPath $OutFile -Value "partial"
                throw "Download failed"
            }
            Mock Assert-VcSignature { throw "Signature validation should not run" }

            { $Item | Save-VcRedist -Path $Dir } | Should -Throw "*Download failed*"

            Get-ChildItem -Path $Dir -Recurse -File | Should -BeNullOrEmpty
            Should -Invoke Assert-VcSignature -Times 0 -Exactly
        }
    }

    It "Removes the temporary file when moving the verified installer fails" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (New-Item -Path "$TestDrive/move-failure" -ItemType "Directory").FullName } {
            Mock Invoke-VcWebRequest { Set-Content -LiteralPath $OutFile -Value "x" }
            Mock Assert-VcSignature { $true }
            Mock Move-Item { throw "Move failed" }

            { $Item | Save-VcRedist -Path $Dir } | Should -Throw "*Move failed*"

            Get-ChildItem -Path $Dir -Recurse -File | Should -BeNullOrEmpty
            Should -Invoke Assert-VcSignature -Times 1 -Exactly
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

    It "Does not create paths or download when WhatIf is used" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (Join-Path -Path $TestDrive -ChildPath "what-if") } {
            Mock Invoke-VcWebRequest { throw "Download should not run" }

            $Result = @($Item | Save-VcRedist -Path $Dir -WhatIf)

            $Dir | Should -Not -Exist
            $Result | Should -BeNullOrEmpty
            Should -Invoke Invoke-VcWebRequest -Times 0 -Exactly
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
            { $Bad | Save-VcRedist -Path $Dir -SkipAuthenticodeValidation } | Should -Throw
            Should -Invoke Invoke-VcWebRequest -Times 0
        }
    }

    It "Rejects an object with missing required properties" {
        InModuleScope VcRedist -Parameters @{ Dir = $TestDrive } {
            $Invalid = [PSCustomObject]@{
                URI          = "https://download.microsoft.com/vc_redist.x64.exe"
                Release      = "2019"
                Architecture = "x64"
            }

            { $Invalid | Save-VcRedist -Path $Dir } | Should -Throw "*Property 'Version' is missing or empty.*"
        }
    }

    It "Rejects an invalid release path component" {
        InModuleScope VcRedist -Parameters @{ Dir = $TestDrive } {
            $Invalid = [PSCustomObject]@{
                URI          = "https://download.microsoft.com/vc_redist.x64.exe"
                Release      = "../outside"
                Version      = "14.29.30156.0"
                Architecture = "x64"
            }

            { $Invalid | Save-VcRedist -Path $Dir } | Should -Throw "*Release '../outside' is invalid.*"
        }
    }

    It "Rejects an invalid version and architecture before downloading" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = $TestDrive } {
            Mock Invoke-VcWebRequest { throw "Download should not run" }
            $InvalidVersion = $Item | Select-Object *
            $InvalidVersion.Version = "not-a-version"
            $InvalidArchitecture = $Item | Select-Object *
            $InvalidArchitecture.Architecture = "mips"

            { $InvalidVersion | Save-VcRedist -Path $Dir } | Should -Throw "*Version 'not-a-version' is invalid.*"
            { $InvalidArchitecture | Save-VcRedist -Path $Dir } | Should -Throw "*Architecture 'mips' is invalid.*"
            Should -Invoke Invoke-VcWebRequest -Times 0 -Exactly
        }
    }

    It "Rejects an allowed-host URI without an installer filename" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (New-Item -Path "$TestDrive/no-filename" -ItemType "Directory").FullName } {
            Mock Invoke-VcWebRequest { throw "Download should not run" }
            $Invalid = $Item | Select-Object *
            $Invalid.URI = "https://download.microsoft.com/"

            { $Invalid | Save-VcRedist -Path $Dir } | Should -Throw "*does not contain an installer filename*"
            Should -Invoke Invoke-VcWebRequest -Times 0 -Exactly
        }
    }

    It "Processes multiple pipeline items and assigns each its own path" {
        InModuleScope VcRedist -Parameters @{ Item = $Item; Dir = (New-Item -Path "$TestDrive/multiple" -ItemType "Directory").FullName } {
            $Second = $Item | Select-Object *
            $Second.Version = "14.0.0.2"
            $Second.Architecture = "arm64"
            $Second.URI = "https://download.microsoft.com/download/test/vc_redist.arm64.exe"
            Mock Invoke-VcWebRequest { Set-Content -LiteralPath $OutFile -Value "x" }
            Mock Assert-VcSignature { $true }

            $Results = @( @($Item, $Second) | Save-VcRedist -Path $Dir )

            $Results.Count | Should -Be 2
            $Results.Path | Should -Contain (Join-Path -Path $Dir -ChildPath "2022/14.0.0.1/x64/vc_redist.x64.exe")
            $Results.Path | Should -Contain (Join-Path -Path $Dir -ChildPath "2022/14.0.0.2/arm64/vc_redist.arm64.exe")
            $Results | ForEach-Object { $_.Path | Should -Exist }
            Should -Invoke Invoke-VcWebRequest -Times 2 -Exactly
        }
    }

    It "Reports a file where a release directory is expected" {
        InModuleScope VcRedist -Parameters @{ Dir = $TestDrive } {
            $ReleasePath = Join-Path -Path $Dir -ChildPath "2019"
            New-Item -Path $ReleasePath -ItemType "File" | Out-Null
            $Valid = [PSCustomObject]@{
                URI          = "https://download.microsoft.com/vc_redist.x64.exe"
                Release      = "2019"
                Version      = "14.29.30156.0"
                Architecture = "x64"
            }

            { $Valid | Save-VcRedist -Path $Dir } | Should -Throw "*is a file, not a folder.*"
        }
    }
}
