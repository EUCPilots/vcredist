---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/export-vcmanifest/
schema: 2.0.0
---

# Export-VcManifest

## SYNOPSIS
Exports the Visual C++ Redistributables JSON manifest to an external file.

## SYNTAX

```
Export-VcManifest [-Path] <String> [-Source <String>] [-Proxy <String>] [-ProxyCredential <PSCredential>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Reads the Visual C++ Redistributables JSON manifests included in the VcRedist module and exports the JSON to an external file.
This enables editing of the JSON manifest for custom scenarios.

## EXAMPLES

### EXAMPLE 1
```
Export-VcManifest -Path "C:\Temp"
```

Description: Export the list of supported Visual C++ Redistributables to C:\Temp\VisualCRedistributables.json.

## PARAMETERS

### -Path
Path to the folder the manifest JSON file will be exported to.

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
Prompts you for confirmation before running the cmdlet.

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

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Export the Redistributable Manifests:](https://vcredist.com/export-vcmanifest/)

