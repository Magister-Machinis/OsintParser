#takes an IP address and returns geolocation information via query to freegeoip 
function geo($ip)
{
    $resource = "http://freegeoip.net/xml/$ip"

    $geoip = Invoke-RestMethod -Method Get -URI $resource

    $hash = @{
        IP = $geoip.Response.IP
        CountryCode = $geoip.Response.CountryCode
        CountryName = $geoip.Response.CountryName
        RegionCode = $geoip.Response.RegionCode
        RegionName = $geoip.Response.RegionName
        City = $geoip.Response.City
        ZipCode = $geoip.Response.ZipCode
        TimeZone = $geoip.Response.TimeZone
        Latitude = $geoip.Response.Latitude
        Longitude = $geoip.Response.Longitude
        MetroCode = $geoip.Response.MetroCode
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
