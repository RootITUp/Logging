---
external help file: Logging-help.xml
Module Name: Logging
online version: https://logging.readthedocs.io/en/latest/functions/Write-Log.md
schema: 2.0.0
---

# Write-Log

## SYNOPSIS
Emits a log record

## SYNTAX

```
Write-Log [-Message] <String> [[-Arguments] <Array>] [[-Body] <Object>] [[-ExceptionInfo] <ErrorRecord>]
 [-Level <String>] [<CommonParameters>]
```

## DESCRIPTION
This function write a log record to configured targets with the matching level

## EXAMPLES

### EXAMPLE 1
```
Write-Log 'Hello, World!'
```

### EXAMPLE 2
```
Write-Log -Level ERROR -Message 'Hello, World!'
```

### EXAMPLE 3
```
Write-Log -Level ERROR -Message 'Hello, {0}!' -Arguments 'World'
```

### EXAMPLE 4
```
Write-Log -Level ERROR -Message 'Hello, {0}!' -Arguments 'World' -Body @{Server='srv01.contoso.com'}
```

## PARAMETERS

### -Message
The text message to write

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Arguments
An array of objects used to format \<Message\>

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
An object that can contain additional log metadata (used in target like ElasticSearch)

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExceptionInfo
An optional ErrorRecord

```yaml
Type: ErrorRecord
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Level
{{Fill Level Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://logging.readthedocs.io/en/latest/functions/Write-Log.md](https://logging.readthedocs.io/en/latest/functions/Write-Log.md)

[https://logging.readthedocs.io/en/latest/functions/Add-LoggingLevel.md](https://logging.readthedocs.io/en/latest/functions/Add-LoggingLevel.md)

[https://github.com/EsOsO/Logging/blob/master/Logging/public/Write-Log.ps1](https://github.com/EsOsO/Logging/blob/master/Logging/public/Write-Log.ps1)

