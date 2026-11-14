function Get-IntuneRequirementArchitecture {
    <#
        .SYNOPSIS
            Maps supported Windows architectures to an IntuneWin32App requirement value.

        .PARAMETER SupportedArchitecture
            The supported Windows architectures from the manifest.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Object] $SupportedArchitecture
    )

    $Supported = @(Get-VcSupportedArchitecture -SupportedArchitecture $SupportedArchitecture)
    if ($Supported.Count -eq 3) { return "AllWithARM64" }
    if ($Supported.Count -eq 2 -and $Supported -contains "x86" -and $Supported -contains "AMD64") { return "x64x86" }
    if ($Supported.Count -eq 1) {
        switch ($Supported[0]) {
            "x86" { return "x86" }
            "AMD64" { return "x64" }
            "ARM64" { return "arm64" }
        }
    }
    throw [System.ArgumentException]::New("IntuneWin32App cannot represent the SupportedArchitecture combination '$($Supported -join ", ")'.")
}
