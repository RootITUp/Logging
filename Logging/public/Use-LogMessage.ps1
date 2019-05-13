<#
    .SYNOPSIS
        Spawned by LoggingManager to consume log messages.
    .DESCRIPTION
        Do not call this method manually. This method will block until log messages
        are laid into the LoggingEventQueue and is then going to properly handle the logging.
    .EXAMPLE
        DO NOT RUN MANUALLY
    .LINK
        https://logging.readthedocs.io/en/latest/functions/Use-LogMessage.md
    .LINK
        https://github.com/EsOsO/Logging/blob/master/Logging/public/Use-LogMessage.ps1
#>

function Use-LogMessage {
    [CmdletBinding(HelpUri = 'https://logging.readthedocs.io/en/latest/functions/Use-LogMessage.md')]
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