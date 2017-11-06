@{
    Name = 'Slack'
    Configuration = @{
        WebHook     = @{Required = $true;  Type = [string]}
        BotName     = @{Required = $false; Type = [string]}
        Channel     = @{Required = $false; Type = [string]}
        Level       = @{Required = $false; Type = [string]}
        Format      = @{Required = $false; Type = [string]}
    }
    Logger = {
        param(
            $Log,
            $Format,
            $Configuration
        )

        $Text = @{
            text = Replace-Token -String $Format -Source $Log
        }

        if ($Configuration.BotName) { $Text['username'] = $Configuration.BotName }

        if ($Configuration.Channel) { $Text['channel'] = $Configuration.Channel }

        if ($Log.LevelNo -ge 40) {
            $Text['icon_emoji'] = ':fire:'
        } elseif ($Log.LevelNo -ge 30 -and $Log.LevelNo -lt 40) {
            $Text['icon_emoji'] = ':warning:'
        } else {
            $Text['icon_emoji'] = ':exclamation:'
        }

        $payload = 'payload={0}' -f ($Text | ConvertTo-Json -Compress)

        Invoke-RestMethod -Method POST -Uri $Configuration.WebHook -Body $payload | Out-Null
    }
}
