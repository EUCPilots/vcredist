function Get-VcIntuneApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpURI = "https://vcredist.com/get-vcintuneapplication/")]
    param ()

    $VcList = Get-VcList -Export "All"
    Get-VcRedistAppsFromIntune -VcList $VcList
}
