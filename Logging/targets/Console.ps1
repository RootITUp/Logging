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
    Init          = {
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
            $Configuration,
            $ParentHost
        )

        $mtx = New-Object System.Threading.Mutex($false, 'ConsoleMtx')
        $mtx.WaitOne()

        try {
            #This call seems to require quite some time
            $logText = Replace-Token -String $Format -Source $Log

            if (![String]::IsNullOrWhiteSpace($Log.ExecInfo)) {
                $logText += "`n" + $Log.ExecInfo.InvocationInfo.PositionMessage
            }
            
            $ParentHost.UI.WriteLine($Configuration.ColorMapping[$Log.Level], $ParentHost.UI.RawUI.BackgroundColor, $logText)
        }
        catch {
            [Console]::WriteLine($_)
        }
        finally {
            [void] $mtx.ReleaseMutex()
            $mtx.Dispose()
        }
    }
}