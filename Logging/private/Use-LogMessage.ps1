function Use-LogMessage {
    [CmdletBinding()]
    param()

    $CustomTargets = $Logging.CustomTargets

    Initialize-LoggingTarget

    foreach ($logMessage in $LoggingEventQueue.GetConsumingEnumerable()) {
        if ($CustomTargets -ne $Logging.CustomTargets) {
            $CustomTargets = $Logging.CustomTargets
            Initialize-LoggingTarget
        }

        if ($Logging.Targets.Count) {
            $Targets = $Logging.Targets
        }
        else {
            $Targets = $null
        }

        foreach ($targetName in $Targets.Keys) {
            $LoggerFormat = $Logging.Format
            $LoggerLevel = Get-LevelNumber -Level $Logging.Level

            $Target = $Targets[$targetName]

            if ($Target) {
                if ($Target.Level) {
                    $LoggerLevel = Get-LevelNumber -Level $Target.Level
                }
                if ($Target.Format) {
                    $LoggerFormat = $Target.Format
                }
                $Configuration = $Target
            }

            if ($logMessage.LevelNo -ge $LoggerLevel) {
                & $LogTargets[$targetName].Logger $logMessage $LoggerFormat $Configuration
            }
        }
    }
}