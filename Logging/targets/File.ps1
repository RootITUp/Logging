@{
    Name          = 'File'
    Configuration = @{
        Path           = @{Required = $true; Type = [string]; Default = $null }
        PrintBody      = @{Required = $false; Type = [bool]; Default = $false }
        PrintException = @{Required = $false; Type = [bool]; Default = $false }
        Append         = @{Required = $false; Type = [bool]; Default = $true }
        Encoding       = @{Required = $false; Type = [string]; Default = 'ascii' }
        Level          = @{Required = $false; Type = [string]; Default = $Logging.Level }
        Format         = @{Required = $false; Type = [string]; Default = $Logging.Format }
    }
    Init          = {
        param(
            [hashtable] $Configuration
        )

        [String] $directoryPath = [System.IO.Path]::GetDirectoryName($Configuration.Path)

        # We (try to) create the directory if it is not yet given
        if (-not [System.IO.Directory]::Exists($directoryPath)){
            # "Creates all directories and subdirectories in the specified path unless they already exist."
            # https://docs.microsoft.com/en-us/dotnet/api/system.io.directory.createdirectory?view=net-5.0#System_IO_Directory_CreateDirectory_System_String_
            [System.IO.Directory]::CreateDirectory($directoryPath) | Out-Null
        }
    }
    Logger        = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        if ($Configuration.PrintBody -and $Log.Body) {
            $Log.Body = $Log.Body | ConvertTo-Json -Compress
        }
        elseif (-not $Configuration.PrintBody -and $Log.Body) {
            $Log.Remove('Body')
        }

        $Text = Replace-Token -String $Configuration.Format -Source $Log

        if (![String]::IsNullOrWhiteSpace($Log.ExecInfo) -and $Configuration.PrintException) {
            $Text += "`n{0}" -f $Log.ExecInfo.Exception.Message
            $Text += "`n{0}" -f (($Log.ExecInfo.ScriptStackTrace -split "`r`n" | % { "`t{0}" -f $_ }) -join "`n")
        }

        $Params = @{
            Append   = $Configuration.Append
            FilePath = Replace-Token -String $Configuration.Path -Source $Log
            Encoding = $Configuration.Encoding
        }

        $Text | Out-File @Params
    }
}