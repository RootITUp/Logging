<#
    .SYNOPSIS
        Wait for the message queue to be emptied

    .DESCRIPTION
        This function can be used to block the execution of a script waiting for the message queue to be emptied

    .EXAMPLE
        PS C:\> Wait-Logging

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Wait-Logging.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Wait-Logging.ps1
#>
function Wait-Logging {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Wait-Logging.md')]
    param()

    while ($MessageQueue.Count -gt 0) {
        Start-Sleep -Milliseconds 10
    }
}
