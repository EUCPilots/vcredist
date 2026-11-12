---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/install-vcredist/
schema: 2.0.0
---

# Install-VcRedist

## SYNOPSIS
ローカル システムに Visual C++ Redistributable をインストールします。

## SYNTAX

```
Install-VcRedist [-VcList] <PSObject> [-Path <String>] [-Silent] [-Force] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Get-VcList で作成された一覧を基に、Save-VcRedist でローカルのフォルダー構成にダウンロードした Microsoft Visual C++ Redistributable をインストールします。
Redistributable のパッシブ インストールとサイレント インストールの両方をサポートします。
HashiCorp Packer を使用したゴールド イメージの作成など、実行時に Redistributable をダウンロードしてインストールする Windows 展開に便利です。
マニフェストの SupportedArchitecture リストにネイティブ Windows アーキテクチャが含まれないインストーラーは、-Force を指定していても警告とともにスキップされます。
各入力オブジェクトには、空でない SupportedArchitecture リストが必要です。

## EXAMPLES

### EXAMPLE 1
```
$VcRedists = Get-VcList -Release 2013, 2019 -Architecture x64
Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists
```

説明: $VcRedists に含まれ、C:\Temp\VcRedists にダウンロードされた 2013 および 2019 の 64 ビット Visual C++ Redistributable をインストールします。

### EXAMPLE 2
```
$VcRedists = Get-VcList -Release "2012","2013","2017" -Architecture x64
Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists
```

説明: $VcRedists に含まれ、C:\Temp\VcRedists にダウンロードされた 64 ビットの 2012、2013、2017 Visual C++ Redistributable のみをインストールします。

### EXAMPLE 3
```
$VcRedists = Get-VcList -Release "2012","2013","2017" -Architecture x64 | Save-VcRedist -Path C:\Temp\VcRedists
Install-VcRedist -VcList $VcRedists -Silent
```

説明: サポート対象のすべての Visual C++ Redistributable を完全なサイレント インストールでインストールします。

## PARAMETERS

### -VcList
Save-VcRedist から取得した Visual C++ Redistributable の詳細を含む配列です。
Save-VcRedist は、Get-VcList からエクスポートされた配列に、インストーラー実行ファイルを指す Path プロパティを追加します。

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

### -Silent
UI を表示せずに VcRedist を完全なサイレント インストールで実行します。
既定のインストールはパッシブです。

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Visual C++ Redistributable がローカル システムに既にインストールされている場合でも、インストールを実行します。

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
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

### -Path
このパラメーターは廃止され、無視されます。-VcList に渡すオブジェクトに Path プロパティが必要です。

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
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

[Redistributable をインストールする:](https://vcredist.com/install-vcredist/)

