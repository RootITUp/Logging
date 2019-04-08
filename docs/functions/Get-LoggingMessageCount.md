---
external help file: Logging-help.xml
Module Name: Logging
online version: https://logging.readthedocs.io/en/latest/functions/Get-LoggingMessageCount.md
schema: 2.0.0
---

# Get-LoggingMessageCount

## SYNOPSIS
Returns the currently processed log message count

## SYNTAX

```
Get-LoggingMessageCount [<CommonParameters>]
```

## DESCRIPTION
When a message is processed by any log target it will be added
to the count of logged messages.
Get-LoggingMessageCount retrieves the sum of those messages.

## EXAMPLES

### EXAMPLE 1
```
Set-LoggingDefaultLevel -Level ERROR
```

Add-LoggingTarget -Name Console
write-Log -Message "Test1"
Write-Log -Message "Test2" -Level ERROR

Get-LoggingMessageCount
=\> 1

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://logging.readthedocs.io/en/latest/functions/Get-LoggingMessageCount.md](https://logging.readthedocs.io/en/latest/functions/Get-LoggingMessageCount.md)

[https://logging.readthedocs.io/en/latest/functions/Write-Log.md](https://logging.readthedocs.io/en/latest/functions/Write-Log.md)

[https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingMessageCount.ps1](https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingMessageCount.ps1)

