@{
    Name = 'Console'
    Description = 'Writes messages to console with different colors.'
    Configuration = @{
        Level        = @{Required = $false; Type = [string]}
        Format       = @{Required = $false; Type = [string]}
        ColorMapping = @{Required = $false; Type = [hashtable]}
    }
    Logger = {
        param(
            $Log,
            $Format,
            $Configuration
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
        $mtx.WaitOne()

        $Text = Replace-Token -String $Format -Source $Log

        if ($Log.ExecInfo) {
            $Text += "`n" + $Log.ExecInfo.InvocationInfo.PositionMessage
        }

        $OldColor = $ParentHost.UI.RawUI.ForegroundColor
        $ParentHost.UI.RawUI.ForegroundColor = $ColorMapping[$Log.Level]
        $ParentHost.UI.WriteLine($Text)
        $ParentHost.UI.RawUI.ForegroundColor = $OldColor

        [void] $mtx.ReleaseMutex()
        $mtx.Dispose()
    }
}