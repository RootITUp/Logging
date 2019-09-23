function Start-LoggingManager {
    [CmdletBinding()]
    param()

    New-Variable -Name LoggingEventQueue    -Scope Script -Value ([System.Collections.Concurrent.BlockingCollection[hashtable]]::new(100))
    New-Variable -Name LoggingRunspace      -Scope Script -Option ReadOnly -Value ([hashtable]::Synchronized(@{ }))

    $InitialSessionState = [initialsessionstate]::CreateDefault()

    if ($InitialSessionState.psobject.Properties['ApartmentState']) {
        $InitialSessionState.ApartmentState = [System.Threading.ApartmentState]::MTA
    }

    # Importing variables into runspace
    foreach ($sessionVariable in 'ScriptRoot', 'LevelNames', 'Logging', 'LoggingEventQueue') {
        $Value = Get-Variable -Name $sessionVariable -ErrorAction Continue -ValueOnly
        Write-Verbose "Importing variable $sessionVariable`: $Value into runspace"
        $v = New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $sessionVariable, $Value, '', ([System.Management.Automation.ScopedItemOptions]::AllScope)
        $InitialSessionState.Variables.Add($v)
    }

    # Importing functions into runspace
    foreach ($Function in 'Replace-Token', 'Initialize-LoggingTarget', 'Get-LevelNumber') {
        Write-Verbose "Importing function $($Function) into runspace"
        $Body = Get-Content Function:\$Function
        $f = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList $Function, $Body
        $InitialSessionState.Commands.Add($f)
    }

    #Setup runspace
    $LoggingRunspace.Runspace = [runspacefactory]::CreateRunspace($InitialSessionState)
    $LoggingRunspace.Runspace.Name = 'LoggingQueueConsumer'
    $LoggingRunspace.Runspace.Open()
    $LoggingRunspace.Runspace.SessionStateProxy.SetVariable('ParentHost', $Host)
    $LoggingRunspace.Runspace.SessionStateProxy.SetVariable('VerbosePreference', $VerbosePreference)

    # Spawn Logging Consumer
    $Consumer = {
        Initialize-LoggingTarget

        foreach ($Log in $LoggingEventQueue.GetConsumingEnumerable()) {
            if ($Logging.EnabledTargets) {
                $ParentHost.NotifyBeginApplication()

                try {
                    #Enumerating through a collection is intrinsically not a thread-safe procedure
                    for ($targetEnum = $Logging.EnabledTargets.GetEnumerator(); $targetEnum.MoveNext(); ) {
                        [string] $LoggingTarget = $targetEnum.Current.key
                        [hashtable] $TargetConfiguration = $targetEnum.Current.Value
                        $Logger = [scriptblock] $Script:Logging.Targets[$LoggingTarget].Logger

                        $targetLevelNo = Get-LevelNumber -Level $TargetConfiguration.Level

                        if ($Log.LevelNo -ge $targetLevelNo) {
                            Invoke-Command -ScriptBlock $Logger -ArgumentList @($Log, $TargetConfiguration)
                        }
                    }
                } catch {
                    $ParentHost.UI.WriteErrorLine($_)
                } finally {
                    $ParentHost.NotifyEndApplication()
                }
            }
        }
    }

    $LoggingRunspace.Powershell = [Powershell]::Create().AddScript($Consumer, $true)
    $LoggingRunspace.Powershell.Runspace = $LoggingRunspace.Runspace
    $LoggingRunspace.Handle = $LoggingRunspace.Powershell.BeginInvoke()

    #region Handle Module Removal
    $OnRemoval = {
        $Script:LoggingEventQueue.CompleteAdding()
        $Script:LoggingEventQueue.Dispose()

        [void] $LoggingRunspace.Powershell.EndInvoke($LoggingRunspace.Handle)
        [void] $LoggingRunspace.Powershell.Dispose()

        Remove-Variable Logging -Scope Script -Force
        Remove-Variable Defaults -Scope Script -Force
        Remove-Variable LevelNames -Scope Script -Force
        Remove-Variable LoggingRunspace -Scope Script -Force
        Remove-Variable LoggingEventQueue -Scope Script -Force

        [System.GC]::Collect()
    }

    $ExecutionContext.SessionState.Module.OnRemove += $OnRemoval
    Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action $OnRemoval
    #endregion Handle Module Removal
}