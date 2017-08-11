function vturl($ip)
{
    $result = "|"
    $param = @{'resource' = $ip; 'scan' =1; 'apikey' = $apikey}
    $vt = Invoke-RestMethod -Uri $vturl -Body $param -Method Post
    if($vt.response_code -eq 1)
    {
        if($vt.verbose_msg -like "*finished*")
        {
            $vt.scans = $vt.scans -replace '[@{}]', ' '
            $result += ",,,"
            $result += ($vt.positives -as [string]) + "|" + ($vt.total -as [string])
            if($vt.positives -eq 0)
            {
                $result += ","
            }
            else
            {
                $result += " positives detected,"
            }
            $result += $vt.scans + ","
            $result += $vt.verbose_message
            $result += $vt.permalink
        }
        else
        {
            $result = "urlprocessing :::" + $vt.scan_id
        }
    }
    else
    {
        $result = ",,,,,"
    }
    return $result
}