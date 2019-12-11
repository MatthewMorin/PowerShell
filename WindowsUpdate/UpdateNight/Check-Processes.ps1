Write-Warning "According to Lev, Dont worry about any Thrive05, Thrive06, HP04, and HP05, and any S12-HP's"


$SearchBase = "OU=Servers,OU=Raleigh,OU=Circle Graphics,DC=circlegraphicsonline,DC=com"

$PrepServers = Get-ADComputer -SearchBase $SearchBase -Filter { Name -like "NC-S12-Prep*" } 
$TrimServers = Get-ADComputer -SearchBase $SearchBase -Filter { Name -like "NC-WXV-Trim*" }
$ThriveServers = Get-ADComputer -SearchBase $SearchBase -Filter { (Name -like "NC-S12-Thrive*") -or (Name -Like "NC*-HP*") -or ( Name -like "*FAKE*") }



Invoke-Command -ComputerName $($PrepServers.DNSHostName) -ScriptBlock { Try { Get-Process -Name "Photoshop" -ErrorAction Stop } catch { Write-Warning "Photoshop not detected on $env:computername" }}



Invoke-Command -ComputerName $($TrimServers.DNSHostName) -ScriptBlock { Try { Get-Process -Name "Illustrator" -ErrorAction Stop } catch { Write-Warning "Illustrator not detected on $env:computername" }}



Invoke-Command -ComputerName $($ThriveServers.DNSHostName) -ScriptBlock { Try { Get-Process -Name "Postershop" -ErrorAction Stop } catch { Write-Warning "Thrive not detected on $env:computername" }}
