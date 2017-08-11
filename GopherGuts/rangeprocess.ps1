
#finds start of ip range
function ipstart ($strNetwork)
{
$StrNetworkAddress = ($strNetwork.split("/"))[0]
$NetworkIP = ([System.Net.IPAddress]$StrNetworkAddress).GetAddressBytes()
[Array]::Reverse($NetworkIP)
$NetworkIP = ([System.Net.IPAddress]($NetworkIP -join ".")).Address
$StartIP = $NetworkIP +1
#Convert To Double
If (($StartIP.Gettype()).Name -ine "double")
{
$StartIP = [Convert]::ToDouble($StartIP)
}
$StartIP = [System.Net.IPAddress]$StartIP
Return $StartIP.IPAddressToString
}


#finds end of ip range
function ipend ($strNetwork)
{
$StrNetworkAddress = ($strNetwork.split("/"))[0]
[int]$NetworkLength = ($strNetwork.split("/"))[1]
$IPLength = 32-$NetworkLength
$NumberOfIPs = ([System.Math]::Pow(2, $IPLength)) -1
$NetworkIP = ([System.Net.IPAddress]$StrNetworkAddress).GetAddressBytes()
[Array]::Reverse($NetworkIP)
$NetworkIP = ([System.Net.IPAddress]($NetworkIP -join ".")).Address
$EndIP = $NetworkIP + $NumberOfIPs
If (($EndIP.Gettype()).Name -ine "double")
{
$EndIP = [Convert]::ToDouble($EndIP)
}
$EndIP = [System.Net.IPAddress]$EndIP
Return $EndIP.IPAddressToString
}

#takes starting and ending IP address and returns array of all IPs between
function iprange ($start, $end)
{
    $iprange= @()
    $ipfillin = [string]::Empty
    [string[]]$start = $start -split"\."
    [string[]]$end = $end -split"\."
    
    $dot = '.'
    #converting string values over to int is apparently rather wonky in powershell
    $intstart = @()
    $intend = @()
    write-host "Starting address octets are"
    foreach($item in $start)
    {
        write-host $item
        $intstart += [convert]::toint32($item, 10)
    }
    
    write-host "Ending address octets are"
    foreach($item in $end)
    {
        write-host $item
        $intend += [convert]::toint32($item, 10)
    }
    $ipstart = $intstart
    while($intstart[0] -le $intend[0])
    {
        while($intstart[1] -le $intend[1])
        {
            while($intstart[2] -le $intend[2])
            {
                while($intstart[3] -le $intend[3])
                {
                    $ipfillin = ($intstart[0] -as [string]) + $dot + ($intstart[1] -as [string]) + $dot + ($intstart[2] -as [string]) + $dot + ($intstart[3] -as [string])
                    $ipfillin
                    $iprange += $ipfillin
                    $intstart[3] += 1
                }
                $ipstart[2] += 1
                $intstart[3] = $ipstart[3]
            }
            $ipstart[1] += 1
            $intstart[2]= $ipstart[2]
        }
        $ipstart[0] += 1
        $intstart[1] = $ipstart[1]
    }
    write-host "Range of addresses is:"
    write-host $iprange
    return $iprange
}
