---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/import-vcconfigmgrapplication/
schema: 2.0.0
---

# Import-VcConfigMgrApplication

## SYNOPSIS
Crée des applications de redistribuables Visual C++ sur un site ConfigMgr.

## SYNTAX

```
Import-VcConfigMgrApplication [-VcList] <PSObject> [-Path <String>] [-CMPath] <String> [-SMSSiteCode] <String>
 [[-AppFolder] <String>] [-Silent] [-NoCopy] [[-Publisher] <String>] [[-Keyword] <String>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Crée une application dans un site Configuration Manager pour chaque redistribuable Visual C++ et définit notamment si celui-ci peut s’exécuter sur Windows 32 ou 64 bits, ainsi que la clé de désinstallation permettant de détecter sa présence.
Chaque type de déploiement reçoit une exigence d’architecture basée sur SupportedArchitecture. La fonction crée ou réutilise une condition globale de script à l’échelle du site qui détecte l’architecture native de Windows sur les appareils cibles.

Utilisez Get-VcList et Save-VcRedist pour télécharger le redistribuable et créer le tableau de redistribuables à importer dans ConfigMgr.

Les applications seront importées dans ConfigMgr avec des propriétés par défaut similaires aux suivantes :

Location: Applications\VcRedists Name: Visual C++ Redistributable 2019 x86 14.28.29913.0 Administrator comments: Microsoft Visual C++ Redistributable 2019 x86 14.28.29913.0 importé par Import-VcConfigMgrApplication Publisher: Microsoft Software version: 14.28.29913.0 Language: en-US Date published: 18/03/2021 Localized application name: Visual C++ Redistributable 2019 x86 14.28.29913.0 User documentation: https://visualstudio.microsoft.com/vs/support/ Link text: https://www.visualstudio.com/downloads/ Privacy URL: https://go.microsoft.com/fwlink/?LinkId=521839 Keywords: Visual C++ Redistributable

Deployment type: Name: SCRIPT_Visual C++ Redistributable for Visual Studio 2019 Technology: Script Installer Administrator comments: Généré par Import-VcConfigMgrApplication Content location: \configmgr\Applications\VcRedists\2019\14.28.29913.0\x86\ Installation program: VC_redist.x86.exe /install /quiet /norestart Uninstall program: "%ProgramData%\Package Cache\{03d1453c-7d5c-479c-afea-8482f406e036}\VC_redist.x86.exe" /uninstall /quiet /noreboot Detection method: (Registry path)

## EXAMPLES

### EXAMPLE 1
```
$VcList = Get-VcList | Save-VcRedist -Path "C:\Temp\VcRedist"
Import-VcConfigMgrApplication -VcList $VcList -CMPath "\\server\share\VcRedist" -SMSSiteCode LAB
```

Description : Télécharge les redistribuables Visual C++ pris en charge dans "C:\Temp\VcRedist", les copie dans "\server\share\VcRedist" et les importe en tant qu’applications dans le site ConfigMgr LAB.

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

### -CMPath
Spécifie un chemin UNC à partir duquel les redistribuables Visual C++ seront distribués.

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

### -SMSSiteCode
Spécifie le code de site à utiliser pour créer les applications ConfigMgr.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
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
Position: 5
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

### -NoCopy
Ne copie pas les fichiers binaires des redistribuables Visual C++ lors de l’importation d’applications dans Configuration Manager.

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

### -Publisher
Spécifie éventuellement le nom de l’éditeur à utiliser dans l’application Configuration Manager.

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

### -Keyword
Spécifie un ou plusieurs mots-clés à ajouter à l’application Configuration Manager.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: Visual C++ Redistributable
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

[Importer des redistribuables dans ConfigMgr : ](https://vcredist.com/import-vcconfigmgrapplication/)

