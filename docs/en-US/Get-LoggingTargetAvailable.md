---
external help file: Logging-help.xml
online version: 
schema: 2.0.0
---

# Get-LoggingTargetAvailable

## SYNOPSIS
Gets the initialized logging targets.

## SYNTAX

```
Get-LoggingTargetAvailable [<CommonParameters>]
```

## DESCRIPTION
The cmdlet lets you retrieve all the the initialized logging targets, built-in and customs.

## EXAMPLES

### Example 1
```
PS C:\> Get-LoggingTargetAvailable

Name                           Value
----                           -----
Email                          {Configuration, Description, ParamsRequired, Logger}
Console                        {Configuration, Description, ParamsRequired, Logger}
ElasticSearch                  {Configuration, Description, ParamsRequired, Logger}
File                           {Configuration, Description, ParamsRequired, Logger}
Slack                          {Configuration, Description, ParamsRequired, Logger}
```

Shows the built-in targets.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

