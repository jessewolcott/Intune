# Intune Win32 Apps

Winget changed everything, and now Intune apps are pretty reasonable to package and install (after some fiddling).

My Install.ps1 does a bunch of things. Set up your variables at the top, most importantly "PackageName". If you ```winget search``` whatever you're looking for, thats that package name. The script flows as so:
```mermaid
flowchart TB
    Invoke("Script Starts")-->StartTranscript("Transcript Starts")
    StartTranscript-->CheckWingetPresence("Check if Winget Exists")
    CheckWingetPresence-->CheckWingetPresenceYes("Yes")
    CheckWingetPresence-->CheckWingetPresenceNo("No")
    CheckWingetPresenceNo-->DownloadFrameworks("Download and install MS Frameworks")
    DownloadFrameworks-->DownloadWingetGH("Download and install Winget from Github")
    CheckWingetPresenceYes-->WingetVersionCheck("Check if Winget is up to date")
    WingetVersionCheck-->WingetVersionCheckYes("Yes")
    WingetVersionCheck-->WingetVersionCheckNo("No")
    WingetVersionCheckYes-->AppInstall("Application installs from Winget")
    WingetVersionCheckNo-->DownloadWingetGH
    DownloadWingetGH-->AppInstall
    AppInstall-->LoggingFolder("Check for Logging Folder, create if needed")
    LoggingFolder-->UpdateScriptFolder("Check for Update Script Folder, create if needed")
    UpdateScriptFolder-->GenerateUpdater("Generate Script that runs updater scripts")
    GenerateUpdater-->GenerateSchTask("Generate Scheduled Task to launch Updater")
    GenerateSchTask-->GenerateIndividualAppUpdater("Generate Script with Package name")
    GenerateIndividualAppUpdater-->StopTranscript("Transcript Stops")
```
