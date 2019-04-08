function Initialize-LoggingTarget {
    param()

    $targets = @()
    $targets += Get-ChildItem "$ScriptRoot\targets" -Filter '*.ps1'

    if ((![String]::IsNullOrWhiteSpace($Logging.CustomTargets)) -and (Test-Path -Path $Logging.CustomTargets -PathType Container)) {
        $targets += Get-ChildItem -Path $Logging.CustomTargets -Filter '*.ps1'
    }

    Write-Verbose -Message ("{0} :: {1} targets configured in sum." -f $MyInvocation.MyCommand,$targets.Length)

    foreach ($target in $targets) {
        $module = . $target.FullName
        $Script:LogTargets[$module.Name] = @{
            Init           = $module.Init
            Logger         = $module.Logger
            Description    = $module.Description
            Configuration  = $module.Configuration
            ParamsRequired = $module.Configuration.GetEnumerator() | Where-Object {$_.Value.Required -eq $true} | Select-Object -ExpandProperty Name
        }
    }
}
