@{
    Name = 'ElasticSearch'
    Configuration = @{
        Index =         @{Required = $true; Type = [string]}
        Type =          @{Required = $true; Type = [string]}
        ServerName =    @{Required = $true; Type = [string]}
        ServerPort =    @{Required = $true; Type = [int]}
        Level =         @{Required = $false; Type = [string]}
        Format =        @{Required = $false; Type = [string]}
    }
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