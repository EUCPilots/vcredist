function Remove-VcIntuneApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High", HelpURI = "https://vcredist.com/remove-vcintuneapplication/")]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Pass a VcList object from Save-VcRedist.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList
    )

    begin {
        $RemovedAppIds = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    }

    process {
        foreach ($Redist in $VcList) {
            $ExistingIntuneApps = Get-VcRedistAppsFromIntune -VcList $Redist
            foreach ($Application in $ExistingIntuneApps) {
                if ($RemovedAppIds.Add([System.String]$Application.Id) -and $PSCmdlet.ShouldProcess($Application.displayName, "Remove")) {
                    Write-Verbose -Message "Removing application: $($Application.displayName) with ID: $($Application.Id)."
                    Remove-IntuneWin32App -Id $Application.Id -ErrorAction "Stop"
                }
            }
        }
    }
}
