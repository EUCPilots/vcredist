---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/import-vcintuneapplication/
schema: 2.0.0
---

# Import-VcIntuneApplication

## SYNOPSIS
Packages the Microsoft Visual C++ Redistributable installers into intunewin format and imports as applications into a Microsoft Intune tenant.

## SYNTAX

```
Import-VcIntuneApplication [-VcList] <PSObject> [-ImportAsUpdate] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates an application in a Microsoft Intune tenant for each Visual C++ Redistributable and includes properties such as target Silent command, Uninstall command, Detection (via Registry) and Requirements.

Use Get-VcList and Save-VcRedist to download the Redistributables and create the array for importing into Microsoft Intune.

An application package will be created for each Visual C++ Redistributable with properties including Name, Description, Publisher, App Version, Information URL, Privacy URL, Notes, Logo, Install command, Uninstall command, Install behavior, Operating system architecture, Minimum operating system, and Detection rules.

This function requires the IntuneWin32App PowerShell module and supported Windows PowerShell only.
Before using this function to import the Redistributables into an Intune tenant, authenticate first with Connect-MSIntuneGraph.

Use `-ImportAsUpdate` to add a file-version requirement based on each package's `DetectionFile`. The app is applicable only when the architecture-specific file exists and is older than the package version. It is not applicable to clean installs or devices with the same or a newer version. This does not change existing Intune apps or their assignments. Verify the detection file and version on target devices, particularly for older, unsupported redistributables that may use side-by-side assemblies. A remote manifest can provide different detection paths from the bundled manifest.

## EXAMPLES

### EXAMPLE 1
```
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com
$VcList = Get-VcList -Release "2022" | Save-VcRedist -Path "C:\Temp\VcRedist"
Import-VcIntuneApplication -VcList $VcList
```

Description: Authenticates to the specified tenant, retrieves the list of Visual C++ Redistributables 2022 version, downloads them to C:\Temp\VcRedist and imports each Redistributable into the target Intune tenant as separate application.

### EXAMPLE 2
```
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com -ClientId "f99877d5-f757-438e-b12b-d905b00ea6f3" -ClientSecret <secret>
Get-VcList | Save-VcRedist -Path "C:\Temp\VcRedist" | Import-VcIntuneApplication
```

Description: Authenticates to the specified tenant using an Azure AD app registration for non-interactive authentication, retrieves the supported list of Visual C++ Redistributables, downloads them to C:\Temp\VcRedist and imports each Redistributable into the target Intune tenant as separate application.

### EXAMPLE 3
```
Get-VcList -Release "14" | Save-VcRedist -Path "C:\Temp\VcRedist" | Import-VcIntuneApplication -ImportAsUpdate
```

Imports v14 applications that apply only to devices with an older installed runtime.

## PARAMETERS

### -ImportAsUpdate
Adds a requirement that the package's `DetectionFile` exists and has a file version lower than the package version.

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

### -Confirm
Prompts you for confirmation before running the cmdlet.

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

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Author: Aaron Parker

## RELATED LINKS

[Import Redistributables into MDT](https://vcredist.com/import-vcmdtapplication/)
