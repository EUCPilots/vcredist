function Get-InstalledVcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpURI = "https://vcredist.com/get-installedvcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Supported", "All")]
        [System.String] $Export = "Supported"
    )

    if ($Export -eq "All") {
        Write-Verbose -Message "Exporting all installed Visual C++ Redistributables and runtime components."
        $Filter = "^Microsoft Visual C\+\+.*(\bRedistributable\b|\b(Additional|Minimum) Runtime\b)"
    }
    else {
        $Filter = "^Microsoft Visual C\+\+.*\bRedistributable\b"
    }

    # Get all installed Visual C++ Redistributables installed components
    Write-Verbose -Message "Matching installed VcRedists with: '$Filter'."
    $VcRedists = Get-InstalledSoftware | Where-Object {
        ($_.Publisher -match "^Microsoft( Corporation)?$") -and ($_.Name -match $Filter)
    }

    # Add Architecture property to each entry
    Write-Verbose -Message "Add Architecture property to output object."
    foreach ($VcRedist in $VcRedists) {
        if ($VcRedist.Name -like "*x64*") { $null = ($VcRedist.Architecture = "x64") }
        elseif ($VcRedist.Name -like "*Arm64*") { $null = ($VcRedist.Architecture = "arm64") }
    }

    # Write the installed VcRedists to the pipeline
    Write-Output -InputObject $VcRedists
}
