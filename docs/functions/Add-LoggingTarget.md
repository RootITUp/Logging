# Add-LoggingTarget

## SYNOPSIS
Enable a logging target

## SYNTAX

```
Add-LoggingTarget [[-Configuration] <Hashtable>] -Name <String> [<CommonParameters>]
```

## DESCRIPTION
This function configure and enable a logging target

## EXAMPLES

### EXAMPLE 1
```
Add-LoggingTarget -Name Console -Configuration @{Level = 'DEBUG'}
```

### EXAMPLE 2
```
Add-LoggingTarget -Name File -Configuration @{Level = 'INFO'; Path = 'C:\Temp\script.log'}
```

## PARAMETERS

### -Configuration
An hashtable containing the configurations for the target

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
{{Fill Name Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://logging.readthedocs.io/en/latest/functions/Add-LoggingTarget.md](https://logging.readthedocs.io/en/latest/functions/Add-LoggingTarget.md)

[https://logging.readthedocs.io/en/latest/functions/Write-Log.md](https://logging.readthedocs.io/en/latest/functions/Write-Log.md)

[https://logging.readthedocs.io/en/latest/AvailableTargets.md](https://logging.readthedocs.io/en/latest/AvailableTargets.md)

[https://github.com/EsOsO/Logging/blob/master/Logging/Logging.psm1#L243](https://github.com/EsOsO/Logging/blob/master/Logging/Logging.psm1#L243)

