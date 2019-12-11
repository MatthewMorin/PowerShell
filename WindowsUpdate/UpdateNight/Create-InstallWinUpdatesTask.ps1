$Action = New-ScheduledTaskAction -Execute Powershell.exe -Argument \\nc-fileshare\Departments\IT\PowerShell\WindowsUpdate\Install-WinUpdates.ps1
$Trigger = New-ScheduledTaskTrigger -Once -At 9/9/1999
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskPath "\Powershell Stuff" -TaskName "Install-WinUpdates" -Description "Check for and install latest Windows Updates" -User "Circle\COD-Powershell" -Password "Mo791Us3qc6Z" 
