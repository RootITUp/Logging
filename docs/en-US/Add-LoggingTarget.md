---
external help file: Logging-help.xml
online version:
schema: 2.0.0
---

# Add-LoggingTarget

## SYNOPSIS
Sets up a new logging target.

## SYNTAX

```
Add-LoggingTarget [-Configuration] <Hashtable> [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet sets up a new logging target. The logging target must be initialized using *Set-LoggingCustomTarget*.

## EXAMPLES

### Example 1
```
PS C:\> Add-LoggingTarget -Name File -Configuration @{Level='DEBUG'; Path='C:\TMP\log.txt'}
```

Sets up a file target with DEBUG level to C:\TMP\log.txt

## PARAMETERS

### -Configuration
Target configuration is an hashtable object.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Target name

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Email, Console, ElasticSearch, File, Slack

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

