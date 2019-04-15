[CmdletBinding()]
param (
    [Parameter()]
    [System.String[]] $TaskList = 'Default',
    [Parameter()]
    [System.Collections.Hashtable] $Parameters,
    [Parameter()]
    [System.Collections.Hashtable] $Properties
)

Write-Verbose -Message ("Beginning '{0}' process..." -f ($TaskList -join ','))

# Bootstrap the environment
$null = Get-PackageProvider -Name NuGet -ForceBootstrap

# Install PSake module if it is not already installed
if (-not (Get-Module -Name PSDepend -ListAvailable))
{
    Install-Module -Name PSDepend -Scope CurrentUser -Force -Confirm:$false
}

# Install build dependencies required for Init task
Import-Module -Name PSDepend
Invoke-PSDepend `
    -Path $PSScriptRoot `
    -Force `
    -Import `
    -Install `
    -Tags 'Bootstrap'

# Execute the PSake tasts from the psakefile.ps1
Invoke-Psake `
    -buildFile (Join-Path -Path $PSScriptRoot -ChildPath 'psakefile.ps1') `
    -nologo `
    @PSBoundParameters

exit ( [int]( -not $psake.build_success ) )
