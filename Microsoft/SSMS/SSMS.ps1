$PackageName          = "Microsoft.SQLServerManagementStudio"
$PackageID            = "" # Does this matter?
$AppInstaller         = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq Microsoft.DesktopAppInstaller
$PackageSource        = 'winget'
$CurrentWingetVersion = "2023.118.406.0"

#Start Logging

# Shout out to https://www.nielskok.tech/intune/use-winget-with-intune/

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
        Break
    }
    }
    elseif ($AppInstaller.Version -eq $CurrentWingetVersion){ write-output "Winget is installed and current as of version $CurrentWingetVersion"}

#Trying to install Package with Winget
IF ($PackageName){
    try {
        Write-Host "Installing $($PackageName) via $PackageSource"

        $ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
        if ($ResolveWingetPath){
               $WingetPath = $ResolveWingetPath[-1].Path
        }
    
        $config
        Set-Location $wingetpath

        .\winget.exe install $PackageName -s $PackageSource --silent --accept-source-agreements --accept-package-agreements # 
        #Start-Process "winget.exe" -ArgumentList "install $PackageName -s $PackageSource --silent --accept-source-agreements --accept-package-agreements" -Verbose
    }
    Catch {
        Throw "Failed to install package $($_)"
    }
}
Else {
    Write-Host "_____________________________________________________________________"
    Write-Host "ERROR while installing $PackageName"
    Write-Host "$_"
}
Stop-Transcript