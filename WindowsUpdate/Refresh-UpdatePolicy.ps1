Write-Output "Connected to $env:computername"
gpupdate /force 
wuauclt.exe /resetauthorization /detectnow