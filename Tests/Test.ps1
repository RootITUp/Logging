Remove-Module Logging -Force
Import-Module .\Logging\Logging.psm1

Add-LoggingTarget -Name Console -Configuration @{Level = 'DEBUG'; Format = '%{filename} %{lineno} %{message}'}

1..100 | Foreach-Object {
    Write-Log -Level (Get-Random 'DEBUG', 'INFO', 'WARNING', 'ERROR') -Message 'Hello, World!'
}

function Invoke-CallerFunction {
    [CmdletBinding()]
    param()
    Add-LoggingTarget -Name Console -Configuration @{Level = 'DEBUG'}
    Set-LoggingDefaultFormat -Format '[%{filename}] [%{caller}] %{message}'

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
    Add-LoggingTarget -Name Console -Configuration @{Level = 'DEBUG'}
    Set-LoggingDefaultFormat -Format '[%{filename}] [%{caller}] %{message}'
    Set-LoggingCallerScope -CallerScope 2

    1..5 | ForEach-Object {
        Write-CustomLog -Level (Get-Random 'DEBUG', 'INFO', 'WARNING', 'ERROR') -Message 'Hello, World! (With caller scope at level 2)'
    }
}

Invoke-CallerFunctionWithCustomLog

Wait-Logging