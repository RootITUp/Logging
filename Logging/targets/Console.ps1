@{
    Name = 'Console'
    Description = 'Writes messages to console with different colors.'
    Configuration = @{
        Level        = @{Required = $false; Type = [string];    Default = Get-LoggingDefaultLevel}
        Format       = @{Required = $false; Type = [string];    Default = Get-LoggingDefaultFormat}
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
                $ParentHost.UI.WriteErrorLine("ERROR: Cannot use custom color '$Color': not a valid [System.ConsoleColor] value")
                continue
            }
        }
    }

    Logger = {
        param(
            $Log,
            $Format,
            $Configuration
        )

        $mtx = New-Object System.Threading.Mutex($false, 'ConsoleMtx')

        $Text = Replace-Token -String $Format -Source $Log

        if ($Log.ExecInfo) {
            $Text += "`n" + $Log.ExecInfo.InvocationInfo.PositionMessage
        }

        $mtx.WaitOne()
        $ParentHost.UI.WriteLine($Configuration.ColorMapping[$Log.Level], $ParentHost.UI.RawUI.BackgroundColor, $Text)
        [void] $mtx.ReleaseMutex()

        $mtx.Dispose()
    }
}