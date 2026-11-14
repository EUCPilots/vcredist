function New-VcConfigMgrArchitectureRequirement {
    <#
        .SYNOPSIS
            Creates a ConfigMgr requirement for the target Windows architecture.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String[]] $SupportedArchitecture
    )

    $ScriptText = (Get-Command -Name "Get-VcOperatingSystemArchitecture" -CommandType "Function" -ErrorAction "Stop").Definition
    $Hasher = [System.Security.Cryptography.SHA256]::Create()
    try {
        $Hash = [System.BitConverter]::ToString($Hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ScriptText))).Replace("-", "").Substring(0, 16)
    }
    finally {
        $Hasher.Dispose()
    }
    $Name = "VcRedist native Windows architecture $Hash"
    $Conditions = @(Get-CMGlobalCondition -Name $Name -ErrorAction "Stop" | Where-Object { $null -ne $_ })
    if ($Conditions.Count -gt 1) {
        throw "Multiple ConfigMgr global conditions named '$Name' were found."
    }
    if ($Conditions.Count -eq 0) {
        $Condition = New-CMGlobalConditionScript -Name $Name -DataType "String" -ScriptLanguage "PowerShell" `
            -ScriptText $ScriptText -Use32BitHost $false -ErrorAction "Stop"
    }
    else {
        $Condition = $Conditions[0]
    }
    if ($null -eq $Condition) {
        throw "Unable to create the ConfigMgr global condition '$Name'."
    }
    $Rule = New-CMRequirementRuleCommonValue -GlobalCondition $Condition -RuleOperator "OneOf" -Value1 $SupportedArchitecture -ErrorAction "Stop"
    if ($null -eq $Rule) {
        throw "Unable to create the ConfigMgr architecture requirement."
    }
    Write-Output -InputObject $Rule
}
