if (Get-Module Logging) {
    Remove-Module Logging -Force -ErrorAction SilentlyContinue
}

$ManifestPath = '{0}\..\Logging\Logging.psd1' -f $PSScriptRoot

Import-Module $ManifestPath -Force

Describe -Tags Targets, TargetFile 'File target' {

    It 'should resolve relative paths' {

        Add-LoggingTarget -Name File -Configuration @{
            Path  = '..\Test.log'
        }

        $a = Get-LoggingTarget
        $a.Values.Path.Contains('..') | Should Be $false
    }

}