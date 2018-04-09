Remove-Module Logging -Force -ErrorAction SilentlyContinue

$ManifestPath   = '{0}\..\Logging\Logging.psd1' -f $PSScriptRoot
$ChangeLogPath  = '{0}\..\CHANGELOG.md' -f $PSScriptRoot

Import-Module $manifestPath -Force
Import-Module Pester

Describe -Tags 'VersionChecks' 'Logging manifest and changelog' {
    $script:Manifest = $null
    It 'has a valid manifest' {
        {
            $script:Manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It 'has a valid name in the manifest' {
        $script:Manifest.Name | Should Be Logging
    }

    It 'has a valid guid in the manifest' {
        $script:Manifest.Guid | Should Be '25a60f1d-85dd-4ad6-9efc-35fd3894f6c1'
    }

    It 'has a valid version in the manifest' {
        $script:Manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }

    $script:ChangelogVersion = $null
    It 'has a valid version in the changelog' {

        foreach ($line in (Get-Content $ChangeLogPath)) {
            if ($line -match '^\D*(?<Version>(\d+\.){1,3}\d+)') {
                $script:ChangelogVersion = $matches.Version
                break
            }
        }
        $script:ChangelogVersion                | Should Not BeNullOrEmpty
        $script:ChangelogVersion -as [Version]  | Should Not BeNullOrEmpty
    }

    It 'changelog and manifest versions are the same' {
        $script:ChangelogVersion -as [Version] | Should be ( $script:Manifest.Version -as [Version] )
    }

}

InModuleScope Logging {
    Describe 'Internal Vars' {
        It 'sets up internal variables' {
            Test-Path Variable:Dispatcher | Should Be $true
            Test-Path Variable:LevelNames | Should Be $true
            Test-Path Variable:Logging | Should Be $true
            Test-Path Variable:LogTargets | Should Be $true
            Test-Path Variable:ScriptRoot | Should Be $true
            Test-Path Variable:MessageQueue | Should Be $true
        }

        It 'stes up Session State' {
            Test-Path Variable:InitialSessionState | Should Be $true
        }
    }

    Describe 'Token replacement' {
        $TimeStamp = Get-Date -UFormat '%Y-%m-%dT%T%Z'
        $Object = [PSCustomObject] @{
            message = 'Test'
            timestamp = $TimeStamp
            level = 'INFO'
        }

        It 'should return a string with token replaced' {
            Replace-Token -String '%{message}' -Source $Object | Should Be 'Test'
        }

        It 'should return a string with token replaced and padded' {
            Replace-Token -String '%{message:7}' -Source $Object | Should Be '   Test'
            Replace-Token -String '%{message:-7}' -Source $Object | Should Be 'Test   '
        }

        It 'should return a string with a timestamp, no formatter' {
            Replace-Token -String '%{timestamp}' -Source $Object | Should Be $TimeStamp
        }

        It 'should return a string using a custom Unix format with token' {
            Replace-Token -String '%{timestamp:+%Y%m%d}' -Source $Object | Should Be $(Get-Date $TimeStamp -UFormat '%Y%m%d')
        }

        It 'should return a string using a custom Unix format without token' {
            Replace-Token -String '%{+%Y%m%d}' -Source $Object | Should Be $(Get-Date -UFormat '%Y%m%d')
        }

        It 'should return a string using a custom Unix format with a full day name, with token' {
            Replace-Token -String '%{timestamp:+%A, %B %d, %Y}' -Source $Object | Should Be $(Get-Date $TimeStamp -UFormat '%A, %B %d, %Y')
        }

        It 'should return a string using a custom Unix format with a full day name, without token' {
            Replace-Token -String '%{+%A, %B %d, %Y}' -Source $Object | Should Be $(Get-Date -UFormat '%A, %B %d, %Y')
        }

        It 'should return a string using a custom Unix format with token, with padding' {
            Replace-Token -String '%{timestamp:+%Y%m:12}' -Source $Object | Should Be $("      {0}" -f (Get-Date $TimeStamp -UFormat '%Y%m'))
        }

        It 'should return a string using a custom Unix format without token, with padding' {
            Replace-Token -String '%{+%Y%m:12}' -Source $Object | Should Be $("      {0}" -f (Get-Date -UFormat '%Y%m'))
        }

        It 'should return a string using a custom [DateTimeFormatInfo] string with token' {
            Replace-Token -String '%{timestamp:+yyyy/MM/dd HH:mm:ss.fff}' -Source $Object | Should Be $(Get-Date $TimeStamp -Format 'yyyy/MM/dd HH:mm:ss.fff')
        }

        It 'should return a string using a custom [DateTimeFormatInfo] string without token' {
            Replace-Token -String '%{+yyyy/MM/dd HH}' -Source $Object | Should Be $(Get-Date -Format 'yyyy/MM/dd HH')
        }

        It 'should return a string using a custom [DateTimeFormatInfo] string with token, with padding' {
            Replace-Token -String '%{timestamp:+HH:mm:ss.fff:15}' -Source $Object | Should Be $("   {0}" -f (Get-Date $TimeStamp -Format 'HH:mm:ss.fff'))
        }

        It 'should return a string using a custom [DateTimeFormatInfo] string without token, with padding' {
            Replace-Token -String '%{+yyyy/MM/dd HH:15}' -Source $Object | Should Be $("  {0}" -f (Get-Date -Format 'yyyy/MM/dd HH'))
        }
    }
    
    Describe 'Logging Levels' {
        It 'should return logging levels names' {
            Get-LevelsName | Should Be @('DEBUG', 'ERROR', 'INFO', 'NOTSET', 'WARNING')
        }

        It 'should return loggin level name' {
            Get-LevelName -Level 10 | Should Be 'DEBUG'
            {Get-LevelName -Level 'DEBUG'} | Should Throw
        }

        It 'should return logging levels number' {
            Get-LevelNumber -Level 0 | Should Be 0
            Get-LevelNumber -Level 'NOTSET' | Should Be 0
        }

        It 'should throw on invalid level' {
            {Get-LevelNumber -Level 11} | Should Throw
            {Get-LevelNumber -Level 'LEVEL_UNKNOWN'} | Should Throw
        }

        It 'should add a new logging level' {
            Add-LoggingLevel -Level 11 -LevelName 'Test'
            Get-LevelsName | Should Be @('DEBUG', 'ERROR', 'INFO', 'NOTSET', 'TEST', 'WARNING')
        }

        It 'should change the level name if same level number' {
            Add-LoggingLevel -Level 11 -LevelName 'Foo'
            Get-LevelsName | Should Be @('DEBUG', 'ERROR', 'FOO', 'INFO', 'NOTSET', 'WARNING')
        }

        It 'should change the level number if same level name' {
            Add-LoggingLevel -Level 21 -LevelName 'Foo'
            Get-LevelsName | Should Be @('DEBUG', 'ERROR', 'FOO', 'INFO', 'NOTSET', 'WARNING')
            Get-LevelNumber -Level 'FOO' | Should Be 21
        }

        It 'return the default logging level' {
            Get-LoggingDefaultLevel | Should Be 'NOTSET'
        }

        It 'sets the default logging level' {
            Set-LoggingDefaultLevel -Level INFO
            Get-LoggingDefaultLevel | Should Be 'INFO'
        }
    }

    Describe 'Logging Targets' {
        It 'loads the logging targets' {
            $Targets = $InitialSessionState.Variables.Item('LogTargets').Value
            $Targets.Count | Should Be 5
        }

        It 'returns the loaded logging targets' {
            $AvailableTargets = Get-LoggingTargetAvailable
            $AvailableTargets | Should Be System.Collections.Hashtable+SyncHashtable
            $AvailableTargets.Count | Should Be 5
        }
    }

    Describe 'Logging Format' {
        It 'should be the default format' {
            Get-LoggingDefaultFormat | Should Be $Defaults.Format
        }

        It 'should change the default logging format' {
            $NewFormat = '[%{level:-7}] %{message}'
            Get-LoggingDefaultFormat | Should Be $Defaults.Format
            Set-LoggingDefaultFormat -Format $NewFormat
            Get-LoggingDefaultFormat | Should Be $NewFormat
        }
    }
}
