---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/import-vcintuneapplication/
schema: 2.0.0
---

# Import-VcIntuneApplication

## SYNOPSIS
Verpackt die Installationsdateien der Microsoft Visual C++ Redistributables im intunewin-Format und importiert sie als Anwendungen in einen Microsoft-Intune-Mandanten.

## SYNTAX

```
Import-VcIntuneApplication [-VcList] <PSObject> [-ImportAsUpdate] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Erstellt für jedes Visual C++ Redistributable eine Anwendung in einem Microsoft-Intune-Mandanten. Die Anwendung enthält Eigenschaften wie den Silent-Zielbefehl, den Deinstallationsbefehl, die Erkennung (über die Registrierung) und die Anforderungen.

Verwenden Sie Get-VcList und Save-VcRedist, um die Redistributables herunterzuladen und das Array für den Import in Microsoft Intune zu erstellen.

Für jedes Visual C++ Redistributable wird ein Anwendungspaket mit Eigenschaften wie Name, Beschreibung, Herausgeber, App-Version, Informations-URL, Datenschutz-URL, Notizen, Logo, Installationsbefehl, Deinstallationsbefehl, Installationsverhalten, Betriebssystemarchitektur, minimalem Betriebssystem und Erkennungsregeln erstellt.

Diese Funktion erfordert das PowerShell-Modul IntuneWin32App und wird nur unter unterstütztem Windows PowerShell ausgeführt.
Bevor Sie mit dieser Funktion Redistributables in einen Intune-Mandanten importieren, authentifizieren Sie sich zuerst mit Connect-MSIntuneGraph.
Die Architekturanforderung stammt aus der Liste SupportedArchitecture des jeweiligen Manifesteintrags. IntuneWin32App 1.5.0 unterstützt die Anforderungen einschließlich ARM64, die im gebündelten Manifest verwendet werden; nicht unterstützte Kombinationen werden abgelehnt. Vorhandene Anwendungen werden nur geändert, wenn ein Update importiert wird.

Verwenden Sie `-ImportAsUpdate`, um eine Dateiversionsanforderung hinzuzufügen, die auf der `DetectionFile` des jeweiligen Pakets basiert. Die App ist nur anwendbar, wenn die architekturspezifische Datei vorhanden und älter als die Paketversion ist. Sie ist nicht auf Neuinstallationen oder Geräte mit derselben oder einer neueren Version anwendbar. Vorhandene Intune-Apps oder deren Zuweisungen werden dadurch nicht geändert. Überprüfen Sie die Erkennungsdatei und -version auf den Zielgeräten, insbesondere bei älteren, nicht unterstützten Redistributables, die möglicherweise Side-by-Side-Assemblys verwenden. Ein Remotemanifest kann andere Erkennungspfade als das gebündelte Manifest enthalten.

## EXAMPLES

### EXAMPLE 1
```
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com
$VcList = Get-VcList -Release "2022" | Save-VcRedist -Path "C:\Temp\VcRedist"
Import-VcIntuneApplication -VcList $VcList
```

Description: Authentifiziert sich beim angegebenen Mandanten, ruft die Liste der Visual C++ Redistributables der Version 2022 ab, lädt sie nach C:\Temp\VcRedist herunter und importiert jedes Redistributable als separate Anwendung in den Zielmandanten von Intune.

### EXAMPLE 2
```
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com -ClientId "f99877d5-f757-438e-b12b-d905b00ea6f3" -ClientSecret <secret>
Get-VcList | Save-VcRedist -Path "C:\Temp\VcRedist" | Import-VcIntuneApplication
```

Description: Authentifiziert sich mithilfe einer Azure-AD-App-Registrierung nicht interaktiv beim angegebenen Mandanten, ruft die Liste der unterstützten Visual C++ Redistributables ab, lädt sie nach C:\Temp\VcRedist herunter und importiert jedes Redistributable als separate Anwendung in den Zielmandanten von Intune.

### EXAMPLE 3
```
Get-VcList -Release "14" | Save-VcRedist -Path "C:\Temp\VcRedist" | Import-VcIntuneApplication -ImportAsUpdate
```

Importiert v14-Anwendungen, die nur für Geräte mit einer älteren installierten Runtime gelten.

## PARAMETERS

### -ImportAsUpdate
Fügt die Anforderung hinzu, dass die `DetectionFile` des Pakets vorhanden ist und eine niedrigere Dateiversion als die Paketversion aufweist.

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

### -Confirm
Fordert vor der Ausführung des Cmdlets zur Bestätigung auf.

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

### -WhatIf
Zeigt, was bei Ausführung des Cmdlets geschehen würde. Das Cmdlet wird nicht ausgeführt.

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
Dieses Cmdlet unterstützt die allgemeinen Parameter -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction und -WarningVariable. Weitere Informationen finden Sie unter [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Autor: Aaron Parker

## RELATED LINKS

[Redistributables in MDT importieren](https://vcredist.com/import-vcmdtapplication/)
