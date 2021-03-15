<#
.SYNOPSIS
Replaces the tokens present in the pattern with the values given inside the source (log) object.

.PARAMETER Pattern
Parameter The pattern that defines tokens and possible operations onto them.

.PARAMETER Source
Parameter Log object providing values, if wildcard parameter is not given

.PARAMETER Wildcard
Parameter If this parameter is given, all tokens are replaced by the wildcard character.

.EXAMPLE
Format-Pattern -Pattern %{timestamp} -Wildcard
#>
function Format-Pattern {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [AllowEmptyString()]
        [Parameter(Mandatory)]
        [string]
        $Pattern,
        [object]
        $Source,
        [switch]
        $Wildcard
    )

    [string] $result = $Pattern
    [regex] $tokenMatcher = '%{(?<token>\w+?)?(?::?\+(?<datefmtU>(?:%[ABCDGHIMRSTUVWXYZabcdeghjklmnprstuwxy].*?)+))?(?::?\+(?<datefmt>(?:.*?)+))?(?::(?<padding>-?\d+))?}'
    $tokenMatches = @()
    $tokenMatches += $tokenMatcher.Matches($Pattern)
    [array]::Reverse($tokenMatches)

    foreach ($match in $tokenMatches) {
        $formattedEntry = [string]::Empty
        $tokenContent = [string]::Empty

        $token = $match.Groups["token"].value
        $datefmt = $match.Groups["datefmt"].value
        $datefmtU = $match.Groups["datefmtU"].value
        $padding = $match.Groups["padding"].value

        if ($Wildcard.IsPresent){
            $formattedEntry = "*"
        }
        else{
            [hashtable] $dateParam = @{ }
            if (-not [string]::IsNullOrWhiteSpace($token)) {
                $tokenContent = $Source.$token
                $dateParam["Date"] = $tokenContent
            }

            if (-not [string]::IsNullOrWhiteSpace($datefmtU)) {
                $formattedEntry = Get-Date @dateParam -UFormat $datefmtU
            }
            elseif (-not [string]::IsNullOrWhiteSpace($datefmt)) {
                $formattedEntry = Get-Date @dateParam -Format $datefmt
            }
            else {
                $formattedEntry = $tokenContent
            }

            if ($padding) {
                $formattedEntry = "{0,$padding}" -f $formattedEntry
            }
        }

        $result = $result.Substring(0, $match.Index) + $formattedEntry + $result.Substring($match.Index + $match.Length)
    }

    return $result
}