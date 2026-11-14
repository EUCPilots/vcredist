function Import-MdtModule {
    <#
        .SYNOPSIS
            Imports the MDT PowerShell module. Returns True on success and throws if MDT cannot be loaded.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Force
            Re-imports the MDT module and its members, even if the module or its members have an access mode of read-only.
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    # Get path to the MDT PowerShell module via the Registry.
    $RegPath = "HKLM:SOFTWARE\Microsoft\Deployment 4"
    if (Test-Path -LiteralPath $RegPath -ErrorAction "Stop") {
        Write-Verbose -Message "Get MDT details from registry at: $RegPath"
        $MdtReg = Get-ItemProperty -LiteralPath $RegPath -ErrorAction "Stop"
    }
    else {
        $Msg = "Unable to read MDT Registry path properties at '$RegPath'. Ensure the Microsoft Deployment Toolkit is installed and try again."
        throw [System.IO.DirectoryNotFoundException]::New($Msg)
    }

    if ($null -eq $MdtReg) {
        $Msg = "Unable to read MDT Registry path properties at '$RegPath'. Ensure the Microsoft Deployment Toolkit is installed and try again."
        throw [System.IO.InvalidDataException]::New($Msg)
    }

    $InstallDirProperty = $MdtReg.PSObject.Properties["Install_Dir"]
    if ($null -eq $InstallDirProperty -or [System.String]::IsNullOrWhiteSpace([System.String]$InstallDirProperty.Value)) {
        $Msg = "The MDT registry key at '$RegPath' does not contain a valid Install_Dir property."
        throw [System.IO.InvalidDataException]::New($Msg)
    }

    # Attempt to load the module
    $MdtInstallDir = (Resolve-Path -LiteralPath $InstallDirProperty.Value -ErrorAction "Stop").ProviderPath
    $MdtModule = [System.IO.Path]::Combine($MdtInstallDir, "bin", "MicrosoftDeploymentToolkit.psd1")
    if (Test-Path -LiteralPath $MdtModule -PathType "Leaf" -ErrorAction "Stop") {
        Write-Verbose -Message "Loading MDT module from: $MdtInstallDir."
        $params = @{
            Name        = $MdtModule
            ErrorAction = "Stop"
            Force       = $Force.IsPresent
        }
        Import-Module @params
        Write-Output -InputObject $true
    }
    else {
        $Msg = "Unable to find the MDT PowerShell module at $MdtModule. Ensure the Microsoft Deployment Toolkit is installed and try again."
        throw [System.IO.FileNotFoundException]::New($Msg)
    }
}
