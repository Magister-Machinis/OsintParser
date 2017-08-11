function geo6($ip)
{
    $resource = "ipinfo.io/$ip"
    write-host "url to use is $resource"
    $geoip = Invoke-RestMethod -Method Get -URI $resource
    $org = $geoip.org -split " ", 2
    $loc = $geoip.loc -split ","
    
    $hash = @{
        IP = $geoip.IP
        CountryCode = $geoip.country
        CountryName = ""
        RegionCode = ""
        RegionName = $geoip.region
        City = $geoip.City
        ZipCode = ""
        TimeZone = ""
        Latitude = $loc[0]
        Longitude = $loc[1]
        MetroCode = " "
        }
    $geor += $hash.CountryCode + ","
    $geor += $hash.CountryName + ","
    $geor += $hash.RegionCode + ","
    $geor += $hash.RegionName + ","
    $geor += $hash.City + ","
    $geor += $hash.ZipCode + ","
    $geor += $hash.TimeZone + ","
    $geor += $hash.Latitude + ","
    $geor += $hash.Longitude + ","
    $geor += $hash.MetroCode + ", "
    write-host $geor
    return $geor
}