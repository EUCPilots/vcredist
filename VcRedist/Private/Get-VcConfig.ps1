function Get-VcConfig {
    <#
        .SYNOPSIS
            Returns the static module configuration from VcRedist.json.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param ()

    $ConfigPath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath "VcRedist.json"
    Get-Content -LiteralPath $ConfigPath -Raw -ErrorAction "Stop" | ConvertFrom-Json -ErrorAction "Stop"
}
