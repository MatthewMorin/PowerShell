<#
.NAME
    Install-WinUpdates

.SYNOPSIS
    A Script to Completely automate installing Windows Updates From WSUS server via powershell or scheduled Task

.SYNTAX
    
    
.DESCRIPTION
     A Script to Completely automate installing Windows Updates From WSUS server via powershell or scheduled Task. Cannot not be run remotley unless
     using a scheduled task.

.PARAMETERS
    None

.NOTES
    None

.RELATED LINKS

#>

$LogPath = "\\NC-S12-STORE01\Departments\IT\Powershell\Logs\Windows-Updates.log"


$Session = New-Object -ComObject "Microsoft.Update.Session"

$Searcher = $Session.CreateUpdateSearcher()

# Servers: 0=default 1=WSUS 2=MicrosoftUpdate
$Searcher.ServerSelection = 1
$SearchResults = $Searcher.Search("IsInstalled=0 and Type='Software'") 

if ($SearchResults.Updates.Count -eq 0)
{
    Write-Output "$(Get-Date) $env:computername : No Updates were found." | Out-file -Append -FilePath $LogPath
    exit
}


$UpdatesToDownload = New-Object -ComObject "Microsoft.Update.UpdateColl"

foreach($Update in $SearchResults.Updates)
{
    if ($_.InstallationBehavior.CanRequestUserInput -ne $TRUE)
    {
        $UpdatesToDownload.Add($Update) | Out-Null
    }
}

$Downloader = $Session.CreateUpdateDownloader()
$Downloader.Updates = $UpdatesToDownload
$Downloader.Download()



$UpdatesToInstall = New-Object -ComObject "Microsoft.Update.UpdateColl"

$UpdatesToDownload | ForEach-Object { if($_.IsDownloaded){ $UpdatesToInstall.add($_) }}
$Installer = $Session.CreateUpdateInstaller()
$Installer.Updates = $UpdatesToDownload
$Results = $Installer.Install()

$Kbs = ""
foreach($Update in $Installer.Updates)
{
   $Kbs += $($Update.KBArticleIDs + " ")
}


If($Results.HResult -eq 0)
{
    Write-Output "$(Get-Date) $env:computername : Installed $($Installer.Updates.Count) Updates : KBs = $KBs"  | Out-file -Append -FilePath $LogPath
}
Else
{
    Write-Output "$(Get-Date) $env:computername : Failed to install $($Installer.Updates.Count) Updates : KBs = $KBs" | Out-file -Append -FilePath $LogPath
}

