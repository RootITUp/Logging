@{
    Name = 'Webex Teams'
    Configuration = @{
        BotToken = @{Required = $true; Type = [string]; Default = $null }
        RoomID = @{Required = $true; Type = [string]; Default = $null }
        Icons   = @{Required = $false; Type = [hashtable]; Default = @{
                'ERROR'   = '🚨'
                'WARNING' = '⚠️'
                'INFO'    = 'ℹ️'
                'DEBUG'   = '🔎'
            }
        }
        Level   = @{Required = $false; Type = [string]; Default = $Logging.Level}
        Format  = @{Required = $false; Type = [string]; Default = $Logging.Format}
    }
    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )
        
        $body = @{
          roomId=$Configuration.RoomID
          text=$Configuration.Icons[$Log.LevelNo]+" "+Replace-Token -String $Configuration.Format -Source $Log
        }

        $json=$body | ConvertTo-Json
        
        Invoke-RestMethod -Method Post `
          -Headers @{"Authorization"="Bearer $Configuration.BotToken"} `
          -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($json)) `
          -Uri "https://api.ciscospark.com/v1/messages"

        
    }
}
