---
external help file: Logging-help.xml
online version: 
schema: 2.0.0
---

# Wait-Logging

## SYNOPSIS
Waits until all messages are processed.

## SYNTAX

```
Wait-Logging [<CommonParameters>]
```

## DESCRIPTION
Suspend the script execution except for the logging part. It allows to flush the messages before continuing the flow.

Used in scripts, less useful in interactive sessions.

## EXAMPLES

### Example 1
```
PS C:\> Write-Log -Level ERROR -Message 'Test'
PS C:\> Wait-Logging
```

Waits until all messages are processed.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

