---
external help file: Logging-help.xml
online version: 
schema: 2.0.0
---

# Get-LoggingTarget

## SYNOPSIS
Gets currently configured targets.

## SYNTAX

```
Get-LoggingTarget [<CommonParameters>]
```

## DESCRIPTION
The cmdlet gets the currently in use targets with their configurations.

## EXAMPLES

### Example 1
```
PS C:\> Get-LoggingTarget

Name                           Value
----                           -----
File                           {Level, Path}
Console                        {Level}
```

Gets currently configured targets.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

