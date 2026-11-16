<#
    .SYNOPSIS
        VcRedist script to initiate the module
#>
[CmdletBinding()]
param ()

# Get public and private function definition files
$PublicRoot = Join-Path -Path $PSScriptRoot -ChildPath "Public"
$PrivateRoot = Join-Path -Path $PSScriptRoot -ChildPath "Private"

# Verify that the public and private function directories exist
foreach ($FunctionRoot in @($PublicRoot, $PrivateRoot)) {
    if (-not (Test-Path -LiteralPath $FunctionRoot -PathType "Container")) {
        throw [System.IO.DirectoryNotFoundException]::New("Required module function directory '$FunctionRoot' was not found.")
    }
}

# Get the list of public and private function files
$Public = @( Get-ChildItem -LiteralPath $PublicRoot -Filter "*.ps1" -File -ErrorAction "Stop" | Sort-Object -Property "Name" )
$Private = @( Get-ChildItem -LiteralPath $PrivateRoot -Filter "*.ps1" -File -ErrorAction "Stop" | Sort-Object -Property "Name" )
$FunctionFiles = @($Public + $Private)
$DuplicateFunctionFiles = @($FunctionFiles | Group-Object -Property "BaseName" | Where-Object { $_.Count -gt 1 })
if ($DuplicateFunctionFiles.Count -gt 0) {
    $DuplicateNames = $DuplicateFunctionFiles.Name -join ", "
    throw "Duplicate function file names found in Public and Private directories: $DuplicateNames."
}

# Dot source the files
foreach ($import in $FunctionFiles) {
    try {
        . $import.FullName
    }
    catch {
        Write-Warning -Message "Failed to import function $($import.FullName)."
        throw
    }
}

# Export the public functions and aliases
$Aliases = @("Get-VcRedist", "Export-VcXml", "Import-VcCmApp", "Import-VcMdtApp", "Test-VcRedistDownload")
Export-ModuleMember -Function $Public.BaseName -Alias $Aliases
