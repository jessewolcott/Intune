$PackageName          = ""                    # Example: "Adobe.Acrobat.Reader.64-bit"
$PackageSource        = 'winget'              #Example: 'winget'
$CurrentWingetVersion = "2023.118.406.0"
$AppInstaller         = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq Microsoft.DesktopAppInstaller

# Update script settings
$FileSuffix       = "_Update.ps1" # What should we name the app update scripts?
$UpdateScriptPath = "C:\Program Files\WingetUpdates\" # Where should we store your update.ps1 files? Example: "C:\Program Files\WingetUpdates\"
# Update Scheduled Task settings
$ScheduledTaskScript = "Winget.ps1"           # Script that runs the scripts
$ScheduledTaskName   = "Winget Updater"       # What should we name your Scheduled Task?
$ScheduledTaskPath   = "\Winget-Updates\"     # Where should we put your Scheduled Task? Example "\Winget-Updates\" or "\"
$DaysOfWeek          = "Monday"               # What day should we run the update script?
$Time                = "9:30"                 # What time should your update script run? Use 24 Hour time. Example: 2PM is 14:00
$WeeksInterval       = "1"                    # How many weeks should pass until this runs again?  Example: "1" runs the script every week.

# Start Logging
$Path_local = "$Env:Programfiles\_MEM" # "$ENV:LOCALAPPDATA\_MEM" for user context installations
Start-Transcript -Path "$Path_local\$PackageName-install.txt" -Force 

if($null -eq $AppInstaller.Version){ 
     Write-Output "Winget is not installed, trying to install latest version from Github"

    Try {
            
        Write-Output "Creating Winget Packages Folder"

        if (!(Test-Path -Path "C:\ProgramData\WinGetPackages")) {
            New-Item -Path "C:\ProgramData\WinGetPackages" -Force -ItemType Directory
        }

        Set-Location "C:\ProgramData\WinGetPackages"

        #Downloading Packagefiles
        #Microsoft.UI.Xaml.2.7.0
        Write-Output "Attempting to download Microsoft.UI.Xaml.2.7.0"
        Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.0" -OutFile "C:\ProgramData\WinGetPackages\microsoft.ui.xaml.2.7.0.zip"
        Write-Output "Attempting to expand Microsoft.UI.Xaml.2.7.0" 
        Expand-Archive "C:\ProgramData\WinGetPackages\microsoft.ui.xaml.2.7.0.zip" -Force

        #Microsoft.VCLibs.140.00.UWPDesktop
        Write-Output "Attempting to download Microsoft.VCLibs.140.00.UWPDesktop"
        Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "C:\ProgramData\WinGetPackages\Microsoft.VCLibs.x64.14.00.Desktop.appx"
        
        #Winget
        Write-Output "Attempting to download Winget from GitHub"
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "C:\ProgramData\WinGetPackages\Winget.msixbundle"
        
        #Installing dependencies + Winget
        Write-Output "Installing dependencies and Winget"
        Add-ProvisionedAppxPackage -online -PackagePath:".\Winget.msixbundle" -DependencyPackagePath ".\Microsoft.VCLibs.x64.14.00.Desktop.appx,.\microsoft.ui.xaml.2.7.0\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.Appx" -SkipLicense

        Write-Output "Starting sleep for Winget to initiate"
        Start-Sleep 2
    }
    Catch {
        Throw "Failed to install Winget"
        Break
    }
}
    elseif ($AppInstaller.Version -lt $CurrentWingetVersion){ 
        Write-Output "Winget is not up to date. Attempting to update"
        try {
                #Winget
        Write-Output "Attempting to download Winget from GitHub"
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "C:\ProgramData\WinGetPackages\Winget.msixbundle"
        
        #Installing dependencies + Winget
        Write-Output "Installing dependencies and Winget"
        Add-ProvisionedAppxPackage -online -PackagePath:".\Winget.msixbundle" -DependencyPackagePath ".\Microsoft.VCLibs.x64.14.00.Desktop.appx,.\microsoft.ui.xaml.2.7.0\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.Appx" -SkipLicense

        Write-Output "Starting sleep for Winget to initiate"
        Start-Sleep 2
            }
    Catch {
        Throw "Failed to install Winget"
        Stop-Transcript
        Break
    }
    }
    elseif ($AppInstaller.Version -eq $CurrentWingetVersion){ write-output "Winget is installed and current as of version $CurrentWingetVersion"}

