function New-MdtDrive {
    <#
        .SYNOPSIS
            Creates a new persistent PS drive mapped to an MDT share.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Path
            A path to a Microsoft Deployment Toolkit share.

        .PARAMETER Drive
            A PS drive letter to map to the MDT share.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Drive = "DS099",

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path
    )

    # Set a description to be applied to the new MDT drive
    $Description = "MDT drive created by $($MyInvocation.MyCommand)"

    if ($PSCmdlet.ShouldProcess("$($Drive): to $($Path)", "Mapping")) {
        $params = @{
            Name        = $Drive
            PSProvider  = "MDTProvider"
            Root        = $Path
            Description = $Description
            ErrorAction = "Stop"
        }
        New-PSDrive @params | Add-MDTPersistentDrive

        # Return the MDT drive name
        $psDrive = Get-MdtPersistentDrive | Where-Object { $_.Path -eq $Path -and $_.Name -eq $Drive }
        Write-Verbose -Message "Found: $($psDrive.Name)"
        Write-Output -InputObject $psDrive.Name
    }
}
