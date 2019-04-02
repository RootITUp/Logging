<#
    .SYNOPSIS
        Sets a global logging severity level

    .DESCRIPTION
        This function sets a global logging severity level

    .PARAMETER Level
        The level severity name to set as default for enabled targets

    .EXAMPLE
        PS C:\> Set-LoggingDefaultLevel -Level ERROR

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Set-LoggingDefaultLevel.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Set-LoggingDefaultLevel.ps1
#>
function Set-LoggingDefaultLevel {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Set-LoggingDefaultLevel.md')]
    param()

    DynamicParam {
        Get-LoggingDynamicParam -Name "Level" -Level -DefaultValue 'VERBOSE'
    }

    End {
        $Logging.Level = Get-LevelNumber -Level $PSBoundParameters.Level
    }
}
