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
#>

function Get-LoggingMessageCount {
    [CmdletBinding()]
    param()

    return $Script:LoggingMessagerCount.Value
}