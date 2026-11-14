function Get-VcOperatingSystemArchitecture {
    <#
        .SYNOPSIS
            Returns the native Windows architecture using manifest architecture names.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    if (-not [System.Environment]::Is64BitOperatingSystem) {
        return "x86"
    }

    $Processor = Get-CimInstance -ClassName "Win32_Processor" -Property "Architecture" -ErrorAction "Stop" | Select-Object -First 1
    switch ($Processor.Architecture) {
        9 { return "AMD64" }
        12 { return "ARM64" }
        default { throw "Unable to determine the native Windows architecture from Win32_Processor." }
    }
}
