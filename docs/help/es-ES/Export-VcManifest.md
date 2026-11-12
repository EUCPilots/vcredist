---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/export-vcmanifest/
schema: 2.0.0
---

# Export-VcManifest

## SYNOPSIS
Exporta el manifiesto JSON de los Redistribuibles de Visual C++ a un archivo externo.

## SYNTAX

```
Export-VcManifest [-Path] <String> [-Source <String>] [-Proxy <String>] [-ProxyCredential <PSCredential>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Lee los manifiestos JSON de los Redistribuibles de Visual C++ incluidos en el módulo VcRedist y exporta el JSON a un archivo externo.
Esto permite editar el manifiesto JSON para escenarios personalizados.

## EXAMPLES

### EXAMPLE 1
```
Export-VcManifest -Path "C:\Temp"
```

Descripción: Exporta la lista de Redistribuibles de Visual C++ compatibles a C:\Temp\VisualCRedistributables.json.

## PARAMETERS

### -Path
Ruta de la carpeta a la que se exportará el archivo JSON del manifiesto.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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
Default value: None
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

### -Proxy
Especifica un servidor proxy para obtener el manifiesto o descargar contenido.

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

### -ProxyCredential
Especifica una cuenta de usuario con permiso para usar el servidor proxy indicado por -Proxy. Si no se especifica, se usan las credenciales de proxy predeterminadas.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
Selecciona el origen del manifiesto. `Auto` (predeterminado) usa el manifiesto remoto alojado en el repositorio de VcRedist y recurre al manifiesto incluido si se produce un error o si el remoto es más antiguo. `Remote` produce un error si el manifiesto remoto no está disponible. `Bundled` usa únicamente el manifiesto incluido en el módulo.

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

### -WhatIf
Muestra lo que ocurriría si se ejecutara el cmdlet. El cmdlet no se ejecuta.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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

### System.String
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Exportar los manifiestos de redistribuibles:](https://vcredist.com/export-vcmanifest/)

