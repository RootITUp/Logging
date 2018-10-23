Function Get-LevelsName {
    [CmdletBinding()]
    param()

    return $LevelNames.Keys | Where-Object {$_ -isnot [int]} | Sort-Object
}
