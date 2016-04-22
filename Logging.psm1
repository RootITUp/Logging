#requires -Version 4

Function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Position=1, 
                   Mandatory=$true, 
                   ValueFromPipeline=$true)]
        [Object] $Message,        
        [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR')]
        [string] $Level = 'WARNING'
    )
    
    PROCESS {
        foreach ($msg in $Message) {
            if ($msg -isnot [hashtable]) {
                $msg = @{
                    title = $msg
                    body = [hashtable] @{}
                }
            }

            $LevelNo = Get-LevelNumber -Level $Level
        
            [void] $MessageQueue.Add(
                [hashtable] @{
                    timestamp = Get-Date -UFormat '%Y-%m-%d %T%Z'
                    levelno = $LevelNo
                    level = Get-LevelName -Level $LevelNo
                    msg = $msg
                }
            )
        }
    }    
}

Function Get-LevelNumber {
    param(
        $Level
    )
    if ($Level -is [int]) {return $Level}
    elseif ([string] $Level -eq $Level) {return $LevelNames[$Level]}
    else {throw ('Level not a valid integer or a valid string: {0}' -f $Level)}    
}

Function Get-LevelName {
    param(
        $Level
    )
    
    $l = $LevelNames[$Level]
    if ($l) {return $l}
    else {return ('Level {0}' -f $Level)}
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

Function Set-LoggingDefaultLevel {
    param(
        [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR')]
        [string] $Level = 'WARNING'
    )
    
    $Logging.Level = Get-LevelNumber -Level $Level
}

Function Get-LoggingDefaultLevel {
    return $Logging.Level
}

$NOTSET = 0
$DEBUG = 10
$INFO = 20
$WARNING = 30
$ERROR_ = 40

$LevelNames = [hashtable]::Synchronized(@{
    $NOTSET = 'NOTSET'
    $ERROR_ = 'ERROR'
    $WARNING = 'WARNING'
    $INFO = 'INFO'
    $DEBUG = 'DEBUG'
    'NOTSET' = $NOTSET
    'ERROR' = $ERROR_
    'WARN' = $WARNING
    'WARNING' = $WARNING
    'INFO' = $INFO
    'DEBUG' = $DEBUG
})

New-Variable -Name ScriptRoot -Value (Split-Path $MyInvocation.MyCommand.Path) -Option AllScope, ReadOnly -Scope Global
New-Variable -Name Dispatcher -Value ([hashtable]::Synchronized(@{})) -Option AllScope, ReadOnly -Scope Global
New-Variable -Name LevelNames -Option AllScope, ReadOnly -Scope Global
New-Variable -Name LogTargets -Value ([hashtable]::Synchronized(@{})) -Option AllScope, ReadOnly -Scope Global
New-Variable -Name Logging -Value ([hashtable]::Synchronized(@{})) -Option AllScope, ReadOnly -Scope Global
New-Variable -Name MessageQueue -Value ([System.Collections.ArrayList]::Synchronized([System.Collections.ArrayList] @())) -Option AllScope, ReadOnly -Scope Global

$Logging.Level = $NOTSET
$Logging.Format = '[%{timestamp:+%Y-%m-%d %T%Z}] [%{level:-7}] %{message}'
$Logging.Targets = [hashtable] @{}

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
                if ($Logging.Targets.Count -and -not $Logging.Destinations) {$Targets = $Logging.Targets}
                elseif (-not $Logging.Targets.Count -and $Logging.Destinations) {$Targets = $Logging.Destinations}
                else {$Targets = $null}
                foreach ($TargetName in $Targets.Keys) {
                    $LoggerFormat = $Logging.Format
                    $LoggerLevel = Get-LevelNumber -Level $Logging.Level

                    $Target = $Targets[$TargetName]
                    
                    if ($Target) {
                        if ($Target.Level) {$LoggerLevel = $Target.Level}
                        if ($Target.Format) {$LoggerFormat = $Target.Format}
                        $Configuration = $Target
                    }
                                        
                    if ($Message.Level -ge $LoggerLevel) {
                        & $LogTargets[$TargetName] $Message $LoggerFormat $Configuration
                    }
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

# Aliases and exports
Function debug      { param([Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)] [Object] $Message) Write-Log -Level DEBUG -Message $Message }
Function info       { param([Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)] [Object] $Message) Write-Log -Level INFO -Message $Message }
Function warning    { param([Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)] [Object] $Message) Write-Log -Level WARNING -Message $Message }
Function error      { param([Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)] [Object] $Message) Write-Log -Level ERROR -Message $Message }

Export-ModuleMember -Function Set-LoggingDefaultLevel
Export-ModuleMember -Function Get-LoggingDefaultLevel
Export-ModuleMember -Function Write-Log
Export-ModuleMember -Function debug
Export-ModuleMember -Function info
Export-ModuleMember -Function warning
Export-ModuleMember -Function error