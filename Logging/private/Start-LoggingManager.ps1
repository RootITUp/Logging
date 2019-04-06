function Start-LoggingManager {
    [CmdletBinding()]
    param()

    if (Get-Variable -Name "LoggingEventQueue" -Scope Script -ErrorAction Ignore) {
        throw [System.InvalidOperationException]::new("LoggingManager is already started.")
    }

    Write-Verbose -Message ("{0} :: Starting first initialization of LoggingManager." -f $MyInvocation.MyCommand)

    [String] $moduleBase = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Module.Path)

    Set-Variable -Name "LoggingMessagerCount" -Option Constant -Scope Script -Value ([ref]0)
    Set-Variable -Name "LoggingEventQueue" -Option Constant -Scope Script -Value ([System.Collections.Concurrent.BlockingCollection[hashtable]]::new(100))
    Set-Variable -Name "LoggingWorker" -Option Constant -Scope Script -Value (@{ })


    $initialState = [InitialSessionState]::CreateDefault()
    $initialState.ApartmentState = 'MTA'

    [String[]] $sessionVariables = @(
        "ScriptRoot", "LevelNames", "Logging", "LogTargets", "LoggingEventQueue", "LoggingMessagerCount"
    )

    foreach ( $sessionVariable in $sessionVariables) {
        $initialState.Variables.Add([System.Management.Automation.Runspaces.SessionStateVariableEntry]::new($sessionVariable, (Get-Variable -Name $sessionVariable -ErrorAction Stop).Value, '', [System.Management.Automation.ScopedItemOptions]::AllScope))
    }
    $initialState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'ParentHost', $Host, ''))

    #Import module for usage
    $initialState.ImportPSModulesFromPath($moduleBase)

    $consumerRunspacePool = [RunspaceFactory]::CreateRunspacePool($initialState)
    $consumerRunspacePool.Open()

    #Spawn Logging Consumer
    $workerJob = [Powershell]::Create()
    
    $workerCommand = $workerJob.AddCommand("Use-LogMessage")
    $workerCommand = $workerCommand.AddParameter("ErrorAction", "Stop")

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