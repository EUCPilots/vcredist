function Get-InstalledSoftware {
    <#
        .SYNOPSIS
            Retrieves software registered in machine and loaded-user uninstall keys.

        .EXAMPLE
            Get-InstalledSoftware

            This example retrieves software registered on the local computer and in loaded user profiles.

        .PARAMETER Name
            The literal software title prefix to limit the query to.

        .NOTES
            Author: Adam Bertram
            URL: https://4sysops.com/archives/find-the-product-guid-of-installed-software-with-powershell/
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name
    )

    $UninstallKeys = @(
        "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall"
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    try {
        $LoadedUserHives = Get-ChildItem -LiteralPath "Registry::HKEY_USERS" -ErrorAction "Stop" |
            Where-Object { $_.PSChildName -match "^S-\d-\d+-(\d+-){1,14}\d+$" }
        $UninstallKeys += $LoadedUserHives | ForEach-Object {
            "Registry::HKEY_USERS\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall"
        }
    }
    catch {
        $PSCmdlet.WriteError($_)
    }

    $NamePattern = if ($PSBoundParameters.ContainsKey("Name")) {
        [System.Management.Automation.WildcardPattern]::Escape($Name) + "*"
    }

    foreach ($UninstallKey in $UninstallKeys) {
        try {
            if (-not (Test-Path -LiteralPath $UninstallKey -ErrorAction "Stop")) {
                continue
            }

            $UninstallEntries = Get-ChildItem -LiteralPath $UninstallKey -ErrorAction "Stop"
        }
        catch {
            $PSCmdlet.WriteError($_)
            continue
        }

        foreach ($UninstallEntry in $UninstallEntries) {
            $DisplayName = $UninstallEntry.GetValue("DisplayName")
            if ([System.String]::IsNullOrWhiteSpace($DisplayName)) {
                continue
            }
            if ($NamePattern -and $DisplayName -notlike $NamePattern) {
                continue
            }

            $Architecture = $null
            if ($DisplayName -match "(?i)\barm64\b") {
                $Architecture = "arm64"
            }
            elseif ($DisplayName -match "(?i)\b(?:x64|amd64)\b") {
                $Architecture = "x64"
            }
            elseif ($DisplayName -match "(?i)\bx86\b") {
                $Architecture = "x86"
            }

            $Release = if ($DisplayName -match "(\d{4})\s+") {
                $Matches[1]
            }
            elseif ($DisplayName -match "v(\d+)") {
                $Matches[1]
            }

            $ProductCode = if ($UninstallEntry.PSChildName -match "^\{[A-Fa-f0-9]{8}(-[A-Fa-f0-9]{4}){3}-[A-Fa-f0-9]{12}\}$") {
                $UninstallEntry.PSChildName
            }

            [PSCustomObject]@{
                Publisher          = $UninstallEntry.GetValue("Publisher")
                Name               = $DisplayName
                Version            = $UninstallEntry.GetValue("DisplayVersion")
                ProductCode        = $ProductCode
                BundleCachePath    = $UninstallEntry.GetValue("BundleCachePath")
                Architecture       = $Architecture
                Release            = $Release
                UninstallString    = $UninstallEntry.GetValue("UninstallString")
                QuietUninstallString = $UninstallEntry.GetValue("QuietUninstallString")
                UninstallKey       = $UninstallKey
            }
        }
    }
}
