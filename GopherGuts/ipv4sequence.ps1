        #fill in procedure for IPv4 addresses
        if($ip -like "*/*")
        {
            write-host "Expanding CIDR notation to list of target addresses"
            if($listtoggle -eq 0)
            {
                $additionalurls += iprange (ipstart $ip) (ipend $ip)
            }
            else
            {
                    $listofIPs += iprange (ipstart $ip) (ipend $ip)
            }
        }
        elseif($ip -like "*-*")
        {
            
            $startip = ($ip -split "-")[0]
            $endip = ($ip -split "-")[1]
            write-host "Expanding IP range to list of target addresses from $startip to $endip"
            if($listtoggle -eq 0)
            {
                $additionalurls += iprange $startip $endip
            }
            else
            {
                $listofIPs += iprange $startip $endip
            }
        }
        else
        {
            if($ip -like "127.*")
            {
                write-host "Address is loopback, skipping information gathering"
                $results += "Loopback,"
            }
            elseif($ip -match $internalIPV4)
            {
                write-host "Address is not publicly routable, skipping information gathering"
                $results += "Internal,"
            }
            else
            {
                write-host "Gathering information on $ip"
                $results += $ip + ", "
                if($DNSRES -eq 1)
                {
                    write-host "resolving DNS"
                    $results += dns $ip
                }
                if($GEOLOCATION -eq 1)
                {
                    if($g -eq $geodaily)
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
                    $results += geo $ip
                    $g += 1
                    
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
                    $results += virust $ip
                    $m += 1
                    $d += 1
                    
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
                }
            }