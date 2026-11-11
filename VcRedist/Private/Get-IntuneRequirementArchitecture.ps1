function Get-IntuneRequirementArchitecture {
    <#
        .SYNOPSIS
            Maps a VcRedist architecture to a value accepted by New-IntuneWin32AppRequirementRule -Architecture.

        .PARAMETER Architecture
            The VcRedist architecture: x86, x64 or ARM64.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Architecture
    )

    # x86 installers run on both 32-bit and 64-bit Windows; "All" is no longer a valid value
    switch ($Architecture) {
        "x86" { Write-Output -InputObject "x64x86" }
        "x64" { Write-Output -InputObject "x64" }
        "ARM64" { Write-Output -InputObject "arm64" }
        default { throw [System.ArgumentException]::New("Unsupported architecture for an Intune requirement rule: '$Architecture'.") }
    }
}
