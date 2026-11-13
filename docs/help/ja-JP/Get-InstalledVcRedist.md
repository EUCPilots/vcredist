---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/get-installedvcredist/
schema: 2.0.0
---

# Get-InstalledVcRedist

## SYNOPSIS
インストール済みの Visual C++ Redistributable を返します。

## SYNTAX

```
Get-InstalledVcRedist [-Export <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
レジストリを照会してローカル システムにインストールされた Visual C++ Redistributable を検索し、その一覧をパイプラインに返します。
既定では主要な Redistributable エントリが含まれます。また、レジストリに記載された追加および最小 Redistributable コンポーネントもエクスポートできます。

## EXAMPLES

### EXAMPLE 1
```
Get-InstalledVcRedist
```

説明: 現在のシステムにインストールされている Microsoft Visual C++ Redistributable を返します。

### EXAMPLE 2
```
Get-InstalledVcRedist -Export All
```

説明: 追加および最小ランタイムを含め、現在のシステムにインストールされている Microsoft Visual C++ Redistributable を返します。

## PARAMETERS

### -Export
返すインストール済み Visual C++ Redistributable を指定します。Supported は主要な Redistributable エントリのみを返し、All は通常「プログラムと機能」に表示されない追加および最小ランタイム コンポーネントも含めます。既定値は Supported です。

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Supported
Accept pipeline input: False
Accept wildcard characters: False
Accepted values: Supported, All
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

[ローカルにインストールされた Redistributable を取得する:](https://vcredist.com/get-installedvcredist/)

