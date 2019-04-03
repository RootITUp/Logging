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


    Set-Variable -Name "LoggingEventQueue" -Option Constant -Scope Script -Value ([BlockingCollection[hashtable]]::new(100))
    Set-Variable -Name "LoggingWorkerJobs" -Option Constant -Value ([List[hashtable]]::new())


    $initialState = [InitialSessionState]::CreateDefault()
    $initialState.ApartmentState = 'MTA'

    $initialState.Commands.Add((New-Object SessionStateFunctionEntry -ArgumentList 'Replace-Token', (Get-Content Function:\Replace-Token)))
    $initialState.Commands.Add((New-Object SessionStateFunctionEntry -ArgumentList 'Initialize-LoggingTarget', (Get-Content Function:\Initialize-LoggingTarget)))
    $initialState.Commands.Add((New-Object SessionStateFunctionEntry -ArgumentList 'Get-LevelNumber', (Get-Content Function:\Get-LevelNumber)))

    $initialState.Variables.Add((New-Object SessionStateVariableEntry -ArgumentList 'ScriptRoot', $ScriptRoot, ''))
    $initialState.Variables.Add((New-Object SessionStateVariableEntry -ArgumentList 'LevelNames', $LevelNames, ''))
    $initialState.Variables.Add((New-Object SessionStateVariableEntry -ArgumentList 'LogTargets', $LogTargets, ''))
    $initialState.Variables.Add((New-Object SessionStateVariableEntry -ArgumentList 'Logging', $Logging, ''))
    $initialState.Variables.Add((New-Object SessionStateVariableEntry -ArgumentList 'LoggingEventQueue', $LoggingEventQueue, ''))
    $initialState.Variables.Add((New-Object SessionStateVariableEntry -ArgumentList 'ParentHost', $Host, ''))

    $consumerRunspacePool = [RunspaceFactory]::CreateRunspacePool($initialState)
    $consumerRunspacePool.SetMinRunspaces(1)
    $consumerRunspacePool.SetMaxRunspaces([int] $env:NUMBER_OF_PROCESSORS + 1)

    $consumerRunspacePool.Open()


    #SPAWN UP TO THREE CONSUMERS
    for ([int] $workerCount = 2; $workerCount -gt 0; $workerCount--){
        $workerJob = [Powershell]::Create().AddScript((Get-Content Function:\Use-LogMessage))
        $workerJob.RunspacePool = $consumerRunspacePool


        $LoggingWorkerJobs.Add(@{
            Job = $workerJob
            Result = $workerJob.BeginInvoke()
        })
    }


    #region Handle Module Removal
    $ExecutionContext.SessionState.Module.OnRemove = {
        $Script:LoggingEventQueue.CompleteAdding()

        Write-Verbose -Message ("{0} :: Stopping running consumer instances." -f $MyInvocation.MyCommand)

        foreach ( $worker in $LoggingWorkerJobs ) {
            Write-Verbose -Message ("{0} :: Stopping : {1}" -f $MyInvocation.MyCommand,$worker.Job.InstanceId)
            $worker.Job.EndInvoke($worker.Result) | Out-Null

            $worker.Job.Dispose()
        }

        [System.GC]::Collect()
    }
    #endregion Handle Module Removal
}