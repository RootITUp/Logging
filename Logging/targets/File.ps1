@{
    Name = 'File'
    Configuration = @{
        Path        = @{Required = $true;   Type = [string];    Default = $null}
        PrintBody   = @{Required = $false;  Type = [bool];      Default = $false}
        Append      = @{Required = $false;  Type = [bool];      Default = $true}
        Encoding    = @{Required = $false;  Type = [string];    Default = 'ascii'}
        Level       = @{Required = $false;  Type = [string];    Default = Get-LoggingDefaultLevel}
        Format      = @{Required = $false;  Type = [string];    Default = Get-LoggingDefaultFormat}
    }

    Logger = {
        param(
            [hashtable] $Log,
            [string] $Format,
            [hashtable] $Configuration
        )

        if ($Configuration.PrintBody -and $Log.Body) {
            $Log.Body = $Log.Body | ConvertTo-Json -Compress
        } elseif (-not $Configuration.PrintBody -and $Log.Body) {
            $Log.Remove('Body')
        }

        $Text = Replace-Token -String $Format -Source $Log

        $Params = @{
            Append      = $Configuration.Append
            FilePath    = Replace-Token -String $Configuration.Path -Source $Log
            Encoding    = $Configuration.Encoding
        }

        $Text | Out-File @Params
    }
}