---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/save-vcredist/
schema: 2.0.0
---

# Save-VcRedist

## SYNOPSIS
Descarga los Redistribuibles de Visual C++ a partir de un manifiesto devuelto por Get-VcList.
La salida de Get-VcList se modifica agregando en la propiedad Path la ruta al instalador del redistribuible.
A continuación, esta salida se puede pasar a otras funciones que necesiten el instalador descargado.

## SYNTAX

```
Save-VcRedist [-VcList] <PSObject> [[-Path] <String>] [-ForceWebRequest] [-Priority <String>]
 [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-UserAgent <String>] [-ShowProgress] [-SkipAuthenticodeValidation]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Descarga los Redistribuibles de Visual C++ de un manifiesto devuelto por Get-VcList en una estructura de carpetas que representa la versión, la compilación y la arquitectura del procesador.
Si el redistribuible ya existe en la ruta especificada, no se vuelve a descargar.

De forma predeterminada, se comprueba que los instaladores descargados o reutilizados tengan una firma de Microsoft Authenticode válida.
En macOS y Linux, usa -SkipAuthenticodeValidation para descargar sin realizar esa comprobación. También se omite la verificación del editor, por lo que solo debes usarlo si los riesgos son aceptables. Se siguen exigiendo HTTPS y el uso de hosts permitidos.

Por ejemplo, al descargar los redistribuibles de 2010, 2012, 2013 y 2019 en C:\VcRedist, se creará la siguiente estructura de carpetas:

C:\VcRedist\2010\10.0.40219.325\x64 C:\VcRedist\2010\10.0.40219.325\x86 C:\VcRedist\2012\11.0.61030.0\x64 C:\VcRedist\2012\11.0.61030.0\x86 C:\VcRedist\2013\12.0.40664.0\x64 C:\VcRedist\2013\12.0.40664.0\x86 C:\VcRedist\2019\14.28.29913.0\x64 C:\VcRedist\2019\14.28.29913.0\x86

## EXAMPLES

### EXAMPLE 1
```
Save-VcRedist -VcList (Get-VcList) -Path C:\Redist
```

Descripción: Descarga los Redistribuibles de Visual C++ compatibles en C:\Redist.

### EXAMPLE 2
```
Get-VcList | Save-VcRedist -Path C:\Redist
```

Descripción: Pasa a Save-VcRedist la lista de Redistribuibles de Visual C++ compatibles y los descarga en C:\Redist.

### EXAMPLE 3
```
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Save-VcRedist -VcList $VcList -Path C:\Redist
```

Descripción: Pasa a Save-VcRedist la lista de Redistribuibles de Visual C++ x86 compatibles de 2013 y 2019 y los descarga en C:\Redist.

### EXAMPLE 4
```
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist
```

Descripción: Descarga los Redistribuibles de Visual C++ de 2010, 2012, 2013 y 2019 en C:\Redist.

### EXAMPLE 5
```
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist -Proxy proxy.domain.local
```

Descripción: Descarga los Redistribuibles de Visual C++ de 2010, 2012, 2013 y 2019 en C:\Redist mediante el servidor proxy 'proxy.domain.local'.

### EXAMPLE 6
```
Get-VcList | Save-VcRedist -Path ./Redist -SkipAuthenticodeValidation
```

Descripción: Descarga los redistribuibles en macOS o Linux sin verificar sus firmas Authenticode ni el editor.

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

### -Path
Especifica la carpeta de destino para descargar los redistribuibles; de lo contrario, se usa la carpeta actual. Si la carpeta no existe, se crea; si no se puede crear, se devuelve un error antes de iniciar cualquier descarga.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Resolve-Path -Path $PWD)
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceWebRequest
Fuerza el uso de Invoke-WebRequest en lugar de Start-BitsTransfer.
Se incluye únicamente por compatibilidad con versiones anteriores.

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

### -Priority
Fuerza la prioridad al usar Start-BitsTransfer.
Se incluye únicamente por compatibilidad con versiones anteriores.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Foreground
Accept pipeline input: False
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

### -SkipAuthenticodeValidation
Omite la validación de la firma Authenticode y del editor de los instaladores descargados y existentes. Úsalo en macOS o Linux, donde no está disponible la validación de Authenticode. Esto reduce la seguridad; se mantienen las comprobaciones de HTTPS y de hosts permitidos.

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

### -UserAgent
Especifica una cadena de agente de usuario para la solicitud web.

El agente de usuario predeterminado identifica el módulo; por ejemplo: VcRedist/5.0.0 (https://github.com/EUCPilots/vcredist; PowerShell 7.5.0; Win32NT 10.0.26100.0)

Para usar en su lugar una cadena de agente de usuario de navegador, utiliza las propiedades de la clase PSUserAgent, como Chrome: Save-VcRedist -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)

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
