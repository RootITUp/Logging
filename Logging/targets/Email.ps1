@{
    Name = 'Email'
    Description = 'Send log message to email recipients'
    Configuration = @{
        SMTPServer  = @{Required = $true;   Type = [string];        Default = $null}
        From        = @{Required = $true;   Type = [string];        Default = $null}
        To          = @{Required = $true;   Type = [string];        Default = $null}
        Subject     = @{Required = $false;  Type = [string];        Default = '[%{level:-7}] %{message}'}
        Credential  = @{Required = $false;  Type = [pscredential];  Default = $null}
        Level       = @{Required = $false;  Type = [string];        Default = Get-LoggingDefaultLevel}
        Port        = @{Required = $false;  Type = [int];           Default = 25}
        UseSsl      = @{Required = $false;  Type = [bool];          Default = $false}
    }
    Logger = {
        param(
            $Log,
            $Format,
            [hashtable] $Configuration
        )

        $Params = @{
            SmtpServer = $Configuration.SMTPServer
            From = $Configuration.From
            To = $Configuration.To.Split(',').Trim()
            Port = $Configuration.Port
            UseSsl = $Configuration.UseSsl
            Subject = Replace-Token -String '[%{level:-7}] %{message}' -Source $Log
        }

        if ($Configuration.Credential) {
            $Params['Credential'] = $Configuration.Credential
        }

        if ($Log.Body) {
            $Params['Body'] += "{0}`n`n{1}" -f ((Replace-Token -String $Format -Source $Log), ($Log.Body | ConvertTo-Json))
        } else {
            $Params['Body'] = Replace-Token -String $Format -Source $Log
        }

        Send-MailMessage @Params
    }
}