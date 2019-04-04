#Requires -Version 5.0
using namespace System.Collections.Concurrent;
using namespace System.Management.Automation.Runspaces;
using namespace System.Collections.Generic;

function Start-LoggingManager {
    [CmdletBinding()]
    param()

    if (Get-Variable -Name "LoggingEventQueue" -Scope Script -ErrorAction Ignore){
        throw [System.InvalidOperationException]::new("LoggingManager is already started.")
    }

    Write-Verbose -Message ("{0} :: Starting first initialization of LoggingManager." -f $MyInvocation.MyCommand)

    Set-Variable -Name "LoggingMessagerCount" -Option Constant -Scope Script -Value ([ref]0)
    Set-Variable -Name "LoggingEventQueue" -Option Constant -Scope Script -Value ([BlockingCollection[hashtable]]::new(100))
    Set-Variable -Name "LoggingWorker" -Option Constant -Scope Script -Value (@{})


    $initialState = [InitialSessionState]::CreateDefault()
    $initialState.ApartmentState = 'MTA'

    $initialState.Commands.Add((New-Object SessionStateFunctionEntry -ArgumentList 'Replace-Token', (Get-Content Function:\Replace-Token)))
    $initialState.Commands.Add((New-Object SessionStateFunctionEntry -ArgumentList 'Get-LevelNumber', (Get-Content Function:\Get-LevelNumber)))

    [String[]] $sessionVariables = @(
        "ScriptRoot", "LevelNames", "Logging", "LogTargets", "LoggingEventQueue", "LoggingMessagerCount"
    )

    foreach( $sessionVariable in $sessionVariables){
        $initialState.Variables.Add([SessionStateVariableEntry]::new($sessionVariable,(Get-Variable -Name $sessionVariable -ErrorAction Stop).Value,'', [System.Management.Automation.ScopedItemOptions]::AllScope))
    }
    $initialState.Variables.Add((New-Object SessionStateVariableEntry -ArgumentList 'ParentHost', $Host, ''))

    $consumerRunspacePool = [RunspaceFactory]::CreateRunspacePool($initialState)
    $consumerRunspacePool.SetMinRunspaces(1)
    $consumerRunspacePool.SetMaxRunspaces([int] $env:NUMBER_OF_PROCESSORS + 1)
    $consumerRunspacePool.Open()


    #Spawn Logging Consumer
    $workerJob = [Powershell]::Create().AddScript((Get-Content Function:\Use-LogMessage))
    $workerJob.RunspacePool = $consumerRunspacePool

    $Script:LoggingWorker["Job"] = $workerJob
    $Script:LoggingWorker["Result"] = $workerJob.BeginInvoke()

    #region Handle Module Removal
    $ExecutionContext.SessionState.Module.OnRemove = {
        $Script:LoggingEventQueue.CompleteAdding()

        Write-Verbose -Message ("{0} :: Stopping running consumer instance." -f $MyInvocation.MyCommand)

        [int] $logCount = $Script:LoggingWorker["Job"].EndInvoke($Script:LoggingWorker["Result"])[0]
        Write-Verbose -Message ("{0} :: Stopping : {1}." -f $MyInvocation.MyCommand, $Script:LoggingWorker["Job"].InstanceId)
        $Script:LoggingWorker["Job"].Dispose()

        Write-Verbose -Message ("{0} :: Logged {1} times." -f $MyInvocation.MyCommand, $logCount)

        [System.GC]::Collect()
    }
    #endregion Handle Module Removal
}