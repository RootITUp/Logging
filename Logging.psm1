Function Write-Log {
    param(
        [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR')]
        [string] $Level = 'WARNING',
        [object] $Message
    )
    
    if ($Message -isnot [hashtable]) {
        $Message = @{
            title = $Message
            body = @{}
        }
    }

    [void] $MessageQueue.Add(
        [hashtable] @{
            timestamp = Get-Date -UFormat '%Y-%m-%d %T%Z'
            level = $Level
            msg = $Message
        }
    )
}

Function Replace-Tokens {
    param(
        [string] $String,
        [object] $Source
    )
    $re = [regex] '%{(?<token>\w+?)?(?::?\+(?<datefmt>(?:%[YmdHMS].*?)+))?(?::(?<padding>-?\d+))?}'
    $re.Replace($String, {
        param($match)
        $token = $match.Groups['token'].value
        $datefmt = $match.Groups['datefmt'].value
        $padding = $match.Groups['padding'].value
        
        if ($token -and -not $datefmt) {
            $var = $Source.$token
        } elseif ($token -and $datefmt) {
            $var = Get-Date $Source.$token -UFormat $datefmt
        } elseif ($datefmt -and -not $token) {
            $var = Get-Date -UFormat $datefmt
        }
        
        if ($padding) {
            $tpl = "{0,$padding}"
        } else {
            $tpl = '{0}'
        }
        
        return ($tpl -f $var)        
    })    
}

New-Variable -Name ScriptRoot -Value (Split-Path $MyInvocation.MyCommand.Path) -Option AllScope, ReadOnly -Scope Global
New-Variable -Name Dispatcher -Value ([hashtable]::Synchronized(@{})) -Option AllScope, ReadOnly -Scope Global
New-Variable -Name LevelNames -Option AllScope, ReadOnly -Scope Global
New-Variable -Name LogTargets -Value ([hashtable]::Synchronized(@{})) -Option AllScope, ReadOnly -Scope Global
New-Variable -Name Logging -Value ([hashtable]::Synchronized(@{})) -Option AllScope, ReadOnly -Scope Global
New-Variable -Name MessageQueue -Value ([System.Collections.ArrayList]::Synchronized([System.Collections.ArrayList] @())) -Option AllScope, ReadOnly -Scope Global

$DEBUG = 10
$INFO = 20
$WARNING = 30
$ERROR_ = 40

$LevelNames = [hashtable]::Synchronized(@{
    $ERROR_ = 'ERROR'
    $WARNING = 'WARNING'
    $INFO = 'INFO'
    $DEBUG = 'DEBUG'
    'ERROR' = $ERROR_
    'WARN' = $WARNING
    'WARNING' = $WARNING
    'INFO' = $INFO
    'DEBUG' = $DEBUG
})

$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$SessionStateFunction = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'Replace-Tokens', (Get-Content Function:\Replace-Tokens)
$InitialSessionState.Commands.Add($SessionStateFunction)

$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'ScriptRoot', $ScriptRoot, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'Dispatcher', $Dispatcher, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'LevelNames', $LevelNames, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'LogTargets', $LogTargets, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'Logging', $Logging, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'MessageQueue', $MessageQueue, ''))
$InitialSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList 'ParentHost', $Host, ''))

$ScriptBlock = {
    foreach ($Target in (Get-ChildItem "$ScriptRoot\targets" -Filter *.ps1)) {
        $Module = . $Target.FullName
        $LogTargets[$Module.Name] = $Module.Logger
    }
    
    if ($Logging.CustomTargets) {
        if (Test-Path $Logging.CustomTargets) {
            foreach ($Target in (Get-ChildItem $Logging.CustomTargets -Filter *.ps1)) {
                $Module = . $Target.FullName
                $LogTargets[$Module.Name] = $Module.Logger
            }
        }
    }
    
    $i = 0
    while ($Dispatcher.Flag) {
        if ($i -gt 1000) {$i = 0; [System.GC]::Collect()}
        if ($MessageQueue.Count -gt 0) {
            foreach ($Message in $MessageQueue) {
                if ($Logging.Targets) {$Targets = $Logging.Targets}
                elseif ($Logging.Destinations) {$Targets = $Logging.Destinations}
                else {$Targets = $null}
                foreach ($TargetName in $Targets.Keys) {
                    $Target = $Targets[$TargetName]
                    $LoggerLevel = if ($Target.Level) {$Target.Level} else {$Logging.Level}
                    $Format = if ($Target.Format) {$Target.Format} else {$Logging.Format}
                    if ($LevelNames[$Message.Level] -ge $LevelNames[$LoggerLevel]) {
                        & $LogTargets[$TargetName] $Message $Format $Target
                    }
                    # $LogTargets | ConvertTo-Json | Out-String | Out-File -FilePath D:\Tools\log\test.log -Append
                }
                $MessageQueue.Remove($Message)
            }
        }
        $i++
        Start-Sleep -Milliseconds 50
    }
}

$Dispatcher.Flag = $true
$Dispatcher.Host = $Host
$Dispatcher.RunspacePool = [runspacefactory]::CreateRunspacePool($InitialSessionState)
$Dispatcher.RunspacePool.Open()
$Dispatcher.Powershell = [powershell]::Create().AddScript($ScriptBlock)
$Dispatcher.Powershell.RunspacePool = $Dispatcher.RunspacePool
$Dispatcher.Handle = $Dispatcher.Powershell.BeginInvoke()

#region Handle Module Removal
$ExecutionContext.SessionState.Module.OnRemove ={
    $Dispatcher.Flag = $False
    #Let sit for a second to make sure it has had time to stop
    Start-Sleep -Seconds 1
    if ($Dispatcher.Handle) {
        $Dispatcher.PowerShell.EndInvoke($Dispatcher.Handle)
        $Dispatcher.PowerShell.Dispose()    
    }
    Remove-Variable -Name Dispatcher -Scope Global -Force
    Remove-Variable -Name MessageQueue -Scope Global -Force
    Remove-Variable -Name Logging -Scope Global -Force
    Remove-Variable -Name LogTargets -Scope Global -Force
    Remove-Variable -Name LevelNames -Scope Global -Force
    Remove-Variable -Name ScriptRoot -Scope Global -Force
    [System.GC]::Collect()
}
#endregion Handle Module Removal

Export-ModuleMember -Function Write-Log