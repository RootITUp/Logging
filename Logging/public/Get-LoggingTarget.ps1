<#
    .SYNOPSIS
        Returns enabled logging targets

    .DESCRIPTION
        This function returns enabled logging targtes

    .EXAMPLE
        PS C:\> Get-LoggingTarget

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Get-LoggingTarget.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Get-LoggingTarget.ps1
#>
function Get-LoggingTarget {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Get-LoggingTarget.md')]
    param()

    return $Logging.Targets
}
