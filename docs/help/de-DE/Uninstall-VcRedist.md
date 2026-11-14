---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/install-vcredist/
schema: 2.0.0
---

# Uninstall-VcRedist

## SYNOPSIS
Deinstalliert die auf dem lokalen System installierten Visual C++ Redistributables.

## SYNTAX

### Manual (Default)
```
Uninstall-VcRedist [[-Release] <String[]>] [[-Architecture] <String[]>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Pipeline
```
Uninstall-VcRedist [-VcList] <PSObject> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Deinstalliert die angegebenen Releases und/oder Architekturen der auf dem lokalen System installierten Visual C++ Redistributables.
Es können alle oder bestimmte Visual C++ Redistributables deinstalliert werden.

## EXAMPLES

### EXAMPLE 1
```
Uninstall-VcRedist -Confirm:$True
```

Description: Deinstalliert alle installierten Visual C++ Redistributables für x64 und x86 aus den Jahren 2005 bis 2019.

### EXAMPLE 2
```
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

Description: Deinstalliert alle installierten Visual C++ Redistributables für x64 und x86 aus den Jahren 2008 und 2010.

### EXAMPLE 3
```
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

Description: Deinstalliert alle installierten Visual C++ Redistributables für x64 und x86 aus den Jahren 2008 und 2010.

## PARAMETERS

### -Release
Gibt das zu deinstallierende Release der Redistributables an.

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: 1
Default value: @("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Gibt die Prozessorarchitektur der zu deinstallierenden Redistributables an.
Mögliche Werte sind x86 und x64.

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -VcList
Gibt das Array mit den herunterzuladenden Visual C++ Redistributables an.

```yaml
Type: PSObject
Parameter Sets: Pipeline
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

[Redistributables deinstallieren:](https://vcredist.com/uninstall-vcredist/)

