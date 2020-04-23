param (
    [string[]] $Task = 'Default'
)

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Install-Module -Name BuildHelpers -RequiredVersion '2.0.11' -Scope CurrentUser
Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
Install-Module Psake, PSDeploy, platyPS, PSScriptAnalyzer -Force -Scope CurrentUser

Import-Module Psake, BuildHelpers, platyPS, PSScriptAnalyzer

Set-BuildEnvironment -GitPath 'git.exe'
Get-Module

Invoke-psake -buildFile .\build.psake.ps1 -taskList $Task -nologo

exit ([int] (-not $psake.build_success))