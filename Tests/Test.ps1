Remove-Module Logging -Force
Import-Module ..\Logging\Logging.psm1

Add-LoggingTarget -Name Console -Configuration @{Level = 'DEBUG'; Format = '[%{timestamputc}] %{filename} [lineno: %{lineno}] %{message}'}

1..10 | Foreach-Object {
    Write-Log -Level (Get-Random 'DEBUG', 'INFO', 'WARNING', 'ERROR') -Message 'Hello, World!'
}

Add-LoggingTarget -Name Console -Configuration @{Level = 'DEBUG'; Format = '[%{timestamputc}] %{filename} [%{caller}] %{message}'}

function Invoke-CallerFunction {
    [CmdletBinding()]
    param()

    1..5 | ForEach-Object {
        Write-Log -Level (Get-Random 'DEBUG', 'INFO', 'WARNING', 'ERROR') -Message 'Hello, World! (With caller scope)'
    }
}

Invoke-CallerFunction

function Write-CustomLog {
    [CmdletBinding()]
    param(
        $Level,
        $Message
    )

    Write-Log -Level $Level -Message $Message
}

function Invoke-CallerFunctionWithCustomLog {

    1..5 | ForEach-Object {
        Write-CustomLog -Level (Get-Random 'DEBUG', 'INFO', 'WARNING', 'ERROR') -Message 'Hello, World! (With caller scope at level 2)'
    }
}

Invoke-CallerFunctionWithCustomLog
