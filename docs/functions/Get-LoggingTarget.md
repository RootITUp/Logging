---
external help file: Logging-help.xml
Module Name: Logging
online version: https://logging.readthedocs.io/en/latest/functions/Get-LoggingTarget.md
schema: 2.0.0
---

# Get-LoggingTarget

## SYNOPSIS
Returns enabled logging targets

## SYNTAX

```
Get-LoggingTarget [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function returns enabled logging targtes

## EXAMPLES

### EXAMPLE 1
```
Get-LoggingTarget
```

### EXAMPLE 2
```
Get-LoggingTarget -Name Console
```

## PARAMETERS

### -Name
The Name of the target to retrieve, if not passed all configured targets will be returned

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://logging.readthedocs.io/en/latest/functions/Get-LoggingTarget.md](https://logging.readthedocs.io/en/latest/functions/Get-LoggingTarget.md)

[https://logging.readthedocs.io/en/latest/functions/Write-Log.md](https://logging.readthedocs.io/en/latest/functions/Write-Log.md)

[https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingTarget.ps1](https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingTarget.ps1)

