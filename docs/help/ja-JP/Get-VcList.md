---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/get-vclist/
schema: 2.0.0
---

# Get-VcList

## SYNOPSIS
他の VcRedist 関数で使用する Microsoft Visual C++ Redistributable のオブジェクトを返します。

## SYNTAX

### Manifest (Default)
```
Get-VcList [[-Release] <String[]>] [[-Architecture] <String[]>] [-Source <String>] [-Proxy <String>]
 [-ProxyCredential <PSCredential>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Export
```
Get-VcList [[-Export] <String>] [-Source <String>] [-Proxy <String>] [-ProxyCredential <PSCredential>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
この関数は、内部マニフェストに記載された Visual C++ Redistributable を読み込み、他の VcRedist 関数に渡せるオブジェクトにします。
インストール済みの Redistributable は確認しません。確認には Get-InstalledVcRedist を使用してください。

Auto では、最初にバンドルされたマニフェストを読み込み、次にリモート マニフェストを確認します。リモートが利用できない、無効、または古い場合は、バンドルされたマニフェストを使用します。バンドルされたマニフェストが無効または読み込み不能な場合はエラーになります。

Release と Architecture は、サポート状況に関係なく一致するエントリを選択します。選択されたエントリにサポート対象外のものがある場合は警告が表示されます。
これらのパラメーターを指定しない場合、x86、x64、arm64 のリリース 14 が選択されます。
-Export Supported、Unsupported、または All を使用すると、すべてのリリースからサポート状況に応じて選択するか、すべてのエントリを返すことができます。Export は Release または Architecture と併用できません。
All と Unsupported は、サポート対象外のエントリがない場合でも常に警告を表示します。
SilentUninstall の #Installer と #ProductCode は、URI のインストーラー ファイル名とエントリの製品コードに置き換えられます。

内部マニフェストは Export-VcManifest でエクスポートできます。

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

説明: 選択されたマニフェストから、x86、x64、arm64 のリリース 14 を返します。

### EXAMPLE 2
```
Get-VcList -Release 2015 -Architecture x86
```

説明: 2015 の x86 Redistributable を返し、選択されたエントリがサポート対象外の場合は警告します。

### EXAMPLE 3
```
Get-VcList -Export All
```

説明: 選択されたマニフェスト内のすべての Visual C++ Redistributable を返し、警告を表示します。

### EXAMPLE 4
```
Get-VcList -Export Supported
```

説明: 選択されたマニフェストから、すべてのリリースのサポート対象 Redistributable を返します。

### EXAMPLE 5
```
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

説明: 選択されたマニフェストからサポート対象外の Redistributable を取得し、そのうち 2008 バージョンをフィルターします。

### EXAMPLE 6
```
Get-VcList -Release 2013, 2019 -Architecture x86
```

説明: 選択されたマニフェストから、2013 および 2019 の x86 Visual C++ Redistributable を返します。

### EXAMPLE 7
```
Get-VcList -Source Bundled
```

説明: モジュールに含まれるマニフェストのみを使用して、リリース 14 の Redistributable を返します。

## PARAMETERS

### -Release
返す Redistributable のリリース (またはバージョン) を指定します。
各値は 2 桁から 4 桁の数字で指定します。完全なバージョン番号は使用できません。

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 1
Default value: @("14")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
返す Redistributable のプロセッサ アーキテクチャを指定します。
x86、x64、または arm64 を指定できます。

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64", "arm64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
エクスポートする Visual C++ Redistributable の一覧を指定します。All、Supported、または Unsupported を選択できます。
Export は Release または Architecture と併用できません。All と Unsupported は警告を表示します。

```yaml
Type: String
Parameter Sets: Export
Aliases:

Required: False
Position: 1
Default value: Supported
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
リモート マニフェストの取得に使用する、資格情報を含まない絶対 HTTP または HTTPS プロキシ URI を指定します。ProxyCredential を省略した場合は既定のプロキシ資格情報を使用します。

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
-Proxy で指定したプロキシ サーバーの資格情報を指定します。空でない資格情報には -Proxy が必要です。

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
マニフェストのソースを選択します。`Auto` (既定) はバンドルされたマニフェストを読み込み、リモートが有効で同じかそれ以上に新しい場合はリモートを使用します。`Remote` はリモートのみ、`Bundled` はバンドルされたマニフェストのみを使用します。

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Auto
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

[Visual C++ Redistributable の一覧を取得する:](https://vcredist.com/get-vclist/)

