Remove-Module Logging -Force -ErrorAction SilentlyContinue

$ModuleManifestPath = '{0}\..\Logging\Logging.psd1' -f $PSScriptRoot
Import-Module $ModuleManifestPath -Force

$TargetFile = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.ps1'
$TargetImplementationPath = '{0}\..\Logging\targets\{1}' -f $PSScriptRoot, $TargetFile

Describe -Tags Targets, TargetWebexTeams 'WebexTeams target' {
    It 'should be available in the module' {
        $Targets = Get-LoggingAvailableTarget
        $Targets.WebexTeams | Should Not BeNullOrEmpty
    }

    It 'should have two required parameters' {
        $Targets = Get-LoggingAvailableTarget
        $Targets.WebexTeams.ParamsRequired | Should Be @('BotToken', 'RoomID')
    }

    It 'should call Invoke-RestMethod' {
        Mock Invoke-RestMethod -Verifiable

        $Module = . $TargetImplementationPath

        $Message = [hashtable] @{
            level   = 'ERROR'
            levelno = 40
            message = 'Hello, WebexTeams!'
        }

        $Configuration = @{
            BotToken = 'SOMEINVALIDTOKEN'
            RoomID = 'SOMEINVALIDROOMID'
            Icons = $Module.Configuration.Icons.Default
        }

        & $Module.Logger $Message $Configuration

        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly
    }
}