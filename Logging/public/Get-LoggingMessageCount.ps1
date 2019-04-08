<#
    .SYNOPSIS
        Returns the currently processed log message count

    .DESCRIPTION
        When a message is processed by any log target it will be added
        to the count of logged messages.
        Get-LoggingMessageCount retrieves the sum of those messages.

    .EXAMPLE
        Set-LoggingDefaultLevel -Level ERROR
        Add-LoggingTarget -Name Console
        write-Log -Message "Test1"
        Write-Log -Message "Test2" -Level ERROR

        Get-LoggingMessageCount
        => 1
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Get-LoggingMessageCount.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingMessageCount.ps1

#>

function Get-LoggingMessageCount {
    [CmdletBinding(HelpUri = 'https://logging.readthedocs.io/en/latest/functions/Get-LoggingMessageCount.md')]
    param()

    if (!(Get-Variable -Name "LoggingMessagerCount" -Scope Script -ErrorAction Ignore)) {
        Start-LoggingManager
    }

    return $Script:LoggingMessagerCount.Value
}