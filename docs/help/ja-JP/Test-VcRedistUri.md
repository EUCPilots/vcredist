---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com/vcredist/test/
schema: 2.0.0
---

# Test-VcRedistUri

## SYNOPSIS
各 Visual C++ Redistributable のダウンロード URI にアクセスできるかをテストします。

## SYNTAX

```
Test-VcRedistUri [-VcList] <PSObject> [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-ShowProgress]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
各エントリについて、HTTPS と許可されたホストを検証し、タイムアウト 30 秒で HEAD 要求を送信します。

各入力エントリについて、Result、Release、Architecture、Version、URI プロパティを含む結果オブジェクトを返します。HTTPS HEAD 要求が成功すると Result は true になり、URI が許可されていない場合や要求に失敗した場合は false になります。

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
Test-VcRedistUri -VcList (Get-VcList -Export All)
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProxyCredential
Proxy パラメーターで指定したプロキシ サーバーを使用する権限を持つユーザー アカウントを指定します。
既定では、プロキシ資格情報は指定されません。

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

[Redistributable ダウンロードをテストする:](https://stealthpuppy.com/vcredist/test/)

