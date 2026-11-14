---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/install-vcredist/
schema: 2.0.0
---

# Install-VcRedist

## SYNOPSIS
Instala los Redistribuibles de Visual C++ en el sistema local.

## SYNTAX

```
Install-VcRedist [-VcList] <PSObject> [-Path <String>] [-Silent] [-Force] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Instala los Redistribuibles de Microsoft Visual C++ de una lista creada por Get-VcList y descargada localmente en una estructura de carpetas con Save-VcRedist.
Admite la instalación pasiva y silenciosa de los redistribuibles.
Resulta útil para implementaciones de Windows, incluida la creación de imágenes maestras con HashiCorp Packer, en las que los redistribuibles se pueden descargar e instalar en tiempo de ejecución.
Los instaladores cuya lista SupportedArchitecture del manifiesto no incluya la arquitectura nativa de Windows se omiten con una advertencia, incluso al usar -Force.
Cada objeto de entrada debe incluir una lista SupportedArchitecture no vacía.

## EXAMPLES

### EXAMPLE 1
```
$VcRedists = Get-VcList -Release 2013, 2019 -Architecture x64
Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists
```

Descripción: Instala los Redistribuibles de Visual C++ de 64 bits de 2013 y 2019 indicados en $VcRedists y descargados en C:\Temp\VcRedists.

### EXAMPLE 2
```
$VcRedists = Get-VcList -Release "2012","2013","2017" -Architecture x64
Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists
```

Descripción: Instala únicamente los Redistribuibles de Visual C++ de 64 bits de 2012, 2013 y 2017 indicados en $VcRedists y descargados en C:\Temp\VcRedists.

### EXAMPLE 3
```
$VcRedists = Get-VcList -Release "2012","2013","2017" -Architecture x64 | Save-VcRedist -Path C:\Temp\VcRedists
Install-VcRedist -VcList $VcRedists -Silent
```

Descripción: Instala todos los Redistribuibles de Visual C++ compatibles de forma completamente silenciosa.

## PARAMETERS

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

### -Silent
Realiza una instalación completamente silenciosa de VcRedist, sin interfaz de usuario.
La instalación predeterminada es pasiva.

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

### -Force
Instala un Redistribuible de Visual C++ aunque ya esté instalado en el sistema local.

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

### -Path
Este parámetro está obsoleto y se ignora. El objeto pasado a -VcList debe tener la propiedad Path.

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

[Instalar los Redistribuibles:](https://vcredist.com/install-vcredist/)

