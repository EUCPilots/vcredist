---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/test-vcredisturi/
schema: 2.0.0
---

# Test-VcRedistUri

## SYNOPSIS
Get-VcList が返すマニフェストに記載された Visual C++ Redistributable のダウンロードが利用可能であること (つまり、
HTTP 200 応答を返すこと) をテストします。

## SYNTAX

```
Test-VcRedistUri [-VcList] <PSObject> [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-ShowProgress]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Get-VcList が返すマニフェストに記載された Visual C++ Redistributable のダウンロードが利用可能であること (つまり、
HTTP 200 応答を返すこと) をテストします。

この関数に渡された各 Visual C++ Redistributable について、True または False が返されます。

## EXAMPLES

### EXAMPLE 1
```
Test-VcRedistUri -VcList (Get-VcList)
```

説明: Get-VcList から渡された Visual C++ Redistributable をテストします。

### EXAMPLE 2
```
Get-VcList | Test-VcRedistUri
```

説明: Get-VcList のサポート対象 Visual C++ Redistributable 一覧をパイプライン経由で Test-VcRedistUri に渡します。

### EXAMPLE 3
```
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Test-VcRedistUri -VcList $VcList
```

説明: サポート対象の 2013 および 2019 x86 Visual C++ Redistributable の一覧をテストします。

### EXAMPLE 4
```
Test-VcRedistUri -VcList (Get-VcList -ExportAll)
```

説明: サポート対象および対象外のすべての Visual C++ Redistributable をエクスポートし、ダウンロードが有効かどうかをテストします。

## PARAMETERS

### -VcList
ダウンロードする Visual C++ Redistributable の一覧を含む配列を指定します。

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

### -Proxy
インターネット上のリソースに直接接続する代わりに、要求に使用するプロキシ サーバーを指定します。
ネットワーク プロキシ サーバーの URI を入力します。

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProxyCredential
Proxy パラメーターで指定したプロキシ サーバーを使用する権限を持つユーザー アカウントを指定します。
既定では現在のユーザーが使用されます。

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: [System.Management.Automation.PSCredential]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowProgress
この関数で使用する Invoke-WebRequest に進行状況を表示するよう指示します。

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

[Redistributable をダウンロードする:](https://vcredist.com/save-vcredist/)

