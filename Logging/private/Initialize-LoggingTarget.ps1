function Initialize-LoggingTarget {
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
            Description = $Module.Description
            Configuration = $Module.Configuration
            ParamsRequired = $Module.Configuration.GetEnumerator() | Where-Object {$_.Value.Required -eq $true} | Select-Object -ExpandProperty Name
        }
    }
}
