---
external help file: Logging-help.xml
online version: 
schema: 2.0.0
---

# Write-Log

## SYNOPSIS
Emits a log message to specific destinations.

## SYNTAX

```
Write-Log [-Message] <String> [[-Arguments] <Array>] [[-Body] <Object>] [-Level] <String> [<CommonParameters>]
```

## DESCRIPTION
Write-Log emits log message to confgured target destinations (files, console, email etc.) with a equal or above log level.

## EXAMPLES

### Example 1
```
PS C:\> Write-Log 'Hello, World!' -Level ERROR
[2016-12-27 10:31:34] [ERROR] Hello, World!
PS C:\>
```

The command writes a 'Hello, World!' to console

### Example 2
```
PS C:\> Write-Log -Message 'Hello, {0}!' -Arguments 'World' -Level ERROR
[2016-12-27 10:31:34] [ERROR] Hello, World!
PS C:\>
```

The command writes a 'Hello, World!' message to console using string formatting and the -Arguments parameter

### Example 3
```
PS C:\> Write-Log -Message '{0}, {1}!' -Arguments 'Hello', 'World' -Level ERROR
[2016-12-27 10:31:34] [ERROR] Hello, World!
PS C:\>
```

The command writes a 'Hello, World!' message to console using string formatting and the -Arguments parameter

## PARAMETERS

### -Arguments
Specifies and array of objects to be injected in message using Powershell string formatting

```yaml
Type: Array
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
Used to enrich message in systems like Elasticsearch. Especially useful in JSON format.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Level
Defines the message logging priority.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: DEBUG, ERROR, INFO, NOTSET, WARNING

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message
The text to be logged

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
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

