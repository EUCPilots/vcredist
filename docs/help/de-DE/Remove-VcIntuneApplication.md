---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/remove-vcintuneapplication/
schema: 2.0.0
---

# Remove-VcIntuneApplication

## SYNOPSIS
Entfernt Microsoft Visual C++ Redistributables, die über Import-VcIntuneApplication in Microsoft Intune importiert wurden.
Akzeptiert eine Liste von Visual C++ Redistributables aus Get-VcList, fragt Intune nach passenden Visual C++ Redistributables ab und entfernt diese aus Intune.

## SYNTAX

```
Remove-VcIntuneApplication [-VcList] <PSObject> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Entfernt Microsoft Visual C++ Redistributables, die über Import-VcIntuneApplication in Microsoft Intune importiert wurden.
Akzeptiert eine Liste von Visual C++ Redistributables aus Get-VcList, fragt Intune nach passenden Visual C++ Redistributables ab und entfernt diese aus Intune.

## EXAMPLES

### EXAMPLE 1
```
$VcList = Get-VcList -Release "2017"
Remove-VcIntuneApplication -VcList $VcList -Confirm:$false
```

Description: Fragt Microsoft Intune nach den Microsoft-Visual-C++-Redistributable-Paketen des Jahres 2017 ab und entfernt sie.

## PARAMETERS

### -VcList
Ein Array mit Details zu den Visual C++ Redistributables aus Get-VcList oder Save-VcRedist.

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
Zeigt, was bei Ausführung des Cmdlets geschehen würde.
Das Cmdlet wird nicht ausgeführt.

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
Fordert vor der Ausführung des Cmdlets zur Bestätigung auf.

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
Legt fest, wie PowerShell auf Fortschrittsmeldungen reagiert.

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
Dieses Cmdlet unterstützt die allgemeinen Parameter -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction und -WarningVariable. Weitere Informationen finden Sie unter [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Autor: Aaron Parker

## RELATED LINKS

[Redistributables entfernen:](https://vcredist.com/remove-vcintuneapplication/)

