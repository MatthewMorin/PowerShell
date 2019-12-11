<#
.NAME
    Reset-WUclient

.SYNOPSIS
    Resets a Windows Update clients services and removes related files

.SYNTAX


.DESCRIPTION
    Resets a Windows Update clients services and removes software distribution folder. This script can remove other update related files as well. 
    Lines 55-60: I have not needed to remove theses files to get stations in my environment to work again. Uncomment at your own risk.
    I needed a simple script to run remotley with Invoke-Command.
    The appidsvc is not running in my environment. no need for me stop it

.PARAMETERS
    None

.INPUTS
    

.OUTPUTS


.NOTES


.RELATED LINKS
    https://www.thewindowsclub.com/manually-reset-windows-update-components

#>


[cmdletBinding()]
param
(


)


#Retrieve windows update services...
$UpdateServices = Get-Service -Name wuauserv, bits, CryptSvc, trustedinstaller

#Stop and disable the services...
ForEach($Service in $UpdateServices)
{
    If($Service.Status -eq "Running")
    {
        $Service | Stop-Service -Force | Set-Service -StartupType Disabled
        
    }
}

#Remove files....
#Remove-Item -Path "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat"
#Remove-Item -Path "$env:ALLUSERSPROFILE\Microsoft\Network\Downloader\qmgr*.dat"
#Rename-Item -Path "$env:SYSTEMROOT\winsxs\pending.xml" -NewName "pending.xml.bak"
#Rename-Item -Path "$env:SYSTEMROOT\winsxs\cleanup.xml" -NewName "cleanup.xml.bak"
#Remove-Item -Path "$env:SYSTEMROOT\system32\Catroot2\*" -Recurse
#Remove-Item -Path "$env:SYSTEMROOT\system32\Catroot\*" -Recurse
Remove-Item -Path "$env:SYSTEMROOT\SoftwareDistribution\*" -Recurse -Force


Write-Output "Re-Enabling Update Services..."

#Reenable services and set startup to automatic
foreach($Service in $UpdateServices)
{
    $Service | Set-Service -StartupType Automatic -Status Running
        
}

#Retrieve GPOs   
gpupdate /force

#Check in with WSUS
wuauclt.exe /resetauthorization /reportnow

Write-Output "Process Complete. Please check for updates and verify this clients status in WSUS."

Start-Process ms-settings:






