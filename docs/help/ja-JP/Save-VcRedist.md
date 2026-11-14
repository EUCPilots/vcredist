---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/save-vcredist/
schema: 2.0.0
---

# Save-VcRedist

## SYNOPSIS
Get-VcList が返すマニフェストから Visual C++ Redistributable をダウンロードします。
Get-VcList の出力に Redistributable インストーラーのパスを Path プロパティとして追加します。
この出力は、ダウンロード済みインストーラーを必要とする他の関数に渡すことができます。

## SYNTAX

```
Save-VcRedist [-VcList] <PSObject> [[-Path] <String>] [-ForceWebRequest] [-Priority <String>]
 [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-UserAgent <String>] [-ShowProgress] [-SkipAuthenticodeValidation]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Get-VcList が返すマニフェストから Visual C++ Redistributable をダウンロードし、リリース、バージョン、プロセッサ アーキテクチャを表すフォルダー構成に保存します。
指定したパスに Redistributable が既に存在する場合、再ダウンロードされません。

既定では、ダウンロードまたは再利用するインストーラーに有効な Microsoft Authenticode 署名があるか確認します。
macOS および Linux では、-SkipAuthenticodeValidation を指定すると、この確認を行わずにダウンロードできます。この指定は発行元の検証も省略するため、リスクを許容できる場合にのみ使用してください。HTTPS と許可されたホストの一覧による制限は引き続き適用されます。

たとえば、2010、2012、2013、2019 の Redistributable を C:\VcRedist にダウンロードすると、次のフォルダー構成が作成されます。

C:\VcRedist\2010\10.0.40219.325\x64 C:\VcRedist\2010\10.0.40219.325\x86 C:\VcRedist\2012\11.0.61030.0\x64 C:\VcRedist\2012\11.0.61030.0\x86 C:\VcRedist\2013\12.0.40664.0\x64 C:\VcRedist\2013\12.0.40664.0\x86 C:\VcRedist\2019\14.28.29913.0\x64 C:\VcRedist\2019\14.28.29913.0\x86

## EXAMPLES

### EXAMPLE 1
```
Save-VcRedist -VcList (Get-VcList) -Path C:\Redist
```

説明: サポート対象の Visual C++ Redistributable を C:\Redist にダウンロードします。

### EXAMPLE 2
```
Get-VcList | Save-VcRedist -Path C:\Redist
```

説明: サポート対象の Visual C++ Redistributable 一覧を Save-VcRedist に渡し、Redistributable を C:\Redist にダウンロードします。

### EXAMPLE 3
```
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Save-VcRedist -VcList $VcList -Path C:\Redist
```

説明: サポート対象の 2013 および 2019 x86 Visual C++ Redistributable 一覧を Save-VcRedist に渡し、Redistributable を C:\Redist にダウンロードします。

### EXAMPLE 4
```
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist
```

説明: 2010、2012、2013、2019 の Visual C++ Redistributable を C:\Redist にダウンロードします。

### EXAMPLE 5
```
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist -Proxy proxy.domain.local
```

説明: プロキシ サーバー 'proxy.domain.local' を使用して、2010、2012、2013、2019 の Visual C++ Redistributable を C:\Redist にダウンロードします。

### EXAMPLE 6
```
Get-VcList | Save-VcRedist -Path ./Redist -SkipAuthenticodeValidation
```

説明: Authenticode 署名または発行元の検証を行わずに、macOS または Linux で Redistributable をダウンロードします。

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

### -Path
Redistributable のダウンロード先フォルダーを指定します。省略した場合は現在のフォルダーを使用します。フォルダーが存在しない場合は作成されます。作成できない場合は、ダウンロードを開始する前にエラーが返されます。

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Resolve-Path -Path $PWD)
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceWebRequest
Start-BitsTransfer の代わりに Invoke-WebRequest を強制的に使用します。
下位互換性のためにのみ含まれています。

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

### -Priority
Start-BitsTransfer の使用時に優先度を強制します。
下位互換性のためにのみ含まれています。

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Foreground
Accept pipeline input: False
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

### -SkipAuthenticodeValidation
ダウンロード済みおよび既存のインストーラーに対する Authenticode 署名と発行元の検証を省略します。Authenticode 検証を利用できない macOS または Linux で使用します。セキュリティが低下しますが、HTTPS と許可されたホストの確認は引き続き有効です。

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

### -UserAgent
Web 要求に使用するユーザー エージェント文字列を指定します。

既定のユーザー エージェントはモジュールを識別します。例: VcRedist/5.0.0 (https://github.com/EUCPilots/vcredist; PowerShell 7.5.0; Win32NT 10.0.26100.0)

代わりにブラウザーのユーザー エージェント文字列を使用するには、PSUserAgent クラスのプロパティ (Chrome など) を指定します: Save-VcRedist -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)

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

[Redistributable をダウンロードする:](https://vcredist.com/save-vcredist/)
