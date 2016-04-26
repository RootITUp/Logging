$Global:Logging.Level = 'WARNING'
$Global:Logging.Format = '[%{timestamp:+%Y-%m-%d %T%Z}] [%{level:-7}] %{message}'
$Global:Logging.Targets = @{
    Console = @{
        Level = 'ERROR'
    }
    File = @{
        Path = 'D:\Tools\log\%{+%Y%m%d}.log'
        Level = 'INFO'
    }
}

Write-Log -Level DEBUG -Message 'Hello world!'
Write-Log -Level INFO -Message 'Hello world!'
Write-Log -Level WARNING -Message 'Hello world!'
Write-Log -Level ERROR -Message 'Hello world!'
Write-Log -Level INFO -Message @{
    body = @{
        field1 = ''
        field2 = ''
    }
    src = ''
}

Write-Log -Level ERROR -Message @{
    error = @{
        line = 22
        function = 'Get-Something'
        message = 'Unable to find something'
    }
    foo = 'bar'
}
