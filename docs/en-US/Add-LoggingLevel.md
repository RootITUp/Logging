---
external help file: Logging-help.xml
online version: 
schema: 2.0.0
---

# Add-LoggingLevel

## SYNOPSIS
Add a custom logging level.

## SYNTAX

```
Add-LoggingLevel [-Level] <Int32> [-LevelName] <String> [<CommonParameters>]
```

## DESCRIPTION
The cmdlet add a custom logging level associated to an Int32 that defines the priority over the built-in levels.

## EXAMPLES

### Example 1
```
PS C:\> Add-LoggingLevel -Level 15 -LevelName MYCUSTOMLEVEL
```

Defines MYCUSTOMLEVEL with a priority of 15 (between DEBUG and INFO)

## PARAMETERS

### -Level
An integer defining the level priority

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LevelName
The name of the level.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

