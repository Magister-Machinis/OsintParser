# intakes IP address and attempts reverse dns resolution through host device's .NET framework
function dns($ip)
{
    $r = $null
    try
    {
    $dnsinput = resolve-dnsname -name $ip -nohostsfile -EA SilentlyContinue
    $r = [string]$dnsinput.Namehost
    write-host "$ip resolves to $r"
    }
    catch
    {
        write-host "Unable to resolve $ip"
        $r = "Cannot resolve"
    }
    $r += ','
    return $r
}