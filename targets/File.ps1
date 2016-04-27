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
        
        $Text = Replace-Tokens -String $Format -Source $Log
        $Path = Replace-Tokens -String $Configuration.Path -Source $Log
        $Text | Out-File -FilePath $Path -Append
    }
}