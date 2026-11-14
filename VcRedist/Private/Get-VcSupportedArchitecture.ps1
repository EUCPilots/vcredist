function Get-VcSupportedArchitecture {
    <#
        .SYNOPSIS
            Validates and normalizes a manifest entry's supported Windows architectures.
    #>
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object] $SupportedArchitecture
    )

    if ($SupportedArchitecture -isnot [System.Array] -or $SupportedArchitecture.Count -eq 0) {
        throw [System.Management.Automation.ValidationMetadataException]::New("SupportedArchitecture must be a non-empty array.")
    }

    $Result = @()
    foreach ($Architecture in $SupportedArchitecture) {
        if ($Architecture -isnot [System.String]) {
            throw [System.Management.Automation.ValidationMetadataException]::New("SupportedArchitecture contains an invalid value.")
        }
        switch ($Architecture) {
            "x86" { $Result += "x86" }
            "AMD64" { $Result += "AMD64" }
            "ARM64" { $Result += "ARM64" }
            default { throw [System.Management.Automation.ValidationMetadataException]::New("Unsupported SupportedArchitecture value '$Architecture'.") }
        }
    }
    Write-Output -InputObject ($Result | Select-Object -Unique)
}
