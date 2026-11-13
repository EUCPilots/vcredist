---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/get-installedvcredist/
schema: 2.0.0
---

# Get-InstalledVcRedist

## SYNOPSIS
Returns the installed Visual C++ Redistributables.

## SYNTAX

```
Get-InstalledVcRedist [[-Export] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries the registry to find the installed Visual C++ Redistributables on the local system and returns the list to the pipeline.
This includes the primary Redistributable entries by default and can export the additional and minimum Redistributable components also listed in the Registry.

## EXAMPLES

### EXAMPLE 1
```
Get-InstalledVcRedist
```

Description: Returns the installed Microsoft Visual C++ Redistributables from the current system.

### EXAMPLE 2
```
Get-InstalledVcRedist -Export All
```

Description: Returns the installed Microsoft Visual C++ Redistributables from the current system including the Additional and Minimum Runtimes.

## PARAMETERS

### -Export
Defines the installed Visual C++ Redistributables to return. Supported returns primary Redistributable entries; All also includes the Additional and Minimum Runtime components typically hidden from Programs and Features. Defaults to Supported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Supported
Accept pipeline input: False
Accept wildcard characters: False
Accepted values: Supported, All
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Get the locally installed Redistributables:](https://vcredist.com/get-installedvcredist/)

