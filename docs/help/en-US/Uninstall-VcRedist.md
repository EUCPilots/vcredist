---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/uninstall-vcredist/
schema: 2.0.0
---

# Uninstall-VcRedist

## SYNOPSIS
Uninstall the installed Visual C++ Redistributables on the local system.

## SYNTAX

### Manual (Default)
```
Uninstall-VcRedist [[-Release] <String[]>] [[-Architecture] <String[]>] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Pipeline
```
Uninstall-VcRedist [-VcList] <PSObject> [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Uninstall the specified Release and/or Architecture of the installed Visual C++ Redistributables on the local system.
The command requires an elevated PowerShell session.
Without parameters, it selects the default releases for x86 and x64.
Use Release and Architecture to filter installed entries, or pass objects from Get-InstalledVcRedist or Get-VcList through the pipeline.

When both Release and Architecture are explicitly specified, each selected combination with no installed match returns a result with State `Not installed` and null Name, Version, and ExitCode properties.
If either parameter is omitted, no such results are generated for missing combinations.

For pipeline input with a missing executable uninstaller, the command checks the product code against installed entries.
An absent product is reported as `Not installed`; a missing uninstaller for an installed product, or an input without a product code, is reported as `Failed` with a warning.
Exit code 1605 is also reported as `Not installed`.

The command supports WhatIf and Confirm.
Checks performed before an uninstall is attempted can still produce `Not installed` or `Failed` results with WhatIf.

## EXAMPLES

### EXAMPLE 1
```
Uninstall-VcRedist -Confirm:$True
```

Description: Prompts before uninstalling installed x86 and x64 Redistributables matching the default releases.

### EXAMPLE 2
```
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

Description: Uninstalls all installed x64 and x86 2008 and 2010 Visual C++ Redistributables.

### EXAMPLE 3
```
Uninstall-VcRedist -Release 14 -Architecture x64 -Confirm:$false
```

Description: Uninstalls installed release 14 x64 Redistributables without prompting, or returns `Not installed` if none match.

### EXAMPLE 4
```
Get-InstalledVcRedist | Uninstall-VcRedist -WhatIf
```

Description: Previews uninstalling Redistributables returned by Get-InstalledVcRedist.

## PARAMETERS

### -Release
Specifies the releases of the Redistributables to uninstall.
Accepted values are 2005, 2008, 2010, 2012, 2013, 2015, 2017, 2019, 2022, and 14.
Release 14 identifies the unified 2015-2022+ runtime.

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: 1
Default value: @("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019", "2022", "14")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Specifies the processor architectures of the Redistributables to uninstall: x86, x64, or ARM64.
ARM64 must be specified explicitly.

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -VcList
Specifies Redistributable objects from Get-InstalledVcRedist or Get-VcList to uninstall.
Accepts objects through the pipeline.

```yaml
Type: PSObject
Parameter Sets: Pipeline
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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
Prompts you for confirmation before running the cmdlet.

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

### -ProgressAction
Determines how PowerShell responds to progress updates.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
Results contain Name, Version, Release, Architecture, State, and ExitCode properties.
State is `Uninstalled` for exit codes 0, 1641, or 3010; `Not installed` for exit code 1605 or the missing selections described above; and `Failed` for a missing uninstaller or an unsuccessful process.
ExitCode is null when no process was run.
Exit code 1641 indicates a restart was initiated, and 3010 indicates a restart is required.

## NOTES
Author: Aaron Parker

## RELATED LINKS

[Uninstall the Redistributables:](https://vcredist.com/uninstall-vcredist/)

