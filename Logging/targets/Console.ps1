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
    Logger = {
        param(
            $Log,
            $Format,
            $Configuration,
            $ParentHost
        )


        $ColorMapping = @{
            'DEBUG'   = 'Blue'
            'INFO'    = 'Green'
            'WARNING' = 'Yellow'
            'ERROR'   = 'Red'
        }

        if ($Configuration.ColorMapping) {
            foreach ($Level in $Configuration.ColorMapping.Keys) {
                $Color = $Configuration.ColorMapping[$Level]

                if ($Color -notin ([System.Enum]::GetNames([System.ConsoleColor]))) {
                    $ParentHost.UI.WriteErrorLine("ERROR: Cannot use custom color '$Color': not a valid [System.ConsoleColor] value")
                    continue
                }

                $ColorMapping[$Level] = $Configuration.ColorMapping[$Level]
            }
        }

        $mtx = New-Object System.Threading.Mutex($false, 'ConsoleMtx')

        try {
            $mtx.WaitOne()
            #This call seems to require quite some time
            $Text = Replace-Token -String $Format -Source $Log

            if ($Log.ExecInfo) {
                $Text += "`n" + $Log.ExecInfo.InvocationInfo.PositionMessage
            }

            $OldColor = $ParentHost.UI.RawUI.ForegroundColor
            $ParentHost.UI.RawUI.ForegroundColor = $ColorMapping[$Log.Level]
            $ParentHost.UI.WriteLine($Text)
            $ParentHost.UI.RawUI.ForegroundColor = $OldColor
        }
        catch {
            $ParentHost.UI.WriteErrorLine($_)
        }
        finally {
            [void] $mtx.ReleaseMutex()
            $mtx.Dispose()
        }
    }
}