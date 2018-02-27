@{
    Name = 'Email'
    Configuration = @{
        SMTPServer  = @{Required = $true;   Type = [string]}
        From        = @{Required = $true;   Type = [string]}
        To          = @{Required = $true;   Type = [string]}
        Subject     = @{Required = $false;  Type = [string]}
        Credential  = @{Required = $false;  Type = [pscredential]}
        Level       = @{Required = $false;  Type = [string]}
    }
    Logger = {
        param(
            $Log,
            $Format,
            [hashtable] $Configuration
        )

        $Params = @{}

        $Params['SmtpServer'] = $Configuration.SMTPServer
        $Params['From'] = $Configuration.From
        $Params['To'] = $Configuration.To.Split(',').Trim()
        $Params['Body'] = Replace-Token -String $Format -Source $Log

        if ($Configuration.Subject) {
            $Params['Subject'] = Replace-Token -String $Configuration.Subject -Source $Log
        } else {
            $Params['Subject'] = Replace-Token -String '[%{level:-7}] %{message}' -Source $Log
        }

        if ($Configuration.Credential) {
            $Params['Credential'] = $Configuration.Credential
        }

        if ($Log.Body) {
            $Params['Body'] += "`n`n{0}" -f ($Log.Body | ConvertTo-Json)
        }

        Send-MailMessage @Params
    }
}