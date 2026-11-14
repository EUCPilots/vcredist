---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/get-vclist/
schema: 2.0.0
---

# Get-VcList

## SYNOPSIS
Devuelve un objeto con los Redistribuibles de Microsoft Visual C++ para usarlo con otras funciones de VcRedist.

## SYNTAX

### Manifest (Default)
```
Get-VcList [[-Release] <String[]>] [[-Architecture] <String[]>] [-Source <String>] [-Proxy <String>]
 [-ProxyCredential <PSCredential>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Export
```
Get-VcList [[-Export] <String>] [-Source <String>] [-Proxy <String>] [-ProxyCredential <PSCredential>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Esta función lee los Redistribuibles de Visual C++ incluidos en un manifiesto interno y los convierte en un objeto que se puede pasar a otras funciones de VcRedist.

El manifiesto se lee del repositorio de VcRedist, por lo que sus actualizaciones no requieren actualizar el módulo. Si el manifiesto remoto no está disponible, no es válido o es más antiguo que el manifiesto incluido, se usa el manifiesto del módulo.

El módulo incluye una lista completa de los redistribuibles compatibles y de todos los que se conocen.
De forma predeterminada, Get-VcList solo devuelve una lista de los Redistribuibles de Visual C++ compatibles.
Para devolver redistribuibles no compatibles, se requiere el parámetro -Export y filtrar la salida con Where-Object.

El manifiesto interno se puede exportar con Export-VcManifest.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

Descripción: Devuelve un objeto con los Redistribuibles de Visual C++ compatibles del manifiesto incluido.

### EXAMPLE 2
```
Get-VcList
```

Descripción: Devuelve las versiones x86 y x64 de 2012, 2013 y 2022 de los Redistribuibles de Visual C++ compatibles del manifiesto incluido.

### EXAMPLE 3
```
Get-VcList -Export All
```

Descripción: Devuelve una lista de todos los Redistribuibles de Visual C++ del manifiesto incluido, incluidas las versiones no compatibles.

### EXAMPLE 4
```
Get-VcList -Export Supported
```

Descripción: Devuelve la lista completa de los Redistribuibles de Visual C++ compatibles del manifiesto incluido.
Es lo mismo que ejecutar Get-VcList sin parámetros.

### EXAMPLE 5
```
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

Descripción: Devuelve la lista completa de los Redistribuibles de Visual C++ no compatibles del manifiesto incluido y filtra las versiones de 2008.

### EXAMPLE 6
```
Get-VcList -Release 2013, 2019 -Architecture x86
```

Descripción: Devuelve los Redistribuibles de Visual C++ x86 de 2013 y 2019 de la lista de redistribuibles compatibles del manifiesto incluido.

### EXAMPLE 7
```
Get-VcList -Source Bundled
```

Descripción: Devuelve los Redistribuibles de Visual C++ compatibles usando únicamente el manifiesto incluido en el módulo, sin contactar con el manifiesto remoto.

## PARAMETERS

### -Release
Especifica la versión de los redistribuibles que se devolverán.

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 1
Default value: @("2012", "2013", "2022")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Especifica la arquitectura del procesador de los redistribuibles que se devolverán.
Puede ser x86 o x64.

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Define la lista de Redistribuibles de Visual C++ que se exportará: todos, los compatibles o los no compatibles.
De forma predeterminada, se exportan los redistribuibles compatibles.

```yaml
Type: String
Parameter Sets: Export
Aliases:

Required: False
Position: 1
Default value: Supported
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

### CommonParameters
Este cmdlet admite los parámetros comunes: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction y -WarningVariable. Para obtener más información, consulta [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Obtener la lista de Redistribuibles de Visual C++:](https://vcredist.com/get-vclist/)

