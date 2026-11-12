InModuleScope VcRedist {
    Describe "New-VcConfigMgrArchitectureRequirement" {
        BeforeAll {
            function Get-CMGlobalCondition { param ($Name) }
            function New-CMGlobalConditionScript { param ($Name, $DataType, $ScriptLanguage, $ScriptText, $Use32BitHost) }
            function New-CMRequirementRuleCommonValue { param ($GlobalCondition, $RuleOperator, $Value1) }
        }
        BeforeEach {
            Mock Get-CMGlobalCondition { $null }
            Mock New-CMGlobalConditionScript { [PSCustomObject]@{ Name = $Name } }
            Mock New-CMRequirementRuleCommonValue { [PSCustomObject]@{ Values = $Value1 } }
        }
        It "Creates a native-architecture condition and a rule for supported targets" {
            $Rule = New-VcConfigMgrArchitectureRequirement -SupportedArchitecture @("AMD64", "ARM64")
            $Rule.Values | Should -Be @("AMD64", "ARM64")
            Should -Invoke New-CMGlobalConditionScript -Times 1 -ParameterFilter {
                $ScriptText -match "Win32_Processor" -and $ScriptLanguage -eq "PowerShell" -and $Use32BitHost -eq $false
            }
            Should -Invoke New-CMRequirementRuleCommonValue -Times 1 -ParameterFilter {
                $RuleOperator -eq "OneOf" -and $Value1 -contains "ARM64"
            }
        }
        It "Reuses an existing condition" {
            Mock Get-CMGlobalCondition { [PSCustomObject]@{ Name = $Name } }
            New-VcConfigMgrArchitectureRequirement -SupportedArchitecture @("AMD64") | Out-Null
            Should -Invoke New-CMGlobalConditionScript -Times 0
            Should -Invoke New-CMRequirementRuleCommonValue -Times 1
        }
        It "Fails if the condition cannot be created" {
            Mock New-CMGlobalConditionScript { $null }
            { New-VcConfigMgrArchitectureRequirement -SupportedArchitecture @("AMD64") } | Should -Throw "*global condition*"
            Should -Invoke New-CMRequirementRuleCommonValue -Times 0
        }
    }
}
