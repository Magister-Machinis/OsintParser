#waits on submitted urls to complete virustotal check, includes logic to throttle check rate to minimize calls
function vtwait($urlsinwaiting)
{
    $throttle = 2
    $waitingcount = 0
    while($waitingcount -lt $urlsinwaiting.count) 
    {
        $waitingcount = 0
        foreach($urlcheck in $urlsinwaiting)
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
            $m += 1
            $d += 1
            write-host "Throttling check requests, waiting $throttle seconds before next request"
            sleepbar $throttle
            $urlparam = @{'resource' = $urlcheck; 'apikey' = $apikey}
            $isready = Invoke-RestMethod -uri http://www.virustotal.com/vtapi/v2/url/report -body $urlparam -method post
            if($isready.verbose_msg -like "*Scan finished*")
            {
                $waitingcount += 1
                $throttle = 2
                write-host "$isready.url scan complete, waiting on other items in list and resetting wait time"
            }
            elseif($isready.response_code -ne 1)
            {
                write-host "error querying $isready.url status, skipping"
                $waitingcount += 1
            }
            else
            {
                $throttle = $throttle * $throttle
                write-host "$isready.url not complete, increasing wait time between checks"
            }
            
        
        }
    }
}