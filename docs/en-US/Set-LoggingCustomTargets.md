---
external help file: Logging-help.xml
online version: 
schema: 2.0.0
---

# Set-LoggingCustomTargets

## SYNOPSIS
Configures custom logging targets.

## SYNTAX

```
Set-LoggingCustomTargets [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Provides the ability to load custom targets from a specific folder. Each target must ends in .ps1 and be a valid Powershell file (for example take a look at the 'targets' folder inside the module)

## EXAMPLES

### Example 1
```
PS C:\> Set-LoggingCustomTargets -Path C:\MyCustomTargets
```

It will try to load every .ps1 file inside C:\MyCustomTargets that meets the requirements.

## PARAMETERS

### -Path
The folder to load targets from

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
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

