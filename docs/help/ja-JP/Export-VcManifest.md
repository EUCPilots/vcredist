---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/export-vcmanifest/
schema: 2.0.0
---

# Export-VcManifest

## SYNOPSIS
Visual C++ Redistributable の JSON マニフェストを外部ファイルにエクスポートします。

## SYNTAX

```
Export-VcManifest [-Path] <String> [-Source <String>] [-Proxy <String>] [-ProxyCredential <PSCredential>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
VcRedist モジュールに含まれる Visual C++ Redistributable の JSON マニフェストを読み込み、JSON を外部ファイルにエクスポートします。
これにより、カスタム シナリオ向けに JSON マニフェストを編集できます。

## EXAMPLES

### EXAMPLE 1
```
Export-VcManifest -Path "C:\Temp"
```

説明: サポート対象の Visual C++ Redistributable の一覧を C:\Temp\VisualCRedistributables.json にエクスポートします。

## PARAMETERS

### -Path
マニフェスト JSON ファイルのエクスポート先フォルダーのパスです。

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

### -Proxy
マニフェストの取得またはコンテンツのダウンロードに使用するプロキシ サーバーを指定します。

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

### -ProxyCredential
-Proxy で指定したプロキシ サーバーを使用する権限を持つユーザー アカウントを指定します。省略した場合は、既定のプロキシ資格情報が使用されます。

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
マニフェストのソースを選択します。`Auto` (既定) は VcRedist リポジトリでホストされるリモート マニフェストを使用し、何らかのエラーが発生した場合、またはリモート マニフェストが古い場合はバンドルされたマニフェストにフォールバックします。`Remote` はリモート マニフェストを利用できない場合に失敗します。`Bundled` はモジュールに含まれるマニフェストのみを使用します。

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

### -WhatIf
コマンドレットを実行した場合の動作を表示します。 コマンドレットは実行されません。

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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

### System.String
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Redistributable マニフェストをエクスポートする:](https://vcredist.com/export-vcmanifest/)

