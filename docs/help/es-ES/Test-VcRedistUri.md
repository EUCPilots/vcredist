---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/test-vcredisturi/
schema: 2.0.0
---

# Test-VcRedistUri

## SYNOPSIS
Comprueba que las descargas de los Redistribuibles de Visual C++ enumerados en el manifiesto devuelto por Get-VcList estén disponibles (es decir,
que devuelvan una respuesta HTTP 200).

## SYNTAX

```
Test-VcRedistUri [-VcList] <PSObject> [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-ShowProgress]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Comprueba que las descargas de los Redistribuibles de Visual C++ enumerados en el manifiesto devuelto por Get-VcList estén disponibles (es decir,
que devuelvan una respuesta HTTP 200).

La función devuelve un valor verdadero o falso por cada Redistribuible de Visual C++ que se le pasa.

## EXAMPLES

### EXAMPLE 1
```
Test-VcRedistUri -VcList (Get-VcList)
```

Descripción: Comprueba los Redistribuibles de Visual C++ recibidos de Get-VcList.

### EXAMPLE 2
```
Get-VcList | Test-VcRedistUri
```

Descripción: Pasa la lista de Redistribuibles de Visual C++ compatibles de Get-VcList a Test-VcRedistUri mediante la canalización.

### EXAMPLE 3
```
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Test-VcRedistUri -VcList $VcList
```

Descripción: Comprueba la lista de Redistribuibles de Visual C++ x86 compatibles de 2013 y 2019.

### EXAMPLE 4
```
Test-VcRedistUri -VcList (Get-VcList -ExportAll)
```

Descripción: Exporta todos los Redistribuibles de Visual C++ compatibles y no compatibles, y comprueba las descargas para determinar si son válidas.

## PARAMETERS

### -VcList
Especifica la matriz que enumera los Redistribuibles de Visual C++ que se descargarán.

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
Especifica un servidor proxy para la solicitud, en lugar de conectarse directamente al recurso de Internet.
Introduce el URI de un servidor proxy de red.

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
Especifica una cuenta de usuario con permiso para usar el servidor proxy indicado por el parámetro Proxy.
De forma predeterminada, se usa el usuario actual.

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
Indica a Invoke-WebRequest, utilizado por esta función, que muestre el progreso.

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

[Descargar los Redistribuibles:](https://vcredist.com/save-vcredist/)

