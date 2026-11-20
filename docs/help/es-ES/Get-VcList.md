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
No comprueba qué Redistribuibles están instalados; use Get-InstalledVcRedist para ello.

Con Auto se lee primero el manifiesto incluido y después se comprueba el remoto. Si el remoto no está disponible, no es válido o es más antiguo, se usa el incluido. Si el manifiesto incluido no se puede leer o no es válido, se produce un error.

Release y Architecture seleccionan las entradas coincidentes, sean compatibles o no. Si alguna entrada seleccionada no es compatible, se emite una advertencia.
Sin estos parámetros, se selecciona la versión 14 para x86, x64 y arm64.
Use -Export Supported, Unsupported o All para seleccionar entradas de todas las versiones por compatibilidad o devolver todas las entradas. Export no se puede combinar con Release ni Architecture.
All y Unsupported siempre emiten una advertencia, incluso si no hay entradas no compatibles.
En SilentUninstall, #Installer y #ProductCode se sustituyen por el nombre del instalador de URI y el código de producto de la entrada.

El manifiesto interno se puede exportar con Export-VcManifest.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

Descripción: Devuelve los Redistribuibles de la versión 14 para x86, x64 y arm64 del manifiesto seleccionado.

### EXAMPLE 2
```
Get-VcList -Release 2015 -Architecture x86
```

Descripción: Devuelve los Redistribuibles x86 de 2015 y advierte si las entradas seleccionadas no son compatibles.

### EXAMPLE 3
```
Get-VcList -Export All
```

Descripción: Devuelve todos los Redistribuibles de Visual C++ del manifiesto seleccionado y emite una advertencia.

### EXAMPLE 4
```
Get-VcList -Export Supported
```

Descripción: Devuelve los Redistribuibles compatibles de todas las versiones del manifiesto seleccionado.

### EXAMPLE 5
```
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

Descripción: Devuelve los Redistribuibles no compatibles del manifiesto seleccionado y filtra las versiones de 2008.

### EXAMPLE 6
```
Get-VcList -Release 2013, 2019 -Architecture x86
```

Descripción: Devuelve los Redistribuibles de Visual C++ x86 de 2013 y 2019 del manifiesto seleccionado.

### EXAMPLE 7
```
Get-VcList -Source Bundled
```

Descripción: Devuelve los Redistribuibles de la versión 14 usando únicamente el manifiesto incluido en el módulo.

## PARAMETERS

### -Release
Especifica la versión de los redistribuibles que se devolverán.
Cada valor debe contener de dos a cuatro dígitos; no se aceptan números de versión completos.

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 1
Default value: @("14")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Especifica la arquitectura del procesador de los redistribuibles que se devolverán.
Puede ser x86, x64 o arm64.

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64", "arm64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Define la lista de Redistribuibles de Visual C++ que se exportará: todos, los compatibles o los no compatibles.
Export no se puede combinar con Release ni Architecture. All y Unsupported emiten una advertencia.

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
Especifica un URI de proxy HTTP o HTTPS absoluto, sin credenciales integradas, para obtener el manifiesto remoto. Si se omite ProxyCredential, se usan las credenciales de proxy predeterminadas.

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
Especifica las credenciales del servidor proxy indicado por -Proxy. Las credenciales no vacías requieren -Proxy.

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
Selecciona el origen del manifiesto. `Auto` (predeterminado) lee el manifiesto incluido y usa el remoto si es válido y al menos igual de reciente. `Remote` usa solo el manifiesto remoto. `Bundled` usa solo el manifiesto incluido.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Auto
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

