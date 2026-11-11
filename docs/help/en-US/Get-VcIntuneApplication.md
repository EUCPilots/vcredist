---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/Get-VcIntuneApplication/
schema: 2.0.0
---

# Get-VcIntuneApplication

## SYNOPSIS
Queries Microsoft Intune for the list Microsoft Visual C++ Redistributables imported by VcRedist.

## SYNTAX

```
Get-VcIntuneApplication [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Queries Microsoft Intune for the list Microsoft Visual C++ Redistributables imported by VcRedist and returns the list to the pipeline.
This function will only return those Visual C++ Redistributable packages in Intune imported by VcRedist.

## EXAMPLES

### EXAMPLE 1
```
Get-VcIntuneApplication
```

Description: Queries Microsoft Intune for the Microsoft Visual C++ Redistributables packages and returns them to the pipeline.

## PARAMETERS

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

[Query Intune for Redistributables:](https://vcredist.com/Get-VcIntuneApplication/)

