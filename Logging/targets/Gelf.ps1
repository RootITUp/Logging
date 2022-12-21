<#

This target can be used to send gelf messages to server, for instance a Graylog server.

Parameters:
    - Server: Defines the fqdn of the gelf endpoint
    - Port: Defines the port used for the gelf endpoint
    - Level: Defines the level of messages that will be sent to target.
    - Hostname: Defines the attribute hostname on the gelf message, defaults to (hostname)
    - Format: Defines the format of the shortmessage attribute on the gelf message
    - Protocol: Defines if the gelf message should be submitted with TCP or UDP.
    - AdditionalField: Defines a hashtable of additional fields to submit.

Prereqs:
    This target depends on the powershell module PSGELF, make sure that module is installed and available.

#>

@{
    Name          = 'Gelf'
    Configuration = @{
        Server          = @{Required = $true; Type = [string]; Default = $null }
        Port            = @{Required = $true; Type = [int]; Default = $null }
        Level           = @{Required = $false; Type = [string]; Default = $Logging.Level }
        HostName        = @{Required = $false; Type = [string]; Default = (hostname) }
        Format          = @{Required = $false; Type = [string]; Default = $Logging.Format }
        Protocol        = @{Required = $false; Type = [string]; Default = 'TCP' }
        AdditionalField = @{Required = $false; Type = [hashtable]; Default = $null }
    }
    Init          = {
        param(
            [hashtable] $Configuration
        )

        try
        {
            Import-Module PSGELF -ErrorAction Stop
        }
        catch
        {
            Write-Warning 'Unable to load module PSGELF, make sure that the module is installed and available in the context of the powershell session running the script. No logging to the gelf server will be performed.'
        }

    }
    Logger        = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        $SyslogLevel = switch ($Log.Level)
        {
            'NOTSET'
            {
                6  # INFORMATION
            }
            'ERROR'
            {
                3  # ERROR
            }
            'WARNING'
            {
                4  # WARNING
            }
            'INFO'
            {
                6  # INFORMATION
            }
            'DEBUG'
            {
                7  # DEBUG
            }
        }

        $Params = @{
            GelfServer   = $Configuration.Server
            Port         = $Configuration.Port
            ShortMessage = (Format-Pattern -Pattern $Configuration.Format -Source $Log)
            Level        = $SysLogLevel
        }

        if ($Configuration.AdditionalField)
        {
            $Params.AdditionalField = $Configuration.AdditionalField
        }

        switch ($Configuration.Protocol)
        {
            'TCP'
            {
                Send-PSGelfTCP @Params
            }
            'UDP'
            {
                Send-PSGelfUDP @Params
            }
        }
    }
}
