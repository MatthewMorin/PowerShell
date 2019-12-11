
#Create Windupdates Scheduled task on a remote machine defined in $PcName
$Servers = Get-Content -Path \\nc-fileshare\Departments\IT\PowerShell\WindowsUpdate\UpdateNight\TaskNotFound.txt


Foreach($Server in $Servers)
{
   Try
   {
        Invoke-Command -ComputerName "$Server" -FilePath \\nc-fileshare\Departments\IT\PowerShell\WindowsUpdate\UpdateNight\Create-InstallWinUpdatesTask.ps1
    }
    Catch
    {
        Invoke-Command -ComputerName "$Server" -ScriptBlock { SCHTASKS /S $PC /CREATE /TN "\PowerShell Stuff\Install-WinUpdates" /XML 'E:\Install-WinUpdates.xml' /RU "COD-Powershell" /RP "Mo791Us3qc6Z" }
    }
}

