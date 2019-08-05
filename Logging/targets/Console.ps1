@{
    Name = 'Console'
    Description = 'Writes messages to console with different colors.'
    Configuration = @{
        Level        = @{Required = $false; Type = [string];    Default = $Logging.Level}
        Format       = @{Required = $false; Type = [string];    Default = $Logging.Format}
        ColorMapping = @{Required = $false; Type = [hashtable]; Default = @{
                                                                    'DEBUG'   = 'Blue'
                                                                    'INFO'    = 'Green'
                                                                    'WARNING' = 'Yellow'
                                                                    'ERROR'   = 'Red'
                                                                }
        }
    }
    Init = {
        param(
            [hashtable] $Configuration
        )

        foreach ($Level in $Configuration.ColorMapping.Keys) {
            $Color = $Configuration.ColorMapping[$Level]

            if ($Color -notin ([System.Enum]::GetNames([System.ConsoleColor]))) {
                [Console]::Error.WriteLine("ERROR: Cannot use custom color '$Color': not a valid [System.ConsoleColor] value")
                continue
            }
        }
    }
    Logger = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        try {
            $logText = Replace-Token -String $Configuration.Format -Source $Log

            if (![String]::IsNullOrWhiteSpace($Log.ExecInfo)) {
                $logText += "`n" + $Log.ExecInfo.InvocationInfo.PositionMessage
            }

            #[Console] is thread safe
            if ($Configuration.ColorMapping.ContainsKey($Log.Level)) {
                [Console]::ForegroundColor = $Configuration.ColorMapping[$Log.Level]
            }
            [Console]::WriteLine($logText)
            [Console]::ResetColor()
        }
        catch {
            $ParentHost.UI.WriteErrorLine($_)
        }
    }
}