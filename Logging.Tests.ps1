Set-LoggingDefaultLevel -Level 'WARNING'
Add-LoggingTarget -Name Console
Add-LoggingTarget -Name Slack -Configuration @{ServerUri = ''; Level = 'DEBUG'}

Write-Log -Level 'DEBUG' -Message 'Starting...'

$Level = 'DEBUG', 'INFO', 'WARNING', 'ERROR'
foreach ($i in 1..5) {
    Write-Log -Level ($Level | Get-Random) -Message ('Message n.{0}' -f $i)
    Start-Sleep -Milliseconds (Get-Random -Min 100 -Max 1000) 
}
