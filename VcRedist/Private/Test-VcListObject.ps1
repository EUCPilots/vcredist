function Test-VcListObject {
    <#
        .SYNOPSIS
            Returns True if running on PowerShell Core.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER InputObject
            The InputObject to validate RequiredProperties against

        .PARAMETER Version
            An array of the require properties to validate against the InputObject
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Pass a VcList object from Get-VcList.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Position = 1)]
        [System.String[]] $RequiredProperties = @("Architecture", "Install", "Name", "ProductCode",
            "Release", "SilentInstall", "SilentUninstall", "UninstallKey", "URI", "URL", "Version",
            "Path", "PackageId", "DetectionFile")
    )

    process {
        $Result = $true
        foreach ($Item in $VcList) {
            $Members = Get-Member -InputObject $Item -MemberType "NoteProperty"
            $MissingProperties = $RequiredProperties | Where-Object { $Members.Name -notcontains $_ }
            foreach ($Property in $MissingProperties) {
                throw [System.Management.Automation.ValidationMetadataException] "Property: '$Property' missing."
            }

            # Only the required properties must have a value; optional properties can be empty
            foreach ($Property in $RequiredProperties) {
                if ([System.String]::IsNullOrEmpty($Item.$Property)) {
                    throw [System.Management.Automation.ValidationMetadataException] "Property '$Property' is null or empty."
                }
            }
        }

        # Return true if all is good with the object
        return $Result
    }
}
