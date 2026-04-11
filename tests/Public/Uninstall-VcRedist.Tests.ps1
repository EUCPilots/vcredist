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

    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
        $SkipAmd = $false
    }
    else {
        $SkipAmd = $true
    }
    if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
        $SkipArm = $false
    }
    else {
        $SkipArm = $true
    }

    # Elevation tests only apply on Windows and only when NOT running as admin
    $SkipElevationTest = -not $IsWindows
    if ($IsWindows) {
        $IsElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        $SkipElevationTest = $IsElevated
    }
}

Describe -Name "Uninstall-VcRedist elevation requirement" -Skip:$SkipElevationTest {
    Context "When the session is not elevated" {
        It "Throws when called without elevation" {
            { Uninstall-VcRedist } | Should -Throw
        }

        It "Throws a ScriptRequiresException when called without elevation" {
            { Uninstall-VcRedist } | Should -Throw -ExceptionType ([System.Management.Automation.ScriptRequiresException])
        }
    }
}

Describe -Name "AMD64 specific tests" -Skip:$SkipAmd {
    Describe -Name "Uninstall-VcRedist" -ForEach $SupportedReleases {
        BeforeAll {
            $Release = $_

            # Create download path
            if ($env:Temp) {
                $Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
            }
            elseif ($env:TMPDIR) {
                $Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
            }
            elseif ($env:RUNNER_TEMP) {
                $Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
            }
            New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null

            $VcList = Get-VcList -Release $Release | Save-VcRedist -Path $Path
            Install-VcRedist -VcList $VcList -Silent | Out-Null
        }

        Context "Uninstall VcRedist <Release>" {
            It "Uninstalls the VcRedist <Release> x64" {
                { Uninstall-VcRedist -Release $Release -Architecture "x64" -Confirm:$false } | Should -Not -Throw
            }

            It "Uninstalls the VcRedist <Release> x86" {
                { Uninstall-VcRedist -Release $Release -Architecture "x86" -Confirm:$false } | Should -Not -Throw
            }
        }
    }
}

Describe -Name "ARM64 specific tests" -Skip:$SkipArm {
    Describe -Name "Uninstall-VcRedist" -ForEach $SupportedReleases {
        BeforeAll {
            $Release = $_

            # Create download path
            if ($env:Temp) {
                $Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
            }
            elseif ($env:TMPDIR) {
                $Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
            }
            elseif ($env:RUNNER_TEMP) {
                $Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
            }
            New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null

            $VcList = Get-VcList -Release $Release | Save-VcRedist -Path $Path
            Install-VcRedist -VcList $VcList -Silent | Out-Null
        }

        Context "Uninstall VcRedist <Release>" {
            It "Uninstalls the VcRedist <Release> arm64" {
                { Uninstall-VcRedist -Release $Release -Architecture "arm64" -Confirm:$false } | Should -Not -Throw
            }
        }
    }
}

Describe -Name "Uninstall VcRedist via the pipeline" {
    Context "Test uninstall via the pipeline" {
        It "Uninstalls the 14 Redistributables via the pipeline" {
            { Get-VcList -Release "14" | Uninstall-VcRedist -Confirm:$false } | Should -Not -Throw
        }
    }
}
