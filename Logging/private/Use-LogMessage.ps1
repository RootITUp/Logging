function Use-LogMessage {
    [CmdletBinding()]
    [OutputType([int])]
    param()

    [int] $logsWritten = 0

    foreach ($logMessage in $LoggingEventQueue.GetConsumingEnumerable()) {
        [string] $loggingFormat = $Logging.Format
        [int] $loggingSeverity = $Logging.LevelNo

        try {
            [boolean] $messageDiscarded = $true

            #Enumerating through a collection is intrinsically not a thread-safe procedure
            for ($targetEnum = $Logging.Targets.GetEnumerator(); $targetEnum.MoveNext(); ) {
                [hashtable] $targetConfiguration = $targetEnum.Current.Value
                [String] $loggingTarget = $targetEnum.Current.Key

                if ($logMessage.LevelNo -ge $targetConfiguration.LevelNo) {
                    Invoke-Command -ScriptBlock $LogTargets[$loggingTarget].Logger -ArgumentList @($logMessage, $targetConfiguration)
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
    }

    return $logsWritten
}