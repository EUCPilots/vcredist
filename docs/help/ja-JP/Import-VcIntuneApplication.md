---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/import-vcintuneapplication/
schema: 2.0.0
---

# Import-VcIntuneApplication

## SYNOPSIS
Microsoft Visual C++ Redistributable インストーラーを intunewin 形式にパッケージ化し、Microsoft Intune テナントにアプリケーションとしてインポートします。

## SYNTAX

```
Import-VcIntuneApplication [-VcList] <PSObject> [-ImportAsUpdate] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
各 Visual C++ Redistributable について Microsoft Intune テナントにアプリケーションを作成し、対象のサイレント コマンド、アンインストール コマンド、検出 (レジストリ経由)、要件などのプロパティを設定します。

Get-VcList と Save-VcRedist を使用して Redistributable をダウンロードし、Microsoft Intune にインポートする配列を作成します。

各 Visual C++ Redistributable のアプリケーション パッケージが作成されます。パッケージには、名前、説明、発行元、アプリのバージョン、情報 URL、プライバシー URL、メモ、ロゴ、インストール コマンド、アンインストール コマンド、インストール動作、オペレーティング システムのアーキテクチャ、最小オペレーティング システム、検出規則などのプロパティが含まれます。

この関数には IntuneWin32App PowerShell モジュールが必要で、サポートされるのは Windows PowerShell のみです。
この関数を使用して Redistributable を Intune テナントにインポートする前に、Connect-MSIntuneGraph で認証してください。
アーキテクチャ要件は、各マニフェスト エントリの SupportedArchitecture リストに基づきます。IntuneWin32App 1.5.0 は、バンドルされたマニフェストで使用される ARM64 を含む要件をサポートします。サポートされない組み合わせは拒否されます。更新をインポートしない限り、既存のアプリケーションは変更されません。

`-ImportAsUpdate` を使用すると、各パッケージの `DetectionFile` に基づくファイル バージョン要件が追加されます。アーキテクチャ固有のファイルが存在し、パッケージ バージョンより古い場合にのみアプリが適用対象になります。クリーン インストールや、同じバージョンまたは新しいバージョンがあるデバイスには適用されません。既存の Intune アプリや割り当ては変更されません。特にサイド バイ サイド アセンブリを使用する可能性のある古いサポート対象外の Redistributable については、対象デバイス上の検出ファイルとバージョンを確認してください。リモート マニフェストでは、バンドルされたマニフェストとは異なる検出パスが指定される場合があります。

## EXAMPLES

### EXAMPLE 1
```
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com
$VcList = Get-VcList -Release "2022" | Save-VcRedist -Path "C:\Temp\VcRedist"
Import-VcIntuneApplication -VcList $VcList
```

説明: 指定したテナントで認証し、Visual C++ Redistributable 2022 の一覧を取得して C:\Temp\VcRedist にダウンロードし、各 Redistributable を個別のアプリケーションとして対象の Intune テナントにインポートします。

### EXAMPLE 2
```
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com -ClientId "f99877d5-f757-438e-b12b-d905b00ea6f3" -ClientSecret <secret>
Get-VcList | Save-VcRedist -Path "C:\Temp\VcRedist" | Import-VcIntuneApplication
```

説明: Azure AD アプリ登録を使用して指定したテナントで非対話型認証を行い、サポート対象の Visual C++ Redistributable 一覧を取得して C:\Temp\VcRedist にダウンロードし、各 Redistributable を個別のアプリケーションとして対象の Intune テナントにインポートします。

### EXAMPLE 3
```
Get-VcList -Release "14" | Save-VcRedist -Path "C:\Temp\VcRedist" | Import-VcIntuneApplication -ImportAsUpdate
```

インストール済みランタイムが古いデバイスにのみ適用される v14 アプリケーションをインポートします。

## PARAMETERS

### -ImportAsUpdate
パッケージの `DetectionFile` が存在し、そのファイル バージョンがパッケージ バージョンより低いことを要件として追加します。

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

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Redistributable を MDT にインポートする](https://vcredist.com/import-vcmdtapplication/)
