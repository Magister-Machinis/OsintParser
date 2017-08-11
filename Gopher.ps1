param (
[string]$source=".\ips.txt",
[string]$outputtarget=".\",
[string]$waitflag="YES"
)
$source = resolve-path $source
$outputtarget = resolve-path $outputtarget

function sleepbar($seconds)
{
    
    for($count = 0; $count -lt $seconds; $count++)
    {
        $percent = ($count / $seconds) * 100
        write-progress -id 1 -activity "Sleeping: " -status "=][=  $count" -percentcomplete $percent -secondsremaining ($seconds - $count)
        start-sleep -s 1
    }
    Write-Progress -id 1 -Completed -activity "Sleeping: "
}
$start = get-date #little timing mechanism
[datetime]$lasttime = (get-childitem ".\GopherGuts\time.txt").lastaccesstime
#timing throttle for time-limitted Get requests
write-host "Current starting time is $start"
write-host "Last retrieval of OSINT information occured at $lasttime"
write-host "Time difference is "
($start-$lasttime).totalminutes
remove-item ".\GopherGuts\time.txt"
$start | out-file -filepath ".\GopherGuts\time.txt"
if(($start-$lasttime).totalminutes -lt 31)
{
    write-host "Time since last OSINT Get too soon, waiting 30 minutes"
    sleepbar 1740
    write-host "Beginning shortly"
    sleepbar 120
}

# CONFIGURATION SECTION

#expected location of address list
$addressList = $source
#expected location of process monitor list
$proc = ".\procmon.csv"
#place full path to where you want the output of all results to be recorded at script completion, including the name of the file itself. THIS WILL OVERWRITE THE CONTENTS OF THE FILE
$output = join-path -path $outputtarget -childpath ".\inteloutput.csv"
#place full path to where you want the output for high suspicion results.
$houtput = join-path -path $outputtarget -childpath ".\suspectinteloutput.csv"
#storage container for ransomware listing NOT IN USE
#$ransomlistlocation = ".\ransomlist.txt"
#Set values to 1 to enable that intel module, 0 to disable
$DNSRES = 1
$GEOLOCATION = 1
$VIRUSTOTAL = 1
$SPAMHAUS = 1
$RANSOMWARE = 1
$TOR = 1

#flag for excel csv formatting
$EXCEL = 1

#crazy regex voodoo goes here for pattern matching, DO NOT TOUCH
$ipv6 = "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))"
$ipv4 = "\b((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\b"
#"(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)[^a-zA-Z]"
$internalIPV4 = "(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)"
$letters = "[a-zA-Z]"
$url = "\." #if there is a dot at this point and its not been caught by the IP filters, it will be treated as a url
#some values below for sorting results into high suspect list

#set to 1 if results from outside of client's region are suspect (high false positive rate), set to 0 if origin of IP address is not a concern 
$extraregional = 0
#input between quotations ("") the name of the region client is in, only works if extraregional is set to 1
$region =@("United States")

#containers for lists of addresses
$listofIPs = @()
$additionalurls = @()
$urlsinwaiting = @()

#VirusTotal configuration
$vtip = "http://www.virustotal.com/vtapi/v2/ip-address/report"
$vturl = "http://www.virustotal.com/vtapi/v2/url/report"
#place your virustotal apikey below, talk to John if you need help getting one
$apikey = "a397bb0bbc39b53f67e57514432281c57beb53c96182292108510aa08b5fe934"


# END OF CONFIGURATION SECTION
# more error handling stuff
if($apikey.length -eq 0 -and $VIRUSTOTAL -eq 1)
{
    write-host "No Virustotal API key provided, exiting"
    sleepbar 3
    exit
}
if((-not(test-path $addressList -pathtype leaf)) -and (-not(test-path $proc -pathtype leaf)))
{
    write-host "neither $addressList or $proc detected, terminating script"
    sleepbar 3
    exit
}
#DNS resolution modules
. .\GopherGuts\dns.ps1
. .\GopherGuts\dnsurl.ps1

#Geolocation module
. .\GopherGuts\geolocation.ps1

#VirusTotal module
. .\GopherGuts\virustotal.ps1

#VirusTotal url module
. .\GopherGuts\virustotalurl.ps1

