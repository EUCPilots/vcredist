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

マニフェストは VcRedist リポジトリから読み込まれるため、マニフェストを更新する際にモジュールを更新する必要はありません。リモート マニフェストを利用できない場合、無効な場合、またはバンドルされたマニフェストより古い場合は、モジュールに含まれるマニフェストが使用されます。

サポート対象および既知のすべての再頒布可能パッケージの一覧がモジュールに含まれています。
既定では、Get-VcList はサポート対象の Visual C++ Redistributable の一覧のみを返します。
サポート対象外の Redistributable を返すには、-Export パラメーターを指定し、Where-Object で出力をフィルターする必要があります。

内部マニフェストは Export-VcManifest でエクスポートできます。

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

説明: 埋め込みマニフェストからサポート対象の Visual C++ Redistributable のオブジェクトを返します。

### EXAMPLE 2
```
Get-VcList
```

説明: 埋め込みマニフェストから、サポート対象の Visual C++ Redistributable のうち、2012、2013、2022 の x86 および x64 バージョンを返します。

### EXAMPLE 3
```
Get-VcList -Export All
```

説明: サポート対象外のバージョンを含む、埋め込みマニフェスト内のすべての Visual C++ Redistributable の一覧を返します。

### EXAMPLE 4
```
Get-VcList -Export Supported
```

説明: 埋め込みマニフェストからサポート対象の Visual C++ Redistributable の完全な一覧を返します。
これは、パラメーターを指定せずに Get-VcList を実行する場合と同じです。

### EXAMPLE 5
```
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

説明: 埋め込みマニフェストからサポート対象外の Visual C++ Redistributable の完全な一覧を取得し、そのうち 2008 バージョンをフィルターします。

### EXAMPLE 6
```
Get-VcList -Release 2013, 2019 -Architecture x86
```

説明: 埋め込みマニフェストのサポート対象 Redistributable 一覧から、2013 および 2019 の x86 Visual C++ Redistributable を返します。

### EXAMPLE 7
```
Get-VcList -Source Bundled
```

説明: リモート マニフェストに接続せず、モジュールに含まれるマニフェストのみを使用して、サポート対象の Visual C++ Redistributable を返します。

## PARAMETERS

### -Release
返す Redistributable のリリース (またはバージョン) を指定します。

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 1
Default value: @("2012", "2013", "2022")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
返す Redistributable のプロセッサ アーキテクチャを指定します。
x86 または x64 を指定できます。

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
エクスポートする Visual C++ Redistributable の一覧を指定します。All、Supported、または Unsupported を選択できます。
既定では、サポート対象の Redistributable がエクスポートされます。

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

### CommonParameters
このコマンドレットは共通パラメーター (-Debug、-ErrorAction、-ErrorVariable、-InformationAction、-InformationVariable、-OutVariable、-OutBuffer、-PipelineVariable、-Verbose、-WarningAction、-WarningVariable) をサポートします。詳細については、[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216) を参照してください。

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Visual C++ Redistributable の一覧を取得する:](https://vcredist.com/get-vclist/)

