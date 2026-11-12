---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/install-vcredist/
schema: 2.0.0
---

# Uninstall-VcRedist

## SYNOPSIS
Desinstala los Redistribuibles de Visual C++ instalados en el sistema local.

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
Desinstala las versiones y/o arquitecturas especificadas de los Redistribuibles de Visual C++ instalados en el sistema local.
Se pueden desinstalar todos los Redistribuibles de Visual C++ o solo algunos.

## EXAMPLES

### EXAMPLE 1
```
Uninstall-VcRedist -Confirm:$True
```

Descripción: Desinstala todos los Redistribuibles de Visual C++ de 2005 a 2019 instalados para x64 y x86.

### EXAMPLE 2
```
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

Descripción: Desinstala todos los Redistribuibles de Visual C++ de 2008 y 2010 instalados para x64 y x86.

### EXAMPLE 3
```
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

Descripción: Desinstala todos los Redistribuibles de Visual C++ de 2008 y 2010 instalados para x64 y x86.

## PARAMETERS

### -Release
Especifica la versión de los redistribuibles que se desinstalarán.

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
Especifica la arquitectura del procesador de los redistribuibles que se desinstalarán.
Puede ser x86 o x64.

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
Especifica la matriz que enumera los Redistribuibles de Visual C++ que se descargarán.

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

[Desinstalar los Redistribuibles:](https://vcredist.com/uninstall-vcredist/)

