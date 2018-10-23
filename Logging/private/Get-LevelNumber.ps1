function Get-LevelNumber {
    [CmdletBinding()]
    param(
        $Level
    )

    if ($Level -is [int] -and $Level -in $LevelNames.Keys) {return $Level}
    elseif ([string] $Level -eq $Level -and $Level -in $LevelNames.Keys) {return $LevelNames[$Level]}
    else {throw ('Level not a valid integer or a valid string: {0}' -f $Level)}
}
