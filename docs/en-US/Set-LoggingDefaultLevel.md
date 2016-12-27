---
external help file: Logging-help.xml
online version: 
schema: 2.0.0
---

# Set-LoggingDefaultLevel

## SYNOPSIS
Sets the default logging level.

## SYNTAX

```
Set-LoggingDefaultLevel -Level <String> [<CommonParameters>]
```

## DESCRIPTION
Sets the default logging level for targets that do not define it.

## EXAMPLES

### Example 1
```
PS C:\> Set-LoggingDefaultLevel -Level DEBUG
```

If a target do not sets the Level parameter, DEBUG will be used

## PARAMETERS

### -Level
Sets the logging level

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: DEBUG, ERROR, INFO, NOTSET, WARNING

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

