    #experimental list ingester, more trouble than its worth currently
    $ResultList += ",Match,Firstseen (UTC),Threat,Malware,Host,URL,Status,Registrar,IP address(es),ASN(s),Country"
    if(test-path $ransomlistlocation -pathtype leaf)
    {
        write-host "Pre-existing list found"
        start-sleep -s 1
        if(test-path $ransomlistlocation -pathtype leaf -olderthan (Get-Date).adddays(-1))
        {
            write-host "List potentially out of date, rebuilding"
            remove-item $ransomlistlocation
            invoke-restmethod "https://ransomwaretracker.abuse.ch/feeds/csv/" | out-file -filepath $ransomlistlocation
        }
    }
    else
    {
        write-host "List not found, building new one"
        invoke-restmethod "https://ransomwaretracker.abuse.ch/feeds/csv/" | out-file -filepath $ransomlistlocation
    }
    $ransomraw = get-content $ransomlistlocation
    $ransom = $ransomraw -split '\n' | select -skip 9
    write-host "List retrieved and processed"
    start-sleep -s 1