---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/export-vcmanifest/
schema: 2.0.0
---

# Export-VcManifest

## SYNOPSIS
Exportiert das JSON-Manifest der Visual C++ Redistributables in eine externe Datei.

## SYNTAX

```
Export-VcManifest [-Path] <String> [-Source <String>] [-Proxy <String>] [-ProxyCredential <PSCredential>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Liest die im VcRedist-Modul enthaltenen JSON-Manifeste der Visual C++ Redistributables und exportiert das JSON in eine externe Datei.
Dadurch kann das JSON-Manifest für benutzerdefinierte Szenarien bearbeitet werden.

## EXAMPLES

### EXAMPLE 1
```
Export-VcManifest -Path "C:\Temp"
```

Description: Exportiert die Liste der unterstützten Visual C++ Redistributables nach C:\Temp\VisualCRedistributables.json.

## PARAMETERS

### -Path
Pfad zu dem Ordner, in den die JSON-Manifestdatei exportiert wird.

```yaml
Type: String
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

### System.String
## NOTES
Autor: Aaron Parker

## RELATED LINKS

[Redistributable-Manifeste exportieren:](https://vcredist.com/export-vcmanifest/)

