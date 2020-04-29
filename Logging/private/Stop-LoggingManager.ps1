function Stop-LoggingManager {
    param ()

    $Script:LoggingEventQueue.CompleteAdding()
    $Script:LoggingEventQueue.Dispose()

    [void] $Script:LoggingRunspace.Powershell.EndInvoke($Script:LoggingRunspace.Handle)
    [void] $Script:LoggingRunspace.Powershell.Dispose()

    $ExecutionContext.SessionState.Module.OnRemove = $null
    #Only remove the event, if it exists
    if( Get-EventSubscriber -Force | Where-Object{$_.SubscriptionId -eq $Script:LoggingRunspace.EngineEvent.id}){
        Unregister-Event -SubscriptionId $Script:LoggingRunspace.EngineEvent.id
    }

    Remove-Variable -Scope Script -Force -Name LoggingEventQueue
    Remove-Variable -Scope Script -Force -Name LoggingRunspace
}