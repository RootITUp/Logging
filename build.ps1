param (
    [string[]] $Task = 'default'
)

if ($env:APPVEYOR) {
    Invoke-psake .\build.psake.ps1 -taskList Build, Test, Release -nologo
    exit ([int] (-not $psake.build_success))
} else {
    Invoke-psake .\build.psake.ps1 -taskList $Task -nologo
}