if (Get-Module Logging) {
    Remove-Module Logging -Force -ErrorAction SilentlyContinue
}

$ModuleManifestPath = '{0}\..\Logging\Logging.psd1' -f $PSScriptRoot
Import-Module $ModuleManifestPath -Force

$TargetFile = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', '.ps1'
$TargetImplementationPath = '{0}\..\Logging\targets\{1}' -f $PSScriptRoot, $TargetFile

Describe -Tags Targets, TargetTeams 'Teams target' {
    It 'should be available in the module' {
        $Targets = Get-LoggingAvailableTarget
        $Targets.Teams | Should Not BeNullOrEmpty
    }

    It 'should have two required parameters' {
        $Targets = Get-LoggingAvailableTarget
        $Targets.Teams.ParamsRequired | Should Be @('WebHook')
    }

    It 'should call Invoke-RestMethod' {
        Mock Invoke-RestMethod -Verifiable

        $Module = . $TargetImplementationPath

        $Message = [hashtable] @{
            level   = 'ERROR'
            levelno = 40
            message = 'Hello, Teams!'
        }

        $Configuration = @{
            WebHook = 'https://office.microsoft.com'
            Details = $true
            Colors = $Module.Configuration.Colors.Default
        }

        & $Module.Logger $Message $Configuration

        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly
    }
}