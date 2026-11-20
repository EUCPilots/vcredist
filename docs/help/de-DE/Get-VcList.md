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
Sie prüft nicht, welche Redistributables installiert sind; verwenden Sie dafür Get-InstalledVcRedist.

Bei Auto wird zuerst das gebündelte Manifest gelesen und anschließend das Remotemanifest geprüft. Ist das Remotemanifest nicht verfügbar, ungültig oder älter, wird das gebündelte Manifest verwendet. Ein ungültiges oder nicht lesbares gebündeltes Manifest führt zu einem Fehler.

Release und Architecture wählen passende Einträge unabhängig vom Unterstützungsstatus aus. Sind darunter nicht unterstützte Einträge, wird eine Warnung ausgegeben.
Ohne diese Parameter wird Release 14 für x86, x64 und arm64 ausgewählt.
Mit -Export Supported, Unsupported oder All werden Einträge über alle Releases nach Unterstützungsstatus beziehungsweise alle Einträge ausgewählt. Export kann nicht mit Release oder Architecture kombiniert werden.
All und Unsupported geben immer eine Warnung aus, auch wenn keine nicht unterstützten Einträge vorhanden sind.
In SilentUninstall werden #Installer und #ProductCode durch den Installationsdateinamen aus URI und den Produktcode des Eintrags ersetzt.

Das interne Manifest kann mit Export-VcManifest exportiert werden.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

Description: Gibt Redistributables für Release 14 und die Architekturen x86, x64 und arm64 aus dem ausgewählten Manifest zurück.

### EXAMPLE 2
```
Get-VcList -Release 2015 -Architecture x86
```

Description: Gibt die Redistributables für 2015 und x86 zurück und warnt bei nicht unterstützten Einträgen.

### EXAMPLE 3
```
Get-VcList -Export All
```

Description: Gibt alle Visual C++ Redistributables aus dem ausgewählten Manifest zurück und gibt eine Warnung aus.

### EXAMPLE 4
```
Get-VcList -Export Supported
```

Description: Gibt die unterstützten Visual C++ Redistributables aller Releases aus dem ausgewählten Manifest zurück.

### EXAMPLE 5
```
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

Description: Gibt die nicht unterstützten Visual C++ Redistributables aus dem ausgewählten Manifest zurück und filtert sie auf Release 2008.

### EXAMPLE 6
```
Get-VcList -Release 2013, 2019 -Architecture x86
```

Description: Gibt die Visual C++ Redistributables für 2013 und 2019 in der x86-Architektur aus dem ausgewählten Manifest zurück.

### EXAMPLE 7
```
Get-VcList -Source Bundled
```

Description: Gibt die Redistributables für Release 14 ausschließlich anhand des im Modul enthaltenen Manifests zurück.

## PARAMETERS

### -Release
Gibt das Release (oder die Version) der zurückzugebenden Redistributables an.
Jeder Wert muss aus zwei bis vier Ziffern bestehen; vollständige Versionsnummern sind nicht zulässig.

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
Gibt die Prozessorarchitektur der zurückzugebenden Redistributables an.
Mögliche Werte sind x86, x64 und arm64.

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
Legt fest, welche Visual C++ Redistributables exportiert werden: alle, unterstützte oder nicht unterstützte Redistributables.
Export kann nicht mit Release oder Architecture kombiniert werden. All und Unsupported geben eine Warnung aus.

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
Gibt einen absoluten HTTP- oder HTTPS-Proxy-URI ohne eingebettete Anmeldeinformationen für Remotemanifest-Anforderungen an. Ohne ProxyCredential werden die Standardanmeldeinformationen verwendet.

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
Gibt Anmeldeinformationen für den mit -Proxy angegebenen Proxyserver an. Nicht leere Anmeldeinformationen erfordern -Proxy.

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
Wählt die Quelle des Manifests aus. `Auto` (Standard) liest das gebündelte Manifest und verwendet das Remotemanifest, wenn es gültig und mindestens ebenso aktuell ist. `Remote` verwendet nur das Remotemanifest. `Bundled` verwendet nur das gebündelte Manifest.

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
Dieses Cmdlet unterstützt die allgemeinen Parameter -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction und -WarningVariable. Weitere Informationen finden Sie unter [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Autor: Aaron Parker

## RELATED LINKS

[Liste der Visual C++ Redistributables abrufen:](https://vcredist.com/get-vclist/)

