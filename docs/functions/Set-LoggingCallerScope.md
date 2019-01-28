---
external help file: Logging-help.xml
Module Name: Logging
online version: https://logging.readthedocs.io/en/latest/functions/Set-LoggingCallerScope.md
schema: 2.0.0
---

# Set-LoggingCallerScope

## SYNOPSIS
Sets the scope from which to get the caller scope

## SYNTAX

```
Set-LoggingCallerScope [[-CallerScope] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
This function sets the scope to obtain information from the caller

## EXAMPLES

### EXAMPLE 1
```
Set-LoggingCallerScope -CallerScope 2
```

### EXAMPLE 2
```
Set-LoggingCallerScope
```

It sets the caller scope to 1

## PARAMETERS

### -CallerScope
Integer representing the scope to use to find the caller information.
Defaults to 1 which represent the scope of the function where Write-Log is being called from

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $Defaults.CallerScope
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

[https://logging.readthedocs.io/en/latest/functions/Set-LoggingCallerScope.md](https://logging.readthedocs.io/en/latest/functions/Set-LoggingCallerScope.md)

[https://logging.readthedocs.io/en/latest/functions/Write-Log.md](https://logging.readthedocs.io/en/latest/functions/Write-Log.md)

[https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingCallerScope.ps1](https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingCallerScope.ps1)

