function Use-LogMessage {
    [CmdletBinding()]
    [OutputType([int])]
    param(
    )
    [int] $logsWritten = 0

    foreach ($logMessage in $LoggingEventQueue.GetConsumingEnumerable()) {
        [String] $loggingFormat = $Logging.Format
        [int] $loggingSeverity = Get-LevelNumber -Level $Logging.Level

        [System.Threading.Monitor]::Enter($Logging.Targets)
        try {
            [boolean] $messageDiscarded = $true

            #Enumerating through a collection is intrinsically not a thread-safe procedure
            for ($targetEnum = $Logging.Targets.GetEnumerator(); $targetEnum.MoveNext(); ) {
                $logTarget = $targetEnum.Value

                [int] $targetSeverity = $loggingSeverity
                [String] $targetFormat = $loggingFormat

                if ($logTarget.Level) {
                    $targetSeverity = Get-LevelNumber -Level $logTarget.Level
                }

                if ($logTarget.Format) {
                    $targetFormat = $logTarget.Format
                }

                if ($logMessage.LevelNo -ge $targetSeverity) {
                    & $LogTargets[$targetEnum.Key].Logger $logMessage $targetFormat $logTarget $ParentHost
                    $logsWritten++

                    $messageDiscarded = $false
                }
            }

            if(!$messageDiscarded){
                [System.Threading.Interlocked]::Increment($LoggingMessagerCount)
            }
        }
        finally {
            [System.Threading.Monitor]::Exit($Logging.Targets)
        }
    }

    return $logsWritten
}