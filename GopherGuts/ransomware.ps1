#compares IP address against processed list of known ransomware gathered from ransomwaretracker.ch
function ran($ip, $ransom)
{
    $check = 0
    foreach($som in $ransom)
    {
        if($som -like "*$ip*")
        {
            $check = 1
            $res = "ransomware match," + $som + ","
            write-host "ransomware match found: $som"
        }
        
    }
    if($check -eq 0)
    {
        $res = "no match found,,,,,,,,,,,"
        write-host "no ransomware match found"
    }
    return $res
}