---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/Get-VcIntuneApplication/
schema: 2.0.0
---

# Get-VcIntuneApplication

## SYNOPSIS
Interroge Microsoft Intune pour obtenir la liste des redistribuables Microsoft Visual C++ importés par VcRedist.

## SYNTAX

```
Get-VcIntuneApplication [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Interroge Microsoft Intune pour obtenir la liste des redistribuables Microsoft Visual C++ importés par VcRedist et renvoie la liste dans le pipeline.
Cette fonction renvoie uniquement les packages de redistribuables Visual C++ importés dans Intune par VcRedist.

## EXAMPLES

### EXAMPLE 1
```
Get-VcIntuneApplication
```

Description : Interroge Microsoft Intune pour obtenir les packages de redistribuables Microsoft Visual C++ et les renvoie dans le pipeline.

## PARAMETERS

### -ProgressAction
Détermine la façon dont PowerShell réagit aux mises à jour de progression.

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
Cette applet de commande prend en charge les paramètres communs suivants : -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction et -WarningVariable. Pour plus d’informations, consultez [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Interroger Intune pour obtenir les redistribuables : ](https://vcredist.com/Get-VcIntuneApplication/)

