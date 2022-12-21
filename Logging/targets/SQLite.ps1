<#

This target can be used to insert rows into a SQLite table

Parameters:
    - Database: Defines the path to the SQLite database
    - TableName: Defines the name of the table to insert rows to
    - ColumnMapping: Defines what log values should be written to witch columns in the table. See the ColumnMapping section below for more information.
    - Level: Defines the level of messages that will be sent to target.
    - MessageFormat: Defines the format of the message. A separate message format is used because it is unlikely that the message for the message column
        should used the same format as specified in the default format of the module. And that format is overriding the default format specified in
        the target definition file.
    - PrintException: Defines that (if provided) the exception object is to be appended to the end of the message.

Prereqs:
    This target depends of the powershell module PSSQLite, make sure that module is installed and available. It is also mandatory to provision the sql
    database and its logging table before messages can be inserted. The logging tool will not provision a new database if none can be found.

Columnmapping:

    Valid values for ColumnMapping is the following: pathname, pid, body, timestamp, rawmessage, lineno, filename, caller, level, timestamputc, execinfo, message, levelno.

    The format of the hashtable is;

    @{
        <SQL column name> = <Value>
        <SQL column name> = <Value>
        <SQL column name> = <Value>
    }

    ie:

    @{
        Time = 'Timestamp'
        Severity = 'Level'
        Source = 'Caller'
        Text = 'Message'
    }

    Only columns that is specified in columnmapping will be filled during insert in the database.

#>

@{
    Name          = 'SQLite'
    Configuration = @{
        Database       = @{Required = $true; Type = [string]; Default = $null }
        TableName      = @{Required = $true; Type = [string]; Default = $null }
        ColumnMapping  = @{Required = $false; Type = [hashtable]; Default = @{Timestamp = 'Timestamp'; Level = 'Level'; Source = 'Caller'; Message = 'Message' } }
        Level          = @{Required = $false; Type = [string]; Default = $Logging.Level }
        MessageFormat  = @{Required = $false; Type = [string]; Default = '[%{lineno}] %{message}' }
        PrintException = @{Required = $false; Type = [bool]; Default = $false }
    }
    Init          = {
        param(
            [hashtable] $Configuration
        )

        try
        {
            Import-Module PSSQLite -ErrorAction Stop
        }
        catch
        {
            Write-Warning 'Unable to load module PSSQLite, make sure that the module is installed and available in the context of the powershell session running the script. No logging to the SQLite database will be performed.'
        }

    }
    Logger        = {
        param(
            [hashtable] $Log,
            [hashtable] $Configuration
        )

        $Message = (Format-Pattern -Pattern $Configuration.MessageFormat -Source $Log)
        if (![String]::IsNullOrWhiteSpace($Log.ExecInfo) -and $Configuration.PrintException)
        {
            $Message += "`n{0}" -f $Log.ExecInfo.Exception.Message
            $Message += "`n{0}" -f (($Log.ExecInfo.ScriptStackTrace -split "`r`n" | ForEach-Object { "`t{0}" -f $_ }) -join "`n")
        }

        $ColumnString = $Configuration.ColumnMapping.Keys -join ','
        $ValueString = ($Configuration.ColumnMapping.Keys -as [string[]]).Foreach({ '@' + $_ }) -join ','
        $ColumnHash = @{}
        foreach ($Key in $Configuration.ColumnMapping.Keys)
        {
            $ColumnHash.Add($Key, $Log.$($Configuration.ColumnMapping[$Key]))
        }

        $query = "INSERT INTO $($Configuration.TableName) ($ColumnString) VALUES ($ValueString)"
        Invoke-SqliteQuery -DataSource $Configuration.Database -Query $query -SqlParameters $ColumnHash
    }
}
