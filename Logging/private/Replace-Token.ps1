function Replace-Token {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
    [CmdletBinding()]
    param(
        [string] $String,
        [object] $Source
    )

    [regex] $tokenMatcher = '%{(?<token>\w+?)?(?::?\+(?<datefmtU>(?:%[ABCDGHIMRSTUVWXYZabcdeghjklmnprstuwxy].*?)+))?(?::?\+(?<datefmt>(?:.*?)+))?(?::(?<padding>-?\d+))?}'
    $tokenMatches = @()
    $tokenMatches += $tokenMatcher.Matches($String)
    [array]::Reverse($tokenMatches)

    foreach ( $match in $tokenMatches ) {
        [String] $formattedDate = [String]::Empty

        $token      = $match.Groups["token"].value
        $datefmt    = $match.Groups["datefmt"].value
        $datefmtU   = $match.Groups["datefmtU"].value
        $padding    = $match.Groups["padding"].value

        if ($token -and -not $datefmt -and -not $datefmtU) {
            $formattedDate = $Source.$token
        } elseif ($token -and $datefmtU) {
            $formattedDate = Get-Date $Source.$token -UFormat $datefmtU
        } elseif ($token -and $datefmt) {
            $formattedDate = Get-Date $Source.$token -Format $datefmt
        } elseif ($datefmtU -and -not $token) {
            $formattedDate = Get-Date -UFormat $datefmtU
        } elseif ($datefmt -and -not $token) {
            $formattedDate = Get-Date -Format $datefmt
        }

        if ($padding) {
            $tpl = "{0,$padding}"
        } else {
            $tpl = "{0}"
        }

        $String = $String.Substring(0, $match.Index) + ($tpl -f $formatedDate) + $String.Substring($match.Index + $match.Length)
    }

    return $String
}