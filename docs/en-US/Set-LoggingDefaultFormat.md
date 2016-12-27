---
external help file: Logging-help.xml
online version: 
schema: 2.0.0
---

# Set-LoggingDefaultFormat

## SYNOPSIS
Sets the default logging message format.

## SYNTAX

```
Set-LoggingDefaultFormat [[-Format] <String>] [<CommonParameters>]
```

## DESCRIPTION
Sets the default logging message format for target that do not define it.

## EXAMPLES

### Example 1
```
PS C:\> Set-LoggingDefaultFormat -Format '{%level} %{message}'
PS C:\> Write-Log -Level DEBUG -Message 'Test'
DEBUG Test
```

It will change the logging message format.

## PARAMETERS

### -Format
The logging format

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 0
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

