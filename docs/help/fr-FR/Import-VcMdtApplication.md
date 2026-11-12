---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/import-vcmdtapplication/
schema: 2.0.0
---

# Import-VcMdtApplication

## SYNOPSIS
Crée des applications de redistribuables Visual C++ dans un partage Microsoft Deployment Toolkit.

## SYNTAX

```
Import-VcMdtApplication [-VcList] <PSObject> [-Path <String>] [-MdtPath] <String> [[-AppFolder] <String>]
 [-Silent] [-DontHide] [-Force] [[-MdtDrive] <String>] [[-Publisher] <String>] [[-Language] <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Crée une application dans un partage Microsoft Deployment Toolkit pour chaque redistribuable Visual C++, avec notamment la ligne de commande silencieuse cible, la plateforme et la clé de désinstallation.
Les plateformes prises en charge sont déterminées à partir du manifeste. Les packages uniquement ARM64 sont ignorés avec un avertissement, car MDT ne prend pas en charge les déploiements ARM64.

Utilisez Get-VcList et Save-VcRedist pour télécharger les redistribuables et créer le tableau à importer dans MDT.

Les applications seront importées dans le partage de déploiement MDT avec des propriétés par défaut similaires aux suivantes :

Location: Applications\VcRedists Name: Visual C++ Redistributable 2019 x86 14.28.29913.0 Comments: Généré par Import-VcMdtApplication Short name: Visual C++ Redistributable for Visual Studio 2019 x86 Version: 14.28.29913.0 Publisher: Microsoft Language: en-US Source directory: .\Applications\Microsoft VcRedist\2019\14.28.29913.0\x86 Quiet install command: .\VC_redist.x86.exe /install /quiet /norestart Working directory: .\Applications\Microsoft VcRedist\2019\14.28.29913.0\x86 Uninstall registry key name: {03d1453c-7d5c-479c-afea-8482f406e036} Hide this application in the Deployment Wizard: Yes

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

### -MdtPath
Chemin local ou réseau du partage de déploiement MDT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppFolder
Spécifie un dossier du nœud Applications dans lequel les VcRedists seront importés.
La valeur par défaut est 'VcRedists'.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: VcRedists
Accept pipeline input: False
Accept wildcard characters: False
```

### -Silent
Ajoute une commande d’installation totalement silencieuse de VcRedist, sans interface utilisateur.
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

### -DontHide
Indique que l’option 'Hide this application in the Deployment Wizard' n’est pas sélectionnée.

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
Force l’importation et le remplacement d’une application existante dans le partage de déploiement MDT.

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
Position: 5
Default value: DS001
Accept pipeline input: False
Accept wildcard characters: False
```

### -Publisher
Spécifie éventuellement le nom de l’éditeur à utiliser dans l’application MDT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: Microsoft
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
Position: 7
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

[Importer des redistribuables dans MDT](https://vcredist.com/import-vcmdtapplication/)

