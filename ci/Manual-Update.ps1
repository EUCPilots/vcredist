Import-Module .\VcRedist\VcRedist.psd1 -Force

# The workflow removes installed redistributables first to ensure a clean comparison.
# This uninstalls them from the machine.
Get-InstalledVcRedist | Uninstall-VcRedist -Confirm:$false -Verbose

New-Item -Path "$env:TEMP\VcRedist" -ItemType Directory -Force | Out-Null

$params = @{
    Release      = @("2017", "2019")
    Architecture = @("x86", "x64")
    Path         = "$env:TEMP\VcRedist"
    VcManifest   = (Resolve-Path .\VcRedist\VisualCRedistributables.json).Path
}

. .\ci\Update-Manifest.ps1 @params
