---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/import-vcintuneapplication/
schema: 2.0.0
---

# Import-VcIntuneApplication

## SYNOPSIS
Empaquette les programmes d’installation des redistribuables Microsoft Visual C++ au format intunewin et les importe en tant qu’applications dans un locataire Microsoft Intune.

## SYNTAX

```
Import-VcIntuneApplication [-VcList] <PSObject> [-ImportAsUpdate] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Crée une application dans un locataire Microsoft Intune pour chaque redistribuable Visual C++, avec notamment les propriétés suivantes : commande silencieuse cible, commande de désinstallation, détection (via le Registre) et exigences.

Utilisez Get-VcList et Save-VcRedist pour télécharger les redistribuables et créer le tableau à importer dans Microsoft Intune.

Un package d’application sera créé pour chaque redistribuable Visual C++, avec notamment les propriétés suivantes : Name, Description, Publisher, App Version, Information URL, Privacy URL, Notes, Logo, Install command, Uninstall command, Install behavior, Operating system architecture, Minimum operating system et Detection rules.

Cette fonction nécessite le module PowerShell IntuneWin32App et ne prend en charge que Windows PowerShell.
Avant d’utiliser cette fonction pour importer les redistribuables dans un locataire Intune, authentifiez-vous avec Connect-MSIntuneGraph.
L’exigence d’architecture provient de la liste SupportedArchitecture de chaque entrée du manifeste. IntuneWin32App 1.5.0 prend en charge les exigences incluant ARM64 utilisées par le manifeste intégré ; les combinaisons non prises en charge sont rejetées. Les applications existantes ne sont pas modifiées, sauf si une mise à jour est importée.

Utilisez `-ImportAsUpdate` pour ajouter une exigence de version de fichier basée sur la valeur `DetectionFile` de chaque package. L’application s’applique uniquement si le fichier propre à l’architecture existe et est d’une version antérieure à celle du package. Elle ne s’applique pas aux nouvelles installations ni aux appareils disposant de la même version ou d’une version plus récente. Cela ne modifie ni les applications Intune existantes ni leurs affectations. Vérifiez le fichier de détection et sa version sur les appareils cibles, en particulier pour les anciens redistribuables non pris en charge susceptibles d’utiliser des assemblys côte à côte. Le manifeste distant peut fournir des chemins de détection différents de ceux du manifeste intégré.

## EXAMPLES

### EXAMPLE 1
```
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com
$VcList = Get-VcList -Release "2022" | Save-VcRedist -Path "C:\Temp\VcRedist"
Import-VcIntuneApplication -VcList $VcList
```

Description : S’authentifie auprès du locataire spécifié, récupère la liste des redistribuables Visual C++ version 2022, les télécharge dans C:\Temp\VcRedist et importe chaque redistribuable dans le locataire Intune cible en tant qu’application distincte.

### EXAMPLE 2
```
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com -ClientId "f99877d5-f757-438e-b12b-d905b00ea6f3" -ClientSecret <secret>
Get-VcList | Save-VcRedist -Path "C:\Temp\VcRedist" | Import-VcIntuneApplication
```

Description : S’authentifie auprès du locataire spécifié à l’aide d’une inscription d’application Azure AD pour une authentification non interactive, récupère la liste des redistribuables Visual C++ pris en charge, les télécharge dans C:\Temp\VcRedist et importe chaque redistribuable dans le locataire Intune cible en tant qu’application distincte.

### EXAMPLE 3
```
Get-VcList -Release "14" | Save-VcRedist -Path "C:\Temp\VcRedist" | Import-VcIntuneApplication -ImportAsUpdate
```

Importe les applications v14 qui s’appliquent uniquement aux appareils sur lesquels une version antérieure du runtime est installée.

## PARAMETERS

### -ImportAsUpdate
Ajoute une exigence selon laquelle le fichier `DetectionFile` du package doit exister et avoir une version de fichier inférieure à celle du package.

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

### -Confirm
Demande une confirmation avant d’exécuter l’applet de commande.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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

### -WhatIf
Affiche ce qui se passerait si l’applet de commande était exécutée. L’applet de commande n’est pas exécutée.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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
