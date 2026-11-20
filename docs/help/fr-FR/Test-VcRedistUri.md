---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com/vcredist/test/
schema: 2.0.0
---

# Test-VcRedistUri

## SYNOPSIS
Vérifie si l’URI de téléchargement de chaque redistribuable Visual C++ est accessible.

## SYNTAX

```
Test-VcRedistUri [-VcList] <PSObject> [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-ShowProgress]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Pour chaque entrée, valide le protocole HTTPS et l’hôte autorisé, puis envoie une requête HEAD avec un délai d’expiration de 30 secondes.

Renvoie un objet de résultat par entrée, avec les propriétés Result, Release, Architecture, Version et URI. Result vaut true si la requête HTTPS HEAD réussit et false si l’URI n’est pas autorisée ou si la requête échoue.

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
Test-VcRedistUri -VcList (Get-VcList -Export All)
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProxyCredential
Spécifie un compte utilisateur autorisé à utiliser le serveur proxy indiqué par le paramètre Proxy.
Par défaut, aucun identifiant de proxy n’est fourni.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

[Tester les téléchargements des redistribuables :](https://stealthpuppy.com/vcredist/test/)

