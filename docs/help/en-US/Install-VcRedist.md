---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/install-vcredist/
schema: 2.0.0
---

# Install-VcRedist

## SYNOPSIS
Installs the Visual C++ Redistributables on the local system.

## SYNTAX

```
Install-VcRedist [-VcList] <PSObject> [-Silent] [-Force] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Installs the Microsoft Visual C++ Redistributables from a list created by Get-VcList and downloaded into a folder structure locally with Save-VcRedist.
Supports both passive and silent installation of the Redistributables.
Useful for Windows deployments including creating gold images via HashiCorp Packer where the Redistributables can be downloaded and installed at runtime.
The function requires an elevated PowerShell session.
Installers whose manifest SupportedArchitecture list does not include the native Windows architecture are skipped with a warning. Use -Force to re-install an already installed redistributable or to install an x64 redistributable on an ARM64 operating system despite the manifest architecture check.
Each input object must include a non-empty SupportedArchitecture list.
All input is collected before installation and sorted by the release order in the bundled manifest, then by version within each release. Releases missing from that order are rejected.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList -Release 2013, 2019 -Architecture x64 |
    Save-VcRedist -Path C:\Temp\VcRedists |
    Install-VcRedist
```

Description: Installs the 2013 and 2019 64-bit Visual C++ Redistributables listed in $VcRedists and downloaded to C:\Temp\VcRedists.

### EXAMPLE 2
```
Get-VcList -Release "2012","2013","2017" -Architecture x64 |
    Save-VcRedist -Path C:\Temp\VcRedists |
    Install-VcRedist
```

Description: Installs only the 64-bit 2012, 2013 and 2017 Visual C++ Redistributables listed in $VcRedists and downloaded to C:\Temp\VcRedists.

### EXAMPLE 3
```
Get-VcList -Release "2012","2013","2017" -Architecture x64 |
    Save-VcRedist -Path C:\Temp\VcRedists |
    Install-VcRedist -Silent
```

Description: Downloads and installs the selected Visual C++ Redistributables using a completely silent install.

## PARAMETERS

### -VcList
An array containing details of the Visual C++ Redistributables from Save-VcRedist.
Save-VcRedist adds the Path property, that points to the installer executable, to the array exported from Get-VcList.

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
Perform a completely silent install of the VcRedist with no UI.
The default install is passive.

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
Re-install a Visual C++ Redistributable even if it is already installed. On an ARM64 operating system, also bypass the manifest architecture check for x64 redistributables.

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
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Install the Redistributables:](https://vcredist.com/install-vcredist/)

