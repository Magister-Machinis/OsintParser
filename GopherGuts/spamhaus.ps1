#queries zen.spamhaus.org to see if results IP is being blackholed by them i.e. known source of spam
function sh ($ip)
{
    $sbl = 0
    $pbl = 0
    $xbl = 0
    $f = 1
    $r = $null
   
    $selected= $ip + ".zen.spamhaus.org"
    $r = resolve-dnsname -name $selected -nohostsfile -ea silentlycontinue
    
    if($r.ipaddress)
    {
        write-host "result(s) found"
    }
    else
    {
        write-host "no results"
        $f = 0
    }
    if($f -eq 1)
    {   
        $res += $r.ipaddress 
        $res -replace '[,]',' |'
        $res += ", "
        switch -wildcard ($r.ipaddress)
        {
            "*.2" {$sbl = 1}
            "*.3" {$sbl = 1}
            "*.9" {$sbl = 1}
            "*.10" {$pbl = 1}
            "*.11" {$pbl = 1}
            "*.4" {$xbl = 1}
        }
        if($sbl -eq 1)
        {
            $res +="Listed in SBL |"
        }
        if($pbl -eq 1)
        {
            $res +="Listed in PBL |"
        }
        if($xbl -eq 1)
        {
            $res +="Listed in XBL |"
        }
       
    }
    
    $res += ", https://www.spamhaus.org/query/ip/$ip, "
    write-host $res
    if($f -eq 1)
    {
        return $res
    }
    else
    {
        return "not found,,,"
    }
}