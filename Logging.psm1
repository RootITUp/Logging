#requires -Version 4

$NOTSET = 0
$DEBUG = 10
$INFO = 20
$WARNING = 30
$ERROR_ = 40

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
New-Variable -Name ScriptRoot   -Value (Split-Path $MyInvocation.MyCommand.Path) -Option ReadOnly
New-Variable -Name MessageQueue -Value ([System.Collections.ArrayList]::Synchronized([System.Collections.ArrayList] @())) -Option ReadOnly

$Logging.Level      = $NOTSET
$Logging.Format     = '[%{timestamp:+%Y-%m-%d %T%Z}] [%{level:-7}] %{message}'
$Logging.Targets    = [hashtable] @{}

<#

#>
Function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Position = 1, 
                   Mandatory = $true)]
        [string] $Message,
        [Parameter(Position = 2,
                   Mandatory = $false)]
        [object] $Body
    )

    DynamicParam {
        $attributes = New-Object System.Management.Automation.ParameterAttribute
        $attributes.ParameterSetName = '__AllParameterSets'
        $attributes.Mandatory = $false
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute(Get-LevelsName)

        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)
        $attributeCollection.Add($ValidateSetAttribute)

        $dynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('Level', [string], $attributeCollection)
        
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add('Level', $dynParam1)
        return $paramDictionary
    }
    
    End {
        $LevelNo = Get-LevelNumber -Level $PSBoundParameters.Level
        
        $mess = [hashtable] @{
                timestamp = Get-Date -UFormat '%Y-%m-%d %T%Z'
                levelno = $LevelNo
                level = Get-LevelName -Level $LevelNo
                message = $Message
        }
        
        if ($Body) { $mess['body'] = $Body | ConvertTo-Json -Compress }
        
        [void] $MessageQueue.Add($mess)
    }    
}


Function Get-LevelsName {
    [CmdletBinding()]
    param()
    
    return $LevelNames.Keys | ?{$_ -isnot [int]} | sort
}


Function Get-LevelNumber {
    [CmdletBinding()]
    param(
        $Level
    )

    if ($Level -is [int]) {return $Level}
    elseif ([string] $Level -eq $Level) {return $LevelNames[$Level]}
    else {throw ('Level not a valid integer or a valid string: {0}' -f $Level)}    
}


Function Get-LevelName {
    [CmdletBinding()]
    param(
        $Level
    )
    
    $l = $LevelNames[$Level]
    if ($l) {return $l}
    else {return ('Level {0}' -f $Level)}
}


Function Replace-Tokens {
    [CmdletBinding()]
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


Function Add-LoggingLevel {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int] $Level,
        [Parameter(Mandatory)]
        [string] $LevelName
    )
    
    $LevelNames[$Level] = $LevelName.ToUpper()
    $LevelNames[$LevelName] = $Level
}

Function Set-LoggingDefaultLevel {
    [CmdletBinding()]
    param()
    
    DynamicParam {
        $attributes = New-Object System.Management.Automation.ParameterAttribute
        $attributes.ParameterSetName = '__AllParameterSets'
        $attributes.Mandatory = $false
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute(Get-LevelsName)

        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)
        $attributeCollection.Add($ValidateSetAttribute)

        $dynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('Level', [string], $attributeCollection)
        $dynParam1.Value = 'VERBOSE'
        
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add('Level', $dynParam1)
        return $paramDictionary
    }
    
    End {
        $Logging.Level = Get-LevelNumber -Level $PSBoundParameters.Level
    }
}


Function Get-LoggingDefaultLevel {
    [CmdletBinding()]
    param()
    
    return Get-LevelName -Level $Logging.Level
}


Function Get-LoggingDefaultFormat {
    [CmdletBinding()]
    param()
    
    return $Logging.Format
}


Function Set-LoggingDefaultFormat {
    [CmdletBinding()]
    param(
        [string] $Format
    )
    
    $Logging.Format = $Format
}


Function Get-LoggingTargetAvailable {
    [CmdletBinding()]
    param()
    
    return $LogTargets
}


Function Get-LoggingTarget {
    [CmdletBinding()]
    param()

    return $Logging.Targets
}

Function Initialize-LoggingTargets {
    [CmdletBinding()]
    param()
    
    $Targets = Get-ChildItem "$ScriptRoot\targets" -Filter '*.ps1'
    if ($Logging.CustomTargets) {
        if (Test-Path $Logging.CustomTargets) {
            $Targets += Get-ChildItem $Logging.CustomTargets -Filter '*.ps1'
        }
    }

    foreach ($Target in $Targets) {
        $Module = . $Target.FullName
        $LogTargets[$Module.Name] = @{
            Logger = $Module.Logger
            Configuration = $Module.Configuration
            ParamsRequired = $Module.Configuration.GetEnumerator() | ?{$_.Value.Required -eq $true} | select -exp Name
        } 
    }    
}


