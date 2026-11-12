---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/save-vcredist/
schema: 2.0.0
---

# Save-VcRedist

## SYNOPSIS
Lädt die Visual C++ Redistributables aus einem von Get-VcList zurückgegebenen Manifest herunter.
Die Ausgabe von Get-VcList wird geändert, indem der Pfad zur Redistributable-Installationsdatei in der Eigenschaft Path ergänzt wird.
Diese Ausgabe kann anschließend an andere Funktionen übergeben werden, die die heruntergeladene Installationsdatei benötigen.

## SYNTAX

```
Save-VcRedist [-VcList] <PSObject> [[-Path] <String>] [-ForceWebRequest] [-Priority <String>]
 [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-UserAgent <String>] [-ShowProgress] [-SkipAuthenticodeValidation]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Lädt die Visual C++ Redistributables aus einem von Get-VcList zurückgegebenen Manifest in eine Ordnerstruktur herunter, die Release, Version und Prozessorarchitektur abbildet.
Ist das Redistributable im angegebenen Pfad bereits vorhanden, wird es nicht erneut heruntergeladen.

Standardmäßig wird bei heruntergeladenen und wiederverwendeten Installationsdateien geprüft, ob eine gültige Microsoft-Authenticode-Signatur vorliegt.
Verwenden Sie unter macOS und Linux -SkipAuthenticodeValidation, um den Download ohne diese Prüfung durchzuführen. Dadurch wird auch die Herausgeberprüfung übersprungen; verwenden Sie diese Option daher nur, wenn die Risiken akzeptabel sind. HTTPS und die Liste zulässiger Hosts werden weiterhin erzwungen.

Beim Herunterladen der Redistributables für 2010, 2012, 2013 und 2019 nach C:\VcRedist wird beispielsweise die folgende Ordnerstruktur erstellt:

C:\VcRedist\2010\10.0.40219.325\x64 C:\VcRedist\2010\10.0.40219.325\x86 C:\VcRedist\2012\11.0.61030.0\x64 C:\VcRedist\2012\11.0.61030.0\x86 C:\VcRedist\2013\12.0.40664.0\x64 C:\VcRedist\2013\12.0.40664.0\x86 C:\VcRedist\2019\14.28.29913.0\x64 C:\VcRedist\2019\14.28.29913.0\x86

## EXAMPLES

### EXAMPLE 1
```
Save-VcRedist -VcList (Get-VcList) -Path C:\Redist
```

Description: Lädt die unterstützten Visual C++ Redistributables nach C:\Redist herunter.

### EXAMPLE 2
```
Get-VcList | Save-VcRedist -Path C:\Redist
```

Description: Übergibt die Liste der unterstützten Visual C++ Redistributables an Save-VcRedist und lädt die Redistributables nach C:\Redist herunter.

### EXAMPLE 3
```
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Save-VcRedist -VcList $VcList -Path C:\Redist
```

Description: Übergibt die Liste der unterstützten Visual C++ Redistributables für 2013 und 2019 in der x86-Architektur an Save-VcRedist und lädt die Redistributables nach C:\Redist herunter.

### EXAMPLE 4
```
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist
```

Description: Lädt die Visual C++ Redistributables für 2010, 2012, 2013 und 2019 nach C:\Redist herunter.

### EXAMPLE 5
```
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist -Proxy proxy.domain.local
```

Description: Lädt die Visual C++ Redistributables für 2010, 2012, 2013 und 2019 über den Proxyserver 'proxy.domain.local' nach C:\Redist herunter.

### EXAMPLE 6
```
Get-VcList | Save-VcRedist -Path ./Redist -SkipAuthenticodeValidation
```

Description: Lädt die Redistributables unter macOS oder Linux herunter, ohne ihre Authenticode-Signaturen oder den Herausgeber zu überprüfen.

## PARAMETERS

### -VcList
Gibt das Array mit den herunterzuladenden Visual C++ Redistributables an.

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
Gibt den Zielordner für die Redistributables an. Wird kein Ordner angegeben, wird der aktuelle Ordner verwendet. Der Ordner wird bei Bedarf erstellt. Kann er nicht erstellt werden, wird ein Fehler ausgegeben, bevor ein Download beginnt.

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
Erzwingt die Verwendung von Invoke-WebRequest anstelle von Start-BitsTransfer.
Nur aus Gründen der Abwärtskompatibilität enthalten.

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
Erzwingt die Priorität bei Verwendung von Start-BitsTransfer.
Nur aus Gründen der Abwärtskompatibilität enthalten.

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
Gibt einen Proxyserver für die Anforderung an, anstatt direkt eine Verbindung zur Internetressource herzustellen.
Geben Sie den URI eines Netzwerkproxyservers ein.

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
Gibt ein Benutzerkonto an, das zur Verwendung des mit dem Parameter Proxy angegebenen Proxyservers berechtigt ist.
Standardmäßig wird der aktuelle Benutzer verwendet.

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

### -ShowProgress
Weist das von dieser Funktion verwendete Invoke-WebRequest an, den Fortschritt anzuzeigen.

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
Überspringt die Prüfung der Authenticode-Signatur und des Herausgebers für heruntergeladene und vorhandene Installationsdateien. Verwenden Sie diese Option unter macOS oder Linux, wo keine Authenticode-Prüfung verfügbar ist. Dadurch wird die Sicherheit verringert; HTTPS- und Prüfungen zulässiger Hosts bleiben aktiviert.

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
Gibt eine User-Agent-Zeichenfolge für die Webanforderung an.

Der Standard-User-Agent identifiziert das Modul, zum Beispiel: VcRedist/5.0.0 (https://github.com/EUCPilots/vcredist; PowerShell 7.5.0; Win32NT 10.0.26100.0)

Wenn Sie stattdessen eine Browser-User-Agent-Zeichenfolge verwenden möchten, nutzen Sie Eigenschaften der Klasse PSUserAgent, beispielsweise Chrome: Save-VcRedist -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)

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

[Redistributables herunterladen:](https://vcredist.com/save-vcredist/)
