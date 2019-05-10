#requires -Version 4


# Dot source public/private functions
$PublicFunctions = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'public/*.ps1') -Recurse -ErrorAction SilentlyContinue)
$PrivateFunctions = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'private/*.ps1') -Recurse -ErrorAction SilentlyContinue)

$AllFunctions = $PublicFunctions + $PrivateFunctions
foreach ($Function in $AllFunctions) {
    try {
        . $Function.FullName
    }
    catch {
        throw "Unable to dot source [$($Function.FullName)]"
    }
}

Export-ModuleMember -Function $PublicFunctions.BaseName

Set-LoggingVariables

Initialize-LoggingTarget

<#
    DO NOT start LoggingManager for children.
    This would result in endless loop (until OOM)!
#>
if (-not (Get-Variable -Name "LoggingEventQueue" -ErrorAction Ignore)) {
    Start-LoggingManager
}