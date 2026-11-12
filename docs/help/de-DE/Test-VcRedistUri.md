---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/test-vcredisturi/
schema: 2.0.0
---

# Test-VcRedistUri

## SYNOPSIS
Prüft, ob die im von Get-VcList zurückgegebenen Manifest aufgeführten Downloads der Visual C++ Redistributables verfügbar sind (d. h.
eine HTTP-200-Antwort zurückgeben).

## SYNTAX

```
Test-VcRedistUri [-VcList] <PSObject> [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-ShowProgress]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Prüft, ob die im von Get-VcList zurückgegebenen Manifest aufgeführten Downloads der Visual C++ Redistributables verfügbar sind (d. h.
eine HTTP-200-Antwort zurückgeben).

Für jedes an die Funktion übergebene Visual C++ Redistributable wird ein Wahrheitswert zurückgegeben.

## EXAMPLES

### EXAMPLE 1
```
Test-VcRedistUri -VcList (Get-VcList)
```

Description: Prüft die von Get-VcList übergebenen Visual C++ Redistributables.

### EXAMPLE 2
```
Get-VcList | Test-VcRedistUri
```

Description: Übergibt die Liste der unterstützten Visual C++ Redistributables von Get-VcList über die Pipeline an Test-VcRedistUri.

### EXAMPLE 3
```
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Test-VcRedistUri -VcList $VcList
```

Description: Prüft die Liste der unterstützten Visual C++ Redistributables für 2013 und 2019 in der x86-Architektur.

### EXAMPLE 4
```
Test-VcRedistUri -VcList (Get-VcList -ExportAll)
```

Description: Exportiert alle unterstützten und nicht unterstützten Visual C++ Redistributables und prüft die Downloads auf ihre Gültigkeit.

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

