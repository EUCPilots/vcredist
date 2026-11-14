---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/install-vcredist/
schema: 2.0.0
---

# Install-VcRedist

## SYNOPSIS
Installe les redistribuables Visual C++ sur le système local.

## SYNTAX

```
Install-VcRedist [-VcList] <PSObject> [-Path <String>] [-Silent] [-Force] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Installe les redistribuables Microsoft Visual C++ à partir d’une liste créée par Get-VcList et téléchargée localement dans une arborescence de dossiers avec Save-VcRedist.
Prend en charge l’installation passive et silencieuse des redistribuables.
Utile pour les déploiements Windows, notamment pour créer des images de référence avec HashiCorp Packer, où les redistribuables peuvent être téléchargés et installés au moment de l’exécution.
Les programmes d’installation dont la liste SupportedArchitecture du manifeste ne comprend pas l’architecture native de Windows sont ignorés avec un avertissement, même si -Force est utilisé.
Chaque objet d’entrée doit contenir une liste SupportedArchitecture non vide.

## EXAMPLES

### EXAMPLE 1
```
$VcRedists = Get-VcList -Release 2013, 2019 -Architecture x64
Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists
```

Description : Installe les redistribuables Visual C++ 2013 et 2019 64 bits répertoriés dans $VcRedists et téléchargés dans C:\Temp\VcRedists.

### EXAMPLE 2
```
$VcRedists = Get-VcList -Release "2012","2013","2017" -Architecture x64
Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists
```

Description : Installe uniquement les redistribuables Visual C++ 2012, 2013 et 2017 64 bits répertoriés dans $VcRedists et téléchargés dans C:\Temp\VcRedists.

### EXAMPLE 3
```
$VcRedists = Get-VcList -Release "2012","2013","2017" -Architecture x64 | Save-VcRedist -Path C:\Temp\VcRedists
Install-VcRedist -VcList $VcRedists -Silent
```

Description : Installe tous les redistribuables Visual C++ pris en charge en mode totalement silencieux.

## PARAMETERS

### -VcList
Tableau contenant les informations sur les redistribuables Visual C++ provenant de Save-VcRedist.
Save-VcRedist ajoute à ce tableau la propriété Path, qui pointe vers le fichier exécutable du programme d’installation, exporté par Get-VcList.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Silent
Effectue une installation totalement silencieuse de VcRedist, sans interface utilisateur.
L’installation par défaut est passive.

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

### -Force
Installe un redistribuable Visual C++ même s’il est déjà installé sur le système local.

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

### -Path
Ce paramètre est obsolète et ignoré. La propriété Path doit figurer dans l’objet transmis à -VcList.

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

[Installer les redistribuables : ](https://vcredist.com/install-vcredist/)

