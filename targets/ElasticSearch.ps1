@{
    Name = 'ElasticSearch'
    Logger = {
        param(
            $Log, 
            $Format, 
            $Configuration
        )
        
        $Index = Replace-Tokens -String $Configuration.Index -Source $Log
        $Uri = 'http://{0}:{1}/{2}/{3}' -f  $Configuration.ServerName, $Configuration.ServerPort, $Index, $Configuration.Type
        # $Uri | Out-File -FilePath D:\Tools\log\test.log -Append
        Invoke-RestMethod -Method Post -Uri $Uri -Body ($Log | ConvertTo-Json) | Out-Null
    }
}