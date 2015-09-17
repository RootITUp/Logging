Function Write-Log {
    <#
    .SYNOPSIS
    This function for unified logging

    .DESCRIPTION
    Write-Log function support multiple handler to log messages to different destinations.
    Each handler support own log level and formatter to specify the layout of the log.

    To use logging functionality you need to define $Global:Logging:
    $Global:Logging['Destinations'] += @{Console = @{Level = 'DEBUG'; Formatter = "%{MESSAGE}"}}

    In this case we use only one handler, Console, with a DEBUG level and a custom formatter.

    To also log to file we could write:
    $Global:Logging['Destinations'] += @{File = @{Level = 'INFO', Path = 'C:\TEMP\powershell.log'}}

    Inside the module are already defined two handlers: Console and File.
    To define your own handler this is the signature of the functions getting called:

    function Foo  {
        param(
            [string]$Message,
            [string]$Level,
            [hashtable]$Configuration
        )
    }

    Inside $Configuration you have access to the global handler configuration, for example the path for the File handler.

    And to activate it:
    $Global:Logging['Handlers'] += @{Foo = 'Foo'}
    $Global:Logging['Destinations']['Foo'] = @{Level = 'WARN'}

    .PARAMETER Message
    .PARAMETER Level

    .EXAMPLE
    Write to defined handlers only if destination level is greater or equal than INFO:
    Write-Log "Hello World!" -Level INFO

    #>

    [CmdletBinding()]
    Param(
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [string[]]$Message,
        [ValidateSet('ERROR','WARN','INFO','DEBUG')]
        [string]$Level = 'WARN'
    )
    BEGIN {
        $levels = @{'DEBUG' = 10; 'INFO' = 20; 'WARN' = 30; 'ERROR' = 40}
        $handlers = @{
            'Console' = 'Logging-Console';
            'File'    = 'Logging-File';
        }

        if ($Global:Logging -is [Hashtable] -and $Global:Logging['Handlers'] -is [Hashtable]) {
            $handlers += $Global:Logging['Handlers']
        }
    }

    PROCESS {
        if ($Global:Logging -is [Hashtable]) {
            foreach ($Msg in $Message) {
                foreach ($handler in $Global:Logging['Destinations'].Keys) {
                    $conf = $Global:Logging['Destinations'][$handler]
                    if ($levels[$Level] -ge $levels[$conf.Level]) {
                        $splattable = @{}
                        if ($conf.Formatter) {
                            $splattable['Formatter'] = $conf.Formatter
                        }
                        $txt = Format-String -Message $Msg -Level $Level @splattable
                        &$handlers[$handler] -Message $txt -Level $Level -Configuration $conf
                    }
                }
            }
        }
    }
}

Function Logging-Console {
    param(
        [string]$Message,
        [string]$Level,
        [hashtable]$Configuration
    )
    $colors = @{'DEBUG' = 'Blue'; 'INFO' = 'Green'; 'WARN' = 'Yellow'; 'ERROR' = 'Red'}
    Write-Host -Object $Message -ForegroundColor $colors[$Level]
}

Function Logging-File {
    param(
        [string]$Message,
        [string]$Level,
        [hashtable]$Configuration
    )
    $mtx = New-Object System.Threading.Mutex($false, 'Write-Log')
    if ($mtx.WaitOne(1000)) {
        Out-File -FilePath $Configuration.Path -InputObject $Message -Encoding unicode -Append
        [void] $mtx.ReleaseMutex()
    } else {
        Write-Warning 'Timed out acquiring mutex on log file.'
    }
}

Function Format-String {
    param(
        [string]$Message,
        [string]$Level,
        [string]$Formatter = '[%{DATETIME:-10}] [%{LEVEL:-7}] %{MESSAGE}'
    )
    $replace = @{
        'MESSAGE'  = $Message
        'LEVEL'    = $Level
        'DATETIME' = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fff'
    }

    foreach ($token in $replace.Keys) {
        $regex = [regex]"%{$token(:(?<len>-?\d+))?}"
        $Formatter -match $regex | Out-Null
        if ($matches['len']) { $tpl = "{0,$($matches['len'])}" }
        else { $tpl = "{0}" }
        $str = $tpl -f $replace[$token]
        $Formatter = $Formatter -replace $regex, $str
    }

    return $Formatter
}

Export-ModuleMember -Function Write-Log