#VirusTotal waiting module
. .\GopherGuts\vtwaiter.ps1

#spamhaus module
. .\GopherGuts\spamhaus.ps1

#ransomware list check module
. .\GopherGuts\ransomware.ps1

#tor check module
. .\GopherGuts\tor.ps1

#loads and processes procmon output and list of addresses
. .\GopherGuts\ingester.ps1

#geolocation module for ipv6 addresses
. .\GopherGuts\geolocation6.ps1

#functions for handling cider notation and ranges for ipv4
. .\GopherGuts\rangeprocess.ps1


write-host "results will be written to $output"
sleepbar 1
write-host "Suspect results will be written to $houtput"
sleepbar 1
$ResultList = @()
#limits and their respective counters
$minute = 4
$daily = 5760
$geodaily = 10000
$geo6daily = 1000

$m = 0
$d = 0
$g = 0
$g6 = 0
$header = ","
$ResultList = "Address:Type, IP, "
if($DNSRES -eq 1)
{
    $header += "Resolution,,"
    $ResultList += "URL,"
    write-host "DNS resolution module enabled"
    sleepbar 1
}
if($GEOLOCATION -eq 1)
{
    $header += "Geolocation,,,,,,,,,,"
    $ResultList += "CountryCode, " + "CountryName, " + "RegionCode, " + "RegionName, " + "City, " + "ZipCode, " + "TimeZone, " + "Latitude, " + "Longitude, " + "MetroCode ,"
    write-host "Geolocation module enabled"
    sleepbar 1
}
if($VIRUSTOTAL -eq 1)
{
    $header += "VirusTotal,,,,,,,"
    $ResultList += "Owner,ASN,detected urls,resolutions,detected samples,response message,virustotal link,"
    write-host "VirusTotal module enabled"
    sleepbar 1
}
if($SPAMHAUS -eq 1)
{
    $header += "Spamhaus,,,"
    $ResultList += "List Codes,Listings,Link (results may differ from api query),"
    write-host "Spamhaus module enabled"
    sleepbar 1
}
if($RANSOMWARE -eq 1)
{
    $header += "Ransomware check,,,,,,,,,,,"
    $ResultList += "Match,Firstseen (UTC),Threat,Malware,Host,Associated URL,Status,Registrar,IP address(es),ASN(s),Country,"
    write-host "Ransomware module enabled, retrieving list:"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $ransomraw = invoke-restmethod "https://ransomwaretracker.abuse.ch/feeds/csv/"
    $ransom = $ransomraw -split '\n' | select -skip 9
    write-host "List retrieved and processed"
    sleepbar 1
}
if ($TOR -eq 1)
{
    $header += "TOR,"
    $ResultList += "TOR Status,"
    write-host "Tor check module enabled"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $TORLIST = invoke-restmethod "https://www.dan.me.uk/torlist/"
    $TORLIST = $TORLIST.Content -split '\n'
    write-host "First TOR list ingested"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls
    $ANOTHERLIST = Invoke-RestMethod "https://torstatus.blutmagie.de/ip_list_all.php/Tor_ip_list_ALL.csv"
    $TORLIST = ($TORLIST + $ANOTHERLIST)| sort -descending -unique
    write-host "Second TOR list ingested"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $ANOTHERLIST = Invoke-RestMethod "https://check.torproject.org/exit-addresses"
    $ANOTHERLIST = $ANOTHERLIST -split ' '
    foreach ($item in $ANOTHERLIST)
    {
        if(($ip -match $ipv4) -and -not ($ip -match $letters))
        {
            $TORLIST += $item
        }
    }
    $TORLIST = $TORLIST | sort -unique
    write-host "Third TOR list ingested"
    sleepbar 1
}
write-host "Preparing to begin:"
sleepbar 5
$header = "," + $header
$ResultList = "Rating," + $ResultList
if($EXCEL -eq 1)
{
    $header = $header -replace ",", "`t"
    $ResultList = $ResultList -replace ",", "`t"
}
$header | out-file -filepath $output
$Resultlist | out-file -filepath $output -append
$Resultlist = "Flags," + $Resultlist
$header = "," + $header
if($EXCEL -eq 1)
{
    $header = $header -replace ",", "`t"
    $ResultList = $ResultList -replace ",", "`t"
}
$header | out-file -filepath $houtput
$Resultlist | out-file -filepath $houtput -append
write-host " "
$listtoggle = 1 #switch for which list to write to
while(($listofIPs.count -gt 0) -or ($additionalurls.count -gt 0))
{
    if($listtoggle -eq 0)
    {
        $listtoggle = 1
    }
    else
    {
        $listtoggle = 0
    }
    $listofIPs = $listofIPs | sort -descending -unique
    write-host "Current list of addresses to check is:"
    $listofIPs
    $IPCOUNT = 0
    foreach($ip in $listofIPs)
    {
        write-progress -activity "Processing item $IPCOUNT of " -status $listofIPS.count -percentcomplete ($IPCOUNT/$listofIPS.count*100)
        $IPCOUNT += 1
        $vtflag = $null
       
        if(($ip -match $ipv4) -and -not ($ip -match $letters))
        {
            $results= "IPv4: $ip,"
            write-host "Treating $ip as IPv4 address"
            . .\GopherGuts\ipv4sequence.ps1
        }
        elseif($ip -match $ipv6)
        {
            $results= "IPv6: $ip,"
            write-host "Treating $ip as IPv6 address"
            . .\GopherGuts\ipv6sequence.ps1
        }
        elseif($ip -match $url -and ($ip -match $letters))
        {
            $results = "URL: $ip,"
            write-host "Treating $ip as URL"
            . .\GopherGuts\urlsequence.ps1
        }
        else
        {
            write-host "$ip unknown format, could it be a private addressing scheme?"
            $results = "Unknown: $ip, address unknown format"
        }
        if($vtflag -eq $null)
        {
            #checks results for partial string matches that would indicate that it should be on the high suspect list
            . .\GopherGuts\suspectcheck.ps1
            
            write-host "Information gathering for $ip complete: "
            
            
            
            sleepbar 1
            write-host " "
        }
    }
    write-progress -Completed -activity "Processing"
    $listofIPs = @()
    
    vtwait $urlsinwaiting
    $urlsinwaiting = @()

    if($listtoggle -eq 0)
    {
        $listtoggle = 1
    }
    else
    {
        $listtoggle = 0
    }
    $additionalurls = $additionalurls | sort -descending -unique
    write-host "Current list of adresses to check is:"
    $additionalurls
    $IPCOUNT = 0
    foreach($ip in $additionalurls)
    {
        write-progress -activity "Processing item $IPCOUNT of " -status $additionalurls.count -percentcomplete ($IPCOUNT/$additionalurls.count*100)
        $IPCOUNT +=1
        $vtflag = $null
     
        if(($ip -match $ipv4) -and -not ($ip -match $letters))
        {
            $results= "IPv4: $ip,"
            write-host "Treating $ip as IPv4 address"
            . .\GopherGuts\ipv4sequence.ps1
        }
        elseif($ip -match $ipv6)
        {
            $results= "IPv6: $ip,"
            write-host "Treating $ip as IPv6 address"
            . .\GopherGuts\ipv6sequence.ps1
        }
        elseif($ip -match $url -and ($ip -match $letters))
        {
            $results = "URL: $ip,"
            write-host "Treating $ip as URL"
            . .\GopherGuts\urlsequence.ps1
        }
        else
        {
            write-host "$ip unknown format, could it be a private addressing scheme?"
            $results = "Unknown: $ip, address unknown format"
        }
        if($vtflag -eq $null)
        {
            #checks results for partial string matches that would indicate that it should be on the high suspect list
            . .\GopherGuts\suspectcheck.ps1
            
            write-host "Information gathering for $ip complete: "
            sleepbar 1
            write-host " "
        }
    }
    write-progress -Completed -activity "Processing"
    $additionalurls = @()
    vtwait $urlsinwaiting
    $urlsinwaiting = @()
}


$end = get-date
$times= $end - $start
write-host "Intelligence gathering of $listsize addresses complete."
write-host "Time taken:"
$times
if($waitflag -eq "YES")
{
    Read-Host -Prompt "Press Enter to exit"
}