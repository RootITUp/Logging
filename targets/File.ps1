@{
    Name = 'File'
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