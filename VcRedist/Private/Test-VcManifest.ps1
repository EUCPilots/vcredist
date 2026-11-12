function Test-VcManifest {
    <#
        .SYNOPSIS
            Validates the structure of a flattened VcRedist manifest object. Returns $true or throws.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowNull()]
        [System.Object] $Manifest,

        [Parameter(Mandatory = $false)]
        [System.Int32] $SupportedSchemaMajor = 1,

        [Parameter(Mandatory = $false)]
        [System.String[]] $AllowedHosts
    )

    $Required = @("Name", "ProductCode", "Version", "URI", "Release", "Architecture", "Install",
        "SilentInstall", "SilentUninstall", "UninstallKey", "PackageId", "DetectionFile", "Supported", "SupportedArchitecture")

    if ($null -eq $Manifest) { throw "Manifest is empty." }
    foreach ($Property in "SchemaVersion", "Updated", "Entries") {
        if ($null -eq $Manifest.PSObject.Properties[$Property]) { throw "Manifest is missing property '$Property'." }
    }

    $Major = 0
    if (-not [System.Int32]::TryParse(([System.String]$Manifest.SchemaVersion).Split(".")[0], [ref] $Major) -or $Major -ne $SupportedSchemaMajor) {
        throw "Unsupported manifest SchemaVersion '$($Manifest.SchemaVersion)'. Supported major version: $SupportedSchemaMajor."
    }
    $Updated = [System.DateTime]::MinValue
    if (-not [System.DateTime]::TryParse([System.String]$Manifest.Updated, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AdjustToUniversal, [ref] $Updated)) {
        throw "Manifest 'Updated' value '$($Manifest.Updated)' is not a valid date."
    }
    if (@($Manifest.Entries).Count -eq 0) { throw "Manifest contains no entries." }

    foreach ($Entry in @($Manifest.Entries)) {
        foreach ($Property in $Required) {
            if ($null -eq $Entry.PSObject.Properties[$Property] -or $null -eq $Entry.$Property -or ($Entry.$Property -is [System.String] -and [System.String]::IsNullOrWhiteSpace($Entry.$Property))) {
                throw "Manifest entry '$($Entry.Name)' is missing a value for '$Property'."
            }
        }
        if ($Entry.Release -isnot [System.String] -or $Entry.Release -notmatch "^[0-9]{2,4}$") {
            throw "Manifest entry '$($Entry.Name)' has an invalid Release '$($Entry.Release)'."
        }
        if ($Entry.Architecture -isnot [System.String] -or @("x86", "x64", "arm64") -notcontains $Entry.Architecture) {
            throw "Manifest entry '$($Entry.Name)' has an invalid Architecture '$($Entry.Architecture)'."
        }
        try {
            Get-VcSupportedArchitecture -SupportedArchitecture $Entry.SupportedArchitecture | Out-Null
        }
        catch {
            throw "Manifest entry '$($Entry.Name)' has invalid SupportedArchitecture: $($_.Exception.Message)"
        }
        if ($Entry.Supported -isnot [System.Boolean]) { throw "Manifest entry '$($Entry.Name)' property 'Supported' must be a boolean." }
        $Version = $null
        if (-not [System.Version]::TryParse($Entry.Version, [ref] $Version)) { throw "Manifest entry '$($Entry.Name)' has an invalid Version '$($Entry.Version)'." }
        if ($PSBoundParameters.ContainsKey("AllowedHosts") -and -not (Test-VcDownloadUri -Uri $Entry.URI -AllowedHosts $AllowedHosts)) {
            throw "Manifest entry '$($Entry.Name)' has a URI that is not HTTPS or not on the allowed host list: '$($Entry.URI)'."
        }
    }
    $true
}
