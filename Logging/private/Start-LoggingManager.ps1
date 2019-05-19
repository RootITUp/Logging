function Start-LoggingManager {
    [CmdletBinding()]
    param()

    Set-Variable -Name 'LoggingMessagerCount' -Option Constant -Scope Script -Value ([ref]0)
    Set-Variable -Name 'LoggingEventQueue' -Option Constant -Scope Script -Value ([System.Collections.Concurrent.BlockingCollection[hashtable]]::new(100))
    Set-Variable -Name 'LoggingWorker' -Option Constant -Scope Script -Value (@{})

    $ISS = [InitialSessionState]::CreateDefault()
    if (Get-Member -InputObject $initialState -Name "ApartmentState" -MemberType Property) {
        $ISS.ApartmentState = [System.Threading.ApartmentState]::MTA
    }

    foreach ( $sessionVariable in 'ScriptRoot', 'LevelNames', 'Logging', 'LogTargets', 'LoggingEventQueue', 'LoggingMessagerCount') {
        $ISS.Variables.Add([System.Management.Automation.Runspaces.SessionStateVariableEntry]::new($sessionVariable, (Get-Variable -Name $sessionVariable -ErrorAction Stop).Value, '', [System.Management.Automation.ScopedItemOptions]::AllScope))
    }

    $ISS.Commands.Add((New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'Replace-Token', (Get-Content Function:\Replace-Token)))
    $ISS.Commands.Add((New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'Use-LogMessage', (Get-Content Function:\Use-LogMessage)))

    #Setup runspace
    Set-Variable -Name "ConsumerRunspace" -Value ([runspacefactory]::CreateRunspace($initialState)) -Scope Script -Option Constant
    $Script:ConsumerRunspace.Name = "Logging_ConsumerRunspace"
    $Script:ConsumerRunspace = [RunspaceFactory]::CreateRunspacePool($ISS)
    $Script:ConsumerRunspace.Open()

    # Spawn Logging Consumer
    $workerJob = [Powershell]::Create()
    $workerJob.Runspace = $Script:ConsumerRunspace

    $workerCommand = $workerJob.AddCommand('Use-LogMessage')
    $workerCommand = $workerCommand.AddParameter('ErrorAction', 'Stop')

    $Script:LoggingWorker['Job'] = $workerJob
    $Script:LoggingWorker['Result'] = $workerJob.BeginInvoke()

    #region Handle Module Removal
    $ExecutionContext.SessionState.Module.OnRemove = {
        $LoggingEventQueue.CompleteAdding()

        Write-Verbose -Message ('{0} :: Stopping running consumer instance.' -f $MyInvocation.MyCommand)

        [int] $logCount = $Script:LoggingWorker["Job"].EndInvoke($Script:LoggingWorker["Result"])[0]
        Write-Verbose -Message ("{0} :: Stopping : {1}." -f $MyInvocation.MyCommand, $Script:LoggingWorker["Job"].InstanceId)
        $Script:LoggingWorker["Job"].Dispose()

        #Dispose Runspace
        $Script:ConsumerRunspace.Dispose()

        Write-Verbose -Message ('{0} :: Logged {1} times.' -f $MyInvocation.MyCommand, $logCount)

        [System.GC]::Collect()
    }
    #endregion Handle Module Removal
}