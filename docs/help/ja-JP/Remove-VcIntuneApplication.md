---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/remove-vcintuneapplication/
schema: 2.0.0
---

# Remove-VcIntuneApplication

## SYNOPSIS
Import-VcIntuneApplication を使用して Microsoft Intune にインポートされた Microsoft Visual C++ Redistributable を削除します。
Get-VcList から Visual C++ Redistributable の一覧を受け取り、一致する Visual C++ Redistributable を Intune に照会して削除します。

## SYNTAX

```
Remove-VcIntuneApplication [-VcList] <PSObject> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Import-VcIntuneApplication を使用して Microsoft Intune にインポートされた Microsoft Visual C++ Redistributable を削除します。
Get-VcList から Visual C++ Redistributable の一覧を受け取り、一致する Visual C++ Redistributable を Intune に照会して削除します。

## EXAMPLES

### EXAMPLE 1
```
$VcList = Get-VcList -Release "2017"
Remove-VcIntuneApplication -VcList $VcList -Confirm:$false
```

説明: Microsoft Intune に Microsoft Visual C++ Redistributable 2017 パッケージを照会し、削除します。

## PARAMETERS

### -VcList
Get-VcList または Save-VcRedist から取得した Visual C++ Redistributable の詳細を含む配列です。

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
コマンドレットを実行した場合の動作を表示します。
コマンドレットは実行されません。

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
コマンドレットの実行前に確認を求めます。

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

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

[Redistributable を削除する:](https://vcredist.com/remove-vcintuneapplication/)

