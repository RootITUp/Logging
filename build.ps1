param (
    [string[]] $Task = 'default'
)

if ($env:APPVEYOR) {
    if ($env:APPVEYOR_REPO_TAG) {
        Invoke-psake .\build.psake.ps1 -taskList Release -nologo
    } else {
        Invoke-psake .\build.psake.ps1 -nologo
    }
    exit ([int] (-not $psake.build_success))
} else {
    Invoke-psake .\build.psake.ps1 -taskList $Task -nologo
}