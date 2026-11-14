---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/install-vcredist/
schema: 2.0.0
---

# Uninstall-VcRedist

## SYNOPSIS
ローカル システムにインストールされた Visual C++ Redistributable をアンインストールします。

## SYNTAX

### Manual (Default)
```
Uninstall-VcRedist [[-Release] <String[]>] [[-Architecture] <String[]>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Pipeline
```
Uninstall-VcRedist [-VcList] <PSObject> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
ローカル システムにインストールされた Visual C++ Redistributable のうち、指定したリリースおよび/またはアーキテクチャをアンインストールします。
すべての Visual C++ Redistributable、または特定のものをアンインストールできます。

## EXAMPLES

### EXAMPLE 1
```
Uninstall-VcRedist -Confirm:$True
```

説明: インストール済みの 2005～2019 Visual C++ Redistributable のうち、x64 および x86 をすべてアンインストールします。

### EXAMPLE 2
```
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

説明: インストール済みの 2008 および 2010 Visual C++ Redistributable のうち、x64 および x86 をすべてアンインストールします。

### EXAMPLE 3
```
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

説明: インストール済みの 2008 および 2010 Visual C++ Redistributable のうち、x64 および x86 をすべてアンインストールします。

## PARAMETERS

### -Release
アンインストールする Redistributable のリリースを指定します。

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: 1
Default value: @("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
アンインストールする Redistributable のプロセッサ アーキテクチャを指定します。
x86 または x64 を指定できます。

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -VcList
ダウンロードする Visual C++ Redistributable の一覧を含む配列を指定します。

```yaml
Type: PSObject
Parameter Sets: Pipeline
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

[Redistributable をアンインストールする:](https://vcredist.com/uninstall-vcredist/)

