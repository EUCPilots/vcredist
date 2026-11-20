---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/get-vclist/
schema: 2.0.0
---

# Get-VcList

## SYNOPSIS
Renvoie un objet contenant les redistribuables Microsoft Visual C++ à utiliser avec les autres fonctions de VcRedist.

## SYNTAX

### Manifest (Default)
```
Get-VcList [[-Release] <String[]>] [[-Architecture] <String[]>] [-Source <String>] [-Proxy <String>]
 [-ProxyCredential <PSCredential>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Export
```
Get-VcList [[-Export] <String>] [-Source <String>] [-Proxy <String>] [-ProxyCredential <PSCredential>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Cette fonction lit les redistribuables Visual C++ répertoriés dans un manifeste interne et les place dans un objet qui peut être transmis aux autres fonctions de VcRedist.
Elle ne vérifie pas quels redistribuables sont installés ; utilisez Get-InstalledVcRedist à cette fin.

Avec Auto, le manifeste intégré est lu en premier, puis le manifeste distant est vérifié. Si celui-ci est indisponible, invalide ou plus ancien, le manifeste intégré est utilisé. Si le manifeste intégré est invalide ou illisible, une erreur est renvoyée.

Release et Architecture sélectionnent les entrées correspondantes, qu'elles soient prises en charge ou non. Un avertissement est émis si une entrée sélectionnée n'est pas prise en charge.
Sans ces paramètres, la version 14 est sélectionnée pour x86, x64 et arm64.
Utilisez -Export Supported, Unsupported ou All pour sélectionner les entrées de toutes les versions selon leur prise en charge ou pour toutes les renvoyer. Export ne peut pas être combiné avec Release ou Architecture.
All et Unsupported émettent toujours un avertissement, même si toutes les entrées sont prises en charge.
Dans SilentUninstall, #Installer et #ProductCode sont remplacés par le nom du programme d'installation extrait de URI et le code produit de l'entrée.

Le manifeste interne peut être exporté avec Export-VcManifest.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

Description : Renvoie les redistribuables de la version 14 pour x86, x64 et arm64 à partir du manifeste sélectionné.

### EXAMPLE 2
```
Get-VcList -Release 2015 -Architecture x86
```

Description : Renvoie les redistribuables 2015 pour x86 et avertit si les entrées sélectionnées ne sont pas prises en charge.

### EXAMPLE 3
```
Get-VcList -Export All
```

Description : Renvoie tous les redistribuables Visual C++ du manifeste sélectionné et émet un avertissement.

### EXAMPLE 4
```
Get-VcList -Export Supported
```

Description : Renvoie les redistribuables pris en charge de toutes les versions du manifeste sélectionné.

### EXAMPLE 5
```
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

Description : Renvoie les redistribuables non pris en charge du manifeste sélectionné, puis filtre les versions 2008.

### EXAMPLE 6
```
Get-VcList -Release 2013, 2019 -Architecture x86
```

Description : Renvoie les redistribuables Visual C++ 2013 et 2019 pour x86 à partir du manifeste sélectionné.

### EXAMPLE 7
```
Get-VcList -Source Bundled
```

Description : Renvoie les redistribuables de la version 14 en utilisant uniquement le manifeste inclus dans le module.

## PARAMETERS

### -Release
Spécifie la version des redistribuables à renvoyer.
Chaque valeur doit contenir deux à quatre chiffres ; les numéros de version complets ne sont pas acceptés.

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 1
Default value: @("14")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Spécifie l’architecture du processeur des redistribuables à renvoyer.
Peut être x86, x64 ou arm64.

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64", "arm64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Définit la liste des redistribuables Visual C++ à exporter : tous, ceux pris en charge ou ceux non pris en charge.
Export ne peut pas être combiné avec Release ou Architecture. All et Unsupported émettent un avertissement.

```yaml
Type: String
Parameter Sets: Export
Aliases:

Required: False
Position: 1
Default value: Supported
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

### -Proxy
Spécifie un URI proxy HTTP ou HTTPS absolu, sans informations d'identification intégrées, pour récupérer le manifeste distant. Si ProxyCredential est omis, les informations d'identification proxy par défaut sont utilisées.

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

### -ProxyCredential
Spécifie les informations d'identification du serveur proxy indiqué par -Proxy. Des informations d'identification non vides nécessitent -Proxy.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
Sélectionne la source du manifeste. `Auto` (valeur par défaut) lit le manifeste intégré et utilise le manifeste distant s'il est valide et au moins aussi récent. `Remote` utilise uniquement le manifeste distant. `Bundled` utilise uniquement le manifeste intégré.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Auto
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

[Obtenir la liste des redistribuables Visual C++ : ](https://vcredist.com/get-vclist/)

