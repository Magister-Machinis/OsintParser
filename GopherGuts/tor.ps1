#quick and dirty tor module, checks if IP is in list of known tor addresses

function Torcheck($ip, $tor)
{
    if ($tor -contains $ip)
    {
        return "Address is TOR node,"
    }
    else
    {
        return "Address not TOR node,"
    }
}