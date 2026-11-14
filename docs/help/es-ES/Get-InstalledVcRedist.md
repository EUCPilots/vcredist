---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/get-installedvcredist/
schema: 2.0.0
---

# Get-InstalledVcRedist

## SYNOPSIS
Devuelve los Redistribuibles de Visual C++ instalados.

## SYNTAX

```
Get-InstalledVcRedist [-Export <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Consulta el Registro para encontrar los Redistribuibles de Visual C++ instalados en el sistema local y devuelve la lista a la canalización.
De forma predeterminada, incluye las entradas principales de los redistribuibles; también puede exportar los componentes adicionales y mínimos que aparecen en el Registro.

## EXAMPLES

### EXAMPLE 1
```
Get-InstalledVcRedist
```

Descripción: Devuelve los Redistribuibles de Microsoft Visual C++ instalados en el sistema actual.

### EXAMPLE 2
```
Get-InstalledVcRedist -Export All
```

Descripción: Devuelve los Redistribuibles de Microsoft Visual C++ instalados en el sistema actual, incluidos los runtimes adicionales y mínimos.

## PARAMETERS

### -Export
Define qué Redistribuibles de Visual C++ instalados se devuelven. Supported devuelve solo las entradas principales; All también incluye los componentes de runtime adicionales y mínimos que suelen estar ocultos en Programas y características. El valor predeterminado es Supported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Supported
Accept pipeline input: False
Accept wildcard characters: False
Accepted values: Supported, All
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

[Obtener los redistribuibles instalados localmente:](https://vcredist.com/get-installedvcredist/)

