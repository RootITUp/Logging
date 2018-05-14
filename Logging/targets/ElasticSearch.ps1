@{
    Name = 'ElasticSearch'
    Configuration = @{
        Index           = @{Required = $true;   Type = [string]}
        Type            = @{Required = $true;   Type = [string]}
        ServerName      = @{Required = $true;   Type = [string]}
        ServerPort      = @{Required = $true;   Type = [int]}
        Flatten         = @{Required = $false;  Type = [bool]}
        Level           = @{Required = $false;  Type = [string]}
    }
    Logger = {
        param(
            $Log,
            $Format,
            $Configuration
        )

        Function ConvertTo-FlatterHashTable {
            [CmdletBinding()]
            param(
                [hashtable] $Object
            )

            $ht = [hashtable] @{}

            foreach ($key in $Object.Keys) {
                if ($Object[$key] -is [hashtable]) {
                    $ht += ConvertTo-FlatterHashTable -Object $Object[$key]
                } else {
                    $ht[$key] = $Object[$key]
                }
            }

            return $ht
        }

        $Index = Replace-Token -String $Configuration.Index -Source $Log
        $Uri = 'http://{0}:{1}/{2}/{3}' -f  $Configuration.ServerName, $Configuration.ServerPort, $Index, $Configuration.Type

        if ($Configuration.Flatten) {
            $Message = ConvertTo-FlatterHashTable $Log | ConvertTo-Json -Compress
        } else {
            $Message = $Log | ConvertTo-Json -Compress
        }

        Invoke-RestMethod -Method Post -Uri $Uri -Body $Message -Headers @{"Content-Type"= "application/json"} | Out-Null
    }
}