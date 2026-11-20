---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/get-vclist/
schema: 2.0.0
---

# Get-VcList

## SYNOPSIS
Returns an object of Microsoft Visual C++ Redistributables for use with other VcRedist functions.

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
This function returns Visual C++ Redistributable entries from a manifest as objects that can be passed to other VcRedist functions.
It does not check which Redistributables are installed; use Get-InstalledVcRedist for that.

By default, `-Source Auto` reads the bundled manifest and tries the remote manifest from the VcRedist repository.
It uses the remote manifest if valid and at least as recent as the bundled manifest; otherwise it uses the bundled manifest.
An unavailable or invalid remote manifest produces a warning; an unreadable or invalid bundled manifest causes an error.
Use `-Source Bundled` for repeatable offline runs.

The Release and Architecture parameters select matching entries regardless of support status; a warning is emitted if any selected entries are unsupported.
Without these parameters, the command selects release 14 for x86, x64, and arm64.
Use `-Export Supported` or `-Export Unsupported` to select entries across releases by support status, or `-Export All` to return all entries.
The Export parameter cannot be combined with Release or Architecture.
The All and Unsupported export modes always emit a warning, even if the selected manifest contains no unsupported entries.

The returned objects include the manifest properties, including Supported, URI, and SupportedArchitecture.
In SilentUninstall, the #Installer and #ProductCode placeholders are replaced with the installer filename from URI and the entry's product code.

The internal manifest can be exported with Export-VcManifest.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

Description: Returns release 14 Redistributables for x86, x64, and arm64 from the selected manifest.

### EXAMPLE 2
```
Get-VcList -Release 2015 -Architecture x86
```

Description: Returns the x86 2015 Redistributables and warns if the selected entries are unsupported.

### EXAMPLE 3
```
Get-VcList -Export All
```

Description: Returns all Visual C++ Redistributables from the selected manifest, including unsupported versions, and emits a warning.

### EXAMPLE 4
```
Get-VcList -Export Supported
```

Description: Returns the full list of supported Visual C++ Redistributables from the selected manifest.
This includes supported entries from all releases, not just the default release 14.

### EXAMPLE 5
```
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

Description: Returns unsupported Redistributables from the selected manifest and filters for the 2008 versions.

### EXAMPLE 6
```
Get-VcList -Release 2013, 2019 -Architecture x86
```

Description: Returns the 2013 and 2019 x86 Visual C++ Redistributables from the selected manifest.

### EXAMPLE 7
```
Get-VcList -Source Bundled
```

Description: Returns the release 14 Redistributables using only the manifest included in the module, without contacting the remote manifest.

## PARAMETERS

### -Release
Specifies one or more release labels to match, such as `14` or `2015`.
Each value must contain two to four digits; full version numbers are not accepted.

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
Specifies the processor architectures of the Redistributables to return: x86, x64, or arm64.

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
Defines the list of Visual C++ Redistributables to export - All, Supported or Unsupported Redistributables.
This parameter selects the Export parameter set and cannot be combined with Release or Architecture.
All and Unsupported emit a warning.

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
Determines how PowerShell responds to progress updates.

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
Specifies an absolute HTTP or HTTPS proxy URI, without embedded credentials, for remote manifest requests.
If ProxyCredential is omitted, default proxy credentials are used.

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
Specifies credentials for the proxy server specified by -Proxy.
Non-empty credentials require -Proxy.

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
Selects the manifest source.
`Auto` (default) reads the bundled manifest, then selects the remote manifest if it is valid and at least as recent; otherwise it uses the bundled manifest.
`Remote` uses only the remote manifest and fails if it cannot be used.
`Bundled` uses only the bundled manifest.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
One object per matching manifest entry. No objects are returned when there are no matches.
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Get the list of Visual C++ Redistributables:](https://vcredist.com/get-vclist/)

