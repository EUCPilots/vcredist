---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/test-vcredisturi/
schema: 2.0.0
---

# Test-VcRedistUri

## SYNOPSIS
Vérifie que les téléchargements des redistribuables Visual C++ répertoriés dans le manifeste renvoyé par Get-VcList sont disponibles (c’est-à-dire
qu’ils renvoient une réponse HTTP 200).

## SYNTAX

```
Test-VcRedistUri [-VcList] <PSObject> [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-ShowProgress]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Vérifie que les téléchargements des redistribuables Visual C++ répertoriés dans le manifeste renvoyé par Get-VcList sont disponibles (c’est-à-dire
qu’ils renvoient une réponse HTTP 200).

Une valeur vraie ou fausse est renvoyée pour chaque redistribuable Visual C++ transmis à la fonction.

## EXAMPLES

### EXAMPLE 1
```
Test-VcRedistUri -VcList (Get-VcList)
```

Description : Teste les redistribuables Visual C++ transmis par Get-VcList.

### EXAMPLE 2
```
Get-VcList | Test-VcRedistUri
```

Description : Transmet la liste des redistribuables Visual C++ pris en charge de Get-VcList à Test-VcRedistUri via le pipeline.

### EXAMPLE 3
```
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Test-VcRedistUri -VcList $VcList
```

Description : Teste la liste des redistribuables Visual C++ 2013 et 2019 pour x86 pris en charge.

### EXAMPLE 4
```
Test-VcRedistUri -VcList (Get-VcList -ExportAll)
```

Description : Exporte tous les redistribuables Visual C++ pris en charge ou non, puis teste les téléchargements pour déterminer s’ils sont valides.

## PARAMETERS

### -VcList
Spécifie le tableau qui répertorie les redistribuables Visual C++ à télécharger.

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

### -Proxy
Spécifie un serveur proxy pour la requête, au lieu de se connecter directement à la ressource Internet.
Saisissez l’URI d’un serveur proxy réseau.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProxyCredential
Spécifie un compte utilisateur autorisé à utiliser le serveur proxy indiqué par le paramètre Proxy.
Par défaut, il s’agit de l’utilisateur actuel.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: [System.Management.Automation.PSCredential]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowProgress
Demande à Invoke-WebRequest, utilisé par cette fonction, d’afficher la progression.

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

[Télécharger les redistribuables : ](https://vcredist.com/save-vcredist/)

