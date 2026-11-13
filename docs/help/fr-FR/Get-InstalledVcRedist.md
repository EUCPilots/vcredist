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
Get-InstalledVcRedist [-Export <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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
Get-InstalledVcRedist -Export All
```

Description : Renvoie les redistribuables Microsoft Visual C++ installés sur le système actuel, y compris les composants d’exécution supplémentaires et minimaux.

## PARAMETERS

### -Export
Définit les redistribuables Visual C++ installés à renvoyer. Supported renvoie uniquement les entrées principales ; All inclut également les composants d’exécution supplémentaires et minimaux généralement masqués dans Programmes et fonctionnalités. La valeur par défaut est Supported.

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

