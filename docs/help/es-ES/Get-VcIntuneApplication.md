---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/Get-VcIntuneApplication/
schema: 2.0.0
---

# Get-VcIntuneApplication

## SYNOPSIS
Consulta Microsoft Intune para obtener la lista de Redistribuibles de Microsoft Visual C++ importados por VcRedist.

## SYNTAX

```
Get-VcIntuneApplication [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Consulta Microsoft Intune para obtener la lista de Redistribuibles de Microsoft Visual C++ importados por VcRedist y la devuelve a la canalización.
Esta función solo devuelve los paquetes de Redistribuibles de Visual C++ de Intune que haya importado VcRedist.

## EXAMPLES

### EXAMPLE 1
```
Get-VcIntuneApplication
```

Descripción: Consulta Microsoft Intune para obtener los paquetes de Redistribuibles de Microsoft Visual C++ y los devuelve a la canalización.

## PARAMETERS

### -ProgressAction
Determina cómo responde PowerShell a las actualizaciones de progreso.

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
Este cmdlet admite los parámetros comunes: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction y -WarningVariable. Para obtener más información, consulta [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Consultar Intune para obtener redistribuibles:](https://vcredist.com/Get-VcIntuneApplication/)

