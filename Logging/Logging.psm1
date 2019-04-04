#requires -Version 4

$NOTSET     = 0
$DEBUG      = 10
$INFO       = 20
$WARNING    = 30
$ERROR_     = 40

$LN = [hashtable]::Synchronized(@{
    $NOTSET = 'NOTSET'
    $ERROR_ = 'ERROR'
    $WARNING = 'WARNING'
    $INFO = 'INFO'
    $DEBUG = 'DEBUG'
    'NOTSET' = $NOTSET
    'ERROR' = $ERROR_
    'WARNING' = $WARNING
    'INFO' = $INFO
    'DEBUG' = $DEBUG
})

New-Variable -Name LevelNames   -Value $LN -Option Constant
New-Variable -Name Logging      -Value ([hashtable]::Synchronized(@{})) -Option Constant
New-Variable -Name LogTargets   -Value ([hashtable]::Synchronized(@{})) -Option Constant
New-Variable -Name MessageQueue -Value ([System.Collections.ArrayList]::Synchronized([System.Collections.ArrayList] @())) -Option Constant
New-Variable -Name ScriptRoot   -Value (Split-Path $MyInvocation.MyCommand.Path) -Option Constant

$Defaults = @{
    Level = $NOTSET
    Format = '[%{timestamp:+%Y-%m-%d %T%Z}] [%{level:-7}] %{message}'
    Timestamp = '%Y-%m-%dT%T%Z'
    CallerScope = 1
}

$Logging.Level      = $Defaults.Level
$Logging.Format     = $Defaults.Format
$Logging.CallerScope = $Defaults.CallerScope
$Logging.Targets    = [hashtable]::Synchronized(@{})
$Logging.CustomTargets = [String]::Empty

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

Initialize-LoggingTarget

Start-LoggingManager