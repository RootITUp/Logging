function Use-LogMessage {
    [OutputType([int])]
    param(
    )

    [int] $logsWritten = 0

    foreach ($logMessage in $LoggingEventQueue.GetConsumingEnumerable()) {
        [string] $loggingFormat = $Logging.Format
        [int] $loggingSeverity = $Logging.LevelNo

        [System.Threading.Monitor]::Enter($Logging.Targets)
        try {
            [boolean] $messageDiscarded = $true

            # Enumerating through a collection is intrinsically not a thread-safe procedure
            for ($targetEnum = $Logging.Targets.GetEnumerator(); $targetEnum.MoveNext();) {
                $logTarget = $targetEnum.Value

                if ($logMessage.LevelNo -ge $logTarget.LevelNo) {
                    Invoke-Command -ScriptBlock $LogTargets[$targetEnum.Key].Logger -ArgumentList @($logMessage, $logTarget)
                    $messageDiscarded = $false
                    $logsWritten++
                }
            }

            if (!$messageDiscarded) {
                [System.Threading.Interlocked]::Increment($LoggingMessagerCount)
            }
        }
        catch {
            $lastColor = [Console]::ForegroundColor.value__
            [Console]::ForegroundColor = [ConsoleColor]::Red
            [Console]::WriteLine($_)
            [Console]::ForegroundColor = $lastColor
        }
        finally {
            [System.Threading.Monitor]::Exit($Logging.Targets)
        }
    }

    return $logsWritten
}