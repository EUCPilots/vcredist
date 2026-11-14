---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/update-vcmdtbundle/
schema: 2.0.0
---

# Update-VcMdtBundle

## SYNOPSIS
Met à jour les lots d’applications de redistribuables Visual C++ dans un partage Microsoft Deployment Toolkit.

## SYNTAX

```
Update-VcMdtBundle [-MdtPath] <String> [-AppFolder <String>] [[-MdtDrive] <String>] [[-Publisher] <String>]
 [[-BundleName] <String>] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Après avoir importé ou ajouté des applications de redistribuables Visual C++ dans un partage Microsoft Deployment Toolkit, vous pouvez mettre à jour un lot existant avec les GUID des nouvelles applications de redistribuables Visual C++.

Le lot sera mis à jour dans le partage de déploiement MDT avec des propriétés par défaut similaires aux suivantes :

Location: Applications\VcRedists Name: Microsoft Visual C++ Redistributables Comments: Lot d’applications destiné à installer les redistribuables Visual C++.
Généré par New-VcMdtBundle Short name: Visual C++ Redistributables Version:2021-Mar-18 Publisher: Microsoft Language: en-US Dependencies: (VcRedists in the MDT share)

## EXAMPLES

### EXAMPLE 1
```
Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist
Update-VcMdtApplication -VcList (Get-VcList) -Path C:\Temp\VcRedist -MdtPath \\server\deployment
Update-VcMdtBundle -MdtPath \\server\deployment
```

Description : Récupère la liste des redistribuables Visual C++, les télécharge dans C:\Temp\VcRedist et met à jour chaque redistribuable dans le partage de déploiement MDT situé à \server\deployment.

## PARAMETERS

### -MdtPath
Chemin local ou réseau du partage de déploiement MDT.

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

### -AppFolder
Sous-dossier de Applications dans lequel se trouvent les redistribuables Visual C++.
La valeur par défaut est "VcRedists".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: VcRedists
Accept pipeline input: False
Accept wildcard characters: False
```

### -MdtDrive
Spécifie éventuellement le nom du lecteur PSDrive à utiliser pour se connecter au partage de déploiement MDT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: DS001
Accept pipeline input: False
Accept wildcard characters: False
```

### -Publisher
Spécifie éventuellement le nom de l’éditeur à utiliser dans l’application MDT.
La valeur par défaut est "Microsoft".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Microsoft
Accept pipeline input: False
Accept wildcard characters: False
```

### -BundleName
Spécifie éventuellement un nom personnalisé pour le lot MDT.
La valeur par défaut est "Visual C++ Redistributables".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Visual C++ Redistributables
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

[Mettre à jour le lot de redistribuables dans MDT : ](https://vcredist.com/update-vcmdtbundle/)

