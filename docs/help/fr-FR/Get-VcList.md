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

Le manifeste est lu depuis le dépôt VcRedist ; les mises à jour du manifeste ne nécessitent donc pas de mise à jour du module. Si le manifeste distant est indisponible, invalide ou plus ancien que le manifeste intégré, le manifeste inclus dans le module est utilisé.

Le module contient la liste complète des redistribuables pris en charge et de tous ceux qui sont connus.
Par défaut, Get-VcList renvoie uniquement la liste des redistribuables Visual C++ pris en charge.
Pour renvoyer les redistribuables non pris en charge, le paramètre -Export est requis ; filtrez ensuite la sortie avec Where-Object.

Le manifeste interne peut être exporté avec Export-VcManifest.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

Description : Renvoie un objet contenant les redistribuables Visual C++ pris en charge à partir du manifeste intégré.

### EXAMPLE 2
```
Get-VcList
```

Description : Renvoie, à partir du manifeste intégré, les versions 2012, 2013 et 2022 prises en charge des redistribuables Visual C++ pour x86 et x64.

### EXAMPLE 3
```
Get-VcList -Export All
```

Description : Renvoie la liste de tous les redistribuables Visual C++ du manifeste intégré, y compris les versions non prises en charge.

### EXAMPLE 4
```
Get-VcList -Export Supported
```

Description : Renvoie la liste complète des redistribuables Visual C++ pris en charge à partir du manifeste intégré.
Cela équivaut à exécuter Get-VcList sans paramètre.

### EXAMPLE 5
```
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

Description : Renvoie la liste complète des redistribuables Visual C++ non pris en charge du manifeste intégré, puis filtre les versions 2008.

### EXAMPLE 6
```
Get-VcList -Release 2013, 2019 -Architecture x86
```

Description : Renvoie les redistribuables Visual C++ 2013 et 2019 pour x86 à partir de la liste des redistribuables pris en charge du manifeste intégré.

### EXAMPLE 7
```
Get-VcList -Source Bundled
```

Description : Renvoie les redistribuables Visual C++ pris en charge en utilisant uniquement le manifeste inclus dans le module, sans contacter le manifeste distant.

## PARAMETERS

### -Release
Spécifie la version des redistribuables à renvoyer.

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 1
Default value: @("2012", "2013", "2022")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Spécifie l’architecture du processeur des redistribuables à renvoyer.
Peut être x86 ou x64.

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Définit la liste des redistribuables Visual C++ à exporter : tous, ceux pris en charge ou ceux non pris en charge.
Par défaut, les redistribuables pris en charge sont exportés.

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
Spécifie un serveur proxy pour les requêtes de récupération du manifeste ou de téléchargement du contenu.

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
Spécifie un compte utilisateur autorisé à utiliser le serveur proxy indiqué par -Proxy. Si cette valeur n’est pas spécifiée, les informations d’identification proxy par défaut sont utilisées.

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
Sélectionne la source du manifeste. `Auto` (valeur par défaut) utilise le manifeste distant hébergé dans le dépôt VcRedist et revient au manifeste intégré en cas d’échec ou si le manifeste distant est plus ancien. `Remote` échoue si le manifeste distant n’est pas disponible. `Bundled` utilise uniquement le manifeste inclus dans le module.

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

### CommonParameters
Cette applet de commande prend en charge les paramètres communs suivants : -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction et -WarningVariable. Pour plus d’informations, consultez [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Obtenir la liste des redistribuables Visual C++ : ](https://vcredist.com/get-vclist/)

