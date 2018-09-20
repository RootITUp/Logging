@{
  Name = 'Seq'
  Description = 'Sends log data to the designated Seq server web service'
  Configuration = @{
    Url         = @{Required = $true; Type = [string]}
    ApiKey      = @{Required = $false; Type = [string]}
    Properties  = @{Required = $true; Type = [hashtable]}
    Level       = @{Required = $false; Type = [string]}
  }
  Logger = {
    param(
      $Log,
      $Format,
      [hashtable]$Configuration
    )

    function Open-Seq
    {
      [CmdletBinding()]
      param(
        [string] $url,
        [string] $apiKey,
        [hashtable]$properties = @{}
      )
      return @{ Url = $url; ApiKey = $apiKey; Properties = $properties.Clone() }
    }

    $seq = Open-Seq -url $Configuration.Url -apiKey $Configuration.ApiKey -properties $Configuration.Properties

    if (-not $Log.Level) {
      $Level = 'Information'
    } else {
      $Level = $Log.Level
    }

    if (@('Verbose', 'Debug', 'Information', 'Warning', 'Error', 'Fatal') -notcontains $Level) {
      $Level = 'Information'
    }

    $allProperties = $seq["Properties"].Clone()
    $allProperties += $Log
    $messageTemplate = $Log.Message

    $body = "{""Events"": [ {
      ""Timestamp"": ""$([System.DateTimeOffset]::Now.ToString('o'))"",
      ""Level"": ""$Level"",
      ""MessageTemplate"": $($messageTemplate | ConvertTo-Json),
      ""Properties"": $($allProperties | ConvertTo-Json) }]}"

    if ($seq["ApiKey"] -ne [string]::Empty) {
      $target = "$($seq["Url"])/api/events/raw?apiKey=$($seq["ApiKey"])"
    } else {
      $target = "$($seq["Url"])/api/events/raw?"
    }

    Invoke-RestMethod -Uri $target -Body $body -ContentType "application/json" -Method POST
  }
}