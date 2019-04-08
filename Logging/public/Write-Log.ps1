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
        [object] $Body = $null,
        [Parameter(Position = 5,
            Mandatory = $false)]
        [System.Management.Automation.ErrorRecord] $ExceptionInfo = $null
    )

    DynamicParam {
        New-LoggingDynamicParam -Level -Mandatory $false -Name "Level"
        $PSBoundParameters["Level"] = "INFO"
    }

    Begin{
        if (!(Get-Variable -Name "LoggingEventQueue" -Scope Script -ErrorAction Ignore)) {
            Start-LoggingManager
        }
    }

    End {
        $levelNumber = Get-LevelNumber -Level $PSBoundParameters.Level
        if ($PSBoundParameters.ContainsKey('Arguments')) {
            $text = $Message -f $Arguments
        }
        else {
            $text = $Message
        }

        $invocationInfo = (Get-PSCallStack).InvocationInfo

        $logMessage = [hashtable] @{
            timestamp = Get-Date -UFormat $Defaults.Timestamp
            level     = $PSBoundParameters.Level
            levelno   = $levelNumber
            lineno    = $invocationInfo.ScriptLineNumber
            pathname  = $invocationInfo.ScriptName
            filename  = $FileName
            caller    = Get-CallerNameInScope
            message   = $text
            body      = $Body
            execinfo  = $ExceptionInfo
            pid       = $PID
        }

        $Script:LoggingEventQueue.Add($logMessage)
    }
}
