---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/save-vcredist/
schema: 2.0.0
---

# Save-VcRedist

## SYNOPSIS
Downloads the Visual C++ Redistributables from an manifest returned by Get-VcList.
The output from Get-VcList is modified by adding the path to the Redistributable installer in the Path property.
This output can then be passed to other functions that require the downloaded installer.

## SYNTAX

```
Save-VcRedist [-VcList] <PSObject> [[-Path] <String>] [-ForceWebRequest] [-Priority <String>]
 [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-UserAgent <String>] [-ShowProgress] [-SkipAuthenticodeValidation]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Downloads the Visual C++ Redistributables from an manifest returned by Get-VcList into a folder structure that represents release, version and processor architecture.
If the redistributable exists in the specified path, it will not be re-downloaded.

By default, downloaded and reused installers are checked for a valid Microsoft Authenticode signature.
On macOS and Linux, use -SkipAuthenticodeValidation to download without that check. This also skips publisher verification, so only use it when the risks are acceptable. HTTPS and the allowed host list are still enforced.

For example, the following folder structure will be created when downloading the 2010, 2012, 2013 and 2019 Redistributables to C:\VcRedist:

C:\VcRedist\2010\10.0.40219.325\x64 C:\VcRedist\2010\10.0.40219.325\x86 C:\VcRedist\2012\11.0.61030.0\x64 C:\VcRedist\2012\11.0.61030.0\x86 C:\VcRedist\2013\12.0.40664.0\x64 C:\VcRedist\2013\12.0.40664.0\x86 C:\VcRedist\2019\14.28.29913.0\x64 C:\VcRedist\2019\14.28.29913.0\x86

## EXAMPLES

### EXAMPLE 1
```
Save-VcRedist -VcList (Get-VcList) -Path C:\Redist
```

Description: Downloads the supported Visual C++ Redistributables to C:\Redist.

### EXAMPLE 2
```
Get-VcList | Save-VcRedist -Path C:\Redist
```

Description: Passes the list of supported Visual C++ Redistributables to Save-VcRedist and downloads the Redistributables to C:\Redist.

### EXAMPLE 3
```
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Save-VcRedist -VcList $VcList -Path C:\Redist
```

Description: Passes the list of 2013 and 2019 x86 supported Visual C++ Redistributables to Save-VcRedist and downloads the Redistributables to C:\Redist.

### EXAMPLE 4
```
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist
```

Description: Downloads the 2010, 2012, 2013, and 2019 Visual C++ Redistributables to C:\Redist.

### EXAMPLE 5
```
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist -Proxy proxy.domain.local
```

Description: Downloads the 2010, 2012, 2013, and 2019 Visual C++ Redistributables to C:\Redist using the proxy server 'proxy.domain.local'

### EXAMPLE 6
```
Get-VcList | Save-VcRedist -Path ./Redist -SkipAuthenticodeValidation
```

Description: Downloads the Redistributables on macOS or Linux without verifying their Authenticode signatures or publisher.

## PARAMETERS

### -VcList
Specifies the array that lists the Visual C++ Redistributables to download.

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
Specify a target folder to download the Redistributables to, otherwise use the current folder. The folder is created if it does not exist; an error is returned before any download if it cannot be created.

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
Force the use of Invoke-WebRequest instead of Start-BitsTransfer.
Included for backwards compatibility only.

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
Force the priority when using Start-BitsTransfer.
Included for backwards compatibility only.

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
Specifies a proxy server for the request, rather than connecting directly to the internet resource.
Enter the URI of a network proxy server.

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
Specifies a user account that has permission to use the proxy server that is specified by the Proxy parameter.
The default is the current user.

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

### -ShowProgress
Instructs Invoke-WebRequest used by this function to display progress.

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
Skips Authenticode signature and publisher validation for downloaded and existing installers. Use on macOS or Linux where Authenticode validation is unavailable. This reduces security; HTTPS and allowed-host checks remain enabled.

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
Specifies a user agent string for the web request.

The default user agent identifies the module, for example: VcRedist/5.0.0 (https://github.com/EUCPilots/vcredist; PowerShell 7.5.0; Win32NT 10.0.26100.0)

To use a browser user agent string instead, use the properties of the PSUserAgent class, such as Chrome: Save-VcRedist -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)

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

[Download the Redistributables:](https://vcredist.com/save-vcredist/)
