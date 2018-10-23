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
        $attributes = New-Object System.Management.Automation.ParameterAttribute
        $attributes.ParameterSetName = '__AllParameterSets'
        $attributes.Mandatory = $true
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute(Get-LevelsName)

        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)
        $attributeCollection.Add($ValidateSetAttribute)

        $dynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('Level', [string], $attributeCollection)
        $dynParam1.Value = 'VERBOSE'

        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add('Level', $dynParam1)
        return $paramDictionary
    }

    End {
        $Logging.Level = Get-LevelNumber -Level $PSBoundParameters.Level
    }
}
