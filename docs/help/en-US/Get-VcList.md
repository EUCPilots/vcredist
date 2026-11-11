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
This function reads the Visual C++ Redistributables listed in an internal manifest into an object that can be passed to other VcRedist functions.

The manifest is read from the VcRedist repository, so manifest updates do not require a module update. If the remote manifest is unavailable, invalid or older than the bundled manifest, the manifest included in the module is used.

A complete listing of the supported and all known redistributables is included in the module.
By default, Get-VcList will only return a list of the supported Visual C++ Redistributables.
To return any of the unsupported Redistributables, the -Export parameter is required with the output filtered with Where-Object.

The internal manifest can be exported with Export-VcManifest.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

Description: Return an object of the supported Visual C++ Redistributables from the embedded manifest.

### EXAMPLE 2
```
Get-VcList
```

Description: Returns the supported 2012, 2013 and 2022, x86 and x64 versions of the supported Visual C++ Redistributables from the embedded manifest.

### EXAMPLE 3
```
Get-VcList -Export All
```

Description: Returns a list of the all Visual C++ Redistributables from the embedded manifest, including unsupported versions.

### EXAMPLE 4
```
Get-VcList -Export Supported
```

Description: Returns the full list of supported Visual C++ Redistributables from the embedded manifest.
This is the same as running Get-VcList with no parameters.

### EXAMPLE 5
```
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

Description: Returns the full list of unsupported Visual C++ Redistributables from the embedded manifest and filters for the 2008 versions of the Redistributables.

### EXAMPLE 6
```
Get-VcList -Release 2013, 2019 -Architecture x86
```

Description: Returns the 2013 and 2019 x86 Visual C++ Redistributables from the list of supported Redistributables in the embedded manifest.

### EXAMPLE 7
```
Get-VcList -Source Bundled
```

Description: Returns the supported Visual C++ Redistributables using only the manifest included in the module, without contacting the remote manifest.

## PARAMETERS

### -Release
Specifies the release (or version) of the redistributables to return.

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
Specifies the processor architecture to of the redistributables to return.
Can be x86 or x64.

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
Defines the list of Visual C++ Redistributables to export - All, Supported or Unsupported Redistributables.
Defaults to exporting the Supported Redistributables.

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
Specifies a proxy server for requests to fetch the manifest or download content.

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
Specifies a user account that has permission to use the proxy server specified by -Proxy. If not specified, default proxy credentials are used.

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
Selects the manifest source. `Auto` (default) uses the remote manifest hosted in the VcRedist repository and falls back to the bundled manifest on any failure, or when the remote manifest is older. `Remote` fails if the remote manifest is unavailable. `Bundled` uses only the manifest included in the module.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Get the list of Visual C++ Redistributables:](https://vcredist.com/get-vclist/)

