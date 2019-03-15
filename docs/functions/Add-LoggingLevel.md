---
external help file: Logging-help.xml
Module Name: Logging
online version: https://logging.readthedocs.io/en/latest/functions/Add-LoggingLevel.md
schema: 2.0.0
---

# Add-LoggingLevel

## SYNOPSIS
Define a new severity level

## SYNTAX

```
Add-LoggingLevel [-Level] <Int32> [-LevelName] <String> [<CommonParameters>]
```

## DESCRIPTION
This function add a new severity level to the ones already defined

## EXAMPLES

### EXAMPLE 1
```
Add-LoggingLevel -Level 41 -LevelName CRITICAL
```

### EXAMPLE 2
```
Add-LoggingLevel -Level 15 -LevelName VERBOSE
```

## PARAMETERS

### -Level
An integer that identify the severity of the level, higher the value higher the severity of the level
By default the module defines this levels:
NOTSET   0
DEBUG   10
INFO    20
WARNING 30
ERROR   40

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -LevelName
The human redable name to assign to the level

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://logging.readthedocs.io/en/latest/functions/Add-LoggingLevel.md](https://logging.readthedocs.io/en/latest/functions/Add-LoggingLevel.md)

[https://logging.readthedocs.io/en/latest/functions/Write-Log.md](https://logging.readthedocs.io/en/latest/functions/Write-Log.md)

[https://github.com/EsOsO/Logging/blob/master/Logging/public/Add-LoggingLevel.ps1](https://github.com/EsOsO/Logging/blob/master/Logging/public/Add-LoggingLevel.ps1)

