#handles potentially multiple ip results from dns resolution
    $geoprocessing = @{}
    $annoyance = 0
    #changes character array to array of strings 
    $ipresult = (($ipresults -join "") -split'\|')
    write-host "Addresses to check geolocation are"
    $ipresult
    foreach($item in $ipresult)
    {
        $georesults = ""
        write-host "Processing data for $item"
        #counter to handle merging of multiple IP results into standard format
        $geocount = 0
        if($item -like "*cannot resolve*")
        {
        }
        elseif($item -like "*.*")
        {
            if($g -eq $geodaily)
            {
                write-host "Submissions per day reached, waiting 24 hours"
                Start-Sleep -Seconds (New-TimeSpan -End "11:59pm").TotalSeconds
                write-host "Resuming shortly"
                Start-Sleep -s 120
                $m = 0
                $d = 0
                $g = 0
                $g6 =0
            }
            $g += 1
            write-host "Gathering Geolocation information"
            $georesults = geo $item
            write-host "IPv4 geodata"
            $georesults
        }
        elseif($item -like "*:*")
        {
            if($g6 -eq $geo6daily)
            {
                write-host "Submissions per day reached, waiting 24 hours"
                Start-Sleep -Seconds (New-TimeSpan -End "11:59pm").TotalSeconds
                write-host "Resuming shortly"
                Start-Sleep -s 120
                $m = 0
                $d = 0
                $g = 0
                $g6 =0
            }
            $g6 += 1
            write-host "Gathering Geolocation information"
            $georesults = geo6 $item
            write-host "IPv6 geodata"
            $georesults
        }
        else
        {
            write-host "error reading Adress"
            $georesults = "error ,reading ,address , "
        }
        $georesults = $georesults -split ","
        write-host "results are:"
        $georesults
        if($annoyance -eq 0)
        {
            write-host "formatting multiple IP results"
            $annoyance = 1
        }
        
        $geoprocessing = @{
        IP = $georesults[0] + "|"
        CountryCode = $georesults[1] + "|"
        CountryName = $georesults[2] + "|"
        RegionCode = $georesults[3] + "|"
        RegionName = $georesults[4] + "|"
        City = $georesults[5] + "|"
        ZipCode = $georesults[6] + "|"
        TimeZone = $georesults[7] + "|"
        Latitude = $georesults[8] + "|"
        Longitude = $georesults[9] + "|"
        MetroCode = $georesults[10] + "|"
        }
        
    }
    #conditional formating for output, hence the wierd string manipulations
    if(($geoprocessing.IP).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.IP).substring(0,($geoprocessing.IP).length -2) + "," 
    }
    if(($geoprocessing.CountryCode).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.CountryCode).substring(0,($geoprocessing.CountryCode).length-1) + "," 
    }
    if(($geoprocessing.CountryName).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.CountryName).substring(0,($geoprocessing.CountryName).length-1) + "," 
    }
    if(($geoprocessing.RegionCode).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.RegionCode).substring(0,($geoprocessing.RegionCode).length-1) + "," 
    }
    if(($geoprocessing.RegionName).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.RegionName).substring(0,($geoprocessing.RegionName).length-1) + ","
    }
    if(($geoprocessing.City).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.City).substring(0,($geoprocessing.City).length-1) + ","
    }
    if(($geoprocessing.ZipCode).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.ZipCode).substring(0,($geoprocessing.ZipCode).length-1) + ","
    }
    if(($geoprocessing.TimeZone).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.TimeZone).substring(0,($geoprocessing.TimeZone).length-1) + ","
    }
    if(($geoprocessing.Latitude).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.Latitude).substring(0,($geoprocessing.Latitude).length-1) + ","
    }
    if(($geoprocessing.Longitude).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.Longitude).substring(0,($geoprocessing.Longitude).length-1) + ","
    }
    if(($geoprocessing.MetroCode).length-1 -le 0)
    {
        $results += ","
    }
    else
    {
        $results += ($geoprocessing.MetroCode).substring(0,($geoprocessing.MetroCode).length-1) + ","
    }