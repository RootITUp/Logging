---
external help file: Logging-help.xml
online version: 
schema: 2.0.0
---

# Get-LoggingDefaultFormat

## SYNOPSIS
Gets the default message format.

## SYNTAX

```
Get-LoggingDefaultFormat [<CommonParameters>]
```

## DESCRIPTION
The cmdlet allows to retrieve the default message format used by targets that do not override it.

## EXAMPLES

### Example 1
```
PS C:\> Get-LoggingDefaultFormat
[%{timestamp:+%Y-%m-%d %T%Z}] [%{level:-7}] %{message}
```

Prints the default message format

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

