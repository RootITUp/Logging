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

New-Variable -Name Dispatcher   -Value ([hashtable]::Synchronized(@{})) -Option ReadOnly
New-Variable -Name LevelNames   -Value $LN -Option ReadOnly
New-Variable -Name Logging      -Value ([hashtable]::Synchronized(@{})) -Option ReadOnly
New-Variable -Name LogTargets   -Value ([hashtable]::Synchronized(@{})) -Option ReadOnly
New-Variable -Name MessageQueue -Value ([System.Collections.ArrayList]::Synchronized([System.Collections.ArrayList] @())) -Option ReadOnly
New-Variable -Name ScriptRoot   -Value (Split-Path $MyInvocation.MyCommand.Path) -Option ReadOnly

$Defaults = @{
    Level = $NOTSET
    Format = '[%{timestamp:+%Y-%m-%d %T%Z}] [%{level:-7}] %{message}'
    Timestamp = '%Y-%m-%dT%T%Z'
    CallerScope = 1
}

$Logging.Level      = $Defaults.Level
$Logging.Format     = $Defaults.Format
$Logging.CallerScope = $Defaults.CallerScope
$Logging.Targets    = [hashtable] @{}

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

$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$InitialSessionState.ApartmentState = 'MTA'

$InitialSessionState.Commands.Add((New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'Replace-Token', (Get-Content Function:\Replace-Token)))
$InitialSessionState.Commands.Add((New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'Initialize-LoggingTarget', (Get-Content Function:\Initialize-LoggingTarget)))
$InitialSessionState.Commands.Add((New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'Get-LevelNumber', (Get-Content Function:\Get-LevelNumber)))

$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'ScriptRoot', $ScriptRoot, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'Dispatcher', $Dispatcher, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'LevelNames', $LevelNames, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'LogTargets', $LogTargets, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'Logging', $Logging, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'MessageQueue', $MessageQueue, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'ParentHost', $Host, ''))

$ScriptBlock = {
    $CustomTargets = $Logging.CustomTargets

    Initialize-LoggingTarget

    while ($Dispatcher.Flag -or $MessageQueue.Count -gt 0) {
        if ($CustomTargets -ne $Logging.CustomTargets) {
            $CustomTargets = $Logging.CustomTargets
            Initialize-LoggingTarget
        }

        if ($MessageQueue.Count -gt 0) {
            foreach ($Message in $MessageQueue) {
                if ($Logging.Targets.Count) {$Targets = $Logging.Targets}
                else {$Targets = $null}

                foreach ($TargetName in $Targets.Keys) {
                    $LoggerFormat = $Logging.Format
                    $LoggerLevel = Get-LevelNumber -Level $Logging.Level

                    $Target = $Targets[$TargetName]

                    if ($Target) {
                        if ($Target.Level) {$LoggerLevel = Get-LevelNumber -Level $Target.Level}
                        if ($Target.Format) {$LoggerFormat = $Target.Format}
                        $Configuration = $Target
                    }

                    if ($Message.LevelNo -ge $LoggerLevel) {
                        & $LogTargets[$TargetName].Logger $Message $LoggerFormat $Configuration
                    }
                }
                $MessageQueue.Remove($Message)
            }
        }
        Start-Sleep -Milliseconds 10
    }
}

$Dispatcher.Flag = $true
$Dispatcher.Host = $Host
$Dispatcher.RunspacePool = [RunspaceFactory]::CreateRunspacePool($InitialSessionState)
$Dispatcher.RunspacePool.SetMinRunspaces(1)
$Dispatcher.RunspacePool.SetMaxRunspaces([int] $env:NUMBER_OF_PROCESSORS + 1)
$Dispatcher.RunspacePool.Open()
$Dispatcher.Powershell = [Powershell]::Create().AddScript($ScriptBlock)
$Dispatcher.Powershell.RunspacePool = $Dispatcher.RunspacePool
$Dispatcher.Handle = $Dispatcher.Powershell.BeginInvoke()

#region Handle Module Removal
$ExecutionContext.SessionState.Module.OnRemove = {
    $Dispatcher.Flag = $false
    #Let sit for a second to make sure it has had time to stop
    Start-Sleep -Seconds 1
    if ($Dispatcher.Handle) {
        [void] $Dispatcher.PowerShell.EndInvoke($Dispatcher.Handle)
        [void] $Dispatcher.PowerShell.Dispose()
    }
    [System.GC]::Collect()
}
#endregion Handle Module Removal

