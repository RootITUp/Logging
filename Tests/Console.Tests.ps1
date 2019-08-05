Remove-Module Logging -Force -ErrorAction SilentlyContinue

$ModuleManifestPath = '{0}\..\Logging\Logging.psd1' -f $PSScriptRoot
Import-Module $ModuleManifestPath -Force

Describe -Tags Targets, TargetConsole 'Console target' {
    # Give time to the runspace to init the targets
    Start-Sleep -Milliseconds 100

    It 'should be available in the module' {
        $Targets = Get-LoggingAvailableTarget
        $Targets.Console | Should Not BeNullOrEmpty
    }

    It "shouldn't have required parameters" {
        $Targets = Get-LoggingAvailableTarget
        $Targets.Console.ParamsRequired | Should BeNullOrEmpty
    }
}