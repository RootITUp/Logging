---
external help file: Logging-help.xml
Module Name: Logging
online version: https://logging.readthedocs.io/en/latest/functions/Set-LoggingDefaultFormat.md
schema: 2.0.0
---

# Set-LoggingDefaultFormat

## SYNOPSIS
Sets a global logging message format

## SYNTAX

```
Set-LoggingDefaultFormat [[-Format] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function sets a global logging message format

## EXAMPLES

### EXAMPLE 1
```
Set-LoggingDefaultFormat -Format '[%{level:-7}] %{message}'
```

### EXAMPLE 2
```
Set-LoggingDefaultFormat
```

It sets the default format as \[%{timestamp:+%Y-%m-%d %T%Z}\] \[%{level:-7}\] %{message}

## PARAMETERS

### -Format
The string used to format the message to log

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $Defaults.Format
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

[https://logging.readthedocs.io/en/latest/functions/Set-LoggingDefaultFormat.md](https://logging.readthedocs.io/en/latest/functions/Set-LoggingDefaultFormat.md)

[https://logging.readthedocs.io/en/latest/functions/LoggingFormat.md](https://logging.readthedocs.io/en/latest/functions/LoggingFormat.md)

[https://logging.readthedocs.io/en/latest/functions/Write-Log.md](https://logging.readthedocs.io/en/latest/functions/Write-Log.md)

[https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingDefaultFormat.ps1](https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingDefaultFormat.ps1)