#Trying to install Package with Winget
IF ($PackageName){
    try {
        Write-Output "Installing $($PackageName) via $PackageSource"

        $ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
        if ($ResolveWingetPath){
               $WingetPath = $ResolveWingetPath[-1].Path
        }
    
        $config
        Set-Location $wingetpath

        .\winget.exe install $PackageName -s $PackageSource --silent --accept-source-agreements --accept-package-agreements --force 
        
        Write-Output "Checking for update log directory"
        If ((Test-Path ("$Path_local\Updates\")) -eq $false){
            Write-Output "Update log directory not found. Creating."
            New-Item -Path ("$Path_local\Updates\") -ItemType Directory
            }
            else {Write-Output "Update log directory found!"}
        
        Write-Output "Checking for update directory"
        If ((Test-Path $UpdateScriptPath) -eq $false){
            Write-Output "Update directory not found. Creating."
            New-Item -Path $UpdateScriptPath -ItemType Directory
            }
            else {Write-Output "Update directory found!"}
        
        $UpdaterScriptLocation = (Join-Path $UpdateScriptPath ($ScheduledTaskScript))

        Write-Output "Writing Update Script for Scheduled Task"

        Remove-Item $UpdaterScriptLocation
$TaskScript1 = @"
Get-ChildItem '$UpdateScriptPath' -Filter "*$FileSuffix" |
"@
$TaskScript2 = @'
    % { & $_.FullName}
'@
            
        New-Item $UpdaterScriptLocation
            $TaskScript1 | Add-Content $UpdaterScriptLocation
            $TaskScript2 | Add-Content $UpdaterScriptLocation
            $UpdateScriptPathQuoted = ('"'+$UpdateScriptPath+$ScheduledTaskScript+'"')
            $Argument = ("-executionpolicy bypass -file $UpdateScriptPathQuoted")
                $TaskParams = @{
                    Action      = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "$Argument"
                    Trigger     = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DaysOfWeek -At $Time -WeeksInterval $WeeksInterval
                    Settings    = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable
                    Principal   = New-ScheduledTaskPrincipal -UserId SYSTEM -LogonType ServiceAccount -RunLevel Highest
                    Description = "Run $($ScheduledTaskName) at $Time on $DaysofWeek every $WeeksInterval week."
                }

            Write-Output "Creating scheduled task called $ScheduledTaskName in $ScheduledTaskPath."
            Register-ScheduledTask -TaskName $ScheduledTaskName -InputObject (New-ScheduledTask @TaskParams) -TaskPath $ScheduledTaskPath -Force       
            $task = Get-ScheduledTask -TaskName $ScheduledTaskName -ErrorAction SilentlyContinue
            if ($null -ne $task){
                Write-Output "Created scheduled task: '$($task.ToString())'."
                }
            else{Write-Output "Created scheduled task: FAILED."}        
        
$UpdateFile = @"
Start-Transcript -Path "$Env:Programfiles\_MEM\Updates\$PackageName-Update.txt" -Force -Append
Set-location (Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe")
.\winget.exe upgrade $PackageName --source $PackageSource --silent --accept-source-agreements --accept-package-agreements --force
Stop-Transcript
"@
        
        Write-Output "Writing updater script for $PackageName"
        $UpdateFile | Out-file (Join-Path $UpdateScriptPath ($PackageName+$FileSuffix)) -Force
    }
    Catch {
        Throw "Failed to install package $($_)"
        stop-transcript

    }
}
Else {
    Write-Host "_____________________________________________________________________"
    Write-Host "ERROR while installing $PackageName"
    Write-Host "$_"
    Stop-Transcript
}
Stop-Transcript
