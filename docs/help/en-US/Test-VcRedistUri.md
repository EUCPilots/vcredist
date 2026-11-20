---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com/vcredist/test/
schema: 2.0.0
---

# Test-VcRedistUri

## SYNOPSIS
Tests whether the download URI for each Visual C++ Redistributable can be reached.

## SYNTAX

```
Test-VcRedistUri [-VcList] <PSObject> [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-ShowProgress]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
For each input entry, validates that the URI uses HTTPS and an allowed host, then sends a HEAD request with a 30-second timeout.

Returns one result object per input entry. Each object includes Result, Release, Architecture, Version, and URI properties. Result is true when the HTTPS HEAD request succeeds and false when the URI is not allowed or the request fails.

## EXAMPLES

### EXAMPLE 1
```
Test-VcRedistUri -VcList (Get-VcList)
```

Description: Test the Visual C++ Redistributables passed from Get-VcList.

### EXAMPLE 2
```
Get-VcList | Test-VcRedistUri
```

Description: Passes the list of supported Visual C++ Redistributables from Get-VcList to Test-VcRedistUri via the pipeline

### EXAMPLE 3
```
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Test-VcRedistUri -VcList $VcList
```

Description: Tests the list of 2013 and 2019 x86 supported Visual C++ Redistributables.

### EXAMPLE 4
```
Test-VcRedistUri -VcList (Get-VcList -Export All)
```

Description: Tests the download URIs for all supported and unsupported manifest entries.

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

### -Proxy
Specifies a proxy server for the request, rather than connecting directly to the internet resource.
Enter the URI of a network proxy server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProxyCredential
Specifies a user account that has permission to use the proxy server that is specified by the Proxy parameter.
By default, no proxy credentials are supplied.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: [System.Management.Automation.PSCredential]::Empty
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

[Test Redistributable downloads:](https://stealthpuppy.com/vcredist/test/)

