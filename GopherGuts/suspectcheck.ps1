
    $suspect = $null #container for suspect check results, will be prepended to results if any are found
    $ratingnumber = 0
    $temp = 0   
   foreach($item in $region)
    {
        write-host $item
        if(-not ($results -like "*$item*"))
            {
                if(-not($results -like "*LOCAL*" -or $results -like "*Internal*"))
                {
                    write-host "Item is not $item"
                    $temp += 1
                }
            }
    }
    if($temp -ge $region.count)
    {
        $temp = 0
        write-host "Added result to suspect list: origin of address is potentially unusual for client"
        $suspect += "| Geolocation"
        $ratingnumber += 10
    }
    if($results -like "*positives*" -or $results -like "*many*" -or $results -like "*much*")
    {
        $suspect += "| VirusTotal"
        write-host "Added result to suspect list: VirusTotal reports potential malware communicating with this IP"
        $ratingnumber += 10
    }
    if($results -like "*Listed*")
    {
        $suspect += "| Spamhaus"
        write-host "Added result to suspect list: IP is on Spamhaus list of known spam sources"
        $ratingnumber += 5
    }
    if($results -like "*ransomware match*")
    {
        $suspect += "| Ransomware"
        write-host "Added result to suspect list: IP is on list of known ransomware"
        $ratingnumber += 20
    }
    if($results -like "*is Tor*")
    {
        $suspect += "| TOR NODE"
        $ratingnumber += 15
    }
    $results = [string]$ratingnumber + "," + $results
    write-host "Result not added to suspect list"
    if($EXCEL -eq 1)
    {
        $results = $results -replace ",", "`t"
    }
    $results | out-file -filepath $output -append
    if($ratingnumber -ge 10)
    {
        $results = $suspect + " |," + $results
        if($EXCEL -eq 1)
        {
            $results = $results -replace ",", "`t"
        }
        $results | out-file -filepath $houtput -append
    }
    $suspect = $null 
