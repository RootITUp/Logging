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
        # Rotation
        ## Rotate after the directory contains the given amount of files. A value that is less than or equal to 0 is treated as not configured.
        RotateAfterAmount   = @{Required = $false; Type = [int]; Default = -1}
        ## Amount of files to be rotated, when RotateAfterAmount is used.
        ## In general max(|Files| - RotateAfterAmount, RotateAmount) files are rotated.
        RotateAmount        = @{Required = $false; Type = [int]; Default = -1}
        ## Rotate after the difference between the current datetime and the datetime of the file(s) are greater then the given timespan. A value of 0 is treated as not configured.
        RotateAfterDate     = @{Required = $false; Type = [timespan]; Default = [timespan]::Zero}
        ## Rotate after the file(s) are greater than the given size in BYTES. A value that is less than or equal to 0 is treated as not configured.
        RotateAfterSize     = @{Required = $false; Type = [int]; Default = -1}
        ## Optionally all rotated files can be compressed. Uses patterns, however only datetimes are allows
        CompressionPath     = @{Required = $false; Type = [string]; Default = [String]::Empty}
    }
    Init          = {
        param(
            [hashtable] $Configuration
        )

        [string] $directoryPath = [System.IO.Path]::GetDirectoryName($Configuration.Path)
        [string] $wildcardBasePath = Format-Pattern -Pattern ([System.IO.Path]::GetFileName($Configuration.Path)) -Wildcard

        # We (try to) create the directory if it is not yet given
        if (-not [System.IO.Directory]::Exists($directoryPath)){
            # "Creates all directories and subdirectories in the specified path unless they already exist."
            # https://docs.microsoft.com/en-us/dotnet/api/system.io.directory.createdirectory?view=net-5.0#System_IO_Directory_CreateDirectory_System_String_
            [System.IO.Directory]::CreateDirectory($directoryPath) | Out-Null
        }

        # Allow for the rolling of log files
        $mtx = New-Object System.Threading.Mutex($false, 'FileMtx')
        [void] $mtx.WaitOne()
        try{
            # Get existing files
            if (-not [System.IO.Directory]::Exists($directoryPath)){
                return
            }

            $rotationDate = $Configuration.RotateAfterDate.Duration()
            $currentDateUtc = [datetime]::UtcNow

            [string[]] $logFiles = [System.IO.Directory]::GetFiles($directoryPath, $wildcardBasePath)
            $toBeRolled = @()
            $givenFiles = [System.IO.FileInfo[]]::new($logFiles.Count)

            for ([int] $i = 0; $i -lt $logFiles.Count; $i++){
                $fileInfo = [System.IO.FileInfo]::new($logFiles[$i])

                # 1. Based on file size
                if ($Configuration.RotateAfterSize -gt 0 -and $fileInfo.Length -gt $Configuration.RotateAfterSize){
                    $toBeRolled += $fileInfo
                }
                # 2. Based on date
                elseif ($rotationDate.TotalSeconds -gt 0 -and ($currentDateUtc - $fileInfo.CreationTimeUtc).TotalSeconds -gt $rotationDate.TotalSeconds){
                    $toBeRolled += $fileInfo
                }
                # 3. Based on number
                else{
                    $givenFiles[$i] = $fileInfo
                }
            }

            # 3. Based on number
            if ($Configuration.RotateAfterAmount -gt 0 -and $givenFiles.Count -gt $Configuration.RotateAfterAmount){
                if ($Configuration.RotateAmount -le 0){
                    $Configuration.RotateAmount = $Configuration.RotateAfterAmount / 2
                }

                $sortedFiles = $givenFiles | Sort-Object -Property CreationTimeUtc

                # Rotate
                # a) until sortedFiles = RotateAfterAmount
                # b) until RotateAmount files are rotated
                for ([int] $i = 0; ($i -lt ($sortedFiles.Count - $Configuration.RotateAfterAmount)) -or ($i -le $Configuration.RotateAmount); $i++){
                    $toBeRolled += $sortedFiles[$i]
                }
            }

            [string[]] $paths = @()
            foreach ($fileInfo in $toBeRolled){
                $paths += $fileInfo.FullName
            }

            if ($paths.Count -eq 0){
                return
            }

            # (opt) compress old files
            if (-not [string]::IsNullOrWhiteSpace($Configuration.CompressionPath)){
                try{
                    Add-Type -As System.IO.Compression.FileSystem
                }catch{
                    $ParentHost.UI.WriteErrorLine("ERROR: You need atleast .Net 4.5 for the compression feature.")
                    return
                }

                [string] $compressionDirectory = [System.IO.Path]::GetDirectoryName($Configuration.CompressionPath)
                [string] $compressionFile = Format-Pattern -Pattern $Configuration.CompressionPath -Source @{
                    timestamp    = [datetime]::now
                    timestamputc = [datetime]::UtcNow
                    pid          = $PID
                }

                # We (try to) create the directory if it is not yet given
                if (-not [System.IO.Directory]::Exists($compressionDirectory)){
                   [System.IO.Directory]::CreateDirectory($compressionDirectory) | Out-Null
                }

                # Compress-Archive not supported for PS < 5
                [string] $temporary = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
                [System.IO.DirectoryInfo] $tempDir = [System.IO.Directory]::CreateDirectory($temporary)

                if ([System.IO.File]::Exists($compressionFile)){
                    [IO.Compression.ZipFile]::ExtractToDirectory($compressionFile, $tempDir.FullName)
                    Remove-Item -Path $compressionFile -Force
                }

                Move-Item -Path $paths -Destination $tempDir.FullName -Force
                [IO.Compression.ZipFile]::CreateFromDirectory($tempDir.FullName, $compressionFile, [System.IO.Compression.CompressionLevel]::Fastest, $false)
                Remove-Item -Path $tempDir.FullName -Recurse -Force
            }else{
                Remove-Item -Path $paths -Force
            }
        }finally{
            [void] $mtx.ReleaseMutex()
            $mtx.Dispose()
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

        $Text = Format-Pattern -Pattern $Configuration.Format -Source $Log

        if (![String]::IsNullOrWhiteSpace($Log.ExecInfo) -and $Configuration.PrintException) {
            $Text += "`n{0}" -f $Log.ExecInfo.Exception.Message
            $Text += "`n{0}" -f (($Log.ExecInfo.ScriptStackTrace -split "`r`n" | % { "`t{0}" -f $_ }) -join "`n")
        }

        $Params = @{
            Append   = $Configuration.Append
            FilePath = Format-Pattern -Pattern $Configuration.Path -Source $Log
            Encoding = $Configuration.Encoding
        }

        $mtx = New-Object System.Threading.Mutex($false, 'FileMtx')
        [void] $mtx.WaitOne()
        try{
            $Text | Out-File @Params
        }finally{
            [void] $mtx.ReleaseMutex()
            $mtx.Dispose()
        }
    }
}