---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/remove-vcintuneapplication/
schema: 2.0.0
---

# Remove-VcIntuneApplication

## SYNOPSIS
Quita de Microsoft Intune los Redistribuibles de Microsoft Visual C++ importados mediante Import-VcIntuneApplication.
Acepta una lista de Redistribuibles de Visual C++ de Get-VcList, consulta Intune para encontrar los redistribuibles correspondientes y los quita de Intune.

## SYNTAX

```
Remove-VcIntuneApplication [-VcList] <PSObject> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Quita de Microsoft Intune los Redistribuibles de Microsoft Visual C++ importados mediante Import-VcIntuneApplication.
Acepta una lista de Redistribuibles de Visual C++ de Get-VcList, consulta Intune para encontrar los redistribuibles correspondientes y los quita de Intune.

## EXAMPLES

### EXAMPLE 1
```
$VcList = Get-VcList -Release "2017"
Remove-VcIntuneApplication -VcList $VcList -Confirm:$false
```

Descripción: Consulta Microsoft Intune para obtener los paquetes de Redistribuibles de Microsoft Visual C++ de 2017 y los quita.

## PARAMETERS

### -VcList
Una matriz con los detalles de los Redistribuibles de Visual C++ obtenidos de Get-VcList o Save-VcRedist.

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
Muestra lo que ocurriría si se ejecutara el cmdlet.
El cmdlet no se ejecuta.

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
Solicita confirmación antes de ejecutar el cmdlet.

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

[Quitar los redistribuibles:](https://vcredist.com/remove-vcintuneapplication/)

