function Assert-LoggingTargetConfiguration {
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
