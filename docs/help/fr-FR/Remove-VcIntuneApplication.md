---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/remove-vcintuneapplication/
schema: 2.0.0
---

# Remove-VcIntuneApplication

## SYNOPSIS
Supprime de Microsoft Intune les redistribuables Microsoft Visual C++ importés avec Import-VcIntuneApplication.
Accepte une liste de redistribuables Visual C++ provenant de Get-VcList, recherche les redistribuables Visual C++ correspondants dans Intune et les supprime d’Intune.

## SYNTAX

```
Remove-VcIntuneApplication [-VcList] <PSObject> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Supprime de Microsoft Intune les redistribuables Microsoft Visual C++ importés avec Import-VcIntuneApplication.
Accepte une liste de redistribuables Visual C++ provenant de Get-VcList, recherche les redistribuables Visual C++ correspondants dans Intune et les supprime d’Intune.

## EXAMPLES

### EXAMPLE 1
```
$VcList = Get-VcList -Release "2017"
Remove-VcIntuneApplication -VcList $VcList -Confirm:$false
```

Description : Recherche dans Microsoft Intune les packages de redistribuables Microsoft Visual C++ 2017 et les supprime.

## PARAMETERS

### -VcList
Tableau contenant les informations sur les redistribuables Visual C++ provenant de Get-VcList ou de Save-VcRedist.

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

[Supprimer les redistribuables : ](https://vcredist.com/remove-vcintuneapplication/)

