<#
.SYNOPSIS
Creates the param used inside the DynamicParam{}-Block

.DESCRIPTION
New-LoggingDynamicParam creates (or appends) a RuntimeDefinedParameterDictionary
with a parameter whos value is validated through a dynamic validate set.

.PARAMETER Name
displayed parameter name

.PARAMETER Level
Constructs the validate set out of the currently configured logging level names.

.PARAMETER Target
Constructs the validate set out of the currently configured logging targets.

.PARAMETER DynamicParams
Dictionary to be appended. (Useful for multiple dynamic params)

.PARAMETER Mandatory
Controls if parameter is mandatory for call. Defaults to $true

.EXAMPLE
DynamicParam{
    New-LoggingDynamicParam -Name "Level" -Level -DefaultValue 'Verbose'
}

DynamicParam{
    $dictionary = New-LoggingDynamicParam -Name "Level" -Level
    New-LoggingDynamicParam -Name "Target" -Target -DynamicParams $dictionary
}
#>

function New-LoggingDynamicParam {
    [OutputType([System.Management.Automation.RuntimeDefinedParameterDictionary])]
    [CmdletBinding(DefaultParameterSetName="DynamicTarget")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "DynamicLevel")]
        [Parameter(Mandatory = $true, ParameterSetName = "DynamicTarget")]
        [String]
        $Name,
        [Parameter(Mandatory = $true, ParameterSetName = "DynamicLevel")]
        [switch]
        $Level,
        [Parameter(Mandatory = $true, ParameterSetName = "DynamicTarget")]
        [switch]
        $Target,
        [boolean]
        $Mandatory = $true,
        [System.Management.Automation.RuntimeDefinedParameterDictionary]
        $DynamicParams
    )

    Write-Verbose -Message ("{0} :: Requested dynamic param for {1}" -f $MyInvocation.MyCommand, $Name)

    if (!$DynamicParams) {
        $DynamicParams = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    }

    $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
    $attribute = New-Object System.Management.Automation.ParameterAttribute

    $attribute.ParameterSetName = '__AllParameterSets'
    $attribute.Mandatory = $Mandatory
    $attribute.Position = 1

    $attributeCollection.Add($attribute)


    [String[]] $allowedValues = @()

    switch ($PSCmdlet.ParameterSetName) {
        "DynamicTarget" {
            $allowedValues += $LogTargets.Keys
        }
        "DynamicLevel" {
            $allowedValues += Get-LevelsName
        }
    }

    Write-Verbose -Message ("{0} :: Currently configured validate set size : {1}" -f $MyInvocation.MyCommand, $allowedValues.Length)

    $validateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($allowedValues)
    $attributeCollection.Add($validateSetAttribute)

    $dynamicParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Name, [string], $attributeCollection)

    $DynamicParams.Add($Name, $dynamicParam)

    return $DynamicParams
}