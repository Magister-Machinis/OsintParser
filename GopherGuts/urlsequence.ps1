        #fill in procedure for url addresses
        write-host "Gathering information on $ip"
        
        $ipcontainer = $null
        if($DNSRES -eq 1)
        {
            write-host "resolving DNS"
            $ipcontainer = dns2 $ip
            $results += $ipcontainer
            write-host "IP addresses will be added to list of items to check"
        }
        $ipresults = $results -split ","
        $ipresults = $ipresults[1] -split "|"
        $results += $ip + ", "
        if($GEOLOCATION -eq 1)
        {
            write-host "Retrieving Geolocation"
           . .\Gopherguts\urlgeo.ps1
        }
        if($VIRUSTOTAL -eq 1)
        {
            if($m -eq $minute)
                {
                    write-host "Submissions per minute reached, waiting 60 seconds."
                    sleepbar 60
                    write-host "Resuming shortly"
                    sleepbar 5
                    $m = 0
                }
            if($d -eq $daily)
                {
                    write-host "Submissions per day reached, waiting 24 hours."
                    sleepbareconds (New-TimeSpan -End "11:59pm").TotalSeconds
                    write-host "Resuming shortly"
                    sleepbar 120
                    $m = 0
                    $d = 0
                    $g = 0
                    $g6 =0
                }
            write-host "Querying VirusTotal"
            $results += vturl $ip
            $m += 1
            $d += 1
            if($results -like "*urlprocessing*")
            {
                write-host "VirusTotal currently processing $ip, moving this address to bottom of list and continuing"
                $vtflag = 1
                $urlsinwaiting +=($results -split ":::")[-1]
                if($ipitem -like "*cannot resolve*")
                {
                    write-host "Skipping unresolved results"
                }
                elseif($listtoggle -eq 0)
                {
                    $additionalurls += ($ip -replace ",","")
                    $listsize += 1
                }
                else
                {
                    $listofIPs += ($ip -replace ",","")
                    $listsize += 1
                }
            }
        }
        if($vtflag -eq $null)
            {
            foreach($ipitem in ($ipcontainer -split "\|"))
            {
                if($ipitem -like "*cannot resolve*")
                {
                    write-host "Skipping unresolved results"
                }
                elseif($listtoggle -eq 0)
                {
                    $additionalurls += ($ipitem -replace ",","")
                    $listsize += 1
                }
                else
                {
                    $listofIPs += ($ipitem -replace ",","")
                    $listsize += 1
                }
            }
            if($SPAMHAUS -eq 1)
            {
                write-host "Skipping Spamhaus module for URLs"
                $results += ",,,,"
            }
            if($RANSOMWARE -eq 1)
            {
                write-host "Comparing to list of known ransomware"
                $results += ran $ip $ransom
            }
            sleepbar 1
            $results
            write-host " "
            if($TOR -eq 1)
            {
                write-host "Skipping TOR module for URLs"
                $results += ","
            }
        }