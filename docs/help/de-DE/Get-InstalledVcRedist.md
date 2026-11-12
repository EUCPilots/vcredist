---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/get-installedvcredist/
schema: 2.0.0
---

# Get-InstalledVcRedist

## SYNOPSIS
Gibt die installierten Visual C++ Redistributables zurück.

## SYNTAX

```
Get-InstalledVcRedist [-ExportAll] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Durchsucht die Registrierung nach den auf dem lokalen System installierten Visual C++ Redistributables und gibt die Liste an die Pipeline zurück.
Standardmäßig sind die primären Redistributable-Einträge enthalten. Zusätzlich können auch die in der Registrierung aufgeführten zusätzlichen und minimalen Redistributable-Komponenten exportiert werden.

## EXAMPLES

### EXAMPLE 1
```
Get-InstalledVcRedist
```

Description: Gibt die installierten Microsoft Visual C++ Redistributables des aktuellen Systems zurück.

### EXAMPLE 2
```
Get-InstalledVcRedist -ExportAll
```

Description: Gibt die installierten Microsoft Visual C++ Redistributables des aktuellen Systems zurück, einschließlich der zusätzlichen und minimalen Runtimes.

## PARAMETERS

### -ExportAll
Exportiert alle installierten Redistributables, einschließlich der zusätzlichen und minimalen Runtimes, die normalerweise unter „Programme und Features“ ausgeblendet sind.

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

[Lokal installierte Redistributables abrufen:](https://vcredist.com/get-installedvcredist/)

