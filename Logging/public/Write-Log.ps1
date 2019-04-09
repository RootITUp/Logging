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
        New-LoggingDynamicParam -Level -Mandatory $false -Name "Level"
        $PSBoundParameters["Level"] = "INFO"
    }

    End {
        $LevelNo = Get-LevelNumber -Level $PSBoundParameters.Level
        if ($PSBoundParameters.ContainsKey('Arguments')) {
            $text = $Message -f $Arguments
        } else {
            $text = $Message
        }

        $InvocationInfo = (Get-PSCallStack)[$Logging.CallerScope]
        # Split-Path throws an exception if called with a -Path that is null or empty.
        if ([string]::IsNullOrEmpty($InvocationInfo.ScriptName)) {
            $PathName = $FileName = ''
        } else {
            $PathName = $InvocationInfo.ScriptName
            $FileName = Split-Path -Path $PathName -Leaf
        }

        $mess = [hashtable] @{
            timestamp = Get-Date -UFormat $Defaults.Timestamp
            level     = Get-LevelName -Level $LevelNo
            levelno   = $LevelNo
            lineno    = $InvocationInfo.ScriptLineNumber
            pathname  = $PathName
            filename  = $FileName
            caller    = Get-CallerNameInScope
            message   = $text
            execinfo  = $ExceptionInfo
            pid       = $PID
        }

        if ($Body) { $mess.body = $Body }
        [void] $MessageQueue.Add($mess)
    }
}
