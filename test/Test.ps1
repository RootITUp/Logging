Remove-Module Logging -Force
Import-Module .\Logging\Logging.psm1

Add-LoggingTarget -Name Console -Configuration @{Level = 'DEBUG'; Format = '%{filename} %{lineno} %{message}'}

1..100 | %{
    Write-Log -Level (Get-RandomChoice 'DEBUG', 'INFO', 'WARNING', 'ERROR') -Message 'Hello, World!'
}

Wait-Logging