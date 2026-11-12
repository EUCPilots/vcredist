InModuleScope VcRedist {
    Describe -Name "Get-VcOperatingSystemArchitecture" {
        BeforeAll {
            $StubCim = -not (Get-Command -Name "Get-CimInstance" -ErrorAction "SilentlyContinue")
            if ($StubCim) {
                Set-Item -Path "Function:script:Get-CimInstance" -Value { }
            }
        }

        AfterAll {
            if ($StubCim) {
                Remove-Item -Path "Function:script:Get-CimInstance"
            }
        }

        It "Maps processor architecture <Code> to <Architecture>" -Skip:(-not [System.Environment]::Is64BitOperatingSystem) -ForEach @(
            @{ Code = 9; Architecture = "AMD64" }
            @{ Code = 12; Architecture = "ARM64" }
        ) {
            Mock Get-CimInstance { [PSCustomObject]@{ Architecture = $Code } }
            Get-VcOperatingSystemArchitecture | Should -Be $Architecture
        }

        It "Fails explicitly for an unknown processor architecture" -Skip:(-not [System.Environment]::Is64BitOperatingSystem) {
            Mock Get-CimInstance { [PSCustomObject]@{ Architecture = 99 } }
            { Get-VcOperatingSystemArchitecture } | Should -Throw "*Unable to determine*"
        }

        It "Propagates architecture query failures" -Skip:(-not [System.Environment]::Is64BitOperatingSystem) {
            Mock Get-CimInstance { throw "CIM unavailable" }
            { Get-VcOperatingSystemArchitecture } | Should -Throw "*CIM unavailable*"
        }

        It "Reports x86 for a 32-bit operating system" -Skip:([System.Environment]::Is64BitOperatingSystem) {
            Get-VcOperatingSystemArchitecture | Should -Be "x86"
        }
    }
}
