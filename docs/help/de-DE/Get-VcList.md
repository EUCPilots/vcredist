---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/get-vclist/
schema: 2.0.0
---

# Get-VcList

## SYNOPSIS
Gibt ein Objekt mit Microsoft Visual C++ Redistributables zur Verwendung mit anderen VcRedist-Funktionen zurück.

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
Diese Funktion liest die in einem internen Manifest aufgeführten Visual C++ Redistributables in ein Objekt ein, das an andere VcRedist-Funktionen übergeben werden kann.

Das Manifest wird aus dem VcRedist-Repository gelesen, sodass Manifestaktualisierungen keine Modulaktualisierung erfordern. Ist das Remotemanifest nicht verfügbar, ungültig oder älter als das gebündelte Manifest, wird das im Modul enthaltene Manifest verwendet.

Das Modul enthält eine vollständige Liste der unterstützten und aller bekannten Redistributables.
Standardmäßig gibt Get-VcList nur eine Liste der unterstützten Visual C++ Redistributables zurück.
Um nicht unterstützte Redistributables zurückzugeben, muss der Parameter -Export verwendet und die Ausgabe mit Where-Object gefiltert werden.

Das interne Manifest kann mit Export-VcManifest exportiert werden.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

Description: Gibt ein Objekt mit den unterstützten Visual C++ Redistributables aus dem eingebetteten Manifest zurück.

### EXAMPLE 2
```
Get-VcList
```

Description: Gibt die unterstützten Visual C++ Redistributables der Versionen 2012, 2013 und 2022 für x86 und x64 aus dem eingebetteten Manifest zurück.

### EXAMPLE 3
```
Get-VcList -Export All
```

Description: Gibt eine Liste aller Visual C++ Redistributables aus dem eingebetteten Manifest zurück, einschließlich nicht unterstützter Versionen.

### EXAMPLE 4
```
Get-VcList -Export Supported
```

Description: Gibt die vollständige Liste der unterstützten Visual C++ Redistributables aus dem eingebetteten Manifest zurück.
Dies entspricht der Ausführung von Get-VcList ohne Parameter.

### EXAMPLE 5
```
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

Description: Gibt die vollständige Liste der nicht unterstützten Visual C++ Redistributables aus dem eingebetteten Manifest zurück und filtert sie auf die Versionen aus dem Jahr 2008.

### EXAMPLE 6
```
Get-VcList -Release 2013, 2019 -Architecture x86
```

Description: Gibt die Visual C++ Redistributables für 2013 und 2019 in der x86-Architektur aus der Liste der unterstützten Redistributables im eingebetteten Manifest zurück.

### EXAMPLE 7
```
Get-VcList -Source Bundled
```

Description: Gibt die unterstützten Visual C++ Redistributables ausschließlich anhand des im Modul enthaltenen Manifests zurück, ohne das Remotemanifest abzufragen.

## PARAMETERS

### -Release
Gibt das Release (oder die Version) der zurückzugebenden Redistributables an.

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
Gibt die Prozessorarchitektur der zurückzugebenden Redistributables an.
Mögliche Werte sind x86 und x64.

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
Legt fest, welche Visual C++ Redistributables exportiert werden: alle, unterstützte oder nicht unterstützte Redistributables.
Standardmäßig werden die unterstützten Redistributables exportiert.

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

### -Proxy
Gibt einen Proxyserver für Anforderungen zum Abrufen des Manifests oder zum Herunterladen von Inhalten an.

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
Gibt ein Benutzerkonto an, das zur Verwendung des mit -Proxy angegebenen Proxyservers berechtigt ist. Wenn keine Anmeldeinformationen angegeben werden, werden die Standardanmeldeinformationen für den Proxy verwendet.

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
Wählt die Quelle des Manifests aus. `Auto` (Standard) verwendet das im VcRedist-Repository gehostete Remotemanifest und greift bei jedem Fehler oder bei einem älteren Remotemanifest auf das gebündelte Manifest zurück. `Remote` schlägt fehl, wenn das Remotemanifest nicht verfügbar ist. `Bundled` verwendet ausschließlich das im Modul enthaltene Manifest.

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
Dieses Cmdlet unterstützt die allgemeinen Parameter -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction und -WarningVariable. Weitere Informationen finden Sie unter [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Autor: Aaron Parker

## RELATED LINKS

[Liste der Visual C++ Redistributables abrufen:](https://vcredist.com/get-vclist/)

