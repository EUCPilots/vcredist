---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/export-vcmanifest/
schema: 2.0.0
---

# Export-VcManifest

## SYNOPSIS
Exporte le manifeste JSON des redistribuables Visual C++ vers un fichier externe.

## SYNTAX

```
Export-VcManifest [-Path] <String> [-Source <String>] [-Proxy <String>] [-ProxyCredential <PSCredential>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Lit les manifestes JSON des redistribuables Visual C++ inclus dans le module VcRedist et exporte le JSON vers un fichier externe.
Cela permet de modifier le manifeste JSON pour des scénarios personnalisés.

## EXAMPLES

### EXAMPLE 1
```
Export-VcManifest -Path "C:\Temp"
```

Description : Exporte la liste des redistribuables Visual C++ pris en charge vers C:\Temp\VisualCRedistributables.json.

## PARAMETERS

### -Path
Chemin du dossier dans lequel le fichier manifeste JSON sera exporté.

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

### System.String
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Exporter les manifestes des redistribuables : ](https://vcredist.com/export-vcmanifest/)

