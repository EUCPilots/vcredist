---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/import-vcmdtapplication/
schema: 2.0.0
---

# New-VcMdtBundle

## SYNOPSIS
Crée des applications de redistribuables Visual C++ dans un partage Microsoft Deployment Toolkit.

## SYNTAX

```
New-VcMdtBundle [-MdtPath] <String> [[-AppFolder] <String>] [-Force] [[-MdtDrive] <String>]
 [[-Publisher] <String>] [[-BundleName] <String>] [[-Language] <String>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Crée une application dans un partage Microsoft Deployment Toolkit pour chaque redistribuable Visual C++, avec notamment la ligne de commande silencieuse cible, la plateforme et la clé de désinstallation.

Utilisez Get-VcList et Save-VcRedist pour télécharger les redistribuables et créer le tableau à importer dans MDT.

Le lot sera importé dans le partage de déploiement MDT avec des propriétés par défaut similaires aux suivantes :

Location: Applications\VcRedists Name: Microsoft Visual C++ Redistributables Comments: Lot d’applications destiné à installer les redistribuables Visual C++.
Généré par New-VcMdtBundle Short name: Visual C++ Redistributables Version:2021-Mar-18 Publisher: Microsoft Language: en-US Dependencies: (VcRedists in the MDT share)

## EXAMPLES

### EXAMPLE 1
```
Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist | Import-VcMdtApplication -Path C:\Temp\VcRedist -MdtPath \\server\deployment
```

Description : Récupère la liste des redistribuables Visual C++, les télécharge dans C:\Temp\VcRedist et importe chaque redistribuable dans le partage de déploiement MDT situé à \server\deployment.

### EXAMPLE 2
```
$VcList = Get-VcList -ExportAll | Save-VcRedist -Path C:\Temp\VcRedist
Import-VcMdtApplication -VcList $VcList -MdtPath \\server\deployment -Bundle
```

Description : Récupère dans la variable $VcList la liste des redistribuables Visual C++ pris en charge ou non, les télécharge dans C:\Temp\VcRedist, importe chaque redistribuable dans le partage de déploiement MDT situé à \server\deployment et crée un lot d’applications.

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
Importe les redistribuables Visual C++ dans un sous-dossier.
La valeur par défaut est "VcRedists".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: VcRedists
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Force l’importation et le remplacement d’un lot existant dans le partage de déploiement MDT.

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

### -MdtDrive
Spécifie éventuellement le nom du lecteur PSDrive à utiliser pour se connecter au partage de déploiement MDT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: DS001
Accept pipeline input: False
Accept wildcard characters: False
```

### -Publisher
Spécifie éventuellement le nom de l’éditeur à utiliser dans le lot MDT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Microsoft
Accept pipeline input: False
Accept wildcard characters: False
```

### -BundleName
Spécifie éventuellement un nom personnalisé pour le lot MDT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Visual C++ Redistributables
Accept pipeline input: False
Accept wildcard characters: False
```

### -Language
Spécifie éventuellement la propriété de langue à appliquer à l’application MDT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: En-US
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

[Créer un lot de redistribuables dans MDT : ](https://vcredist.com/new-vcmdtbundle/)

