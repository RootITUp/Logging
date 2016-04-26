@{
    Name = 'File'
    Configuration = @{
        Path = @{Required = $true; Type = [string]}
        Level = @{Required = $false; Type = [string]}
        Format = @{Required = $false; Type = [string]}
    }
    Logger = {
        param(
            $Log, 
            $Format, 
            $Configuration
        )
        
        if ($Log.Msg.Title) {
            $Log.Message = $Log.Msg.Title
        } else {
            $Log.Message = $Log.Msg | ConvertTo-Json -Compress | Out-String
        }

        $Text = Replace-Tokens -String $Format -Source $Log
        $Path = Replace-Tokens -String $Configuration.Path -Source $Log
        $Text | Out-File -FilePath $Path -Append
    }
}