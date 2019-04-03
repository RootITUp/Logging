<#
    .SYNOPSIS
        Enable a logging target

    .DESCRIPTION
        This function configure and enable a logging target

    .PARAMETER Name
        The name of the target to enable and configure

    .PARAMETER Configuration
        An hashtable containing the configurations for the target

    .EXAMPLE
        PS C:\> Add-LoggingTarget -Name Console -Configuration @{Level = 'DEBUG'}

    .EXAMPLE
        PS C:\> Add-LoggingTarget -Name File -Configuration @{Level = 'INFO'; Path = 'C:\Temp\script.log'}

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Add-LoggingTarget.md

    .LINK
        https://logging.readthedocs.io/en/latest/functions/Write-Log.md

    .LINK
        https://logging.readthedocs.io/en/latest/AvailableTargets.md

    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Add-LoggingTarget.ps1
#>
function Add-LoggingTarget {
    [CmdletBinding(HelpUri='https://logging.readthedocs.io/en/latest/functions/Add-LoggingTarget.md')]
    param(
        [Parameter(Position = 2)]
        [hashtable] $Configuration = @{}
    )

    DynamicParam {
        New-LoggingDynamicParam -Name "Name" -Target
    }

    End {
        Assert-LoggingTargetConfiguration -Target $PSBoundParameters.Name -Configuration $Configuration
        $Logging.Targets[$PSBoundParameters.Name] = $Configuration
    }
}
