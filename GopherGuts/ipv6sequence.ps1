        #fill in procedure for IPv6 addresses
        
        write-host "Gathering information on $ip"
        $results += $ip + ", "
        if($DNSRES -eq 1)
        {
            write-host "resolving DNS"
            $results += dns $ip
        }
        if($GEOLOCATION -eq 1)
        {
            if($g6 -eq $geo6daily)
            {
                write-host "Submissions per day reached, waiting 24 hours"
                sleepbareconds (New-TimeSpan -End "11:59pm").TotalSeconds
                write-host "Resuming shortly"
                sleepbar 120
                $m = 0
                $d = 0
                $g = 0
                $g6 =0
            }
            write-host "Gathering Geolocation information"
            $results += geo6 $ip
            $g6 += 1
        }
        if($VIRUSTOTAL -eq 1)
        {
            write-host "Skipping Virustotal check, Virustotal unable to process IPV6 addresses"
            $results += ",,,,,"
        }
        if($SPAMHAUS -eq 1)
        {
            write-host "Querying Spamhaus"
            $results += sh $ip
        }
        if($RANSOMWARE -eq 1)
        {
            write-host "Comparing to list of known ransomware"
            $results += ran $ip $ransom
        }
        if($TOR -eq 1)
        {
            write-host "Comparing to list of known TOR nodes"
            $results += Torcheck $ip $TORLIST
        }
        sleepbar 1
        $results
