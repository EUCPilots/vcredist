---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/save-vcredist/
schema: 2.0.0
---

# Save-VcRedist

## SYNOPSIS
Télécharge les redistribuables Visual C++ à partir d’un manifeste renvoyé par Get-VcList.
La sortie de Get-VcList est modifiée : le chemin d’accès au programme d’installation du redistribuable est ajouté dans la propriété Path.
Cette sortie peut ensuite être transmise aux autres fonctions qui nécessitent le programme d’installation téléchargé.

## SYNTAX

```
Save-VcRedist [-VcList] <PSObject> [[-Path] <String>] [-ForceWebRequest] [-Priority <String>]
 [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-UserAgent <String>] [-ShowProgress] [-SkipAuthenticodeValidation]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Télécharge les redistribuables Visual C++ à partir d’un manifeste renvoyé par Get-VcList dans une arborescence de dossiers correspondant à la version, au numéro de version et à l’architecture du processeur.
Si le redistribuable existe déjà dans le chemin spécifié, il ne sera pas téléchargé à nouveau.

Par défaut, les programmes d’installation téléchargés ou réutilisés sont vérifiés afin de confirmer la validité de leur signature Microsoft Authenticode.
Sous macOS et Linux, utilisez -SkipAuthenticodeValidation pour télécharger sans cette vérification. Cela désactive également la vérification de l’éditeur ; ne le faites que si les risques sont acceptables. HTTPS et la liste des hôtes autorisés restent obligatoires.

Par exemple, l’arborescence de dossiers suivante sera créée lors du téléchargement des redistribuables 2010, 2012, 2013 et 2019 dans C:\VcRedist :

C:\VcRedist\2010\10.0.40219.325\x64 C:\VcRedist\2010\10.0.40219.325\x86 C:\VcRedist\2012\11.0.61030.0\x64 C:\VcRedist\2012\11.0.61030.0\x86 C:\VcRedist\2013\12.0.40664.0\x64 C:\VcRedist\2013\12.0.40664.0\x86 C:\VcRedist\2019\14.28.29913.0\x64 C:\VcRedist\2019\14.28.29913.0\x86

## EXAMPLES

### EXAMPLE 1
```
Save-VcRedist -VcList (Get-VcList) -Path C:\Redist
```

Description : Télécharge les redistribuables Visual C++ pris en charge dans C:\Redist.

### EXAMPLE 2
```
Get-VcList | Save-VcRedist -Path C:\Redist
```

Description : Transmet la liste des redistribuables Visual C++ pris en charge à Save-VcRedist et télécharge les redistribuables dans C:\Redist.

### EXAMPLE 3
```
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Save-VcRedist -VcList $VcList -Path C:\Redist
```

Description : Transmet la liste des redistribuables Visual C++ 2013 et 2019 pour x86 pris en charge à Save-VcRedist et les télécharge dans C:\Redist.

### EXAMPLE 4
```
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist
```

Description : Télécharge les redistribuables Visual C++ 2010, 2012, 2013 et 2019 dans C:\Redist.

### EXAMPLE 5
```
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist -Proxy proxy.domain.local
```

Description : Télécharge les redistribuables Visual C++ 2010, 2012, 2013 et 2019 dans C:\Redist à l’aide du serveur proxy 'proxy.domain.local'.

### EXAMPLE 6
```
Get-VcList | Save-VcRedist -Path ./Redist -SkipAuthenticodeValidation
```

Description : Télécharge les redistribuables sous macOS ou Linux sans vérifier leurs signatures Authenticode ni leur éditeur.

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

### -Path
Spécifie le dossier de destination des redistribuables à télécharger ; à défaut, le dossier actuel est utilisé. Le dossier est créé s’il n’existe pas. Si sa création échoue, une erreur est renvoyée avant tout téléchargement.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Resolve-Path -Path $PWD)
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceWebRequest
Force l’utilisation de Invoke-WebRequest à la place de Start-BitsTransfer.
Conservé uniquement pour assurer la compatibilité avec les versions précédentes.

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

### -Priority
Force la priorité lors de l’utilisation de Start-BitsTransfer.
Conservé uniquement pour assurer la compatibilité avec les versions précédentes.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Foreground
Accept pipeline input: False
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

### -SkipAuthenticodeValidation
Ignore la validation de la signature Authenticode et de l’éditeur pour les programmes d’installation téléchargés ou déjà présents. À utiliser sous macOS ou Linux, où la validation Authenticode n’est pas disponible. Cela réduit la sécurité ; les vérifications HTTPS et des hôtes autorisés restent activées.

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

### -UserAgent
Spécifie la chaîne d’agent utilisateur de la requête Web.

L’agent utilisateur par défaut identifie le module, par exemple : VcRedist/5.0.0 (https://github.com/EUCPilots/vcredist; PowerShell 7.5.0; Win32NT 10.0.26100.0)

Pour utiliser plutôt une chaîne d’agent utilisateur de navigateur, utilisez les propriétés de la classe PSUserAgent, par exemple Chrome : Save-VcRedist -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)

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

[Télécharger les redistribuables : ](https://vcredist.com/save-vcredist/)
