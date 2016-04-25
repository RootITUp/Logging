@{
    Name = 'Slack'
    Logger = {
        param(
            $Log, 
            $Format, 
            $Configuration
        )
        
        $Index = Replace-Tokens -String $Configuration.Index -Source $Log
        $Uri = '{0}' -f  $Configuration.ServerURI
        $text=@{text=$($log.msg.title + $log.msg.body)}  
        if ($log.msg.body)
        {
            $text=@{text=$($log.msg.title +": " +$log.msg.body)}
        }
        else 
        {
            $text=@{text=$log.msg.title}        
        }
        if ($Configuration.BotName)
        {
          $text.Add("username",$Configuration.BotName)    
        }    
        if ($Configuration.Channel)
        {
            $text.Add("channel",$Configuration.Channel)
        }
        if ($log.levelno -ge 30 -and $log.levelno -lt 40)
        {
            $text.Add("icon_emoji",":warning:")
        }
        elseif ($log.levelno -ge 40)
        {
            $text.Add("icon_emoji",":fire:")
        }
        else 
        {
            $text.Add("icon_emoji",":exclamation:")
        }
        Invoke-RestMethod -Method Post -Uri $Uri -Body ($text|ConvertTo-Json)|out-null
    }
}
