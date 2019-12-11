$Computers = Get-ADComputer -SearchBase "OU=WorkStations,OU=Raleigh,OU=Circle Graphics,DC=CircleGraphicsOnline,DC=com" -Filter { Name -like "*" -and Enabled -eq $True -and Name -notlike "*ITWB*" -and Name -notlike "*mmorin*" -and Name -notlike "*joe*" }

foreach($PC in $Computers)
{
    if(Test-Connection -ComputerName $PC.DnsHostName -Count 1 -Quiet)
    {
        Write-warning "Rebooting $($PC.DnsHostname)"
        Restart-Computer -ComputerName $PC.Dnshostname -Force
        Start-sleep 2
    }
}