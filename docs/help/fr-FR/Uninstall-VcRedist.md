---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/install-vcredist/
schema: 2.0.0
---

# Uninstall-VcRedist

## SYNOPSIS
Désinstalle les redistribuables Visual C++ installés sur le système local.

## SYNTAX

### Manual (Default)
```
Uninstall-VcRedist [[-Release] <String[]>] [[-Architecture] <String[]>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Pipeline
```
Uninstall-VcRedist [-VcList] <PSObject> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Désinstalle sur le système local les redistribuables Visual C++ installés correspondant à la version et/ou à l’architecture spécifiées.
Il est possible de désinstaller tous les redistribuables Visual C++ ou seulement certains d’entre eux.

## EXAMPLES

### EXAMPLE 1
```
Uninstall-VcRedist -Confirm:$True
```

Description : Désinstalle tous les redistribuables Visual C++ 2005 à 2019 installés pour x64 et x86.

### EXAMPLE 2
```
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

Description : Désinstalle tous les redistribuables Visual C++ 2008 et 2010 installés pour x64 et x86.

### EXAMPLE 3
```
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

Description : Désinstalle tous les redistribuables Visual C++ 2008 et 2010 installés pour x64 et x86.

## PARAMETERS

### -Release
Spécifie la version des redistribuables à désinstaller.

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: 1
Default value: @("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Spécifie l’architecture du processeur des redistribuables à désinstaller.
Peut être x86 ou x64.

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -VcList
Spécifie le tableau qui répertorie les redistribuables Visual C++ à télécharger.

```yaml
Type: PSObject
Parameter Sets: Pipeline
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
Affiche ce qui se passerait si l’applet de commande était exécutée.
L’applet de commande n’est pas exécutée.

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
Demande une confirmation avant d’exécuter l’applet de commande.

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

[Désinstaller les redistribuables : ](https://vcredist.com/uninstall-vcredist/)