Function Set-LoggingCustomTargets {
    [CmdletBinding()]
    param(
        [ValidateScript({Test-Path -Path $_})]
        [string] $Path
    )
    
    $Logging.CustomTargets = $Path
}


Function Assert-LoggingTargetConfiguration {
    [CmdletBinding()]
    param(
        $Target,
        $Configuration
    )
    
    $TargetName = $Target
    $TargetConf = $LogTargets[$Target]
    
    foreach ($Param in $TargetConf.ParamsRequired) {
        if ($Param -notin $Configuration.Keys) {
            throw ('Configuration {0} is required for target {2}; please provide one of type {1}' -f $Param, $TargetConf.Configuration[$Param].Type, $TargetName)
        }
    }
    
    foreach ($Conf in $Configuration.Keys) {
        if ($TargetConf.Configuration[$Conf] -and $Configuration[$Conf] -isnot $TargetConf.Configuration[$Conf].Type) {
            throw ('Configuration {0} has to be of type {1} for target {2}' -f $Conf, $TargetConf.Configuration[$Conf].Type, $TargetName)
        }
    }
}


Function Add-LoggingTarget {
    [CmdletBinding()]
    param(
        [hashtable] $Configuration = @{}
    )
    
    DynamicParam {
        $attributes = New-Object System.Management.Automation.ParameterAttribute
        $attributes.ParameterSetName = '__AllParameterSets'
        $attributes.Mandatory = $false
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($LogTargets.Keys)

        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)
        $attributeCollection.Add($ValidateSetAttribute)

        $dynParam1 = New-Object System.Management.Automation.RuntimeDefinedParameter('Name', [string], $attributeCollection)
            
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add('Name', $dynParam1)
        return $paramDictionary
    }
    
    End {
        Assert-LoggingTargetConfiguration -Target $PSBoundParameters.Name -Configuration $Configuration
        $Logging.Targets[$PSBoundParameters.Name] = $Configuration
        
    }
}


$InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$InitialSessionState.Commands.Add((New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'Replace-Tokens', (Get-Content Function:\Replace-Tokens)))
$InitialSessionState.Commands.Add((New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'Initialize-LoggingTargets', (Get-Content Function:\Initialize-LoggingTargets)))
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
    
    Initialize-LoggingTargets

    $i = 0
    while ($Dispatcher.Flag -or $MessageQueue.Count -gt 0) {
        if ($CustomTargets -ne $Logging.CustomTargets) {
            $CustomTargets = $Logging.CustomTargets
            Initialize-LoggingTargets
        }
        
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
        $i++
        Start-Sleep -Milliseconds 10
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
$ExecutionContext.SessionState.Module.OnRemove = {
    $Dispatcher.Flag = $false
    #Let sit for a second to make sure it has had time to stop
    Start-Sleep -Seconds 1
    if ($Dispatcher.Handle) {
        $Dispatcher.PowerShell.EndInvoke($Dispatcher.Handle)
        $Dispatcher.PowerShell.Dispose()    
    }
    [System.GC]::Collect()
}
#endregion Handle Module Removal

# Aliases and exports
Function debug      { param([Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)] [Object] $Message) Write-Log -Level DEBUG -Message $Message }
Function info       { param([Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)] [Object] $Message) Write-Log -Level INFO -Message $Message }
Function warning    { param([Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)] [Object] $Message) Write-Log -Level WARNING -Message $Message }
Function error      { param([Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true)] [Object] $Message) Write-Log -Level ERROR -Message $Message }

Export-ModuleMember -Function Add-LoggingLevel
Export-ModuleMember -Function Set-LoggingDefaultLevel
Export-ModuleMember -Function Get-LoggingDefaultLevel
Export-ModuleMember -Function Set-LoggingDefaultFormat
Export-ModuleMember -Function Get-LoggingDefaultFormat
Export-ModuleMember -Function Set-LoggingCustomTargets
Export-ModuleMember -Function Get-LoggingTargetAvailable
Export-ModuleMember -Function Get-LoggingTarget
Export-ModuleMember -Function Add-LoggingTarget
Export-ModuleMember -Function Write-Log
Export-ModuleMember -Function debug
Export-ModuleMember -Function info
Export-ModuleMember -Function warning
Export-ModuleMember -Function error