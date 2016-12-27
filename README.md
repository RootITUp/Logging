# Powershell Logging Module v2.3.9

## Features

* Separate thread that dispatch messages to targets to avoid bottleneck in the main script
* Extensible with new targets
* Custom formatting
* Each target can have his own logging level

## Installation

### PowerShell Gallery

```powershell
> Install-Module Logging
> Import-Module Logging
```

### GitHub

#### Clone Repo

```terminal
> git clone https://github.com/EsOsO/Logging.git
> Import-Module .\Logging\Logging.psm1

```

#### Download Repo

* Download [the zip](https://github.com/EsOsO/Logging/archive/master.zip)
* Unzip the content of "Logging-master" to:
* C:\Program Files\WindowsPowerShell\Modules\Logging [System wide]
* D:\Users\<username>\Documents\WindowsPowerShell\Modules\Logging [User only]

```powershell
> Import-Module Logging
```

## TL;DR

```powershell
Set-LoggingDefaultLevel -Level 'WARNING'
Add-LoggingTarget -Name Console
Add-LoggingTarget -Name File -Configuration @{Path = 'C:\Temp\example_%{+%Y%m%d}.log'}

$Level = 'DEBUG', 'INFO', 'WARNING', 'ERROR'
foreach ($i in 1..100) {
    Write-Log -Level ($Level | Get-Random) ('Message n.{0}' -f $i)
    Start-Sleep -Milliseconds (Get-Random -Min 100 -Max 1000)
}

Wait-Logging        # See Note
```

### NOTE

When used in *unattended* scripts (scheduled tasks, spawned process) you need to call Wait-Logging to avoid losing messages. If you run your main script in an interactive shell that stays open at the end of the execution you could avoid using it (keep in mind that if there are messeages in the queue when you close the shell, you'll lose it)

## Configuration

The following section describe how to configure the Logging module.

* Level
* Format
* Targets
* CustomTargets

#### Level

The *Level* property defines the default logging level.
Valid values are:

```powershell
* NOTSET    ( 0)
* DEBUG     (10)
* INFO      (20)
* WARNING   (30)
* ERROR     (40)
```

For example:

```powershell
> Get-LoggingDefaultLevel                       # Get the default value
NOTSET                                          # NOTSET level
> Set-LoggingDefaultLevel -Level 'ERROR'        # Set default level to ERROR
> Get-LoggingDefaultLevel                       # Get the current global level
ERROR
```

#### Format

The *Format* property defines how the message is rendered.

The default value is: `[%{timestamp}] [%{level:-7}] %{message}`

The Log object has a number of attributes that are replaced in the format string to produce the message:

| Format         | Description |
| -------------- | ----------- |
| `%{timestamp}` | Time when the log message was created. Defaults to `%Y-%m-%d %T%Z` (*2016-04-20 14:22:45+02*). Take a look at the [Technet article](https://technet.microsoft.com/en-us/library/hh849887.aspx#sectionSection7) about the UFormat parameter |
| `%{level}`     | Text logging level for the message (*DEBUG*, *INFO*, *WARNING*, *ERROR*)
| `%{levelno}`   | Number logging level for the message (*10*, *20*, *30*, *40*)
| `%{message}`   | The logged message
| `%{body}`      | The logged body (json format not pretty printed)

After the placeholder name you can pass a padding or a date format string separated by a colon (`:`):

##### Padding

If the padding value is negative, the field will be left aligned and padded with spaces on the right:

```powershell
> Set-LoggingDefaultFormat -Format '[%{level:-7}]'
[DEBUG  ]
[INFO   ]
[WARNING]
[ERROR  ]
```

If the padding value is positive, the field will be right aligned and padded with spaces on the left:

```powershell
> Set-LoggingDefaultFormat -Format '[%{level:7}]'
[  DEBUG]
[   INFO]
[WARNING]
[  ERROR]
```

##### Date format string

The date format string starts with a plus sign (`+`) followed by **UFormat** parameters. See [here](https://technet.microsoft.com/en-us/library/hh849887.aspx#sectionSection7) for available formats.

```powershell
> Set-LoggingDefaultFormat -Format '%{timestamp}'
2016-04-20 13:31:12+02
> Set-LoggingDefaultFormat -Format '%{timestamp:+%A, %B %d, %Y}'
Wednesday, April 20, 2016
> Set-LoggingDefaultFormat -Format '[%{timestamp:+%T:12}]'   # You could also use padding and date format string at the same time
[   13:31:12]
```

### Targets

The *Targets* property stores the used logging targets, it's where you define where to route your messages.

Keys of the hashtable depends on the target you are configuring. The module ships with 3 targets but you can write your own for specific usage.

* Console
* File
* ElasticSearch
* Slack
* Email

#### Console
From version 2.3.3 it supports acquiring lock for issues with git prompt that sometimes gets splitted during output.
The mutex name to acquire is ```ConsoleMtx```

```powershell
> Add-LoggingTarget -Name Console -Configuration @{
    Level       = <NOTSET>          # <Not required> Sets the logging level for this target
    Format      = <NOTSET>          # <Not required> Sets the logging format for this target
}
```

#### File

```powershell
> Add-LoggingTarget -Name File -Configuration @{
    Path        = <NOTSET>          # <Required> Sets the file destination (eg. 'C:\Temp\%{+%Y%m%d}.log')
                                    #            It supports templating like $Logging.Format
    PrintBody   = $false            # <Not required> Prints body message too
    Append      = $true             # <Not required> Append to log file
    Encoding    = 'ascii'           # <Not required> Sets the log file encoding
    Level       = <NOTSET>          # <Not required> Sets the logging level for this target
    Format      = <NOTSET>          # <Not required> Sets the logging format for this target
}
```

#### ElasticSearch

```powershell
> Add-LoggingTarget -Name ElasticSearch -Configuration @{
    ServerName  = <NOTSET>          # <Required> Sets the ES server name (eg. 'localhost')
    ServerPort  = <NOTSET>          # <Required> Sets the ES server port (eg. 9200)
    Index       = <NOTSET>          # <Required> Sets the ES index name to log to (eg. 'logs-%{+%Y.%m.%d}')
                                    #            It supports templating like $Logging.Format
    Type        = <NOTSET>          # <Required> Sets the ES type for the message (eg. 'log')
    Level       = <NOTSET>          # <Not required> Sets the logging format for this target
}
```

#### Slack

```powershell
> Add-LoggingTarget -Name Slack -Configuration @{
    ServerURI   = <NOTSET>          # <Required> Sets the Slack Webhook URI (eg. 'https://hooks.slack.com/services/xxxx/xxxx/xxxxxxxxxx')
    Channel     = <NOTSET>          # <Not required> Overrides the default channel of the Webhook (eg. '@username' or '#other-channel')
    BotName     = <NOTSET>          # <Not required> Overrides the default name of the bot (eg. 'PoshLogging')
    Level       = <NOTSET>          # <Not required> Sets the logging format for this target
}
```

#### Email

```powershell
> Add-LoggingTarget -Name Email -Configuration @{
    SMTPServer  = <NOTSET>          # <Required> SMTP server FQDN
    From        = <NOTSET>          # <Required> From address
    To          = @(<NOTSET>)       # <Required> An array of recipients. NB: @() are needed around the value
    Subject     = '[%{level:-7}] %{message}'    # <Not required> Email subject. Supports formatting and expansion
    Credential  = <NOTSET>          # <Not required> If your server uses authentication
    Level       = <NOTSET>          # <Not required> Sets the logging format for this target
}
```

### CustomTargets

It lets define a folder to load custom targets.

```powershell
> Set-LoggingCustomTarget -Path 'C:\temp\'
> Get-LoggingTargetAvailable
Name                           Value
----                           -----
Console                        {Configuration, ParamsRequired, Logger}
ElasticSearch                  {Configuration, ParamsRequired, Logger}
File                           {Configuration, ParamsRequired, Logger}
Slack                          {Configuration, ParamsRequired, Logger}
MyCustomTarget                 {Configuration, ParamsRequired, Logger}
```

## Contributing

Please use [issues](https://github.com/EsOsO/Logging/issues) system or GitHub pull requests to contribute to the project.

For more information, see [CONTRIBUTING](CONTRIBUTING.md)

## Notes

* The dispatcher thread starts the first time a `Write-Log` command is executed and keeps running in the background to dispatch new messages until the module is removed.
* The runspace code is inspired by the work and research of Boe Prox (@proxb).