#queries virustotal information concerning ip, has exception handles for large results
function virust($ip)
{
    $result = $null
    $param = @{'ip' = $ip; 'apikey' = $apikey}
    $vt = Invoke-RestMethod -Uri $vtip -Body $param -Method Get
    if($vt.response_code -eq 1)
    {
        $own = $vt.as_owner -replace '[,]',' '
        $result = $own + ", "
        $result += $vt.asn + ", "
        $sizecheck = $vt.detected_urls -split ';'
        if($sizecheck.count -lt 12)
        {
            foreach($det in $vt.detected_urls)
            {
                $idet = $det -replace '[@{}]',''
                $result += $idet
            }
        }
        else
        {
            $result += "too many urls associated with this address-please refer to virustotal link"
        }
        $result += ", "
        $sizecheck = $vt.resolutions -split ';'
        if($sizecheck.count -lt 12)
        {
            foreach($res in $vt.resolutions)
            {
                $ires = $res -replace '[{}]',''
                $ires = $ires -replace '[@]',''
                $result += $ires
            }
        }
        else
        {
            $result += "too many urls associated with this address-please refer to virustotal link"
        }
        $result += ", "    
        $sizecheck = $vt.detected_communicating_samples -split ';'
        if($sizecheck.count -lt 12)
        {
            foreach($mal in $vt.detected_communicating_samples)
            {
                $imal = $mal -replace '[{}]',''
                $imal = $imal -replace '[@]',''
                $result += $imal
            }
        }
        else
        {
           $result += "too many instances of malware communicating with this address-please refer to virustotal link"
        }
        $result += ", "

    }   
    else
    {
        $result += ",,,,,"
    }
    $result += $vt.verbose_msg + ", https://www.virustotal.com/en/ip-address/$ip/information/,"
    
    
    write-host $result
    return $result
}