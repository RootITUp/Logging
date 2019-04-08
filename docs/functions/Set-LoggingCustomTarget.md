---
external help file: Logging-help.xml
Module Name: Logging
online version: https://logging.readthedocs.io/en/latest/functions/Set-LoggingCustomTarget.md
schema: 2.0.0
---

# Set-LoggingCustomTarget

## SYNOPSIS
Sets a folder as custom target repository

## SYNTAX

```
Set-LoggingCustomTarget [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
This function sets a folder as a custom target repository.
Every *.ps1 file will be loaded as a custom target and available to be enabled for logging to.

## EXAMPLES

### EXAMPLE 1
```
Set-LoggingCustomTarget -Path C:\Logging\CustomTargets
```

## PARAMETERS

### -Path
A valid path containing *.ps1 files that defines new loggin targets

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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

[https://logging.readthedocs.io/en/latest/functions/Set-LoggingCustomTarget.md](https://logging.readthedocs.io/en/latest/functions/Set-LoggingCustomTarget.md)

[https://logging.readthedocs.io/en/latest/functions/CustomTargets.md](https://logging.readthedocs.io/en/latest/functions/CustomTargets.md)

[https://logging.readthedocs.io/en/latest/functions/Write-Log.md](https://logging.readthedocs.io/en/latest/functions/Write-Log.md)

[https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingCustomTarget.ps1](https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingCustomTarget.ps1)

