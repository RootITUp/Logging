@{
    Name = 'ElasticSearch'
    Configuration = @{
        Index           = @{Required = $true;   Type = [string]}
        Type            = @{Required = $true;   Type = [string]}
        ServerName      = @{Required = $true;   Type = [string]}
        ServerPort      = @{Required = $true;   Type = [int]}
        Flatten         = @{Required = $false;  Type = [bool]}
        Level           = @{Required = $false;  Type = [string]}
        Authorization   = @{Required = $false;  Type = [string]}
        Https           = @{Required = $false;  Type = [bool]}
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
        
        if ($Configuration.Https) {
            $httpType = "https"
        } else {
            $httpType = "http"           
        }

        $Index = Replace-Token -String $Configuration.Index -Source $Log
        $Uri = '{0}://{1}:{2}/{3}/{4}' -f  $httpType, $Configuration.ServerName, $Configuration.ServerPort, $Index, $Configuration.Type

        if ($Configuration.Flatten) {
            $Message = ConvertTo-FlatterHashTable $Log | ConvertTo-Json -Compress
        } else {
            $Message = $Log | ConvertTo-Json -Compress
        }

        if ($Configuration.Authorization) {
            $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("$($Configuration.Authorization)")))      
            Invoke-RestMethod -Method Post -Uri $Uri -Body $Message -Headers @{"Content-Type"= "application/json";Authorization="Basic $base64Auth"}
        } else {
            Invoke-RestMethod -Method Post -Uri $Uri -Body $Message -Headers @{"Content-Type"= "application/json"} 
        }
    }
}