@{
    Name = 'File'
    Configuration = @{
        Path        = @{Required = $true;   Type = [string]}
        PrintBody   = @{Required = $false;  Type = [bool]}
        Append      = @{Required = $false;  Type = [bool]}
        Encoding    = @{Required = $false;  Type = [string]}
        Level       = @{Required = $false;  Type = [string]}
        Format      = @{Required = $false;  Type = [string]}
    }
    Logger = {
        param(
            $Log,
            $Format,
            [hashtable] $Configuration
        )

        $Params = @{}

        $Params['FilePath'] = Replace-Token -String $Configuration.Path -Source $Log
        $Text = Replace-Token -String $Format -Source $Log

        if ($Configuration.PrintBody -and $Log.Body) {
            $Text += ': {0}' -f ($Log.Body | ConvertTo-Json -Compress)
        }

        if (-not $Configuration.ContainsKey('Append')) {$Params['Append'] = $true}
        else {$Params['Append'] = $Configuration.Append}

        if (-not $Configuration.ContainsKey('Encoding')) {$Params['Encoding'] = 'ascii'}
        else {$Params['Encoding'] = $Configuration.Encoding}

        $Text | Out-File @Params
    }
}