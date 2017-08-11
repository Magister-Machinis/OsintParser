#handles inloading and formatting of manual lists and procmon output
if(test-path $addressList -pathtype leaf)
{
    write-host "Retrieving address list from $addressList"
    start-sleep -s 1
    $listofIPs = Get-Content $addressList
    start-sleep -s 1
    write-host "Address list loaded"
    start-sleep -s 1
}
if(test-path $proc -pathtype leaf)
{
    write-host "Retrieving Process Monitor results from $proc"
    start-sleep -s 1
    $csvraw = import-csv $proc
    $rawlist = $null
    foreach($csvitem in $csvraw.path[1..(($csvraw.path).length)])
    {
        $csvitem = $csvitem -split":"
        $listofIPs += $csvitem[0..($csvitem.length-2)] -join":"
    }
    
    write-host "Process Monitor results loaded"
    start-sleep -s 1
}
write-host "Optimizing list"
$listofIPs = $listofIPs | sort -descending -unique
$listsize = $listofIPs.count
start-sleep -s 1
write-host "Address list loaded and optimized"
start-sleep -s 1
