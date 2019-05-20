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

#Module no longer loaded inside Start-LoggingManager
Start-LoggingManager