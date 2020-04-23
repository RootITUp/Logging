Remove-Module Logging -Force -ErrorAction SilentlyContinue

$ModuleManifestPath = '{0}\..\Logging\Logging.psd1' -f $PSScriptRoot
Import-Module $ModuleManifestPath -Force

$TargetFile = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.ps1'
$TargetImplementationPath = '{0}\..\Logging\targets\{1}' -f $PSScriptRoot, $TargetFile

Describe -Tags Targets, TargetWinEventLog 'WinEventLog target' {
    # Give time to the runspace to init the targets
    Start-Sleep -Milliseconds 100

    It 'should be available in the module' {
        $Targets = Get-LoggingAvailableTarget
        $Targets.WinEventLog | Should Not BeNullOrEmpty
    }

    It 'should have two required parameters' {
        $Targets = Get-LoggingAvailableTarget
        $Targets.WinEventLog.ParamsRequired | Should Be @('LogName', 'Source')
    }

    It 'should call Write-EventLog' -Skip {
        Mock Write-EventLog -Verifiable

        $Message = [hashtable] @{
            level   = 'ERROR'
            levelno = 40
            message = 'Hello, Windows Event Log!'
            body    = @{ EventId = 123 }
        }

        $LoggerFormat  = '[%{timestamp:+%Y-%m-%d %T%Z}] [%{level:-7}] %{message}'

        $Configuration = @{
            LogName = 'Application'
            Source  = 'PesterTestSource'
        }

        # Wasn't able to get a 'Write-EventLog' mock working inside of the .Logger scriptblocks which
        # are already loaded into the module. Instead, load the scriptblock for testing here
        $Module = . $TargetImplementationPath
        & $Module.Logger $Message $Configuration

        Assert-MockCalled -CommandName 'Write-EventLog' -Times 1 -Exactly -ParameterFilter {
            ($LogName   -eq 'Application') -and
            ($Source    -eq 'PesterTestSource') -and
            ($EntryType -eq 'Error') -and
            ($EventId   -eq 123) -and
            ($Message   -eq 'Hello, Windows Event Log!')
        }
    }
}