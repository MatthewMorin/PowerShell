<#
.NAME
    Install-MicrosoftUpdates

.SYNOPSIS
    A Script to Completely automate installing Windows Updates From Microsofts servers via powershell or scheduled Task.

.SYNTAX
    
    
.DESCRIPTION
     A Script to Completely automate installing Windows Updates From Microsofts server via powershell or scheduled Task. Cannot not be run remoteley unless
     using a scheduled task. Disregards drivers and new build updates

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
$Searcher.ServerSelection = 2

$SearchResults = $Searcher.Search("IsInstalled=0")      #and Type='Software' and IsHidden=0") type != Updgrades

if ($SearchResults.Updates.Count -eq 0)
{
    Write-Output "$(Get-Date) $env:computername : No Updates were found." | Out-file -Append -FilePath $LogPath
    exit
}



$UpdatesToDownload = New-Object -ComObject "Microsoft.Update.UpdateColl"

ForEach($Update in $SearchResults.Updates)
{
   $SkipUpdate = $False
   
   ForEach($Category in $Update.Categories)
   {
        If($Category.Name -like "*Upgrade*")  #$Category.Name -like "*Driver*"
        {
            $SkipUpdate = $True
        }

   }
   
   if($SkipUpdate -ne $True)
   {
        $UpdatesToDownload.Add($Update) | Out-Null

   }

}


$Downloader = $Session.CreateUpdateDownloader()

if($UpdatesToDownload -ne $null)
{
    $Downloader.Updates = $UpdatesToDownload
    $Downloader.Download()
}
Else
{
    Write-Output "$(Get-Date) $env:computername : Updates Found but skipped." | Out-file -Append -FilePath $LogPath
    exit
}


$UpdatesToInstall = New-Object -ComObject "Microsoft.Update.UpdateColl"

ForEach($Update in $Downloader.Updates)
{
    if($Update.IsDownloaded)
    {
        $UpdatesToInstall.Add($Update)
    }
}

$Installer = $Session.CreateUpdateInstaller()
$Installer.Updates = $UpdatesToInstall
$Results = $Installer.Install()

$Kbs = ""
foreach($Update in $Installer.Updates)
{
   $Kbs += $($Update.KBArticleIDs) + " "
}


If($Results.HResult -eq 0)
{
    Write-Output "$(Get-Date) $env:computername : Installed $($Installer.Updates.Count) Updates : KBs = $KBs"  | Out-file -Append -FilePath $LogPath
}
Else
{
    Write-Output "$(Get-Date) $env:computername : Failed to install $($Installer.Updates.Count) Updates : KBs = $KBs" | Out-file -Append -FilePath $LogPath
}

