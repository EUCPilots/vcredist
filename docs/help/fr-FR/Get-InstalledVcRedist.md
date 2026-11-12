---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/get-installedvcredist/
schema: 2.0.0
---

# Get-InstalledVcRedist

## SYNOPSIS
Renvoie les redistribuables Visual C++ installés.

## SYNTAX

```
Get-InstalledVcRedist [-ExportAll] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Interroge le Registre pour trouver les redistribuables Visual C++ installés sur le système local et renvoie la liste dans le pipeline.
Par défaut, la liste comprend les entrées principales des redistribuables. Elle peut également inclure les composants supplémentaires et minimaux répertoriés dans le Registre.

## EXAMPLES

### EXAMPLE 1
```
Get-InstalledVcRedist
```

Description : Renvoie les redistribuables Microsoft Visual C++ installés sur le système actuel.

### EXAMPLE 2
```
Get-InstalledVcRedist -ExportAll
```

Description : Renvoie les redistribuables Microsoft Visual C++ installés sur le système actuel, y compris les composants d’exécution supplémentaires et minimaux.

## PARAMETERS

### -ExportAll
Exporte tous les redistribuables installés, y compris les composants d’exécution supplémentaires et minimaux généralement masqués dans Programmes et fonctionnalités.

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

[Obtenir la liste des redistribuables installés localement : ](https://vcredist.com/get-installedvcredist/)

