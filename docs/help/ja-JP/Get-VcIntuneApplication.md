---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/Get-VcIntuneApplication/
schema: 2.0.0
---

# Get-VcIntuneApplication

## SYNOPSIS
VcRedist によってインポートされた Microsoft Visual C++ Redistributable の一覧を Microsoft Intune に照会します。

## SYNTAX

```
Get-VcIntuneApplication [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
VcRedist によってインポートされた Microsoft Visual C++ Redistributable の一覧を Microsoft Intune に照会し、その一覧をパイプラインに返します。
この関数は、VcRedist によって Intune にインポートされた Visual C++ Redistributable パッケージのみを返します。

## EXAMPLES

### EXAMPLE 1
```
Get-VcIntuneApplication
```

説明: Microsoft Intune に Microsoft Visual C++ Redistributable パッケージを照会し、結果をパイプラインに返します。

## PARAMETERS

### -ProgressAction
進行状況の更新に対する PowerShell の応答方法を指定します。

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
このコマンドレットは共通パラメーター (-Debug、-ErrorAction、-ErrorVariable、-InformationAction、-InformationVariable、-OutVariable、-OutBuffer、-PipelineVariable、-Verbose、-WarningAction、-WarningVariable) をサポートします。詳細については、[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216) を参照してください。

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Intune に Redistributable を照会する:](https://vcredist.com/Get-VcIntuneApplication/)

