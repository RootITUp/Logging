@{
    Name = 'Slack'
    Configuration = @{
        ServerUri = @{Required = $true; Type = [string]}
        BotName = @{Required = $false; Type = [string]}
        Channel = @{Required = $false; Type = [string]}
        Level = @{Required = $false; Type = [string]}
    }
    Logger = {
        param(
            $Log, 
            $Format, 
            $Configuration
        )
                
        $Text = @{
            Text = '{0}' -f $Log.msg.Title
        }
        
        if ($Log.msg.Body.Count -ne 0) { $Text.Text += ': {0}' -f $Log.msg.Body | ConvertTo-Json}
        
        if ($Configuration.BotName) { $Text['username'] = $Configuration.BotName }
        
        if ($Configuration.Channel) { $Text['channel'] = $Configuration.Channel }
        
        if ($Log.levelno -ge 30 -and $Log.levelno -lt 40) {
            $Text['icon_emoji'] = ':warning:'
        } elseif ($Log.levelno -ge 40) {
            $Text['icon_emoji'] = ':fire:'
        } else {
            $Text['icon_emoji'] = ':exclamation:'
        }
                 
        Invoke-RestMethod -Method Post -Uri $Configuration.ServerUri -Body ($Text | ConvertTo-Json) | Out-Null
    }
}
