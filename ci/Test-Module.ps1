<#
    .SYNOPSIS
        Runs module tests with explicit failure and discovery gates.
    .PARAMETER Intune
        Runs only the live Intune tests and requires tenant credentials.
    .PARAMETER ResultName
        Identifies the test result and coverage files.
#>
[CmdletBinding()]
param (
    [System.Management.Automation.SwitchParameter] $Intune,
    [ValidatePattern("^[a-zA-Z0-9-]+$")]
    [System.String] $ResultName = "local"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Path $PSScriptRoot -Parent
$env:GITHUB_WORKSPACE = $Root
if (-not $env:RUNNER_TEMP) { $env:RUNNER_TEMP = [System.IO.Path]::GetTempPath() }
& (Join-Path -Path $Root -ChildPath "tests/Install-Pester.ps1")
Import-Module -Name (Join-Path -Path $Root -ChildPath "VcRedist/VcRedist.psd1") -Force -ErrorAction "Stop"

$Config = New-PesterConfiguration
$Config.Run.Path = Join-Path -Path $Root -ChildPath "tests"
$Config.Run.PassThru = $true
$Config.Run.Throw = $true
$Config.TestResult.Enabled = $true
$Config.TestResult.OutputFormat = "NUnitXml"
$Config.TestResult.OutputPath = Join-Path -Path $Root -ChildPath "TestResults-$ResultName.xml"
$Config.Output.Verbosity = "Detailed"
if ($Intune) {
    foreach ($Name in @("TENANT_ID", "CLIENT_ID", "CLIENT_SECRET")) {
        if (-not [System.Environment]::GetEnvironmentVariable($Name)) { throw "Missing required credential: $Name." }
    }
    $Config.Filter.Tag = @("Intune")
}
else {
    $Config.Filter.ExcludeTag = @("Intune")
    $Config.CodeCoverage.Enabled = $true
    $Config.CodeCoverage.Path = Join-Path -Path $Root -ChildPath "VcRedist"
    $Config.CodeCoverage.OutputFormat = "JaCoCo"
    $Config.CodeCoverage.OutputPath = Join-Path -Path $Root -ChildPath "CodeCoverage-$ResultName.xml"
}
$Result = Invoke-Pester -Configuration $Config
if ($Result.PassedCount -eq 0) { throw "No tests passed; check discovery and filters." }
if (-not $Intune) {
    $ModuleTestPath = [System.IO.Path]::GetFullPath((Join-Path -Path $Root -ChildPath "tests/Module.Tests.ps1"))
    $ModuleContainer = @($Result.Containers | Where-Object { $_.Name -ieq $ModuleTestPath })
    $ModulePath = Join-Path -Path $Root -ChildPath "VcRedist"
    $ScriptCount = @(Get-ChildItem -Path $ModulePath -Recurse -Include "*.ps1", "*.psm1", "*.psd1").Count
    $FunctionCount = @(Get-ChildItem -Path $ModulePath -Recurse -Filter "*.ps1").Count
    $ExpectedCount = (2 * $ScriptCount) + (2 * $FunctionCount) + 2
    if ($ModuleContainer.Count -ne 1 -or $ModuleContainer[0].PassedCount -lt $ExpectedCount) {
        $PassedCount = if ($ModuleContainer.Count -eq 1) { $ModuleContainer[0].PassedCount } else { 0 }
        throw "Module validation cases were not discovered or did not pass: expected at least $ExpectedCount passed cases, found $PassedCount in $($ModuleContainer.Count) matching test containers."
    }
}
