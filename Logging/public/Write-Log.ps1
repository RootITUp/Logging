<#
    .SYNOPSIS
        Emits a log record

    .DESCRIPTION
        This function write a log record to configured targets with the matching level

    .PARAMETER Level
        The log level of the message. Valid values are DEBUG, INFO, WARNING, ERROR, NOTSET
        Other custom levels can be added and are a valid value for the parameter
        INFO is the default

    .PARAMETER Message
        The text message to write

    .PARAMETER Arguments
        An array of objects used to format <Message>

    .PARAMETER Body
        An object that can contain additional log metadata (used in target like ElasticSearch)

    .PARAMETER ExceptionInfo
        An optional ErrorRecord

    .EXAMPLE
        PS C:\> Write-Log 'Hello, World!'

    .EXAMPLE
        PS C:\> Write-Log -Level ERROR -Message 'Hello, World!'

    .EXAMPLE
        PS C:\> Write-Log -Level ERROR -Message 'Hello, {0}!' -Arguments 'World'

    .EXAMPLE
        PS C:\> Write-Log -Level ERROR -Message 'Hello, {0}!' -Arguments 'World' -Body @{Server='srv01.contoso.com'}

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Add-LoggingLevel.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Write-Log.ps1
#>
Function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Position = 2,
                   Mandatory = $true)]
        [string] $Message,
        [Parameter(Position = 3,
                   Mandatory = $false)]
        [array] $Arguments,
        [Parameter(Position = 4,
                   Mandatory = $false)]
        [object] $Body,
        [Parameter(Position = 5,
                   Mandatory = $false)]
        [System.Management.Automation.ErrorRecord] $ExceptionInfo = $null
    )

    DynamicParam {
        $Level = New-Object System.Management.Automation.ParameterAttribute
        $Level.ParameterSetName = '__AllParameterSets'
        $Level.Mandatory = $false
        $Level.Position = 1
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute(Get-LevelsName)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($Level)
        $AttributeCollection.Add($ValidateSetAttribute)

        $LevelParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Level', [string], $AttributeCollection)
        $PSBoundParameters['Level'] = 'INFO'

        $RDPDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RDPDic.Add('Level', $LevelParam)
        return $RDPDic
    }

    End {
        $LevelNo = Get-LevelNumber -Level $PSBoundParameters.Level
        if ($PSBoundParameters.ContainsKey('Arguments')) {
            $text = $Message -f $Arguments
        } else {
            $text = $Message
        }

        $InvocationInfo = (Get-PSCallStack).InvocationInfo

        $mess = [hashtable] @{
            timestamp = Get-Date -UFormat $Defaults.Timestamp
            level     = Get-LevelName -Level $LevelNo
            levelno   = $LevelNo
            lineno    = $InvocationInfo.ScriptLineNumber
            pathname  = $InvocationInfo.ScriptName
            filename  = $FileName
            caller    = Get-CallerNameInScope
            message   = $text
            execinfo  = $ExceptionInfo
        }

        if ($Body) { $mess.body = $Body }
        [void] $MessageQueue.Add($mess)
    }
}
