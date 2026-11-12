---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/Get-VcIntuneApplication/
schema: 2.0.0
---

# Get-VcIntuneApplication

## SYNOPSIS
Fragt Microsoft Intune nach der Liste der von VcRedist importierten Microsoft Visual C++ Redistributables ab.

## SYNTAX

```
Get-VcIntuneApplication [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Fragt Microsoft Intune nach der Liste der von VcRedist importierten Microsoft Visual C++ Redistributables ab und gibt diese Liste an die Pipeline zurück.
Diese Funktion gibt nur die Visual-C++-Redistributable-Pakete in Intune zurück, die von VcRedist importiert wurden.

## EXAMPLES

### EXAMPLE 1
```
Get-VcIntuneApplication
```

Description: Fragt Microsoft Intune nach den Microsoft-Visual-C++-Redistributable-Paketen ab und gibt sie an die Pipeline zurück.

## PARAMETERS

### -ProgressAction
Legt fest, wie PowerShell auf Fortschrittsmeldungen reagiert.

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
Dieses Cmdlet unterstützt die allgemeinen Parameter -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction und -WarningVariable. Weitere Informationen finden Sie unter [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Autor: Aaron Parker

## RELATED LINKS

[Redistributables in Intune abfragen:](https://vcredist.com/Get-VcIntuneApplication/)

