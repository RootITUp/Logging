function Initialize-LoggingTarget {
    param()

    [System.Threading.Monitor]::Enter($LoggingRunspace.syncRoot)
    $ParentHost.NotifyBeginApplication()
    Write-Verbose 'Initializing targets'

    $targets = @()
    $targets += Get-ChildItem "$ScriptRoot\targets" -Filter '*.ps1'

    if ((![String]::IsNullOrWhiteSpace($Script:Logging.CustomTargets)) -and (Test-Path -Path $Script:Logging.CustomTargets -PathType Container)) {
        $targets += Get-ChildItem -Path $Script:Logging.CustomTargets -Filter '*.ps1'
    }

    Write-Verbose ('{0} targets found' -f $targets.Length)

    foreach ($target in $targets) {
        Write-Verbose ('Init target: {0}' -f $target.FullName)
        $module = . $target.FullName
        $Script:Logging.Targets[$module.Name] = @{
            Init           = $module.Init
            Logger         = $module.Logger
            Description    = $module.Description
            Defaults       = $module.Configuration
            ParamsRequired = $module.Configuration.GetEnumerator() | Where-Object {$_.Value.Required -eq $true} | Select-Object -ExpandProperty Name
        }
    }

    $ParentHost.NotifyEndApplication()
    [System.Threading.Monitor]::Enter($LoggingRunspace.syncRoot)
}
