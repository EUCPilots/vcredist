---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/import-vcintuneapplication/
schema: 2.0.0
---

# Import-VcIntuneApplication

## SYNOPSIS
Empaqueta los instaladores de Redistribuibles de Microsoft Visual C++ en formato intunewin y los importa como aplicaciones en un inquilino de Microsoft Intune.

## SYNTAX

```
Import-VcIntuneApplication [-VcList] <PSObject> [-ImportAsUpdate] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Crea una aplicación en un inquilino de Microsoft Intune para cada Redistribuible de Visual C++ e incluye propiedades como el comando silencioso de destino, el comando de desinstalación, la detección (mediante el Registro) y los requisitos.

Usa Get-VcList y Save-VcRedist para descargar los redistribuibles y crear la matriz que se importará en Microsoft Intune.

Se creará un paquete de aplicación para cada Redistribuible de Visual C++, con propiedades como nombre, descripción, editor, versión de la aplicación, URL de información, URL de privacidad, notas, logotipo, comando de instalación, comando de desinstalación, comportamiento de instalación, arquitectura del sistema operativo, sistema operativo mínimo y reglas de detección.

Esta función requiere el módulo de PowerShell IntuneWin32App y solo es compatible con Windows PowerShell.
Antes de usar esta función para importar redistribuibles en un inquilino de Intune, autentícate primero con Connect-MSIntuneGraph.
El requisito de arquitectura se obtiene de la lista SupportedArchitecture de cada entrada del manifiesto. IntuneWin32App 1.5.0 admite los requisitos que incluyen ARM64 usados por el manifiesto incluido; se rechazan las combinaciones no compatibles. Las aplicaciones existentes no se modifican a menos que se importe una actualización.

Usa `-ImportAsUpdate` para agregar un requisito de versión de archivo basado en `DetectionFile` de cada paquete. La aplicación solo se aplica cuando existe el archivo específico de la arquitectura y su versión es anterior a la del paquete. No se aplica a instalaciones limpias ni a dispositivos con la misma versión o una más reciente. Esto no modifica las aplicaciones existentes de Intune ni sus asignaciones. Verifica el archivo de detección y su versión en los dispositivos de destino, especialmente para redistribuibles antiguos no compatibles que puedan usar ensamblados en paralelo. Un manifiesto remoto puede proporcionar rutas de detección distintas de las del manifiesto incluido.

## EXAMPLES

### EXAMPLE 1
```
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com
$VcList = Get-VcList -Release "2022" | Save-VcRedist -Path "C:\Temp\VcRedist"
Import-VcIntuneApplication -VcList $VcList
```

Descripción: Se autentica en el inquilino especificado, obtiene la lista de Redistribuibles de Visual C++ de la versión 2022, los descarga en C:\Temp\VcRedist e importa cada redistribuible en el inquilino de Intune de destino como una aplicación independiente.

### EXAMPLE 2
```
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com -ClientId "f99877d5-f757-438e-b12b-d905b00ea6f3" -ClientSecret <secret>
Get-VcList | Save-VcRedist -Path "C:\Temp\VcRedist" | Import-VcIntuneApplication
```

Descripción: Se autentica en el inquilino especificado mediante un registro de aplicación de Azure AD para la autenticación no interactiva, obtiene la lista de Redistribuibles de Visual C++ compatibles, los descarga en C:\Temp\VcRedist e importa cada redistribuible en el inquilino de Intune de destino como una aplicación independiente.

### EXAMPLE 3
```
Get-VcList -Release "14" | Save-VcRedist -Path "C:\Temp\VcRedist" | Import-VcIntuneApplication -ImportAsUpdate
```

Importa aplicaciones v14 que solo se aplican a dispositivos con un runtime instalado de una versión anterior.

## PARAMETERS

### -ImportAsUpdate
Agrega el requisito de que exista `DetectionFile` del paquete y que su versión de archivo sea inferior a la versión del paquete.

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

### -VcList
Una matriz con los detalles de los Redistribuibles de Visual C++ obtenidos de Save-VcRedist.
Save-VcRedist agrega la propiedad Path, que apunta al ejecutable del instalador, a la matriz exportada por Get-VcList.

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

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Importar redistribuibles en MDT](https://vcredist.com/import-vcmdtapplication/)
