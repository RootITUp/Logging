param (
    [string[]] $Task = 'Default'
)

$VerbosePreference = 'Continue'

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Install-Module Psake, PSDeploy, BuildHelpers, platyPS, PSScriptAnalyzer -Force -Scope CurrentUser
Install-Module Pester -Force -SkipPublisherCheck -Scope CurrentUser

Import-Module Psake, BuildHelpers, platyPS, PSScriptAnalyzer

Set-BuildEnvironment -GitPath 'git.exe'
Get-Module

Invoke-psake -buildFile .\build.psake.ps1 -taskList $Task -nologo

exit ([int] (-not $psake.build_success))