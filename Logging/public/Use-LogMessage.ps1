<#
.SYNOPSIS
Spawned by LoggingManager to consume log messages.

.DESCRIPTION
Do not call this method manually. This method will block until log messages
are laid into the LoggingEventQueue and is then going to properly handle the logging.
#>

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
                    Invoke-Command -ScriptBlock $LogTargets[$targetEnum.Key].Logger -ArgumentList @($logMessage, $targetFormat, $logTarget, $ParentHost)
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