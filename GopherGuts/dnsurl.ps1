#takes url and resolves IP address
function dns2($ip)
{
    $dnsresults = @()
    $r= $null
    try
    {
        $dnsresults =  resolve-dnsname -name $ip -nohostsfile -EA SilentlyContinue
        
        if($dnsresults.IPAddress)
        {
            foreach($item in $dnsresults.IPAddress)
            {
                $r += $item + "|"
            }
        }
        else
        {
            $r = "Cannot Resolve|"
        }
        write-host "$ip resolves to $r"
    }
    catch
    {
        write-host "Unable to resolve $ip"
        $r += "Cannot resolve  |"
    }
    $r = $r.substring(0,$r.length-1) + ","
    return $r
}