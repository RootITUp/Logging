function Stop-LoggingManager {
    param ()

    $Script:LoggingEventQueue.CompleteAdding()
    $Script:LoggingEventQueue.Dispose()

    [void] $Script:LoggingRunspace.Powershell.EndInvoke($Script:LoggingRunspace.Handle)
    [void] $Script:LoggingRunspace.Powershell.Dispose()

    $ExecutionContext.SessionState.Module.OnRemove = $null
    if( $Script:LoggingRunspace.EngineEvent.id -ne $null){
        Unregister-Event -SubscriptionId $Script:LoggingRunspace.EngineEvent.id
    }

    Remove-Variable -Scope Script -Force -Name LoggingEventQueue
    Remove-Variable -Scope Script -Force -Name LoggingRunspace
}