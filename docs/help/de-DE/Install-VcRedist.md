---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/install-vcredist/
schema: 2.0.0
---

# Install-VcRedist

## SYNOPSIS
Installiert die Visual C++ Redistributables auf dem lokalen System.

## SYNTAX

```
Install-VcRedist [-VcList] <PSObject> [-Path <String>] [-Silent] [-Force] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Installiert die Microsoft Visual C++ Redistributables aus einer mit Get-VcList erstellten Liste, die mit Save-VcRedist lokal in eine Ordnerstruktur heruntergeladen wurde.
Unterstützt sowohl die passive als auch die stille Installation der Redistributables.
Nützlich für Windows-Bereitstellungen, einschließlich der Erstellung von Golden Images mit HashiCorp Packer, bei denen die Redistributables zur Laufzeit heruntergeladen und installiert werden können.
Installationsdateien, deren SupportedArchitecture-Liste im Manifest die native Windows-Architektur nicht enthält, werden mit einer Warnung übersprungen, auch wenn -Force verwendet wird.
Jedes Eingabeobjekt muss eine nicht leere SupportedArchitecture-Liste enthalten.

## EXAMPLES

### EXAMPLE 1
```
$VcRedists = Get-VcList -Release 2013, 2019 -Architecture x64
Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists
```

Description: Installiert die in $VcRedists aufgeführten 64-Bit-Visual-C++-Redistributables der Jahre 2013 und 2019, die nach C:\Temp\VcRedists heruntergeladen wurden.

### EXAMPLE 2
```
$VcRedists = Get-VcList -Release "2012","2013","2017" -Architecture x64
Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists
```

Description: Installiert ausschließlich die in $VcRedists aufgeführten 64-Bit-Visual-C++-Redistributables der Jahre 2012, 2013 und 2017, die nach C:\Temp\VcRedists heruntergeladen wurden.

### EXAMPLE 3
```
$VcRedists = Get-VcList -Release "2012","2013","2017" -Architecture x64 | Save-VcRedist -Path C:\Temp\VcRedists
Install-VcRedist -VcList $VcRedists -Silent
```

Description: Installiert alle unterstützten Visual C++ Redistributables vollständig im Hintergrund.

## PARAMETERS

### -VcList
Ein Array mit Details zu den Visual C++ Redistributables aus Save-VcRedist.
Save-VcRedist fügt dem aus Get-VcList exportierten Array die Eigenschaft Path hinzu, die auf die ausführbare Installationsdatei verweist.

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
Installiert das VcRedist vollständig im Hintergrund und ohne Benutzeroberfläche.
Die Standardinstallation erfolgt passiv.

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
Installiert ein Visual C++ Redistributable auch dann, wenn es bereits auf dem lokalen System installiert ist.

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
Zeigt, was bei Ausführung des Cmdlets geschehen würde.
Das Cmdlet wird nicht ausgeführt.

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
Fordert vor der Ausführung des Cmdlets zur Bestätigung auf.

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
Dieser Parameter ist veraltet und wird ignoriert. Das an -VcList übergebene Objekt muss die Eigenschaft Path enthalten.

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
Legt fest, wie PowerShell auf Fortschrittsmeldungen reagiert.

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
Dieses Cmdlet unterstützt die allgemeinen Parameter -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction und -WarningVariable. Weitere Informationen finden Sie unter [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Autor: Aaron Parker

## RELATED LINKS

[Redistributables installieren:](https://vcredist.com/install-vcredist/)

