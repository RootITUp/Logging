# Powershell Logging Module

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
* Ublock the zip file (`Unblock-File -Path <path_to_zip>`)
* Unzip the content of "Logging-master" to:
    - C:\Program Files\WindowsPowerShell\Modules\Logging **[System wide]**
    - D:\Users\\{username}\Documents\WindowsPowerShell\Modules\Logging **[User only]**

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
    Write-Log -Level ($Level | Get-Random) -Message 'Message n. {0}' -Arguments $i
    Start-Sleep -Milliseconds (Get-Random -Min 100 -Max 1000)
}

Wait-Logging        # See Note
```

### NOTE

When used in *unattended* scripts (scheduled tasks, spawned process) you need to call Wait-Logging to avoid losing messages. If you run your main script in an interactive shell that stays open at the end of the execution you could avoid using it (keep in mind that if there are messeages in the queue when you close the shell, you'll lose it)
